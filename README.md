# awcoleman/cups-avahi-airprint

Fork from [quadportnick/docker-cups-airprint](https://github.com/quadportnick/docker-cups-airprint)  
And then from [chuckcharlie/cups-avahi-airprint](https://github.com/chuckcharlie/docker-cups-airprint)

Forked from chuckcharlie to include drivers for HP Color LaserJet 2600n, and insert printer config for my home printer. (Thanks for the awesome work to build from!)

This Alpine-based Docker image runs a CUPS instance that is meant as an AirPrint relay for printers that are already on the network but not AirPrint capable. The other images out there never seemed to work right. I forked the original to use Alpine instead of Ubuntu and work on more host OS's.

## Configuration

### Volumes:
* `/config`: where the persistent printer configs will be stored
* `/services`: where the Avahi service files will be generated

### Variables:
* `CUPSADMIN`: the CUPS admin user you want created
* `CUPSPASSWORD`: the password for the CUPS admin user  
Will autogenerate password for printadmin user and print to console if not specified.

### Ports/Network:
* Must be run on host network. This is required to support multicasting which is needed for Airprint.

### Example build command:
```
docker build -t awcoleman/cups2600n .
```

### Example run command:
Slim version:  
```
mkdir -p /tmp/{config,services}
docker run --name cups --restart unless-stopped --net host \
  -v /tmp/services:/services -v /tmp/config:/config \
  awcoleman/cups2600n:latest
```

Full featured:  
```
docker run --name cups --restart unless-stopped  --net host\
  -v <your services dir>:/services \
  -v <your config dir>:/config \
  -e CUPSADMIN="<username>" \
  -e CUPSPASSWORD="<password>" \
  chuckcharlie/cups-avahi-airprint:latest
```

## Add and set up printer:
* CUPS will be configurable at http://[host ip]:631 using the CUPSADMIN/CUPSPASSWORD.
* Make sure you select `Share This Printer` when configuring the printer in CUPS.
* ***After configuring your printer, you need to close the web browser for at least 60 seconds. CUPS will not write the config files until it detects the connection is closed for as long as a minute.***

