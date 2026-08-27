#!/bin/bash
chosen=$(printf "  Apagar\n  Reiniciar\n  Suspender\n  Cerrar sesión\n  Bloquear" | wofi --dmenu --prompt "Sistema")

case $chosen in
    "  Apagar")     systemctl poweroff ;;
    "  Reiniciar")  systemctl reboot ;;
    "  Suspender")  systemctl suspend ;;
    "  Cerrar sesión") hyprctl dispatch exit ;;
    "  Bloquear")   hyprlock ;;
esac
