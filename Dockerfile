FROM nginx:alpine
ENV SFTP_PASSWORD=""
#supported arguments
ARG SFTP_USER
ARG SFTP_PASSWORD
#true or false, so that user will be restricted to use only sftp
ARG SFTP_ONLY 

RUN apk update \
      && apk add \
      openssh \
      php7 \
      php7-fpm \
      php7-gd \
      php7-mysqli \
      php7-zlib \
      php7-curl

COPY ./src /usr/share/nginx/html/
COPY ./image-setup/ /tmp/image-setup/

RUN chmod +x /tmp/image-setup/init.sh
RUN /tmp/image-setup/init.sh

#additional exposed port
EXPOSE 22
CMD [ "entrypoint.sh" ]