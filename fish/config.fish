if status is-interactive

    # =============================
    # ALIASES — GENERAL
    # =============================
    alias ll='ls -lahF --color=auto'
    alias la='ls -A'
    alias cls='clear'
    alias q='exit'
    alias mkdir='mkdir -pv'
    alias grep='grep --color=auto'
    alias df='df -h'
    alias du='du -sh'
    alias free='free -h'

    # =============================
    # ALIASES — SISTEMA
    # =============================
    alias update='sudo pacman -Syu'
    alias install='sudo pacman -S'
    alias remove='sudo pacman -Rns'
    alias search='pacman -Ss'
    alias aurinstall='yay -S'
    alias hyprconf='nvim ~/.config/hypr/hyprland.conf'
    alias fishconf='nvim ~/.config/fish/config.fish'
    alias waybarconf='nvim ~/.config/waybar/config'

    # =============================
    # ALIASES — HTB / PENTEST
    # =============================

    # VPN
    alias starthtb='sudo openvpn ~/Downloads/machines_us-dedivip-5.ovpn > /dev/null 2>&1 &; echo "HTB VPN iniciando..."; sleep 2; ip addr show tun0 | grep inet'
    alias startacademy='sudo openvpn ~/Downloads/academy-regular.ovpn > /dev/null 2>&1 &; echo "HTB VPN iniciando..."; sleep 2; ip addr show tun0 | grep inet'
    alias stophtb='sudo pkill openvpn; echo "HTB VPN desconectada"'
    alias myhtbip='ip addr show tun0 2>/dev/null | grep "inet " | awk "{print \$2}" | cut -d/ -f1'

    # Nmap
    alias scan='nmap -sV -sC -oN scan.txt $IP'
    alias fullscan='nmap -sV -sC -p- --min-rate 5000 -oN full.txt $IP'
    alias udpscan='sudo nmap -sU --top-ports 200 -oN udp.txt $IP'
    alias webscan='nmap -sV -sC -p 80,443,8080,8443 -oN web.txt $IP'
    alias rust='rustscan -a $IP --ulimit 1000 -r 1-65535 -- -A -sC -sV -Pn -o nmapresult.txt'

    # Servidor HTTP
    alias srv='python3 -m http.server 8080'
    alias srv80='sudo python3 -m http.server 80'
    alias srv443='sudo python3 -m http.server 443'

    # Reverse shell listener
    alias listen='nc -lvnp 4444'
    alias listen443='sudo nc -lvnp 443'
    alias listen80='sudo nc -lvnp 80'

    # FUNCIONES
    # =============================

    # Extraer cualquier archivo
    function extract
        if test -f $argv[1]
            switch $argv[1]
                case '*.tar.bz2'
                    tar xjf $argv[1]
                case '*.tar.gz'
                    tar xzf $argv[1]
                case '*.tar.xz'
                    tar xJf $argv[1]
                case '*.zip'
                    unzip $argv[1]
                case '*.rar'
                    unrar x $argv[1]
                case '*.7z'
                    7z x $argv[1]
                case '*'
                    echo "'$argv[1]' no se puede extraer"
            end
        else
            echo "'$argv[1]' no es un archivo válido"
        end
    end

    # Crear directorio y entrar
    function mkcd
        mkdir -p $argv[1] && cd $argv[1]
    end

    # Ver IP local y pública
    function myip
        echo "Local:   "(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v 127)
        echo "HTB tun0:"(ip addr show tun0 2>/dev/null | grep "inet " | awk '{print $2}' | cut -d/ -f1)
    end

    # Iniciar máquina HTB
    function htbinit
        set -Ux TARGET $argv[1]
        echo "Target seteado: $TARGET"
        mkdir -p ~/htb/$argv[1]/{nmap,exploits,loot}
        cd ~/htb/$argv[1]
        echo "Directorio creado: ~/htb/$argv[1]"
    end

end
#set -x PYENV_ROOT $HOME/.pyenv
set -x PATH $PYENV_ROOT/bin $PATH
#pyenv init - | source
starship init fish | source
set fish_greeting ""

# Created by `pipx` on 2026-08-27 03:10:35
set PATH $PATH /home/javikrd/.local/bin
