#!/bin/bash
clear
stty erase '^?'

OSREQUIREMENT=`awk '/Ubuntu 8.04.3 LTS/ {print $0}' /etc/issue`
#Ubuntu 8.04.3 LTS \n \l

if [ -z "$OSREQUIREMENT" ];
then
   echo "This program must be executed on Ubuntu 8.04.3 LTS Server or Desktop"
   exit 1
fi

if [ -x /usr/sbin/apache2 ] ; then
        echo "Apache package already installed. This script cannot be run"
        exit 0 
fi

if [ -x /etc/apache2 ] ; then
        echo "/etc/apache2 already exists. This script cannot be run"
        exit 0
fi

if [ -x /var/lib/postgresql ] ; then
        echo "Postgres already installed. This script cannot be run"
        exit 0
fi


echo "Do you want to upgrade Ubuntu's System Packages? (Y/n)"
echo "Press Enter for default one (y)"
read SYSTEMUPGRADE
if [ -z "$SYSTEMUPGRADE" ];
then
SYSTEMUPGRADE=y
fi
echo "\"your answer is\" = "$SYSTEMUPGRADE""


echo "---------------------------------------------------------------------"
echo "Enter DNS name for your URL: "
echo "Press ENTER for default one (openerpweb.com)"
read url
if [ -z "$url" ]
then
url=openerpweb.com
fi
echo "\"your DNS name is\" = "$url""

echo
echo "---------------------------------------------------------------------"
echo "Modifying /etc/hosts file."
#!/bin/bash
for lang in `/sbin/ifconfig  | grep 'inet '| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}'`;
do
array=( "${array[@]}" "$lang" )
done

