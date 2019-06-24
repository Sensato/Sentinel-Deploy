# Sentinel Appliance Deployment

This is assumed to be used for something you don't know about unless you do.
Should be a private repository, but I'm poor. 

To get it up and running:
* Clone this repository in home directory, preferably.
* Place the `.service` file in `/etc/systemd/system`
* Go there and make it an executable file
* Place the `.sh` file in `/usr/bin`

..and then:
`sudo systemctl start sentinel_deploy`
`sudo systemctl status sentinel_deploy`
`sudo systemctl enable sentinel_deploy`

