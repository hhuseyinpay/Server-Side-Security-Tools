#!/bin/sh
# Hasan Huseyin Pay 11/04/2018

RED='\033[0;31m'
GREEN='\033[0;32m'
SET='\033[0m'

if [ "`/usr/bin/id | awk '{print $1}' | cut -d= -f2 | cut -d\( -f1`" != "0" ]; then
    echo -e "${RED}HATA: Bu betik root kullanicisi tarafindan calistirilmalidir. ${SET}"
    exit 1
fi

MYSQL_PREFIX="/usr"
MYSQL_CLIENT="$MYSQL_PREFIX/bin/mysql"
MYSQL_OPTION="-B -N"

MYSQL_HOSTNAME="localhost"
MYSQL_USERNAME="root"
MYSQL_PASSWORD="1"

# Dosyalarin olusacagi dizin
WEB_DATA_DIR="/var/www"

# ApacheLog dizini
ERRORLOG_DIR="/var/apache_logs"

# Apache site sites-available dizini
APACHE_CONF_DIR="/etc/apache2/sites-available"

# Kullanıcıya mail gonderecek script
MAIL_SCRIPT_DIR="/home/huseyin"

# passwd'yi kullanmak icin gerekli script. Calistirma yetkisi olması gerekiyor. expect programinin yuklu olmali!
SETPWD_DIR="."

GREP_DIR="/bin/grep"
regexp_check() {
    echo "$1" | $GREP_DIR -Pq "$2"
    return $?
}

# Website ********************************************
while true; do
    echo "Website adresi []: " | tr -d '\n'
    read input
    
    if regexp_check "$input" "[a-zA-Z0-9_\-./]+"; then
        webAddress="`echo $input | sed 's/\/$//g'`"
        break
    else
        echo -e "${RED}Website adresi sadece alfanumerik karakterler ile '_', '-', '.' ve '/' icerebilir. ${SET}"
    fi
done

if [ -n "`echo $webAddress | cut -d '/' -f 2 -s | tr -d ' '`" ]; then
    webDomain="`echo $webAddress | cut -d '/' -f 1`"
    webFolder="`echo $webAddress | sed 's/\//-/g'`"
else
    webDomain="$webAddress"
    webFolder="$webAddress"
fi

# Path:
IFS='/'

for folder in $webAddress; do
    webTarget="../$webTarget"
done

# Real:
IFS=' '
# END OF Website ********************************************

# E-mail  ********************************************
while true; do
    echo "Teknik sorumlu e-posta []: " | tr -d '\n'
    read input
    
    if regexp_check "$input" "[a-zA-Z0-9_\-.]+@[a-zA-Z0-9_\-.]+"; then
        contactEmail="$input"
        break
    else
        echo -e "${RED}Lutfen gecerli bir e-posta adresi giriniz. ${SET}"
    fi
done
# END OF E-mail  ********************************************

# FTP  ********************************************
while true; do
    echo "FTP kullanici adi []: " | tr -d '\n'
    read input
    
    if regexp_check "$input" "[a-zA-Z0-9_\-.@]+"; then
        if [ "`cat /etc/passwd | grep \"^$input:\" | wc -l | sed -e 's/^ *//g' -e 's/*$//g'`" -gt "0" -o "`cat /etc/group | grep \"^$input:\" | wc -l | sed -e 's/^*//g' -e 's/ *$//g'`" -gt "0" ]; then
            echo -e "${RED}$input FTP kullanici adi zaten kullanilmaktadir, lutfen baska bir ad giriniz.${SET}"
        else
            ftpUsername="$input"
            break
        fi
    else
        echo -e "${RED}FTP kullanici adi sadece alfanumerik karakterler ile '_', '-', '.' ve '@' icerebilir. ${SET}"
    fi
done
# END OF FTP  ********************************************

# MYSQL  ********************************************
while true; do
    echo "MySQL kullanici adi [$ftpUsername]: " | tr -d '\n'
    read input
    
    if [ "x$input" = "x" ]; then
        input="$ftpUsername"
    fi
    
    if regexp_check "$input" "[a-zA-Z0-9_\-.@]+"; then
        if [ "`echo \"SELECT User FROM mysql.user WHERE User LIKE '$input' AND Host ='%'\" | $MYSQL_CLIENT $MYSQL_OPTION -h$MYSQL_HOSTNAME -u$MYSQL_USERNAME -p$MYSQL_PASSWORD 2>/dev/null | wc -l | sed -e 's/^ *//g' -e 's/ *$//g'`" -gt "0" ]; then
            echo -e "${RED}$input MySQL kullanici adi zaten kullanilmaktadir, lutfen baska bir ad giriniz. ${SET}"
        else
            sqlUsername="$input"
            break
        fi
    else
        echo -e "${RED}MySQL kullanici adi sadece alfanumerik karakterler ile '_', '-', '.' ve '@' icerebilir.${SET}"
    fi
