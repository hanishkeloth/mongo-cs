ARG BASE_IMAGE_TAG

FROM wodby/php:${BASE_IMAGE_TAG}

ENV DRUSH_LAUNCHER_FALLBACK="/home/wodby/.composer/vendor/bin/drush" \
    \
    PHP_REALPATH_CACHE_TTL="3600" \
    PHP_OUTPUT_BUFFERING="16384"

USER root

RUN set -ex; \
    \
    # We keep global drush version 8 because newer version do not support drupal 7 and  \
    # mostly D7 projects are not composer-based and can't install newer drush as a part of their composer project.
    su-exec wodby composer global require drush/drush:^8.0; \
    drush_launcher_url="https://github.com/drush-ops/drush-launcher/releases/download/0.10.2/drush.phar"; \
    wget -O drush.phar "${drush_launcher_url}"; \
    chmod +x drush.phar; \
    mv drush.phar /usr/local/bin/drush; \
    \
    # Drush extensions
    su-exec wodby mkdir -p /home/wodby/.drush; \
    drush_rr_url="https://ftp.drupal.org/files/projects/registry_rebuild-7.x-2.5.tar.gz"; \
    wget -qO- "${drush_rr_url}" | su-exec wodby tar zx -C /home/wodby/.drush; \
    \
    # Drupal console
    console_url="https://github.com/hechoendrupal/drupal-console-launcher/releases/download/1.9.7/drupal.phar"; \
    curl "${console_url}" -L -o drupal.phar; \
    mv drupal.phar /usr/local/bin/drupal; \
    chmod +x /usr/local/bin/drupal; \
    \
    mv /usr/local/bin/actions.mk /usr/local/bin/php.mk; \
    # Change overridden target name to avoid warnings.
    sed -i 's/git-checkout:/php-git-checkout:/' /usr/local/bin/php.mk; \
    \
    mkdir -p "${FILES_DIR}/config"; \
    chown www-data:www-data "${FILES_DIR}/config"; \
    chmod 775 "${FILES_DIR}/config"; \
    \
    # Clean up
    su-exec wodby composer clear-cache; \
    su-exec wodby drush cc drush
RUN apk --update add --virtual build-dependencies build-base openssl-dev autoconf \
  && pecl install -f "mongodb-1.15.1"\
  && docker-php-ext-enable mongodb \
  && apk del build-dependencies build-base openssl-dev autoconf \
  && rm -rf /var/cache/apk/*

USER wodby

COPY templates /etc/gotpl/
COPY bin /usr/local/bin
COPY init /docker-entrypoint-init.d/
