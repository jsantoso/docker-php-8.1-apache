#!/bin/bash

source /etc/bashrc

if [ ! -z "$ENABLE_XDEBUG" ]; then
  echo "*** Enabling xdebug"
  docker-php-ext-enable xdebug
fi

exec /usr/local/bin/apache2-foreground
	