done

while true; do
    echo "MySQL veritabani adi [$sqlUsername]: " | tr -d '\n'
    read input
    
    if [ "x$input" = "x" ]; then
        input="$sqlUsername"
    fi
    
    if regexp_check "$input" "[a-zA-Z0-9_\-.@]+"; then
        if [ "`echo \"SHOW DATABASES LIKE '$input'\" | $MYSQL_CLIENT $MYSQL_OPTION -h$MYSQL_HOSTNAME -u$MYSQL_USERNAME -p$MYSQL_PASSWORD 2>/dev/null | wc -l | sed -e 's/^ *//g' -e 's/ *$//g'`" -gt "0" ]; then
            echo -e "${RED}$input MySQL veritabani adi zaten kullanilmaktadir, lutfen baska bir ad giriniz.${SET}"
        else
            sqlDatabase="$input"
            break
        fi
    else
        echo -e "${RED}MySQL veritabani adi sadece alfanumerik karakterler ile '_', '-', '.' ve '@' icerebilir.${SET}"
    fi
done
# END OF MYSQL  ********************************************
ftpPassword=`openssl rand -base64 12 2>/dev/null`
sqlPassword=`openssl rand -base64 12 2>/dev/null`

echo ""
echo ""
echo ""
echo -e "${GREEN}=== Website Hesap Bilgileri =======================${SET}"
echo ""
echo "Website: $webAddress"
echo "Sorumlu: $contactEmail"
echo ""
echo ""
echo -e "${GREEN}=== FTP Bilgileri =================================${SET}"
echo "FTP Sunucusu: `hostname`"
echo "FTP Kapi No: 21"
echo "FTP Web Arayuzu: https://kontrol.deu.edu.tr/ftp-client"
echo ""
echo "FTP Kullanici: $ftpUsername"
echo "FTP Sifre: $ftpPassword"
echo ""
echo ""
echo -e "${GREEN}=== MySQL Bilgileri ===============================${SET}"
echo "MySQL Sunucusu: localhost"
echo "MySQL Kapi No: 3306"
echo "MySQL Web Arayuzu: https://kontrol.deu.edu.tr/mysql-client"
echo ""
echo "MySQL Kullanici: $sqlUsername"
echo "MySQL Sifre: $sqlPassword"
echo "MySQL Veritabani: $sqlDatabase"
echo ""


while true; do
    echo -e "${RED}Yukaridaki bilgilerle devam etmek istiyor musunuz? (E/H) ${SET}" | tr -d '\n'
    read input
    
    if regexp_check "$input" "[yYeE]"; then
        break
        elif regexp_check "$input" "[nNhH]"; then
        exit 0
    fi
done


echo "FTP hesabi olusturuluyor..."
useradd -c "`echo $contactEmail | sed 's/@/_at/g'`" -d $WEB_DATA_DIR/$webFolder -s /sbin/nologin -U $ftpUsername
mkdir -m 555 $WEB_DATA_DIR/$webFolder
mkdir -m 755 $WEB_DATA_DIR/$webFolder/etc
mkdir -m 755 $WEB_DATA_DIR/$webFolder/logs
mkdir -m 755 $WEB_DATA_DIR/$webFolder/www
chown root:wheel $WEB_DATA_DIR/$webFolder/etc
chown root:wheel $WEB_DATA_DIR/$webFolder/logs
chown $ftpUsername:$ftpUsername $WEB_DATA_DIR/$webFolder/www
chmod g+s $WEB_DATA_DIR/$webFolder/www
expect $SETPWD_DIR/setpwd "$ftpUsername" "$ftpPassword"

if [ -n "`echo $webAddress | cut -d '/' -f 2 -s | tr -d ' '`" ]; then
    ln -s $webTarget$webFolder/www $WEB_DATA_DIR`echo $webAddress | cut -d '/' -f 1 | tr -d
    ' '`/www/`echo $webAddress | cut -d '/' -f2-`
fi

echo "MySQL hesabi olusturuluyor..."
echo "CREATE USER $sqlUsername@'%';\nSET PASSWORD FOR ${sqlUsername}@'%' = PASSWORD('${sqlPassword}');\nCREATE DATABASE ${sqlDatabase};\nGRANT ALL PRIVILEGES ON ${sqlDatabase}.* TO ${sqlUsername}@'%';\nFLUSH PRIVILEGES;" | $MYSQL_CLIENT $MYSQL_OPTION -h$MYSQL_HOSTNAME -u$MYSQL_USERNAME -p$MYSQL_PASSWORD