echo "List of IP addresses already configured on your Ubuntu system:"
echo "-------------------------------------------------------------"
echo
element_count=${#array[@]}
# Special syntax to extract number of elements in array.
index=0
echo   "Index Number	IP address"
echo   ---------------------------------
while [ "$index" -lt "$element_count" ];
do    # List all the elements in the array.
  echo "   $index)		${array[$index]}"
  #    ${array[index]} also works because it's within ${ ... } brackets.
  let "index+=1"
done

if [ $element_count -lt 1 ];
then
echo -------------------------------------------------------------------------------------
echo "No IP addresses available on your Ubuntu !!"
echo "At least one IP address configured on Ubuntu is required. Script execution aborted."
echo -------------------------------------------------------------------------------------
read -p "Press any key to continue…"
exit
else 
# IP addresses available on the system
IPnumber=100
array[$IPnumber]=${array[0]}
while [ $IPnumber -ge $element_count -o $IPnumber -lt 0 ];
do
echo
echo "--------------------------------------------------------------------"
echo "Please select one IP address for your OpenERP service:  "
echo "Type the index number"
echo "Press ENTER for default one (${array[0]})"
echo "--------------------------------------------------------------------"
read IPnumber
#get the numerical values from a string of letters and numbers
IPnumber=`echo "$IPnumber" | sed 's#[^[:digit:]]##g'`
if [ -z "$IPnumber" ];
then
array[0]=${array[0]}
break
fi
echo
done
ipaddrvar=${array[$IPnumber]}
fi
echo "\"your IP address is\" = "$ipaddrvar""
read -p "Press any key to continue…"

echo
echo "---------------------------------------------------------------------------"
echo "Please enter the Administrator Password                                    "
echo "You will need to remember this password to administer your OpenERP database"
echo "Press ENTER for default one (openerp)"
echo "---------------------------------------------------------------------------"
read passwvar
if [ -z "$passwvar" ];
then
passwvar=openerp
fi
echo "\"your Administrator Password is\" = "$passwvar""

PATH=/usr/bin:/sbin:/bin:/usr/sbin

#/usr/sbin/adduser --no-create-home --quiet --system openerp (ubuntu)
sudo /usr/sbin/adduser --quiet --system openerp
#/usr/sbin/adduser -m -r -s /bin/bash openerp (RHEL)


sudo apt-get install wget -y
cd /opt
sudo wget http://www.openerp.com/download/stable/source/openerp-server-5.0.3.tar.gz
sudo wget http://www.openerp.com/download/stable/source/openerp-client-5.0.3.tar.gz
sudo wget http://www.openerp.com/download/stable/source/openerp-web-5.0.3.tar.gz
sudo tar xvzf openerp-server-5.0.3.tar.gz;sudo tar xvzf openerp-client-5.0.3.tar.gz;sudo tar xvzf openerp-web-5.0.3.tar.gz

sudo apt-get update
if [ "$SYSTEMUPGRADE" = "y" ]; then
   sudo apt-get upgrade -y
fi


sudo apt-get install -y python python-dev build-essential python-setuptools python-psycopg2 python-reportlab python-egenix-mxdatetime python-tz python-pychart python-pydot python-lxml python-libxslt1 python-vobject graphviz python-xml python-libxml2 python-imaging bzr
# openerp-client requirements:
sudo apt-get install -y python-gtk2 python-glade2 xpdf 
# Matplotlib & hippocanvas still required by openerp-client (not listed as a dependency for the package):
sudo apt-get install -y python-matplotlib python-hippocanvas
# Ubuntu 8.04.3 LTS Server requires xauth binary to remotely display linux applications like openerp-client:
sudo apt-get install -y xauth

sudo apt-get install postgresql-8.3 postgresql-client-8.3 pgadmin3 -y
#sudo apt-get install postgresql-8.3 postgresql-client-8.3 -y

#Postgres Database configuration:
#sudo vi /etc/postgresql/8.3/main/pg_hba.conf
#Replace the following line:
    ## “local” is for Unix domain socket connections only
    #local all all ident sameuser
#with:
    ##”local” is for Unix domain socket connections only
    #local all all md5
sudo sed -i 's/\(local[[:space:]]*all[[:space:]]*all[[:space:]]*\)\(ident[[:space:]]*sameuser\)/\1md5/g' /etc/postgresql/8.3/main/pg_hba.conf

#Restart Postgres:
sudo /etc/init.d/postgresql-8.3 restart

#Create a user account called openerp with password “openerp” and with privileges to create Postgres databases:
#sudo su postgres
#createuser openerp -P
#    Enter password for new role: (openerp)
#    Enter it again:
#    Shall the new role be a superuser? (y/n) n
#    Shall the new role be allowed to create databases? (y/n) y
#    Shall the new role be allowed to create more new roles? (y/n) n
sudo -u postgres createuser openerp --no-superuser --createdb --no-createrole 
sudo -u postgres psql template1 -U postgres -c "alter user openerp with password '$passwvar'"

cd /opt/openerp-server-5.0.3
sudo python setup.py install
cd /opt/openerp-client-5.0.3
sudo python setup.py install
cd /opt/openerp-web-5.0.3
sudo python setup.py install
cd /opt

#####################
# Extending Open ERP
# To extend Open ERP you’ll need to copy modules into the addons directory. That’s in your server’s openerp-server directory (which differs between Windows, 
# Mac and some of the various Linux distributions and not available at all in the Windows all-in-one installer).
# You can add modules in two main ways – through the server, or through the client.
# To add new modules through the server is a conventional systems administration task. As rootuser or other suitable user, you’d put the module in the 
# addons directory and change its permissions to match those of the other modules.
# To add new modules through the client you must first change the permissions of the addonsdirectory of the server, so that it is writable by the server. 
# That will enable you to install Open ERP modules using the Open ERP client (a task ultimately carried out on the application server by the server software).
#
sudo chmod 777 /usr/lib/python2.5/site-packages/openerp-server/addons
#
#####################################################################################
# openerp-server init script
#####################################################################################
cat > /tmp/openerp-server <<"EOF"
#!/bin/sh

### BEGIN INIT INFO
# Provides:		openerp-server
# Required-Start:	$syslog
# Required-Stop:	$syslog
# Should-Start:		$network
# Should-Stop:		$network
# Default-Start:	2 3 4 5
# Default-Stop:		0 1 6
# Short-Description:	Enterprise Resource Management software
# Description:		OpenERP is a complete ERP and CRM software.
### END INIT INFO

PATH=/sbin:/bin:/usr/sbin:/usr/bin
DAEMON=/usr/bin/openerp-server
NAME=openerp-server
DESC=openerp-server
USER=openerp

test -x ${DAEMON} || exit 0

set -e

case "${1}" in
	start)
		echo -n "Starting ${DESC}: "

		start-stop-daemon --start --quiet --pidfile /var/run/${NAME}.pid \
			--chuid ${USER} --background --make-pidfile \
			--exec ${DAEMON} -- --config=/etc/openerp-server.conf

		echo "${NAME}."
		;;

	stop)
		echo -n "Stopping ${DESC}: "

		start-stop-daemon --stop --quiet --pidfile /var/run/${NAME}.pid \
			--oknodo

		echo "${NAME}."
		;;

	restart|force-reload)
		echo -n "Restarting ${DESC}: "

		start-stop-daemon --stop --quiet --pidfile /var/run/${NAME}.pid \
			--oknodo

		sleep 1

		start-stop-daemon --start --quiet --pidfile /var/run/${NAME}.pid \
			--chuid ${USER} --background --make-pidfile \
			--exec ${DAEMON} -- --config=/etc/openerp-server.conf

		echo "${NAME}."
		;;

	*)
		N=/etc/init.d/${NAME}
		echo "Usage: ${NAME} {start|stop|restart|force-reload}" >&2
		exit 1
		;;
