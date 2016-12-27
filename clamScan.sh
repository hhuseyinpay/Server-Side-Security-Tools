#!/bin/bash
LOGFILE="/var/log/clamav/clamav-$(date +'%Y-%m-%d').log";
EMAIL_MSG="Lutfen ekteki log dosyasina bakin.";
EMAIL_FROM="***sunucu mail adresi***";
EMAIL_TO="**mail atılacak adres**";
DIRTOSCAN="/var/www /var/vmail"; # taranacak yerler.

for S in ${DIRTOSCAN}; do
 DIRSIZE=$(du -sh "$S" 2>/dev/null | cut -f1);

 echo "$S" "dizininde gunluk tarama baslatiliyor. 
 Taranacak veri miktari "$DIRSIZE" 'dir.";

 clamscan -ri "$S" >> "$LOGFILE";

 # Sadece malware tespit edilen satirlari al
 MALWARE=$(tail "$LOGFILE"|grep Infected|cut -d" " -f3);

 # Deger sifira esit degilse, log dosyasi ekli bir e-posta gönderin
 if [ "$MALWARE" -ne "0" ];then
 #  heirloom-mailx kullanarak gonder
 echo "$EMAIL_MSG"|mail -a "$LOGFILE" -s "Malware Bulundu." -r "$EMAIL_FROM" "$EMAIL_TO";
 fi 
done

exit 0
