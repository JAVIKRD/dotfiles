#!/bin/bash

THEME="$HOME/.config/rofi/cheatsheet.rasi"

keybinds=$(cat << 'KEYS'
󰀻  Apps ──────────────────────────────────────
   Super + Enter          →  Terminal (kitty)
   Super + D              →  Launcher (wofi)
   Super + B              →  Firefox
   Super + E              →  Archivos (thunar)
   Super + Shift + Enter  →  VS Code

󱂬  Ventanas ───────────────────────────────────
   Super + Q              →  Cerrar ventana
   Super + F              →  Fullscreen
   Super + Shift + F      →  Maximize
   Super + Space          →  Toggle floating
   Super + Tab            →  Siguiente ventana
   Super + Shift + E      →  Salir de Hyprland

  Foco (vim-style) ───────────────────────────
   Super + H/J/K/L        →  Mover foco
   Super + Shift + H/J/K/L →  Mover ventana
   Super + Ctrl + H/J/K/L →  Resize ventana

󰙀  Workspaces ─────────────────────────────────
   Super + 1-9            →  Ir al workspace
   Super + Shift + 1-9    →  Mover ventana al WS
   Super + S              →  Scratchpad
   Super + Shift + S      →  Mover al scratchpad
   Super + Scroll         →  Cambiar workspace

󰁪  Sistema ────────────────────────────────────
   Super + L              →  Lockscreen
   Super + V              →  Clipboard
   Super + N              →  Cerrar notificaciones
   Super + F1             →  Este cheatsheet

  Screenshots ────────────────────────────────
   Print                  →  Screenshot área
   Shift + Print          →  Screenshot monitor
   Super + Print          →  Screenshot y guardar

󰕾  Media ──────────────────────────────────────
   XF86AudioRaiseVolume   →  Subir volumen
   XF86AudioLowerVolume   →  Bajar volumen
   XF86AudioMute          →  Mute
   XF86AudioPlay          →  Play/Pause
   XF86MonBrightnessUp    →  Brillo +
   XF86MonBrightnessDown  →  Brillo -
KEYS
)

echo "$keybinds" | rofi \
    -dmenu \
    -p "󰌌 Keybinds" \
    -theme "$THEME" \
    -no-custom \
    -i
