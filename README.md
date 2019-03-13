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


### 1. Automatic Virtual Machine Setup
After you run the below command, you'll see an endpoint to add to your local git remote.

```console
wget https://raw.githubusercontent.com/codingforentrepreneurs/Hello-Linux/master/setup.sh
chmod +x setup.sh
./setup.sh
```


### 2. Production-Ready Django Project
We'll be using a bare bones Django project that's mostly ready for production. It's just an example but an important one to get this working.

Go to [this guide](https://kirr.co/8mjnna) to get started.


### 3. Create PostgreSQL Database for Django

To create a PostgreSQL database, **it's recommended to use [setup.sh](./setup.sh) on Server**. 

Another option is to run:

```console

# enable current logged in user as a default user for postgres
sudo -u postgres createuser $USER

sudo -u postgres psql --command="CREATE DATABASE ${projectDB};"

sudo -u postgres psql --command="CREATE USER ${projectDBuser} WITH PASSWORD '${newPassword}';"

sudo -u postgres psql --command="ALTER ROLE ${projectDBuser} SET client_encoding TO 'utf8';"

sudo -u postgres psql --command="ALTER ROLE ${projectDBuser} SET default_transaction_isolation TO 'read committed';"

sudo -u postgres psql --command="ALTER ROLE ${projectDBuser} SET timezone TO 'UTC';"

sudo -u postgres psql --command="GRANT ALL PRIVILEGES ON DATABASE ${projectDB} TO ${projectDBuser};"


```

Be sure to replace `${projectDB}`, `${projectDBuser}`, and `${newPassword}` to the values you want to use. The setup script does this automatically.

#### Update Django Production Settings (`src/cfehome/settings/production.py`)
```
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': os.path.join(BASE_DIR, 'db.sqlite3'),
    }
}

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': '${projectDB}',
        'USER': '${projectDBuser}',
        'PASSWORD': '{newPassword}',
        'HOST': 'localhost',
        'PORT': '',
    }
}
```

#### Activate Virtual Environment & Migrate Django
```console
$ cd path/to/django/proj
$ pipenv shell
(venv) $ pipenv install psycopg2-binary # you might need this
(venv) $ python manage.py migrate
```

Our example
```console
$ cd /var/www/hello_linux/src/
$ pipenv shell
(src) $ python manage.py migrate
```