esac

exit 0

EOF

sudo cp /tmp/openerp-server /etc/init.d/
sudo chmod +x /etc/init.d/openerp-server
#Create /var/log/openerp with proper ownership:
sudo mkdir -p /var/log/openerp
sudo touch /var/log/openerp/openerp.log
sudo chown -R openerp.root /var/log/openerp/

#####################################################################################
# openerp-server config file
#####################################################################################
cat > /tmp/openerp-server.conf <<"EOF2"
# /etc/openerp-server.conf(5) - configuration file for openerp-server(1)

[options]
# Enable the debugging mode (default False).
#verbose = True 

# The file where the server pid will be stored (default False).
#pidfile = /var/run/openerp.pid

# The file where the server log will be stored (default False).
logfile = /var/log/openerp/openerp.log

# The IP address on which the server will bind.
# If empty, it will bind on all interfaces (default empty).
#interface = localhost
interface = 
# The TCP port on which the server will listen (default 8069).
port = 8069

# Enable debug mode (default False).
#debug_mode = True 

# Launch server over https instead of http (default False).
secure = False

# Specify the SMTP server for sending email (default localhost).
smtp_server = localhost

# Specify the SMTP user for sending email (default False).
smtp_user = False

# Specify the SMTP password for sending email (default False).
smtp_password = False

# Specify the database name.
db_name =

# Specify the database user name (default None).
db_user = openerp

# Specify the database password for db_user (default None).
db_password = 

# Specify the database host (default localhost).
db_host =

# Specify the database port (default None).
db_port = 5432

EOF2

sudo cp /tmp/openerp-server.conf /etc/
sudo chown openerp.root /etc/openerp-server.conf
sudo chmod 640 /etc/openerp-server.conf

sudo sed -i "s/db_password =/db_password = $passwvar/g" /etc/openerp-server.conf

#####################################################################################
# openerp-web init script
#####################################################################################

sudo cp /usr/lib/python2.5/site-packages/openerp_web-5.0.3-py2.5.egg/scripts/openerp-web /etc/init.d/
sudo chmod +x /etc/init.d/openerp-web
sudo cp /usr/lib/python2.5/site-packages/openerp_web-5.0.3-py2.5.egg/config/openerp-web.cfg /etc/
#ln -s /usr/lib/python2.5/site-packages/openerp_web-5.0.3-py2.5.egg/config/openerp-web.cfg /etc/openerp-web.cfg
sudo chown openerp.root /etc/openerp-web.cfg
sudo chmod 640 /etc/openerp-web.cfg

