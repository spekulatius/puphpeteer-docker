#
# This file builds the base for the Puphpeteer docker containers
# See https://github.com/rialto-php/puphpeteer-docker
# 

# Base it on the PHP version requested.
ARG PHP_VERSION
FROM php:$PHP_VERSION
ARG NODE_VERSION

# Fixed for now. Could be auto-updated or passed in as well.
ENV NVM_VERSION v0.37.2

# Update the repository sources list and install dependencies
RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y curl libzip-dev zip
RUN apt-get autoclean -y && apt-get autoremove -y

# Replace shell with bash so we can source files
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# The current version requires sockets and zip
RUN docker-php-ext-install sockets zip

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php && \ 
    mv composer.phar /usr/local/bin/composer && \ 
    chmod +x /usr/local/bin/composer


# nvm environment variables
ENV NVM_DIR /usr/local/nvm
RUN mkdir $NVM_DIR

# install nvm
# https://github.com/creationix/nvm#install-script  
RUN curl --silent -o- https://raw.githubusercontent.com/creationix/nvm/{$NVM_VERSION}/install.sh | bash \
    && source $NVM_DIR/nvm.sh \
    && nvm install "$NODE_VERSION" \
    && nvm use "$NODE_VERSION"

# add node and npm to path so the commands are available
ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH


# Install requirements for PuPHPeteer
RUN composer require nesk/puphpeteer
RUN npm install @nesk/puphpeteer