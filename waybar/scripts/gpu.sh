#!/bin/sh
best=""; max=0
for d in /sys/class/drm/card*/device; do
  [ -r "$d/gpu_busy_percent" ] || continue
  v=$(cat "$d/mem_info_vram_total" 2>/dev/null || echo 0)
  if [ "$v" -gt "$max" ]; then max=$v; best=$d; fi
done
if [ -n "$best" ]; then cat "$best/gpu_busy_percent"; else echo 0; fi
