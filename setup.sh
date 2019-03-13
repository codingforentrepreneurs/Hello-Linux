echo "What is your project name?"
read projectname

# lowercase name, convert spaces to _
projectslug="$(echo -n "${projectname}" | sed -e 's/[^[:alnum:]]/_/g' \
| tr -s '_' | tr A-Z a-z)"

projectgit=${projectslug}.git
localip=$(hostname  -I | cut -f1 -d' ')



echo
echo "Your project name will be stored as:"
echo
echo "${projectslug} on ${localip}"
echo "git repo on /var/repo/${projectgit}/"
echo "Working dir /var/www/${projectslug}/"
echo
echo "A shortcut will be created on ~/${projectslug}"
echo
echo

echo "Do you want to continue? y/n"
read runSetup
runSetupResponse="$(echo -n "${doSetup}" | sed -e 's/[^[:alnum:]]/-/g' \
| tr -s '_' | tr A-Z a-z)"

if [ "$runSetupResponse" == "n" ]
then
    exit 1
fi


echo "Run system setup installs? y/n (recommended)"
read doSetup
doSetupResponse="$(echo -n "${doSetup}" | sed -e 's/[^[:alnum:]]/-/g' \
| tr -s '_' | tr A-Z a-z)"


if [ "$doSetupResponse" == "y" ]
then
    sudo apt-get update -y

    sudo apt-get install build-essential libssl-dev libcurl4-gnutls-dev libexpat1-dev gettext unzip -y

    sudo apt-get install supervisor -y 

    sudo apt-get install python3-pip python3-dev python3-venv -y

    sudo apt-get install nano -y

    sudo apt-get install git -y 

    sudo python3 -m pip install virtualenv

    sudo service supervisor start

    sudo apt autoremove -y
else:
    echo "Setup installs skipped"
fi



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
echo "/var/www/${projectslug}"
echo
echo "Your project is linked"
echo "~/${projectslug}"
echo
echo
echo "Be sure to run this on your local repo:"
echo "git remote add live ssh://${USER}@${localip}/var/repo/${projectgit}"
echo


