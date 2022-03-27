#! /bin/bash -eu

echo $PATH
cd /usr/local/bin

sudo wget https://gitlab.com/ApexAI/ade-cli/uploads/f6c47dc34cffbe90ca197e00098bdd3f/ade+x86_64
sudo mv ade+x86_64 ade
sudo chmod +x ade
sudo ./ade --version
sudo ./ade update-cli
sudo ./ade --version
echo "ade install finish"