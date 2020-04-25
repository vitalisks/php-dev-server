#customization variables
DEFAULT_SFTP_ONLY="true"
DEFAULT_SFTP_USERNAME="webupload"

#check and initalize default values
if [ -z "$SFTP_ONLY" ]
then
    #default mode
    SFTP_ONLY="$DEFAULT_SFTP_ONLY"
    echo "Using default sft_only=$SFTP_ONLY"
fi
if [ -z "$SFTP_USER" ]
then
    #default user
    SFTP_USER="$DEFAULT_SFTP_USERNAME"
    echo "Using default SFTP_USER=$SFTP_USER"
fi


echo "Starting build of the image"
cd /tmp/image-setup
#copy trustable https apk repositories
cp ./config/nginx.conf /etc/nginx/conf.d/default.conf
cp ./config/apk_repositories /etc/apk/repositories

#create entrypoint script
echo "#!bin/sh" > /usr/sbin/entrypoint.sh
#allow to override password if environment variable is provided during the container startup
echo "if [ ! -f ~/initdone ] && [ -n \"\$SFTP_PASSWORD\" ]" >> /usr/sbin/entrypoint.sh
echo "then" >> /usr/sbin/entrypoint.sh
echo "  (echo \$SFTP_PASSWORD;echo \$SFTP_PASSWORD) | passwd $SFTP_USER " >> /usr/sbin/entrypoint.sh
echo "  touch ~/initdone" >> /usr/sbin/entrypoint.sh
echo "fi" >> /usr/sbin/entrypoint.sh
#main startup services: ssh, http, php
echo "/usr/sbin/sshd" >> /usr/sbin/entrypoint.sh
echo "/usr/sbin/php-fpm7" >> /usr/sbin/entrypoint.sh
echo "/usr/sbin/nginx -g 'daemon off;'" >> /usr/sbin/entrypoint.sh
chmod +x /usr/sbin/entrypoint.sh

#generate host keys
ssh-keygen -A
#create user to access and set inital password
adduser -h /usr/share/nginx -D $SFTP_USER
#set user as owner to of nginx server root
chown root:root /usr/share/nginx
chown -R $SFTP_USER:$SFTP_USER /usr/share/nginx/html

#init image password if set during the build
if [ -n "$SFTP_PASSWORD" ]
then
    #set user password    
    (echo $SFTP_PASSWORD;echo $SFTP_PASSWORD) | passwd $SFTP_USER     
else
    echo "Password for $SFTP_USER not set. Login will not be available."
fi

#comment this section if you want to enable ssh access to allow user password change
if [ $SFTP_ONLY = "true" ]
then  
  echo "Match user ${SFTP_USER}" >> /etc/ssh/sshd_config
  echo "ForceCommand internal-sftp">>/etc/ssh/sshd_config
  echo "ChrootDirectory %h" >> /etc/ssh/sshd_config
  echo "X11Forwarding no" >> /etc/ssh/sshd_config
  echo "AllowTcpForwarding no" >> /etc/ssh/sshd_config
fi
#remote image setup folder
rm /tmp/image-setup -rf
echo "Image build complete"