# Compact SFTP, HTTP, PHP7

Compact Alpine-based container using openssh-sftp-server with built in http server and php7.

The intended usage is to get up and running http server with scripting engine and sftp access (php7 included) for easy access over the network.

# Usage

- Build docker image by specifying --build-arg parameters or fill them in the `docker-compose.yml`
  - `SFTP_ONLY` - `true` or `false`. ssh access is enabled for `false` value. Default is `true`.
  - `SFTP_USERNAME` - specify username, which will be setup during the build of the image. Default is `webupload`
  - `SFTP_PASSWORD` - initial password for the created user, which later can be changed using `docker exec` or `passwd` by the sftp user if ssh access was enabled. Default is **not set** so required to provide during the image build or container startup `-e 'SFTP_PASSWORD='`
- Image initialization
  - Image is initilized using init.sh script, which creates default user and assigns password if provided in the build arguments
  - keys are automatically generated using `ssh-keygen -A`
  - php can be excluded by modifying 
    - nginx.conf - cgi configuration
    - init.sh - exclude from startup
    - Dockerfile - exclude packages
 
# Examples
All examples provided without a default password due to security reasons.
- Build
  - `docker build -t mydefaultimage:mydefaulttag . --build-arg SFTP_USER=myuser --build-arg SFTP_PASSWORD= --build-arg SFTP_ONLY=true`
- Run
  - Without password change `docker run --name mywebserver -p 9080:8080 -p 9022:22 mydefaultimage:mydefaulttag`
  - With password change `docker run --name mywebserver -p 9080:8080 -p 9022:22 -e 'SFTP_PASSWORD=' mydefaultimage:mydefaulttag`
- docker-compose
  - default open ports 7080 (http), 7022 (ssh, sftp) 
  - mounted volume `http-volume`
  - default memory limit to **50M**
