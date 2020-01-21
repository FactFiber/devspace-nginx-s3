FROM alpine:3.3 as base
# Bring in gettext so we can get `envsubst`, then throw
# the rest away. To do this, we need to install `gettext`
# then move `envsubst` out of the way so `gettext` can
# be deleted completely, then move `envsubst` back.
RUN apk add --no-cache --virtual .gettext gettext \
    && mv /usr/bin/envsubst /tmp/ \
    \
    && runDeps="$( \
        scanelf --needed --nobanner /tmp/envsubst \
            | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
            | sort -u \
            | xargs -r apk info --installed \
            | sort -u \
    )" \
    && apk add --no-cache $runDeps \
    && apk del .gettext \
    && mv /tmp/envsubst /usr/local/bin/

# main stage
#
# NB we setup envsubst in separate stage because ficusio/openresty
# ONBUILD loads nginx configuration, which triggers rebuild from 
# start. This way we can avoid reinstall of envsubst if we change
# nginx config.
FROM ficusio/openresty:1.9 as nginx
COPY --from=base /usr/local/bin/envsubst /usr/local/bin/envsubst
COPY --from=base /usr/lib/libintl.so.8.1.4 /usr/lib/libintl.so.8 /usr/lib/

EXPOSE 80
CMD [ "/bin/ash", "-c", "envsubst '$$s3_bucket $$aws_key $$aws_secret $prefix'  < /opt/openresty/nginx/conf/nginx.conf.template > /opt/openresty/nginx/conf/nginx.conf && exec nginx" ]
