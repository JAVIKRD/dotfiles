function extractPorts
    set file $argv[1]

    if test -z "$file"
        echo "[!] Uso: extractPorts <archivo_nmap>"
        return 1
    end

    if not test -f "$file"
        echo "[!] El archivo no existe: $file"
        return 1
    end

    set ports (grep -oP '\d{1,5}/(tcp|udp)\s+open' "$file" | awk -F/ '{print $1}' | xargs | tr ' ' ',')
    set ip_address (grep -oP '\d{1,3}(\.\d{1,3}){3}' "$file" | sort -u | head -n 1)

    echo
    echo "[*] Extracting information..."
    echo
    echo "    [*] IP Address: $ip_address"
    echo "    [*] Open ports: $ports"
    echo

    if test -n "$ports"
        printf "%s" "$ports" | wl-copy
        echo "[*] Ports copied to clipboard"
    else
        echo "[!] No se encontraron puertos abiertos"
        return 1
    end
end
