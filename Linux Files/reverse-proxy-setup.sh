#!/bin/bash
apt install -y htop vim curl git openssh-client openssl apache2 snapd ufw
snap install core
snap refresh core
snap install --classic certbot
ln -s /snap/bin/certbot /usr/bin/certbot
sed -i 's/#\?\(Port\s*\).*$/\1 2222/' /etc/ssh/sshd_config
sed -i 's/#\?\(PerminRootLogin\s*\).*$/\1 yes/' /etc/ssh/sshd_config
/etc/init.d/ssh restart
echo -e "┌─────────────────────────────────────────────────────────────┐"
echo -e "│ Bitte waehle eine der folgenden Zahlen aus:"
echo -e "                                                              \e[1A│"
echo -e "│  [\e[36m1\e[39m] fuer DHCP"
echo -e "                                                              \e[1A│"
echo -e "│  [\e[36m2\e[39m] fuer eine statische Netzwerkkonfiguration"
echo -e "└─────────────────────────────────────────────────────────────┘"
read -rp "Auswahl: " menu
case $menu in
    1)
        tee -a "/etc/network/interfaces" > /dev/null <<EOF
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
allow-hotplug eth0
iface eth0 inet dhcp
EOF
    ;;
    2)
        echo "Bitte gebe die gewuenschte IP fuer den Reverse-Proxy ein:"
        read -rp "IP: " ip
        echo "Bitte gebe die gewuenschte Subnetzmaske ein:"
        read -rp "Subnetz: " subnet
        echo "Bitte gebe das gewuenschte Gateway ein:"
        read -rp "Gateway: " gateway
        echo "Bitte gebe den gewuenschten lokalen DNS ein:"
        read -rp "DNS: " dns
        tee -a "/etc/network/interfaces" > /dev/null <<EOF
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
allow-hotplug eth0
iface eth0 inet static
adress $ip
netmask $subnet
gateway $gateway
dns-nameservers $dns
EOF
    ;;
    *)
        echo "Falsche Eingabe, Skript wird abgebrochen..."
        exit 1
    ;;
esac

echo "Bitte gebe den gewuenschten FQDN ein:"
read -rp "FQDN: " fqdn
echo "Bitte gebe die gewünschte Ziel-IP-Adresse für die Weiterleitung ein:"
read -rp "Ziel-IP: " webserver
echo "Bitte gebe den gewünschten Ziel-Port für die Weiterleitung ein:"
read -rp "Ziel-Port: " port
a2enmod rewrite
a2enmod headers
a2enmod proxy
a2enmod proxy_http
systemctl restart apache2
mv /etc/apache2/sites-enabled/000-default.conf /etc/apache2/sites-enabled/"$fqdn".conf
tee -a "/etc/network/interfaces" > /dev/null <<EOF
<VirtualHost *:443>
	ServerName $fqdn
	ErrorLog ${APACHE_LOG_DIR}/$fqdn-error.log
	CustomLog ${APACHE_LOG_DIR}/$fqdn-access.log combined	
	SSLEngine on

	ProxyRequests Off
	ProxyPass / http://$webserver:$port/
	ProxyPassReverse / http://$webserver:$port/
	
	# Let's Encrypt SSL Config
	SSLCertificateFile /etc/letsencrypt/live/$fqdn/fullchain.pem
	SSLCertificateKeyFile /etc/letsencrypt/live/$fqdn/privkey.pem
	Include /etc/letsencrypt/options-ssl-apache.conf
</VirtualHost>

<VirtualHost *:80>
ServerName $fqdn
RewriteEngine on
RewriteCond %{SERVER_NAME} =$fqdn
RewriteRule ^ https://%{SERVER_NAME}%{REQUEST_URI} [END,NE,R=permanent]
</VirtualHost>
EOF
apache2ctl reload
certbot --apache -d "$fqdn"
