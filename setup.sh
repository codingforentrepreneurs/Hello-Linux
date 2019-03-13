echo

echo "What is your project name?"
read projectname


# lowercase name, convert spaces to _
projectslug="$(echo -n "${projectname}" | sed -e 's/[^[:alnum:]]/_/g' \
| tr -s '_' | tr A-Z a-z)"
echo "Using ${projectslug} (formatted automatically)"
echo
echo

projectgit=${projectslug}.git
localip=$(hostname  -I | cut -f1 -d' ')
projectDB="${projectslug}_db"
projectDBuser="${projectslug}_user"



echo "Install system dependencies? y/n"
read doInstalls
doInstallsResponse="$(echo -n "${doInstalls}" | sed -e 's/[^[:alnum:]]/-/g' \
| tr -s '_' | tr A-Z a-z)"

echo "Use default blank django project? (y/n)"
read defaultDjangoProject
defaultDjangoProjectResponse="$(echo -n "${defaultDjangoProject}" | sed -e 's/[^[:alnum:]]/-/g' \
| tr -s '_' | tr A-Z a-z)"


if [ "$defaultDjangoProject" != 'y' ]
then
echo "Setup production-ready git repo for project? y/n"
read createGitRepo
createGitRepoResponse="$(echo -n "${createGitRepo}" | sed -e 's/[^[:alnum:]]/-/g' \
| tr -s '_' | tr A-Z a-z)"
fi

echo "Create a postgresql database? (y/n)"
read databaseCreate
databaseCreateResponse="$(echo -n "${databaseCreate}" | sed -e 's/[^[:alnum:]]/-/g' \
| tr -s '_' | tr A-Z a-z)"


customDBPW='false'
newPassword=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
if [ "$databaseCreateResponse" == 'custom' ]
then
    while true; do
        echo "What would you like the database password to be?"
        read -s -p "Password (typing hidden): " newPassword
        echo
        read -s -p "Confirm password (typing hidden): " password2
        customDBPW='true'
        echo
        [ "$newPassword" = "$password2" ] && break
        echo "Please try again"
    done
fi



echo "Add gunicorn service? (y/n)"
read setupGunicorn
setupGunicornResponse="$(echo -n "${setupGunicorn}" | sed -e 's/[^[:alnum:]]/-/g' \
| tr -s '_' | tr A-Z a-z)"


echo "Add nginx? (y/n)"
read setupNginx
setupNginxResponse="$(echo -n "${setupNginx}" | sed -e 's/[^[:alnum:]]/-/g' \
| tr -s '_' | tr A-Z a-z)"


echo "Add celery? (y/n)"
read setupCelery
setupCeleryResponse="$(echo -n "${setupCelery}" | sed -e 's/[^[:alnum:]]/-/g' \
| tr -s '_' | tr A-Z a-z)"




echo
echo "Your project name will be used as:"
echo
echo "Name: ${projectslug}"
echo "IP: ${localip}"

if [ "$defaultDjangoProjectResponse" == 'y' ]
then
    echo
    echo "Using Default Django Project from:"
    echo "https://github.com/codingforentrepreneurs/CFE-Blank-Project"
    echo "If you setup git below (recommended),"
    echo "you'll be able to pull this project"
    echo "to work locally on it."
fi


if [ "$createGitRepoResponse" == 'y' ] || [ "$defaultDjangoProjectResponse" == 'y' ]
then
    echo 
    echo "Local Project details"
    echo "Repo: /var/repo/${projectgit}/"
    echo "Working Dir: /var/www/${projectslug}/"
    echo "Working Dir Symlink: ~/${projectslug}"
    echo "Remote: ssh://${USER}@${localip}/var/repo/${projectgit}"
fi 

if [ "$databaseCreateResponse" == 'y' ]
then
    echo
    echo "Database will be created with"
    echo "Database Name: ${projectDB}"
    echo "Database Username: ${projectDBuser}"
    if [ "$customDBPW" == 'false' ]
    then
        echo "Database password ${newPassword}"
    fi
fi

if [ "$setupNginxResponse" == 'y' ]
then
    echo "Celery will be setup."
fi

if [ "$setupGunicornResponse" == 'y' ]
then
    echo "Gunicorn will be setup."
fi

if [ "$setupCeleryResponse" == 'y' ]
then
    echo "Celery will be setup."
fi

echo
echo "Everything will be generated automatically based on the project name you gave."
echo

echo "Do you want to continue? y/n"
read runSetup
runSetupResponse="$(echo -n "${runSetup}" | sed -e 's/[^[:alnum:]]/-/g' \
| tr -s '_' | tr A-Z a-z)"

if [ "$runSetupResponse" == "n" ]
    then 
        echo 'Setup exited.' 
        exit
