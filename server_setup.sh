#!/bin/sh
set -e
echo "Installing dependencies (build-essential libpcre3 libpcre3-dev libssl-dev)..."
apt-get -y -qq install build-essential libpcre3 libpcre3-dev libssl-dev

tmpfolder=$(mktemp -dq)

echo "Downloading nginx..."
wget -O $tmpfolder/nginx.tar.gz https://nginx.org/download/nginx-1.13.6.tar.gz

echo "Downloading nginx-rtmp-module"
git clone https://github.com/arut/nginx-rtmp-module.git $tmpfolder/nginx-rtmp-module

echo "Unzipping nginx..."
tar -xf $tmpfolder/nginx.tar.gz -C $tmpfolder

echo "Installing nginx with rtmp module..."
(cd $tmpfolder/nginx-1.13.6; ./configure --with-http_ssl_module --add-module=$tmpfolder/nginx-rtmp-module; make; make install)


echo "Configuring nginx server..."
echo "server {
        listen 1935;
        chunk_size 4096;
        application live {
            live on;
            record off;
        }
    }
}" >> /usr/local/nginx/conf/nginx.conf;

# Not working yet, set path manually
# SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
# sed -i -e "s/root *DroneMonitorCenter;/root $SCRIPTDIR;/g";

echo "Cleaning up..."
rm -Rf $tmpfolder
