# Sentinel Appliance Deployment

This is assumed to be used for something you don't know about unless you do.
Should be a private repository, but I'm poor. 

To get it up and running:
* Clone this repository in home directory, preferably. -> `git clone [url].git`
* Place the `.service` file in `/etc/systemd/system` -> `mv [file] [directory]`
* Go there and make it an executable file -> `cd /etc/systemd/system && chmod 644 sentinel_deploy.service` 
* Place the `.sh` file in `/usr/bin` -> `mv [file] [directory]`

..and then:
* `sudo systemctl start sentinel_deploy.service`
* `sudo systemctl status sentinel_deploy.service`
* `sudo systemctl enable sentinel_deploy.service`

