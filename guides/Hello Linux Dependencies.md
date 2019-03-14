This is a comprehensive overview of all installations needed for the upcoming __Hello Linux__ series. And yes, these installations will be on a Ubuntu 18.04 server. 

In __Hello Linux__, we want to have the following implemented:

- __Git__ for pushing, building, & deploying ([Guide](https://www.codingforentrepreneurs.com/blog/git-push-local-code-to-live-linux-server/))
- __Supervisor__ for managing processes
- __Nginx__ as our web server
- __Redis__ for our task queue datastore / message broker
- __Celery__ as our Python app task queue / scheduler
- __Gunicorn__ as our WSGI web server
- __PostgreSQL__ as our database
- __Django__ as our Python web framework
- __Let's Encrypt__ for HTTPs Certificates



#### Installation Dependencies
Ubuntu 18.04
```
sudo apt-get update -y

sudo apt-get install build-essential libssl-dev libpq-dev libcurl4-gnutls-dev libexpat1-dev gettext unzip -y

sudo apt-get install supervisor -y 

sudo apt-get install python3-pip python3-dev python3-venv -y

sudo apt-get install nano -y

sudo apt install redis-server -y

sudo apt-get install git -y 

sudo apt-get install postgresql postgresql-contrib -y

sudo apt-get install nginx curl -y

sudo apt-get install ufw -y

sudo ufw allow 'Nginx Full'

sudo ufw allow ssh

sudo add-apt-repository ppa:certbot/certbot

sudo apt-get install python-certbot-nginx -y

sudo python3 -m pip install virtualenv

sudo service supervisor start

sudo apt autoremove -y
```