# Use Ubuntu 20.04 as the base image
FROM ubuntu:20.04

# Set noninteractive mode during build
ARG DEBIAN_FRONTEND=noninteractive

# Install software-properties-common to get add-apt-repository
RUN apt-get update && \
    apt-get install -y software-properties-common

# Install additional packages
RUN apt-get update && \
    apt-get install -y \
	apache2 \
	php7.4 \
        graphviz \
        aspell \
        ghostscript \
        clamav \
        php7.4-pspell \
        php7.4-curl \
        php7.4-gd \
        php7.4-intl \
        php7.4-mysql \
        php7.4-xml \
        php7.4-xmlrpc \
        php7.4-ldap \
        php7.4-zip \
        php7.4-soap \
	apache2-utils \
        php7.4-mbstring && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*


# Update Apache configuration for error logs
RUN sed -i 's/ErrorLog ${APACHE_LOG_DIR}\/error.log/ErrorLog "|\/usr\/bin\/rotatelogs ${APACHE_LOG_DIR}\/errorlog.%Y-%m-%d-%H_%M_%S 5M"/' /etc/apache2/sites-enabled/000-default.conf && \
    sed -i 's/CustomLog ${APACHE_LOG_DIR}\/access.log combined/CustomLog "|\/usr\/bin\/rotatelogs -l ${APACHE_LOG_DIR}\/logfile.%Y.%m.%d 86400" common/' /etc/apache2/sites-enabled/000-default.conf

# Update security configuration
RUN echo 'ServerTokens Prod' >> /etc/apache2/conf-enabled/security.conf && \
    echo 'ServerSignature Off' >> /etc/apache2/conf-enabled/security.conf

# Disable directory listing
# Update /var/www directory Options
RUN sed -i 's/Options Indexes FollowSymLinks/Options -Indexes +FollowSymLinks/' /etc/apache2/apache2.conf

# Set MaxKeepAliveRequests to 500
RUN sed -i 's/MaxKeepAliveRequests 100/MaxKeepAliveRequests 500/' /etc/apache2/apache2.conf

# Set Timeout to 60 seconds
RUN sed -i 's/Timeout 300/Timeout 60/' /etc/apache2/apache2.conf

# Set KeepAliveTimeout to 3 seconds
RUN sed -i 's/KeepAliveTimeout 5/KeepAliveTimeout 3/' /etc/apache2/apache2.conf

# Increase the maximum number of Apache worker processes
RUN sed -i 's/StartServers			 5/StartServers			 10/' /etc/apache2/mods-available/mpm_prefork.conf && \
    sed -i 's/MinSpareServers		  5/MinSpareServers		  10/' /etc/apache2/mods-available/mpm_prefork.conf && \
    sed -i 's/MaxSpareServers		 10/MaxSpareServers		 20/' /etc/apache2/mods-available/mpm_prefork.conf && \
    sed -i 's/MaxRequestWorkers	  150/MaxRequestWorkers	  600/' /etc/apache2/mods-available/mpm_prefork.conf && \
    sed -i 's/MaxConnectionsPerChild   0/MaxConnectionsPerChild   5/' /etc/apache2/mods-available/mpm_prefork.conf

# Set memory_limit to 128MB, post_max_size, and upload_max_filesize to 512MB
RUN sed -i 's/memory_limit = .*/memory_limit = 128M/' /etc/php/7.4/apache2/php.ini \
    && sed -i 's/post_max_size = .*/post_max_size = 512M/' /etc/php/7.4/apache2/php.ini \
    && sed -i 's/upload_max_filesize = .*/upload_max_filesize = 512M/' /etc/php/7.4/apache2/php.ini

# Expose port 80
EXPOSE 80
EXPOSE 443

# Start Apache service
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]

