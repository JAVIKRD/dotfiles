#!/bin/sh
best=""; max=0
for d in /sys/class/drm/card*/device; do
  [ -r "$d/gpu_busy_percent" ] || continue
  v=$(cat "$d/mem_info_vram_total" 2>/dev/null || echo 0)
  if [ "$v" -gt "$max" ]; then max=$v; best=$d; fi
done
[ -n "$best" ] || { printf '{"text":"0","tooltip":"GPU no encontrada"}\n'; exit 0; }
use=$(cat "$best/gpu_busy_percent")
vu=$(cat "$best/mem_info_vram_used" 2>/dev/null || echo 0)
vu_g=$(awk -v b="$vu" 'BEGIN{printf "%.1f", b/1073741824}')
vt_g=$(awk -v b="$max" 'BEGIN{printf "%.1f", b/1073741824}')
t=$(cat "$best"/hwmon/hwmon*/temp1_input 2>/dev/null | head -n1)
t=$(( ${t:-0} / 1000 ))
printf '{"text":"%s","tooltip":"GPU: %s%%\\nVRAM: %s / %s GiB\\nTemp: %s°C"}\n' "$use" "$use" "$vu_g" "$vt_g" "$t"
