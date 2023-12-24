# ==
# == DEFINIZIONE DELLE FUNZIONI
# ==
# Funzione per gestire la logica di creazione del folder di appoggio dati
manageFolder() {
    # Parametro passato alla funzione (nomeCartella)
    local nomeCartella="$1"

    # Ottieni il percorso del desktop dell'utente corrente
    local desktopPath="$HOME/Desktop"
    
    # Percorso completo della cartella specificata sul desktop
    local cartellaCompleta="$desktopPath/$nomeCartella"

    # Verifica se la cartella esiste sul desktop
    if [ ! -d "$cartellaCompleta" ]; then
        mkdir "$cartellaCompleta"
    fi

    # Entra nella cartella
    cd "$cartellaCompleta" || exit

    # Verifica se esiste il file readme.txt
    if [ -f "readme.txt" ]; then
        # Il file readme esiste quindi lo apro
        xdg-open "readme.txt"
    else
        # se non esiste lo creo e lo apro
        touch "readme.txt"
        # Apri il file readme.txt
        xdg-open "readme.txt"
    fi
    # Apri la cartella
    xdg-open "$cartellaCompleta" >/dev/null 2>&1    
    # Restituisci il percorso completo della cartella
    echo "$cartellaCompleta"    
}


# Genero il file con gli users
generate_users() {
local file_path=$1
# Verifica se il file esiste, altrimenti lo crea
if [ ! -e "$file_path" ]; then
touch "$file_path"
names=("admin" "administrator" "user" "guest" "root" "(name of box)" "wampp" "public" "private" "manager")
for name in "${names[@]}"; do
    echo "$name" >> "$file_path"
done
fi
# Se il file esiste già non lo tocca
}

# Genero il file con le password
generate_passwords() {
local file_path=$1
# Verifica se il file esiste, altrimenti lo crea
if [ ! -e "$file_path" ]; then
touch "$file_path"
names=("admin" "password" "administrator" "(name of box)" "user" "12345" "guest" "root" "xampp" "public" "private" "manager")
for name in "${names[@]}"; do
    echo "$name" >> "$file_path"
done
fi
# Se il file esiste già non lo tocca    
}



#!/bin/bash

# Funzione per estrarre l'IP dall'URL
get_ip() {
    url=$1
    ip=$(dig +short "$(echo "$url" | grep -oP '(?<=://)[^/]+')" | grep -E '([0-9]{1,3}\.){3}[0-9]{1,3}')
    echo "$ip"
}

# Funzione per estrarre il dominio dall'URL
get_domain() {
    url=$1
    domain=$(echo "$url" | awk -F[/:] '{print $4}' | awk -F. '{
        if (NF == 2 || (NF == 3 && length($(NF-1)) > 3)) {
            print $(NF-1)"."$NF
        } else {
            print $(NF-2)"."$(NF-1)"."$NF
        }
    }')
    echo "$domain"
}

# Funzione per estrarre il sito web dall'URL
get_website() {
    url=$1
    website=$(echo "$url" | grep -oP '://\K[^/]+')
    echo "$website"
}

# Funzione per mostrare i valori e chiedere conferma/modifica
confirm_values() {
    value_type=$1
    value=$2
    read -p "Confirm or modify the $value_type [$value]: " new_value
    new_value=${new_value:-$value} # Usa il valore precedente se non viene inserito uno nuovo
    echo "$new_value"
}

# Funzione per mostrare i valori
show_values() {
    echo "IP: $1"
    echo "Sito web: $2"
    echo "Dominio: $3"
    echo "Project Folder $4"
}

# Funzione per chiedere all'utente l'URL
ask_for_url() {
    read -p "Inserisci l'URL: " url
}








# ==
# == MY MAIN
# ==

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <Interface> <Target site>"
    echo " - Interface: Interface from which attacker exexutes action"
    echo " - Target site: if target has a web site, this is site root without protocol definition. If target has no web site fill this field as you want"
    echo ""
    echo "Example:"
    echo "$0 tun0 http://www.hackedbox.htb"
    exit 1
fi


url=$2
# Estrai valori
ip=$(get_ip "$url")
website=$(get_website "$url")
domain=$(get_domain "$url")
fold=$domain

# Mostra i valori e chiedi conferma/modifica
ip=$(confirm_values "IP" "$ip")
website=$(confirm_values "sito web" "$website")
domain=$(confirm_values "domain" "$domain")
fold=$(confirm_values "project folder" "$fold")
# Mostra i valori trovati o inseriti
show_values "$ip" "$website" "$domain" "$fold"


#=============== Variabili per moduli applicativi =================
# Attacker interface
attackerInt=$1
# Attacker IP
attackerIP=$(ip addr show eth0 | grep 'inet ' | awk -F' ' '{print $2}'| awk -F'/' '{print $1}')
# target IP
ip=$ip
# target DOMAIN
domain=$domain
# target site
site=$website
folderAppo=$fold
# wp-press token per analizzare il sito target
wptoken="20En7agrVr8NXWYdZ8CczavcXaJaFYdRm6sWyhPEJu8"
# cartella principale del progetto /target/
folderProject=$(manageFolder "$folderAppo")
# PathFile con Users e Password
pathFile_users="$folderProject/users.txt"
pathFile_passwords="$folderProject/passwords.txt"

folderProjectInfoGathering="$folderProject/InfoGathering"
folderProjectServiceInfoGathering="$folderProject/ServiceInfoGathering"
folderProjectQucikWin="$folderProject/QuickWin"
folderProjectWebFingerprint="$folderProject/WebFingerprint"
folderProjectWebInfo="$folderProject/WebInfoGathering"
folderProjectWebAuthN="$folderProject/WebAuthNbypass"
folderProjectEngine="$folderProjectWebAuthN/engine"
folderProjectWebStuff="$folderProject/WebAuthNStuff"

#===================================================================

# Creo il file con users e passwords
generate_users "$pathFile_users"
generate_passwords "$pathFile_passwords"

# Preparo il il filesystem che conterrà i risultati delle analisi
if [ ! -d "$folderProjectInfoGathering" ]; then
    # Se non esiste, crea la cartella
    mkdir -p "$folderProjectInfoGathering"
fi

if [ ! -d "$folderProjectServiceInfoGathering" ]; then
    # Se non esiste, crea la cartella
    mkdir -p "$folderProjectServiceInfoGathering"
fi
if [ ! -d "$folderProjectQucikWin" ]; then
    # Se non esiste, crea la cartella
    mkdir -p "$folderProjectQucikWin"
fi
if [ ! -d "$folderProjectWebFingerprint" ]; then
    # Se non esiste, crea la cartella
    mkdir -p "$folderProjectWebFingerprint"
fi
if [ ! -d "$folderProjectWebInfo" ]; then
    # Se non esiste, crea la cartella
    mkdir -p "$folderProjectWebInfo"
fi
if [ ! -d "$folderProjectWebAuthN" ]; then
    # Se non esiste, crea la cartella
    mkdir -p "$folderProjectWebAuthN"
fi
if [ ! -d "$folderProjectWebStuff" ]; then
    # Se non esiste, crea la cartella
    mkdir -p "$folderProjectWebStuff"
fi
#preparo il folder con i file di appoggio per command injection
if [ ! -d "$folderProjectEngine" ]; then
    # Se non esiste, crea la cartella
    mkdir -p "$folderProjectEngine"
fi
#copio i file dalla cartella di appoggio a quella di destinazione sul folder del progetto target sovrascrivendo nel caso siano già presenti
cp -f ./engine/* "$folderProjectEngine"
