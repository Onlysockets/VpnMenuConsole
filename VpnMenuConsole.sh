#!/bin/bash


# Ruta a la carpeta donde se encuentran los archivos .ovpn , edita esto a tu gusto.
RUTA_VPNS="/home/usuario/Documents/vpn/"



#FUNCION CONTROL C

function ctrl_c() {
    echo -e "[!] Se ha detectado la combinacion: Ctrl+c, saliendo..."
    exit 1
}

# Establecer la función ctrl_c como manejador de la señal SIGINT
trap ctrl_c SIGINT


function listar_vpns {
    archivos_ovpn=($RUTA_VPNS*.ovpn)
    
    if [ ${#archivos_ovpn[@]} -eq 0 ]; then
        echo -e "\e[91m[!] No se encontraron archivos .ovpn en la ruta especificada.\e[0m"
        exit 1
    fi

echo -e "\n\e[1mDetectadas las siguientes VPNs:\e[0m\n"
echo -e "\e[92mID\e[0m\t\e[33mVPN\e[0m"

for ((i = 0; i < ${#archivos_ovpn[@]}; i++)); do
    nombre_archivo=$(basename "${archivos_ovpn[$i]}")
    id="\e[32m$((i + 1))\e[0m"
    vpn="\e[33m$nombre_archivo\e[0m"
    echo -e "$id\t$vpn"
done
exit 0
}

function verificar_vpn_en_uso {
    if pgrep openvpn > /dev/null; then
        echo -e "\e[93m[+] Una VPN está en uso actualmente.\e[0m"
        exit 1
    fi
}

function detener_vpn {
    if ! pgrep openvpn > /dev/null; then
        echo -e "\n\e[91m[!] No hay ninguna VPN activa para detener.\e[0m"
        exit 1
    fi
    sudo killall openvpn &>/dev/null
    echo -e "\e[92m[+] La VPN se ha detenido correctamente.\e[0m"
}

function iniciar_vpn {
    verificar_vpn_en_uso
    if [ "$2" ]; then
        archivos_ovpn=($RUTA_VPNS*.ovpn)
        if [ "${#archivos_ovpn[@]}" -eq 0 ]; then
            echo -e "\e[91m[!] No se encontraron archivos .ovpn en la ruta especificada.\e[0m"
            exit 1
        fi
        if (( $2 < 1 || $2 > ${#archivos_ovpn[@]} )); then
            echo -e "\e[91m[!] Identificador no válido.\e[0m"
            exit 1
        fi
        archivo="${archivos_ovpn[$2 - 1]}"
        if sudo -n true 2>/dev/null; then
            sudo openvpn --config "$archivo" &>/dev/null &
            echo -e "\e[92m[+] Iniciando VPN: $(basename "$archivo")\e[0m"
        else
            if ! read -s -p $'\e[96m[?] Contraseña sudo: \e[0m' password </dev/tty; then
                echo ""
                echo -e "\e[91m[!] Error al leer la contraseña.\e[0m"
                exit 1
            fi
            if echo "$password" | sudo -S true 2>/dev/null; then
                echo ""
                sudo openvpn --config "$archivo" &>/dev/null &
                echo -e "\e[92m[+] Iniciando VPN: $(basename "$archivo")\e[0m"
            else
                echo ""
                echo -e "\e[91m[!] Contraseña incorrecta.\e[0m"
                exit 1
            fi
        fi
    else
        echo -e "\n\e[91m[!] Falta el identificador de la VPN.\e[0m \n"

        mostrar_ayuda
        exit 1
    fi
}

function mostrar_ayuda {
    echo -e "\n\e[96m[?] Uso: <command> <argument>\n"
    echo -e "\e[96m\t -s/--start: Iniciar VPN\e[0m (Debes incluir el VPN_ID)" 
    echo -e "\e[96m\t -st/--stop: Detener VPN\e[0m"
    echo -e "\e[96m\t -l/--list: VPNs Disponibles + ID\e[0m"
    echo -e "\e[96m\t -c/--creator: Muestra el creador de la herramienta\e[0m"
}


function show_creator(){
echo -e "Created By Julangas Alias \"Onlysockets\"" | lolcat -s 5 
}

# Comprueba si se proporciona algún argumento
if [ $# -eq 0 ]; then
    mostrar_ayuda
    exit 1
fi

case "$1" in
 "--start" | "-s") iniciar_vpn "$@" ;;
    "--stop" | "-st") detener_vpn ;;
    "--list" | "-l") listar_vpns ;;
    "--creator" | "-c") show_creator ;;
    *) echo -e "\n\e[91m[!] Argumento no válido.\e[0m \n"; mostrar_ayuda; exit 1 ;;
esac
