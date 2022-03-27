#! /bin/bash -eu

cd ~/
mkdir adehome
cd adehome
touch .adehome

git clone https://gitlab.com/autowarefoundation/autoware.auto/AutowareAuto.git

cd ~/adehome/AutowareAuto
ade start --update --enter


echo "autoware install finish"