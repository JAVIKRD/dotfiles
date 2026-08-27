#!/usr/bin/env bash
# ================================================
#  WAYBAR — NETWORK MENU
#  Deps: nmcli, rofi, notify-send
# ================================================

ROFI_THEME="/tmp/waybar-net.rasi"

cat >"$ROFI_THEME" <<'RASI'
* {
    background-color:   #1d2021;
    text-color:         #a89984;
    border-color:       #3c3836;
    selected-normal-background: #3c3836;
    selected-normal-foreground: #ebdbb2;
}
window {
    width:          340px;
    border:         1px;
    border-radius:  10px;
    padding:        6px;
}
mainbox {
    spacing:    4px;
    padding:    4px;
}
inputbar {
    background-color:   #282828;
    border-radius:      6px;
    padding:            6px 10px;
    spacing:            6px;
    children:           [ prompt, entry ];
}
prompt {
    background-color:   #282828;
    text-color:         #7daea3;
}
entry {
    background-color:   #282828;
    text-color:         #ebdbb2;
}
listview {
    lines:      10;
    spacing:    2px;
    padding:    4px 0px;
}
element {
    padding:        6px 10px;
    border-radius:  5px;
}
element selected.normal {
    background-color:   #3c3836;
    text-color:         #ebdbb2;
}
element normal.normal {
    background-color:   #1d2021;
    text-color:         #a89984;
}
RASI

ROFI_CMD="rofi -dmenu -i -theme $ROFI_THEME"

notify() {
  notify-send -a "Network" -t 3000 "$1" "$2"
}

main_menu() {
  local connected
  connected=$(nmcli -t -f NAME,TYPE,STATE connection show --active |
    grep -v loopback | head -1 | cut -d: -f1)

  local wifi_status
  wifi_status=$(nmcli radio wifi)

  local items=""

  if [[ "$wifi_status" == "enabled" ]]; then
    items+="󰖩  Escanear redes Wi-Fi\n"
    items+="󰑓  Reconectar\n"
    items+="󰖪  Desactivar Wi-Fi\n"
  else
    items+="󰖩  Activar Wi-Fi\n"
  fi

  if [[ -n "$connected" ]]; then
    items+="󱘖  Desconectar: $connected\n"
    items+="󰿃  Ver detalles de conexión\n"
  fi

  items+="󰖔  Olvidar una red guardada\n"
  items+="󰒍  Abrir configuración avanzada\n"

  local choice
  choice=$(echo -e "$items" | sed '/^$/d' | $ROFI_CMD -p "󰖩 Red")

  case "$choice" in
  *"Escanear redes"*) scan_wifi ;;
  *"Reconectar"*) reconnect ;;
  *"Desactivar Wi-Fi"*) toggle_wifi off ;;
  *"Activar Wi-Fi"*) toggle_wifi on ;;
  *"Desconectar:"*) disconnect "$connected" ;;
  *"Ver detalles"*) show_details ;;
  *"Olvidar"*) forget_network ;;
  *"configuración avanzada"*) nm_advanced ;;
  esac
}

scan_wifi() {
  notify "Escaneando..." "Buscando redes disponibles"
  nmcli device wifi rescan 2>/dev/null
  sleep 1

  local networks
  networks=$(nmcli -f IN-USE,SSID,SIGNAL,SECURITY device wifi list |
    tail -n +2 |
    awk '{
        in_use = ($1 == "*") ? "● " : "  "
        signal = $3+0
        if (signal >= 75) icon = "󰤨"
        else if (signal >= 50) icon = "󰤥"
        else if (signal >= 25) icon = "󰤢"
        else icon = "󰤟"
        sec = ($4 != "--") ? " 󰌆" : ""
        printf "%s%s  %-28s%s  %s%%\n", in_use, icon, $2, sec, $3
      }')

  local choice
  choice=$(echo "$networks" | $ROFI_CMD -p "󰖩 Conectar a")
  [[ -z "$choice" ]] && return

  local ssid
  ssid=$(echo "$choice" | awk '{print $2}')
  [[ -z "$ssid" ]] && return

  connect_to "$ssid"
}

connect_to() {
  local ssid="$1"

  if nmcli connection show "$ssid" &>/dev/null; then
    notify "Conectando..." "$ssid"
    nmcli connection up "$ssid" &&
      notify "Conectado ✓" "$ssid" ||
      notify "Error" "No se pudo conectar a $ssid"
    return
  fi

  local security
  security=$(nmcli -f SSID,SECURITY device wifi list |
    awk -v s="$ssid" '$1==s {print $2}' | head -1)

  if [[ "$security" == "--" ]]; then
    notify "Conectando..." "$ssid (abierta)"
    nmcli device wifi connect "$ssid" &&
      notify "Conectado ✓" "$ssid" ||
      notify "Error" "No se pudo conectar"
  else
    local pass
    pass=$(rofi -dmenu -p "󰌆 Contraseña para $ssid" -password -theme "$ROFI_THEME" <<<"")
    [[ -z "$pass" ]] && return

    notify "Conectando..." "$ssid"
    nmcli device wifi connect "$ssid" password "$pass" &&
      notify "Conectado ✓" "$ssid" ||
      notify "Contraseña incorrecta" "No se pudo conectar a $ssid"
  fi
}

disconnect() {
  nmcli connection down "$1" &&
    notify "Desconectado" "$1" ||
    notify "Error" "No se pudo desconectar"
}

reconnect() {
  local iface
  iface=$(nmcli -t -f DEVICE,TYPE device status | grep wifi | cut -d: -f1 | head -1)
  nmcli device disconnect "$iface" 2>/dev/null
  sleep 1
  nmcli device connect "$iface" &&
    notify "Reconectado ✓" "$iface" ||
    notify "Error" "No se pudo reconectar"
}

toggle_wifi() {
  nmcli radio wifi "$1"
  [[ "$1" == "on" ]] &&
    notify "Wi-Fi activado" "Buscando redes..." ||
    notify "Wi-Fi desactivado" ""
}

show_details() {
  local info
  info=$(nmcli -f GENERAL.CONNECTION,IP4.ADDRESS,IP4.GATEWAY,GENERAL.DEVICE \
    device show 2>/dev/null |
    grep -E "CONNECTION|ADDRESS|GATEWAY|DEVICE" |
    sed 's/^[^:]*:\s*//' | head -8)

  echo "$info" | rofi -dmenu -p "󰿃 Detalles" -theme "$ROFI_THEME" -no-custom >/dev/null
}

forget_network() {
  local saved
  saved=$(nmcli -t -f NAME,TYPE connection show | grep wifi | cut -d: -f1)

  local choice
  choice=$(echo "$saved" | $ROFI_CMD -p "󰖔 Olvidar red")
  [[ -z "$choice" ]] && return

  nmcli connection delete "$choice" &&
    notify "Red olvidada" "$choice" ||
    notify "Error" "No se pudo eliminar $choice"
}

nm_advanced() {
  if command -v nm-connection-editor &>/dev/null; then
    nm-connection-editor &
  else
    foot nmtui &
  fi
}

main_menu