fi

if [ "$doInstallsResponse" == "y" ]
then
    echo 'Installing dependancies'
    echo
    echo
    sudo apt-get update -y

    sudo apt-get install build-essential libssl-dev libpq-dev libcurl4-gnutls-dev libexpat1-dev gettext unzip -y

    sudo apt-get install supervisor -y 

    sudo apt-get install python3-pip python3-dev python3-venv -y

    sudo apt-get install nano -y

    sudo apt-get install git -y 

    sudo apt-get install postgresql postgresql-contrib -y

    sudo apt-get install nginx curl -y

    sudo apt-get install ufw -y

    sudo ufw allow 'Nginx Full'

    sudo ufw allow ssh

    sudo python3 -m pip install virtualenv

    sudo service supervisor start

    sudo apt autoremove -y
else:
    echo "Setup installs skipped"
    echo
fi


if [ "$createGitRepoResponse" == "y" ] || [ "$defaultDjangoProject" == 'y' ]
then
    echo 'Creating working directory and git repo...'
    echo
    echo
    sudo mkdir /var/www/
    sudo mkdir /var/www/${projectslug}/
    cd ~/
    ln -s /var/www/${projectslug}/ ~/


    mkdir /var/repo/
    mkdir /var/repo/${projectgit}/
    cd /var/repo/${projectgit}/
    if [ "$defaultDjangoProject" == 'y' ] 
    then
        git clone https://github.com/codingforentrepreneurs/CFE-Blank-Project . --bare
        git --work-tree="/var/www/${projectslug}" --git-dir="/var/repo/${projectgit}" checkout -f
        virtualenv  -p python3.6 /var/www/${projectslug}
        sudo rm /var/www/${projectslug}/src/cfehome/settings/local.py
        virtualenvbin="/var/www/${projectslug}/bin"
        $virtualenvbin/python -m pip install -r "/var/www/${projectslug}/src/requirements.txt"
        
        cat <<EOT >> /var/repo/${projectgit}/hooks/post-receive
git --work-tree=/var/www/${projectslug} --git-dir=/var/repo/${projectgit} checkout -f

${virtualenvbin}/python -m pip install -r /var/www/${projectslug}/src/requirements.txt

rm /var/www/${projectslug}/src/cfehome/settings/local.py

supervisorctl reread
supervisorctl update

EOT

    else
        git init --bare
        cat <<EOT >> /var/repo/${projectgit}/hooks/post-receive
git --work-tree=/var/www/${projectslug} --git-dir=/var/repo/${projectgit} checkout -f

supervisorctl reread
supervisorctl update
EOT
    fi



    chmod +x /var/repo/${projectgit}/hooks/post-receive

    echo "Success. You can access your project on your server at:"
    echo
    echo "Be sure to run this on your local repo:"
    echo "git remote add live ssh://${USER}@${localip}/var/repo/${projectgit}"
fi

if [ "$defaultDjangoProject" == 'y' ] 
then
    cd /var/www/${projectslug}/

fi

if [ "$databaseCreateResponse" == 'y' ]
then
    echo
    echo 'Creating postgresql database.'
    echo
    echo "Create Root postgres user (ignore if fails)"
    cd  /tmp

    sudo -u postgres createuser $USER

    sudo -u postgres createdb $USER
    #su postgres

    sudo -u postgres psql --command="CREATE DATABASE ${projectDB};"

    sudo -u postgres psql --command="CREATE USER ${projectDBuser} WITH PASSWORD '${newPassword}';"

    sudo -u postgres psql --command="ALTER ROLE ${projectDBuser} SET client_encoding TO 'utf8';"

    sudo -u postgres psql --command="ALTER ROLE ${projectDBuser} SET default_transaction_isolation TO 'read committed';"

    sudo -u postgres psql --command="ALTER ROLE ${projectDBuser} SET timezone TO 'UTC';"

    sudo -u postgres psql --command="GRANT ALL PRIVILEGES ON DATABASE ${projectDB} TO ${projectDBuser};"

    cd ~/ 

    echo "Database created"
    echo "Database name: ${projectDB}"
    echo "Database username ${projectDBuser}"
    if [ "$customDBPW" == 'false' ]
    then
        echo "Database password ${newPassword}"
    fi
    if [ "$defaultDjangoProject" == 'y' ] 
    then
        echo "Updating django project to include database settings"
        databaseSettingsPath="/var/www/${projectslug}/src/cfehome/settings/db_conf.py"
        databaseSettings="ALLOWED_HOSTS=['${localip}']
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': '${projectDB}',
        'USER':  '${projectDBuser}',
        'PASSWORD': '${newPassword}',
        'HOST': 'localhost',
        'PORT': '',

    }
}"
        echo "${databaseSettings}" > "${databaseSettingsPath}"
        echo "Django updated with Created Database Settings"

        ${virtualenvbin}/python /var/www/${projectslug}/src/manage.py migrate
        cd /var/www/${projectslug}
        source bin/activate
        cd src
        djangoPassword=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
        echo "from django.contrib.auth import get_user_model; User = get_user_model(); User.objects.create_superuser('admin', 'admin@myproject.com', '${djangoPassword}')" | python manage.py shell
        echo "Django Username: admin"
        echo "Django Password: ${djangoPassword}"
    fi
