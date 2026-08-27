#!/bin/bash

THEME="$HOME/.config/rofi/cheatsheet.rasi"

# Obtener redes disponibles
get_networks() {
    # Red actual
    current=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d: -f2)
    
    # Listar todas las redes
    nmcli -t -f ssid,signal,security dev wifi list 2>/dev/null | \
    while IFS=: read -r ssid signal security; do
        [ -z "$ssid" ] && continue
        
        # Ícono de señal
        if [ "$signal" -ge 75 ]; then icon="󰤨"
        elif [ "$signal" -ge 50 ]; then icon="󰤥"
        elif [ "$signal" -ge 25 ]; then icon="󰤢"
        else icon="󰤟"
        fi
        
        # Ícono de seguridad
        [ -n "$security" ] && lock="󰌾 " || lock=""
        
        # Marcar red actual
        if [ "$ssid" = "$current" ]; then
            echo "󰤨  $ssid  ● conectado"
        else
            echo "$icon  $ssid  $lock"
        fi
    done | sort -u
}

# Opciones extra
OPTIONS=$(cat << 'OPT'
─────────────────────────
󰖪  Desconectar WiFi
󰣺  Abrir configuración
󰑓  Escanear redes
OPT
)

# Mostrar menú
CHOICE=$({ get_networks; echo "$OPTIONS"; } | rofi \
    -dmenu \
    -p "󰖩 Red" \
    -theme "$THEME" \
    -i)

[ -z "$CHOICE" ] && exit

# Extraer SSID limpio
SSID=$(echo "$CHOICE" | sed 's/^[^ ]* *//' | sed 's/  .*//' | xargs)

case "$CHOICE" in
    *"Desconectar WiFi"*)
        nmcli radio wifi off
        notify-send "WiFi" "Desconectado" -i network-wireless-offline
        ;;
    *"Abrir configuración"*)
        nm-connection-editor
        ;;
    *"Escanear redes"*)
        nmcli dev wifi rescan
        notify-send "WiFi" "Escaneando redes..." -i network-wireless
        sleep 2
        exec "$0"
        ;;
    *"conectado"*)
        notify-send "WiFi" "Ya estás conectado a $SSID" -i network-wireless
        ;;
    *)
        # Intentar conectar
        if nmcli con up "$SSID" 2>/dev/null; then
            notify-send "WiFi" "Conectado a $SSID" -i network-wireless
        else
            # Pedir contraseña si es nueva red
            PASS=$(rofi -dmenu -p "󰌾 Contraseña para $SSID" -theme "$THEME" -password)
            if [ -n "$PASS" ]; then
                if nmcli dev wifi connect "$SSID" password "$PASS"; then
                    notify-send "WiFi" "Conectado a $SSID" -i network-wireless
                else
                    notify-send "WiFi" "Error al conectar a $SSID" -i network-wireless-offline
                fi
            fi
        fi
        ;;
esac
