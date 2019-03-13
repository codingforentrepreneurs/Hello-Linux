# Hello Linux


This series is all about deploying a Python web application on Ubuntu 18.04 LTS.


You can spin up a virtual machine with Ubuntu at a variety of places: 

- [Digital Ocean](https://kirr.co/l8v1n1) | ([without referral code](https://www.digitalocean.com))

- Google Cloud Compute Engine (https://cloud.google.com/compute/)

- Amazon Web Services EC2 (https://aws.amazon.com/ec2/)


We'll be using Digital Ocean since it's really easy to get started. What you'll learn here can also be applied to deploying Python projects on any Ubuntu server. In some cases, this setup will work with other Linux distributions too albeit different methods of installation (ie not using `apt-get`).


Here's the plan:

- Launch a virtual machine (droplet) with [Digital Ocean](https://kirr.co/l8v1n1)
- Access our droplet via SSH 
- Install Updates & Dependancies via bash script which is [here](./setup.sh)
- Configure & Implement:
    - Git (for push, build, & deploy) [[docs](https://git-scm.com/)]
    - Supervisor (process manager) [[docs](http://supervisord.org)]
    - Nginx (web server / load balancer) [[docs](http://nginx.org/en/docs/)]
    - Redis (task queue datastore / message broker) [[docs](https://redis.io/documentation)]
    - Celery (worker / task queues) [[docs](http://www.celeryproject.org/)]
    - Gunicorn (WSGI web server for python) [[docs](https://gunicorn.org/)]
    - PostgreSQL (database) [[docs](https://www.postgresql.org/docs/)]
    - Django (Python web framework) [[docs](https://www.djangoproject.com)]
    - Let's Encrypt for HTTPs Certificates


Intall & Setup
ssh into your virtual machine:
```console
wget https://raw.githubusercontent.com/codingforentrepreneurs/Hello-Linux/master/setup.sh
chmod +x setup.sh
./setup.sh
```

