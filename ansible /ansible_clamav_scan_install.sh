#!/bin/bash

#root ?
if [ "$EUID" -ne 0 ] ; then
    echo "Pour installer ou scanner avec clamav exécuté le script avec la commande sudo : \"sudo bash clamav-scan.sh\""
    exit
fi

# Ligne à écrire dans cron.d
text_scan="00 13 * * 1-5 root ionice -c3 nice -n 19 bash /var/opt/ansible_clamav.sh"

clamav_verif=$(which apache | grep -o apache > /dev/null &&  echo 1 || echo 0)

# Installation de Clamav
clamav_install() {
    apt remove clamav && apt purge clamav
    echo "clamav remove"
    if [ ${clamav_verif} -ne 0 ] ; then
        # Installation
        apt-get -y update
        apt-get -y install clamav clamav-daemon build-essential
        apt-get build-dep clamav
        echo "clamav install"
    fi
}

# Mises à jour automatiques
clamav_maj() {
        echo "/etc/init.d/clamav-freshclam stop
        /usr/bin/freshclam -v >> /var/log/clamav/updates.txt
        /etc/init.d/clamav-freshclam start" > /etc/cron.daily/clamav
        chmod -R 644 /etc/cron.daily/clamav
        echo "clamav MAJ auto"
}

# Scan automatique
clamav_auto() {
        echo "${text_scan}" > /etc/cron.daily/clamav
        chmod +x /etc/cron.daily/clamav
        echo "clamav Scan auto "
}

# Menu principal
mainMenu() {
    clamav_install
    clamav_maj
    clamav_auto
}