fi







if [ "$setupGunicornResponse" == 'y' ]
then
    echo
    echo
    echo "Creating gunicorn service in supervisor"
    sudo mkdir /var/log
    sudo mkdir /var/log/${projectslug}/
    gunicornConfFile="/etc/supervisor/conf.d/${projectslug}-gunicorn.conf"
    echo "Your gunicorn supervisor file will located at:"
    echo "${gunicornConfFile}"
    echo
    supervisorText="[program:${projectslug}_gunicorn]
user=${USER}
directory=/var/www/${projectslug}/src/
command=${virtualenvbin}/gunicorn --workers 3 --bind unix:${projectslug}.sock cfehome.wsgi:application
 
autostart=true
autorestart=true
stdout_logfile=/var/log/${projectslug}/gunicorn.log
stderr_logfile=/var/log/${projectslug}/gunicorn.err.log"
    echo "${supervisorText}" > "${gunicornConfFile}"
    supervisorctl reread
    supervisorctl update
fi




if [ "$setupCeleryResponse" == 'y' ]
then
    echo
    echo
    echo "Creating celery service in supervisor"
    sudo mkdir /var/log
    sudo mkdir /var/log/${projectslug}/
    celeryConfFile="/etc/supervisor/conf.d/${projectslug}-celery.conf"
    echo "Your celery supervisor file will located at:"
    echo "${celeryConfFile}"
    echo
    supervisorText="[program:${projectslug}_celery]
user=${USER}
directory=/var/www/${projectslug}/src
command=${virtualenvbin}/celery -A ${projectslug}.celery worker
autostart=false
autorestart=false
stdout_logfile=/var/log/${projectslug}/celery.log
stderr_logfile=/var/log/${projectslug}/celery.err.log"
    echo "${supervisorText}" > "${celeryConfFile}"
    supervisorctl reread
    supervisorctl update
fi


if [ "$setupNginxResponse" == 'y' ]
then
    echo
    echo
    echo "Creating Nginx configuration file for Project"
    echo "Your nginx conf file will located at:"
    nginxFilePath="/etc/nginx/sites-available/${projectslug}.conf"
    nginxEnabledPath="/etc/nginx/sites-enabled/${projectslug}.conf"
    echo "${nginxFilePath}"
    echo
    nginxConfText="server {
    server_name ${localip};
    listen 80;
    listen [::]:80;

    location / {
        include proxy_params;
        proxy_pass http://unix:/var/www/${projectslug}/src/${projectslug}.sock;
        proxy_buffer_size       128k;
        proxy_buffers           4 256k;
        proxy_read_timeout 60s;
        proxy_busy_buffers_size 256k;
        client_max_body_size 2M;
    }
}"
    echo "${nginxConfText}" > "${nginxFilePath}"
    rm /etc/nginx/sites-enabled/default
    cp "${nginxFilePath}" "${nginxEnabledPath}"

    systemctl daemon-reload

    sudo systemctl reload nginx
fi


echo
echo
echo
echo "//////// Final Summary \\\\\\\\\\\\\\\\"
echo
echo
if [ "$databaseCreateResponse" == 'y' ]
then
    echo "**Postgresql Database Created**"
    echo
    echo "Database name: ${projectDB}"
    echo "Database username ${projectDBuser}"
    if [ "$customDBPW" == 'false' ]
    then
        echo "Database password ${newPassword}"
    fi
fi
if [ "$createGitRepoResponse" == "y" ] || [ "$defaultDjangoProjectResponse" == "y" ]
then
    echo
    echo "**Repo & Project Created**"
    echo
    echo "Your project is stored in"
    echo "/var/www/${projectslug}"
    echo "~/${projectslug}"
    echo
    echo "Update your local git repo to..."
    echo 
    echo "git remote add live ssh://${USER}@${localip}/var/repo/${projectgit}"
    echo
fi

if [ "$defaultDjangoProjectResponse" == "y" ]
then
    echo "Login URL: ${localip}/admin"
    echo "Django Username: admin"
    echo "Django Password: ${djangoPassword}"
    echo "You should change this password right away."
fi



