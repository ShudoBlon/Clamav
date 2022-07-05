user_folder=$(getent passwd 1000 | cut -d":" -f6)

for (( i = 0; i < 30; i++ )); do
    clamscan -i -r ${user_folder}/* | tail -n 11 >> /var/log/clamav/home.log
    clamscan -i -r /etc/* | tail -n 11 >> /var/log/clamav/etc.log
    clamscan -i -r /tmp/* | tail -n 11 >> /var/log/clamav/tmp.log
done


tar -czvf /var/log/clamav/clamav_log_$(date +"%d_%m_%Y").tar.gz /var/log/clamav/etc.log /var/log/clamav/home.log /var/log/clamav/tmp.log