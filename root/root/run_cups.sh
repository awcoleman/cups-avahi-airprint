#!/bin/sh
set -e
set -x

# Create CUPS admin user to allow changes from webUI
if [ ! -z ${CUPSADMIN+x} ] && [ ! -z ${CUPSPASSWORD+x} ]; then
  if [ $(grep -ci $CUPSADMIN /etc/shadow) -eq 0 ]; then
    adduser -S -G lpadmin --no-create-home $CUPSADMIN 
  fi
  echo $CUPSADMIN:$CUPSPASSWORD | chpasswd
else
  id -u printadmin &>/dev/null || adduser -S -G lpadmin --no-create-home printadmin
  CUPSPASSWORD=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32})
  echo "printadmin:${CUPSPASSWORD}" | chpasswd
  echo "CUPS Credentials (usually on http://localhost:631 ): USER printadmin PASS ${CUPSPASSWORD}"
fi

if [ -f /resources/savedconfig/printers.conf ]; then
  echo "Using prepackaged awcoleman 2600n config"
  cp -r /resources/savedconfig/* /config
  chown -R root:root /config
  cp -r /resources/savedservices/* /services
  chown -R root:root /services
  rm -rf /etc/avahi/services/*
  rm -rf /etc/cups/ppd
  ln -s /config/ppd /etc/cups
  cp -f /services/*.service /etc/avahi/services/
else
  echo "Using default,empty config"
  mkdir -p /config/ppd
  mkdir -p /services
  rm -rf /etc/avahi/services/*
  rm -rf /etc/cups/ppd
  ln -s /config/ppd /etc/cups
  if [ `ls -l /services/*.service 2>/dev/null | wc -l` -gt 0 ]; then
    cp -f /services/*.service /etc/avahi/services/
  fi
  if [ `ls -l /config/printers.conf 2>/dev/null | wc -l` -eq 0 ]; then
      touch /config/printers.conf
  fi
  cp /config/printers.conf /etc/cups/printers.conf
fi

/usr/sbin/avahi-daemon --daemonize
/root/printer-update.sh &
exec /usr/sbin/cupsd -f
