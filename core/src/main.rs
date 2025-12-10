use bluer::{Adapter, Session};
use dbus::blocking::Connection;
// FIX: Added 'Any' back to the imports so .state() and .interface() work
use networkmanager::devices::{Any, Device, Wireless};
use networkmanager::NetworkManager;
use serde::Serialize;
use std::collections::HashMap;
use std::time::Duration;

#[derive(Serialize, Clone)]
struct WifiNetwork {
    ssid: String,
    signal: u8,
    security: String,
    active: bool,
}

#[derive(Serialize, Clone)]
struct BluetoothDevice {
    name: String,
    mac: String,
    connected: bool,
    paired: bool,
    rssi: i16,
}

#[derive(Serialize, Clone, Default)]
struct SystemState {
    wifi_enabled: bool,
    wifi_connected: bool,
    wifi_ssid: String,
    wifi_strength: u8,
    wifi_networks: Vec<WifiNetwork>,
    wired_connected: bool,
    wired_device: String,
    bt_powered: bool,
    bt_scanning: bool,
    bt_devices: Vec<BluetoothDevice>,
}

fn get_security_string(flags: u32, wpa_flags: u32, rsn_flags: u32) -> String {
    if flags == 0 && wpa_flags == 0 && rsn_flags == 0 {
        "Open".to_string()
    } else if rsn_flags != 0 {
        "WPA2/WPA3".to_string()
    } else if wpa_flags != 0 {
        "WPA".to_string()
    } else {
        "WEP".to_string()
    }
}

fn update_network_state(dbus_conn: &Connection, state: &mut SystemState) {
    let nm = NetworkManager::new(dbus_conn);

    state.wifi_networks.clear();
    state.wifi_connected = false;
    state.wifi_ssid = String::new();
    state.wifi_strength = 0;

    state.wifi_enabled = nm.wireless_enabled().unwrap_or(false);

    if let Ok(devices) = nm.get_devices() {
        for dev in devices {
            match dev {
                Device::WiFi(wifi) => {
                    if let Ok(ap) = wifi.active_access_point() {
                        if let Ok(ssid) = ap.ssid() {
                            state.wifi_connected = true;
                            state.wifi_ssid = ssid;
                            state.wifi_strength = ap.strength().unwrap_or(0);
                        }
                    }

                    if let Ok(aps) = wifi.get_access_points() {
                        let mut seen: HashMap<String, bool> = HashMap::new();
                        for ap in aps {
                            if let Ok(ssid) = ap.ssid() {
                                if ssid.is_empty() || seen.contains_key(&ssid) {
                                    continue;
                                }
                                seen.insert(ssid.clone(), true);

                                let active = state.wifi_ssid == ssid;
                                state.wifi_networks.push(WifiNetwork {
                                    ssid,
                                    signal: ap.strength().unwrap_or(0),
                                    security: get_security_string(
                                        ap.flags().unwrap_or(0),
                                        ap.wpa_flags().unwrap_or(0),
                                        ap.rsn_flags().unwrap_or(0),
                                    ),
                                    active,
                                });
                            }
                        }
                    }
                    state
                        .wifi_networks
                        .sort_by(|a, b| b.active.cmp(&a.active).then(b.signal.cmp(&a.signal)));
                }
                Device::Ethernet(eth) => {
                    // .state() is available because we imported 'Any'
                    if let Ok(dev_state) = eth.state() {
                        if dev_state == 100 {
                            state.wired_connected = true;
                            // .interface() is available because we imported 'Any'
                            state.wired_device = eth.interface().unwrap_or_default();
                        } else {
                            state.wired_connected = false;
                        }
                    }
                }
                _ => {}
            }
        }
    }
}

async fn update_bluetooth_state(adapter: &Adapter, state: &mut SystemState) {
    state.bt_powered = adapter.is_powered().await.unwrap_or(false);
    state.bt_scanning = adapter.is_discovering().await.unwrap_or(false);
    state.bt_devices.clear();

    if state.bt_powered {
        if let Ok(addrs) = adapter.device_addresses().await {
            for addr in addrs {
                if let Ok(device) = adapter.device(addr) {
                    let name = device
                        .name()
                        .await
                        .ok()
                        .flatten()
                        .unwrap_or_else(|| addr.to_string());
                    let paired = device.is_paired().await.unwrap_or(false);
                    let connected = device.is_connected().await.unwrap_or(false);
                    let rssi = device.rssi().await.ok().flatten().unwrap_or(-100);

                    state.bt_devices.push(BluetoothDevice {
                        name,
                        mac: addr.to_string(),
                        connected,
                        paired,
                        rssi,
                    });
                }
            }
        }
    }

    state.bt_devices.sort_by(|a, b| {
        b.connected
            .cmp(&a.connected)
            .then(b.paired.cmp(&a.paired))
            .then(b.rssi.cmp(&a.rssi))
    });
}

#[tokio::main]
async fn main() {
    let dbus_conn = match Connection::new_system() {
        Ok(conn) => conn,
        Err(e) => {
            eprintln!("Failed to connect to D-Bus: {}", e);
            std::process::exit(1);
        }
    };

    let bt_session = Session::new().await.expect("Failed to create BT session");
    let bt_adapter = bt_session
        .default_adapter()
        .await
        .expect("No BT adapter found");

    let mut state = SystemState::default();
    let mut last_json = String::new();

    loop {
        update_network_state(&dbus_conn, &mut state);
        update_bluetooth_state(&bt_adapter, &mut state).await;

        let json = serde_json::to_string(&state).unwrap();
        if json != last_json {
            println!("{}", json);
            last_json = json;
        }

        tokio::time::sleep(Duration::from_secs(2)).await;
    }
}
