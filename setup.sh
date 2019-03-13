echo
echo
echo
echo "What is your project name?"
read projectname

# lowercase name, convert spaces to _
projectslug="$(echo -n "${projectname}" | sed -e 's/[^[:alnum:]]/_/g' \
| tr -s '_' | tr A-Z a-z)"

projectgit=${projectslug}.git
localip=$(hostname  -I | cut -f1 -d' ')
projectDB="${projectslug}_db"
projectDBuser="${projectslug}_user"


echo
echo "Your project name will be used as:"
echo
echo "Name: ${projectslug}"
echo "IP: ${localip}"
echo
echo "If you create a git repo below, you'll have:"
echo "Repo: /var/repo/${projectgit}/"
echo "Working Dir: /var/www/${projectslug}/"
echo "Working Dir Symlink: ~/${projectslug}"
echo "Remote: ssh://${USER}@${localip}/var/repo/${projectgit}"
echo 
echo "If you create a database below, you'll have:"
echo "Database Name: ${projectDB}"
echo "Database Username: ${projectDBuser}"
echo "Database Password: <you set below>"
echo
echo "These values will be generated automatically based the name you gave."


echo "Do you want to continue? y/n"
read runSetup
runSetupResponse="$(echo -n "${runSetup}" | sed -e 's/[^[:alnum:]]/-/g' \
| tr -s '_' | tr A-Z a-z)"

if [ "$runSetupResponse" == "n" ]
    then 
        echo 'Setup exited.' 
        exit
fi

echo "Run latest installs? y/n"
read doInstalls
doInstallsResponse="$(echo -n "${doInstalls}" | sed -e 's/[^[:alnum:]]/-/g' \
| tr -s '_' | tr A-Z a-z)"


echo "Setup production-ready git repo for project? y/n (recommended)"
read createGitRepo
createGitRepoResponse="$(echo -n "${createGitRepo}" | sed -e 's/[^[:alnum:]]/-/g' \
| tr -s '_' | tr A-Z a-z)"


echo "Do you want to create a database? (y/n)"
read databaseCreate
databaseCreateResponse="$(echo -n "${databaseCreate}" | sed -e 's/[^[:alnum:]]/-/g' \
| tr -s '_' | tr A-Z a-z)"

if [ "$databaseCreateResponse" == 'y' ]
then
    while true; do
        echo "What would you like the database password to be?"
        read -s -p "Password (typing hidden): " newPassword
        echo
        read -s -p "Confirm password (typing hidden): " password2
        echo
        [ "$newPassword" = "$password2" ] && break
        echo "Please try again"
    done
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

    sudo python3 -m pip install pipenv

    sudo python3 -m pip install virtualenv

    sudo service supervisor start

    sudo apt autoremove -y
else:
    echo "Setup installs skipped"
    echo
fi


if [ "$createGitRepoResponse" == "y" ]
then
    echo 'Creating git repo...'
    echo
    echo
    sudo mkdir /var/www/
    sudo mkdir /var/www/${projectslug}/
    cd ~/
    ln -s /var/www/${projectslug}/ ~/


    mkdir /var/repo/
    mkdir /var/repo/${projectgit}/
    cd /var/repo/${projectgit}/

    git init --bare

    cat <<EOT >> /var/repo/${projectgit}/hooks/post-receive
git --work-tree=/var/www/${projectslug} --git-dir=/var/repo/${projectgit} checkout -f
EOT

    chmod +x /var/repo/${projectgit}/hooks/post-receive

    echo "Success. You can access your project on your server at:"
    echo
    echo "Be sure to run this on your local repo:"
    echo "git remote add live ssh://${USER}@${localip}/var/repo/${projectgit}"
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
    echo "Database password ******** (set above)"
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
    echo "Database password ******** (set above)"
fi
if [ "$createGitRepoResponse" == "y" ]
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