#OpenERP Web configuration:
#    tools.proxy.on = True
sudo sed -i "s/^#tools\.proxy\.on.*/tools.proxy.on = True/g" /etc/openerp-web.cfg 

#Create /var/log/openerp-web.log with proper ownership:
sudo mkdir -p /var/log/openerp-web
sudo touch /var/log/openerp-web/access.log
sudo touch /var/log/openerp-web/error.log
sudo chown -R openerp.root /var/log/openerp-web/

#Now run following command to start the OpenERP Web automatically on system startup (Debian/Ubuntu):
sudo update-rc.d openerp-server start 21 2 3 4 5 . stop 21 0 1 6 .
sudo update-rc.d openerp-web start 70 2 3 4 5 . stop 20 0 1 6 .

############################################################################################
#HTTPS and Proxy with Apache
sudo apt-get -y install apache2

############################################################################################
# /etc/apache2/sites-available/default-ssl (Available in Ubuntu9.04, but not in Ubuntu8.04)
# apache2-ssl-certificate script/package is missing in Ubuntu8.04
############################################################################################

cat > /tmp/default <<"EOF3"
NameVirtualHost *:80
<VirtualHost *:80>
        ServerAdmin webmaster@localhost
        ServerName openerpweb.com
        Redirect / https://openerpweb.com/

        DocumentRoot /var/www/
        <Directory />
                Options FollowSymLinks
                AllowOverride None
        </Directory>
        <Directory /var/www/>
                Options Indexes FollowSymLinks MultiViews
                AllowOverride None
                Order allow,deny
                allow from all
        </Directory>

        ScriptAlias /cgi-bin/ /usr/lib/cgi-bin/
        <Directory "/usr/lib/cgi-bin">
                AllowOverride None
                Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch
                Order allow,deny
                Allow from all
        </Directory>

        ErrorLog /var/log/apache2/error.log

        # Possible values include: debug, info, notice, warn, error, crit,
        # alert, emerg.
        LogLevel warn

        CustomLog /var/log/apache2/access.log combined
        ServerSignature On

    Alias /doc/ "/usr/share/doc/"
    <Directory "/usr/share/doc/">
        Options Indexes MultiViews FollowSymLinks
        AllowOverride None
        Order deny,allow
        Deny from all
        Allow from 127.0.0.0/255.0.0.0 ::1/128
    </Directory>

</VirtualHost>
EOF3

sudo cp /tmp/default /etc/apache2/sites-available/default
sudo chown root.root /etc/apache2/sites-available/default
sudo chmod 644 /etc/apache2/sites-available/default

cat > /tmp/default-ssl <<"EOF4"
NameVirtualHost *:443
<VirtualHost *:443>
	ServerName openerpweb.com
        ServerAdmin webmaster@localhost
	#DocumentRoot /var/www/
	SSLEngine on
	SSLCertificateFile /etc/apache2/ssl/apache.pem
	<Proxy *>
	  Order deny,allow
	  Allow from all
	</Proxy>
	ProxyRequests Off
	ProxyPass        /   http://127.0.0.1:8080/
	ProxyPassReverse /   http://127.0.0.1:8080/

        RequestHeader set "X-Forwarded-Proto" "https"

        # Fix IE problem (http error 408/409)
        SetEnv proxy-nokeepalive 1

        ErrorLog /var/log/apache2/error-ssl.log
        # Possible values include: debug, info, notice, warn, error, crit,
        # alert, emerg.
        LogLevel warn
        CustomLog /var/log/apache2/access-ssl.log combined
        ServerSignature On
</VirtualHost>
EOF4

sudo cp /tmp/default-ssl /etc/apache2/sites-available/default-ssl
sudo chown root.root /etc/apache2/sites-available/default-ssl
sudo chmod 644 /etc/apache2/sites-available/default-ssl

sudo mkdir /etc/apache2/ssl
sudo /usr/sbin/make-ssl-cert /usr/share/ssl-cert/ssleay.cnf /etc/apache2/ssl/apache.pem

