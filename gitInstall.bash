#!/bin/bash

#############################################
# Installation de git, serveur mail, openVpn
# $1 utilisateur
# $2 email

apt-get update -y && apt-get install git-core

adduser git

su $1

git config --global user.name $1
git config --global user.email $2

cat ./ressources/add_.gitconfig >> .gitconfig

ssh-keygen -t rsa -b 4096 -C $2

eval $(ssh-agent -s)
ssh-add ~/.ssh/id_rsa

read -p "Test de la connection avec github" ok
ssh -T git@github.com

read -p "Attention après le git init, ne pas oublier de creer le repertoire de travail, git init, puis de faire un git remote add/set-url origin git@github.com:USER/REPO.git" ok
