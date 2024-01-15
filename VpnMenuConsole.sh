#!/bin/bash
#He actualizado el script a fecha de 15/01/2024, el manual.pdf esta desactualizado, sin embargo la parte importante(instalacion) no se ve afectada.
#Es posible que necesites instalar Lolcat --> sudo apt install lolcat

#Variables Globales

# Ruta a la carpeta donde se encuentran los archivos .ovpn , edita esto a tu gusto.
RUTA_VPNS="/home/username/Documents/vpn/"

#Carpeta oculta, edita esto a tu gusto
carpeta_oculta="$RUTA_VPNS/hidden_vpn/"

#version del script
version='1.2'

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

 function ocultar_vpn {
    id_a_ocultar=$2
    archivos_ovpn=($RUTA_VPNS*.ovpn)
    carpeta_oculta="$RUTA_VPNS/hidden_vpn"

    if [ ! -d "$carpeta_oculta" ]; then
        echo -e "Se ha creado la carpeta oculta, debido a que no existia previamente"
        mkdir "$carpeta_oculta"
    fi

    if [ ${#archivos_ovpn[@]} -eq 0 ]; then
        echo -e "\e[91m[!] No se encontraron archivos .ovpn en la ruta especificada.\e[0m"
        exit 1
    fi

    if (( id_a_ocultar < 1 || id_a_ocultar > ${#archivos_ovpn[@]} )); then
        echo -e "\e[91m[!] Identificador no válido.\e[0m"
        exit 1
    fi

    archivo_a_ocultar="${archivos_ovpn[$id_a_ocultar - 1]}"
    nombre_archivo=$(basename "$archivo_a_ocultar")

    # Crea la carpeta oculta si no existe


    # Mueve el archivo a la carpeta oculta
    mv "$archivo_a_ocultar" "$carpeta_oculta/$nombre_archivo"
    echo -e "\e[92m[+] VPN ocultada: \e[0m\e[33m$nombre_archivo\e[0m\e[93m\n\e[0m"
    exit 0
}


function mostrar_vpn() {
    carpeta_oculta="$RUTA_VPNS/hidden_vpn"

    if [ ! -d "$carpeta_oculta" ]; then
        echo -e "\e[91m[!] No se encontró la carpeta oculta.\e[0m"
        exit 1
    fi

    archivos_ocultos=$(find "$carpeta_oculta" -maxdepth 1 -type f -name "*.ovpn")

    if [ -z "$archivos_ocultos" ]; then
        echo -e "\e[93mNo existen VPNs ocultas.\e[0m"
        exit 0
    else
        echo "-----------------------------------------"
        echo -e "\e[92m           VPNs ocultadas\e[0m"
        echo "-----------------------------------------"
        
        contador=1
        for archivo in $archivos_ocultos; do
            nombre_archivo=$(basename "$archivo")
            echo -e "\e[96mID: $contador   Archivo: $nombre_archivo\e[0m"
            ((contador++))
        done

        echo -en "\e[96m¿Qué VPN quieres desocultar? Indica su ID --> \e[0m"
        read id_a_desocultar

        if (( id_a_desocultar < 1 || id_a_desocultar > $(echo "$archivos_ocultos" | wc -l) )); then
            echo -e "\e[91m[!] ID Inválido! Solo existen estas VPNS ocultas:\e[0m"
            contador=1
            for archivo in $archivos_ocultos; do
                nombre_archivo=$(basename "$archivo")
                echo -e "\e[96mID: $contador   Archivo: $nombre_archivo\e[0m"
                ((contador++))
            done
            exit 1
        fi

        archivo_a_desocultar=$(echo "$archivos_ocultos" | sed -n "${id_a_desocultar}p")
        nombre_archivo=$(basename "$archivo_a_desocultar")

        echo -e "\e[92m[+] VPN desocultada: $nombre_archivo\e[0m"
        mv "$archivo_a_desocultar" "$RUTA_VPNS/$nombre_archivo"
        exit 0
    fi
}




function eliminar_vpn {
    id_a_eliminar=$2
    archivos_ovpn=($RUTA_VPNS*.ovpn)

    if [ ${#archivos_ovpn[@]} -eq 0 ]; then
        echo -e "\e[91m[!] No se encontraron archivos .ovpn en la ruta especificada.\e[0m"
        exit 1
    fi

    if (( id_a_eliminar < 1 || id_a_eliminar > ${#archivos_ovpn[@]} )); then
        echo -e "\e[91m[!] Identificador no válido.\e[0m Debes indicar el VPN_ID"
        exit 1
    fi

    archivo_a_eliminar="${archivos_ovpn[$id_a_eliminar - 1]}"
    confirmacion=""
    
    while [[ "$confirmacion" != "s" && "$confirmacion" != "n" ]]; do
        #echo -e "\e[93m[?] ¿Estás seguro que quieres eliminar la VPN: $(basename "$archivo_a_eliminar")? (s/n)\e[0m"
        echo -e "\nVPN SELECCIONADA:  \e[93m\e[0m\e[33m$(basename "$archivo_a_eliminar")\e[0m\e[93m\e[0m\n"
        read -p "¿Estás seguro que quieres eliminar la VPN (s/n): " confirmacion
        
        if [[ "$confirmacion" != "s" && "$confirmacion" != "n" ]]; then
            echo -e "\033[A\033[K\e[93m[!] Responde solo 's' o 'n': \e[0m"
        fi
    done

    if [ "$confirmacion" = "s" ]; then
        rm "$archivo_a_eliminar"
        echo -e "\e[92m[+] VPN eliminada: $(basename "$archivo_a_eliminar")\e[0m"
    else
        echo -e "\e[93m[-] Operación cancelada.\e[0m"
    fi
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
    echo -e "\n\e[96m[?] Uso: <comando> <argumento>\n"
    echo -e "\e[96m\t -s/--start: Iniciar VPN\e[0m <VPN_ID>" 
    echo -e "\e[96m\t -st/--stop: Detener VPN\e[0m"
    echo -e "\e[96m\t -l/--list: Mostrar VPNs Disponibles\e[0m <VPN_ID> "
    echo -e "\e[96m\t -c/--creator: Mostrar el creador de la herramienta\e[0m"
    echo -e "\e[96m\t -r/--remove: eliminar_vpn\e[0m <VPN_ID>"
    echo -e "\e[96m\t -hi/--hide: ocultar_vpn\e[0m <VPN_ID>"
    echo -e "\e[96m\t -uh/--unhide Hacer Visible una Vpn oculta\e[0m <VPN_ID>"
    echo -e "\e[96m\t -v/--version Mostrar version del script \e[0m"
}


function show_creator(){
echo -e "Created By Julangas Alias \"Onlysockets\"" | lolcat -s 5 
}

function version_checker(){
    tput civis
    sleep 0.3
    echo -e "Version ---> $version" | pv -qL 20
    tput cnorm
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
    "--remove" | "-r") eliminar_vpn "$@" ;;
    "--version" | "-v") version_checker ;;
    "--hide" | "-hi") ocultar_vpn "$@" ;;
    "--unhide" | "-uh")
        if [ -n "$2" ]; then
            echo -e "\n\e[91m[!] Error de sintaxis.\e[0m Uso correcto: -uh/--unhide"
            exit 1
        else
            mostrar_vpn "$@"
        fi ;;
    *) mostrar_ayuda ;;
esac