# Apache Modules:
sudo a2enmod ssl
# We enable default-ssl site after creating "/etc/apache2/sites-available/default-ssl" file (not available in Ubuntu8.04)
sudo a2ensite default-ssl
sudo a2enmod rewrite
sudo a2enmod suexec
sudo a2enmod include
sudo a2enmod proxy
sudo a2enmod proxy_http
sudo a2enmod proxy_connect
sudo a2enmod proxy_ftp
sudo a2enmod headers

#Add your server’s IP address and URL in /etc/hosts:
#    $ sudo vi /etc/hosts
#Replace
#    127.0.0.1 localhost
#    127.0.0.1 yourhostname yourhostnamealias
#With
#
#    127.0.0.1 localhost
#    192.168.x.x openerpweb.com yourhostname yourhostnamealias
sudo sed -i "s/\(^127\.0\.1\.1[[:space:]]*\)\([[:alnum:]].*\)/#\0\n$ipaddrvar $url \2/g" /etc/hosts

sudo sed -i "s/openerpweb\.com/$url/g" /etc/apache2/sites-available/default
sudo sed -i "s/openerpweb\.com/$url/g" /etc/apache2/sites-available/default-ssl

sudo /etc/init.d/apache2 restart

# FIREWALL:
sudo ufw enable
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https
# OpenERP port (GTK client):
sudo ufw allow 8069/tcp 
# OpenERP port (GTK client):
sudo ufw allow 8070/tcp 

sudo /etc/init.d/openerp-server start
sudo /etc/init.d/openerp-web start


#########################################################################################################
# This code makes links in your Desktop for openerp-client and openerpweb URL (only on Ubuntu Desktop):
#########################################################################################################
`dpkg-query -W -f='${Status}\n' xdg-user-dirs > /tmp/dpkg-query.txt`
UBUNTUDESKTOPINSTALLED=`awk '/install ok installed/ {print $0}' /tmp/dpkg-query.txt`
if [ -n "$UBUNTUDESKTOPINSTALLED" ];
then
MYDESKTOP=`xdg-user-dir DESKTOP`
cat > $MYDESKTOP/openerp-client.desktop <<"EOF5"
[Desktop Entry]
Version=1.0
Encoding=UTF-8
Name=openerp-client
Type=Application
Terminal=false
Name[es_ES]=openerp-client
Exec=/usr/bin/openerp-client
Comment[es_ES]=OpenERP GTK client
Comment=OpenERP GTK client
GenericName[en_US]=
EOF5
cat > $MYDESKTOP/OpenERPweb.desktop <<"EOF6"
[Desktop Entry]
Version=1.0
Encoding=UTF-8
Name=link to OpenERP Web
Type=Link
URL=http://openerpweburl
Icon=gnome-fs-bookmark
EOF6
sed -i "s/openerpweburl/$url/g" $MYDESKTOP/OpenERPweb.desktop
READMEPATH=$MYDESKTOP
else
READMEPATH=$HOME
fi