echo "Hesap bilgi e-postasi gonderiliyor..."
$MAIL_SCRIPT_DIR/send-new-account-mail.sh "$ftpUsername" "$sqlUsername" "$sqlPassword" "$sqlDatabase" "$contactEmail" "$webAddress" "$ftpPassword"



apacheConf="$APACHE_CONF_DIR/$webDomain.conf"

if [ -f "$apacheConf" ]; then
        rm "$apacheConf"
fi

touch "$apacheConf"
chown root:wheel "$apacheConf"
chmod 644 "$apacheConf"

echo "<VirtualHost *:80>" >>$apacheConf
echo "# The ServerName directive sets the request scheme, hostname and port that" >>$apacheConf
echo "# the server uses to identify itself. This is used when creating" >>$apacheConf
echo "# redirection URLs. In the context of virtual hosts, the ServerName" >>$apacheConf
echo "# specifies what hostname must appear in the request's Host: header to" >>$apacheConf
echo "# match this virtual host. For the default virtual host (this file) this" >>$apacheConf
echo "# value is not decisive as it is used as a last resort host regardless." >>$apacheConf
echo "# However, you must set it for any further virtual host explicitly." >>$apacheConf
echo "# ServerName www.example.com" >>$apacheConf
echo "    ServerName  $webDomain.deu.edu.tr" >>$apacheConf
echo "    ServerAlias  www.$webDomain.deu.edu.tr" >>$apacheConf
echo "    DocumentRoot $WEB_DATA_DIR/$webDomain.deu.edu.tr" >>$apacheConf
echo "    DirectoryIndex index.html index.htm index.php" >>$apacheConf
echo "    ErrorLog  $ERRORLOG_DIR/$webDomain.deu.edu.tr-error_log" >>$apacheConf
echo "    CustomLog $ERRORLOG_DIR/$webDomain.deu.edu.tr-access_log common" >>$apacheConf
echo "    #" >>$apacheConf
echo "    # Per virtual host PHP settings:" >>$apacheConf
echo "    #" >>$apacheConf
echo "    php_admin_value open_basedir "/dev/:/tmp/:$WEB_DATA_DIR/$webDomain.deu.edu.tr"" >>$apacheConf
echo "    php_flag display_errors off" >>$apacheConf
echo "	" >>$apacheConf
echo "	<files xmlrpc.php>" >>$apacheConf
echo "    	order allow,deny" >>$apacheConf
echo "    	deny from all" >>$apacheConf
echo "    </files>" >>$apacheConf
echo "" >>$apacheConf
echo "	<Directory $WEB_DATA_DIR/$webDomain.deu.edu.tr/>" >>$apacheConf
echo "		Options Indexes FollowSymLinks MultiViews" >>$apacheConf
echo "		AllowOverride all" >>$apacheConf
echo "		Order allow,deny" >>$apacheConf
echo "		allow from all" >>$apacheConf
echo "	</Directory>" >>$apacheConf
echo "	# Available loglevels: trace8, ..., trace1, debug, info, notice, warn," >>$apacheConf
echo "	# error, crit, alert, emerg." >>$apacheConf
echo "	# It is also possible to configure the loglevel for particular" >>$apacheConf
echo "	# modules, e.g." >>$apacheConf
echo "	#LogLevel info ssl:warn" >>$apacheConf
echo "" >>$apacheConf
echo "	#ErrorLog ${APACHE_LOG_DIR}/error.log" >>$apacheConf
echo "	#CustomLog ${APACHE_LOG_DIR}/access.log combined" >>$apacheConf
echo "" >>$apacheConf
echo "	# For most configuration files from conf-available/, which are" >>$apacheConf
echo "	# enabled or disabled at a global level, it is possible to" >>$apacheConf
echo "	# include a line for only one particular virtual host. For example the" >>$apacheConf
echo "	# following line enables the CGI configuration for this host only" >>$apacheConf
echo "	# after it has been globally disabled with "a2disconf"." >>$apacheConf
echo "	#Include conf-available/serve-cgi-bin.conf" >>$apacheConf
echo "	<IfModule mod_security2.c>" >>$apacheConf
echo "		SecRequestBodyNoFilesLimit 5242880" >>$apacheConf
echo "	</IfModule>" >>$apacheConf
echo "</VirtualHost>" >>$apacheConf

a2ensite $webDomain.conf
service apache2 reload

echo -e "${GREEN} ISLEM BASARILI${SET}"
