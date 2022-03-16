#!/bin/bash

#root ?
if [ "$EUID" -ne 0 ] ; then 
    whiptail --title "ERROR" --msgbox "Pour installer ou scanner avec clamav exécuté le script avec la commande sudo : \"sudo bash clamav-scan.sh\"" 8 67
    exit
fi

# Dossier home de l'utilisateur 
user_folder=$(getent passwd 1000 | cut -d":" -f6)

# Ligne à écrire dans cron.d
text_scan="
00 13 * * 1-5 root ionice -c3 nice -n 19 clamscan -i -r ${user_folder}/* | tail -n 11 >> /var/log/clamav/home.log
00 13 * * 1-5 root ionice -c3 nice -n 19 clamscan -i -r /etc/* | tail -n 11 >> /var/log/clamav/etc.log
00 13 * * 1-5 root ionice -c3 nice -n 19 clamscan -i -r /tmp/* | tail -n 11 >> /var/log/clamav/tmp.log
00 13 1 * * root ionice -c3 nice -n 30 tar -czvf /var/log/clamav/clamav_log_$(date +"%m_%Y").tar.gz /var/log/clamav/etc.log /var/log/clamav/home.log /var/log/clamav/tmp.log"

# Installation de Clamav ainsi que de son automatisation
clamav_install() {
    clamav_verif=$(which apache | grep -o apache > /dev/null &&  echo 1 || echo 0)
    if [ ${clamav_verif} -ne 0 ] ; then
        # Installation
        apt update -y && apt install -y clamav

        # Mises à jour automatiques
        echo "/etc/init.d/clamav-freshclam stop
        /usr/bin/freshclam -v >> /var/log/clamav/updates.txt
        /etc/init.d/clamav-freshclam start" > /etc/cron.daily/clamav
        chmod -R 644 /etc/cron.daily/clamav

        # Scan automatique
        echo "${text_scan}" > /etc/cron.d/clamav
        chmod +x /etc/cron.d/clamav
    
        whiptail --title "Successful installation" --msgbox "Clamav a bien été installé,\nil se lancera tous les jours à 13h00" 10 50
    else
        whiptail --title "Error installation" --msgbox "Clamav est déjà installé sur votre machine" 10 50
    fi
}

# Scan de l'utilisateur 
user_scan() {
    scan_1=$(clamscan -i ${user_folder}/* | tail -n 11 )
    whiptail --title "Scan User" --msgbox "Résultat du scan : \n ${scan_1}" 16 50
}

# Scan complet de la machine 
full_scan() {
    scan_2=$(clamscan -i /* | tail -n 11)
    whiptail --title "Scan Complet" --msgbox "Résultat du scan : \n ${scan_2}" 16 50
}

# Menu principal 
mainMenu() {
    menu=$(whiptail --title "Clamav Menu" --fb --menu "Merci de choisir une option :" 15 70 4 \
    "1" "Scan du menu ${user_folder}" \
    "2" "Scan complet de l'ordinateur" \
    "3" "Installer Clamav" \
    "4" "Quitter" 3>&1 1>&2 2>&3)
    case $menu in
        1)
        user_scan
        ;;
        2)
        full_scan
        ;;
        3)
        clamav_install
        ;;
        4)
        exit
        ;;
    esac
}

#Events
while true ; do
    mainMenu
done