clear
echo | tee -a $READMEPATH/OpenERP-README.txt
echo "------------------------------------------------------------------------------------------------------------------------------------------------" | tee -a $READMEPATH/OpenERP-README.txt
echo " THE REMAINING STEPS CAN BE CONFIGURED FROM THE WEB INTERFACE (OPENERP WEB)" | tee -a $READMEPATH/OpenERP-README.txt
echo | tee -a $READMEPATH/OpenERP-README.txt
echo " 1. Register the DNS Name \"$url\" with its corresponding IP address ($ipaddrvar)." | tee -a $READMEPATH/OpenERP-README.txt
echo "   \"$url\" is the external URL of OpenERP Web. Make sure this URL is reachable by your Web clients (Open ERP users)" | tee -a $READMEPATH/OpenERP-README.txt
echo "    In Linux this can be done locally by adding the following line to /etc/hosts file:" | tee -a $READMEPATH/OpenERP-README.txt
echo | tee -a $READMEPATH/OpenERP-README.txt
echo "    	$ipaddrvar $url" | tee -a $READMEPATH/OpenERP-README.txt
echo | tee -a $READMEPATH/OpenERP-README.txt
echo "    The hosts file is located in different locations in different operating systems and versions: \"http://en.wikipedia.org/wiki/Hosts_file\"" | tee -a $READMEPATH/OpenERP-README.txt
echo "    The hosts file is a computer file used to store information on where to find a node on a computer network. " | tee -a $READMEPATH/OpenERP-README.txt
echo "    This file maps hostnames to IP addresses. The hosts file is used as a supplement to (or a replacement of) the Domain Name System (DNS) on " | tee -a $READMEPATH/OpenERP-README.txt
echo "    networks of varying sizes. Unlike DNS, the hosts file is under the control of the local computer's administrator" | tee -a $READMEPATH/OpenERP-README.txt
echo | tee -a $READMEPATH/OpenERP-README.txt
echo " 2. Your OpenERP Web Service can now be reached with a web browser at: \"http://$url\"" | tee -a $READMEPATH/OpenERP-README.txt
echo | tee -a $READMEPATH/OpenERP-README.txt
echo " 3. WELCOME TO OPENERP: -> Click on \"Databases\" -> CREATE A NEW DATABASE:" | tee -a $READMEPATH/OpenERP-README.txt
echo "    3.1  Super Administrator Password: admin" | tee -a $READMEPATH/OpenERP-README.txt
echo "    3.2  New Name of the database: xxx " | tee -a $READMEPATH/OpenERP-README.txt
echo "    3.3  Load Demo Data (y/n)" | tee -a $READMEPATH/OpenERP-README.txt
echo "    3.4  Default language: ... " | tee -a $READMEPATH/OpenERP-README.txt
echo "    3.5  Administrator Password: $passwvar" | tee -a $READMEPATH/OpenERP-README.txt
echo "    3.6  Confirm Administrator Password: $passwvar" | tee -a $READMEPATH/OpenERP-README.txt
echo  | tee -a $READMEPATH/OpenERP-README.txt
echo " 4. WELCOME TO OPENERP:" | tee -a $READMEPATH/OpenERP-README.txt
echo "    4.1 Database: xxx " | tee -a $READMEPATH/OpenERP-README.txt
echo "    4.2 Administrator Username: admin " | tee -a $READMEPATH/OpenERP-README.txt
echo "    4.3 Administrator Password: $passwvar" | tee -a $READMEPATH/OpenERP-README.txt
echo "    4.4 Click on \"Login\"" | tee -a $READMEPATH/OpenERP-README.txt
echo | tee -a $READMEPATH/OpenERP-README.txt
echo " 5. INSTALLATION & CONFIGURATION. You will now be asked to install and configure modules and users required by your Enterprise" | tee -a $READMEPATH/OpenERP-README.txt
echo "    5.1 Click on \"Logout\"" | tee -a $READMEPATH/OpenERP-README.txt
echo | tee -a $READMEPATH/OpenERP-README.txt
echo " 6. WELCOME TO OPENERP: You can now log in with the following users" | tee -a $READMEPATH/OpenERP-README.txt
echo "    6.1 User \"demo\" / Password \"demo\", in case you clicked on \"Load Demo Data\"" | tee -a $READMEPATH/OpenERP-README.txt
echo "    6.2 User \"admin\" / Password \"$passwvar\"" | tee -a $READMEPATH/OpenERP-README.txt
echo "    6.3 Users created by you during step #4" | tee -a $READMEPATH/OpenERP-README.txt
echo "------------------------------------------------------------------------------------------------------------------------------------------------" | tee -a $READMEPATH/OpenERP-README.txt
echo " Notes:" | tee -a $READMEPATH/OpenERP-README.txt
echo "    * OpenERP GTK Client can be run as non-root with the command \"openerp-client\"" | tee -a $READMEPATH/OpenERP-README.txt
echo "        (Make sure you enable X11 Forwarding on your SSH remote session)" | tee -a $READMEPATH/OpenERP-README.txt
echo "    * Ports 8069 & 8070 are open for remote access of OpenERP GTK clients " | tee -a $READMEPATH/OpenERP-README.txt
echo | tee -a $READMEPATH/OpenERP-README.txt