export TERMINFO=/usr/lib/terminfo
TERM=xterm
echo "Working Directory is........"
pwd
export TE_GROUP=$(TE_GROUP)
sudo curl -Os https://downloads.thousandeyes.com/agent/install_thousandeyes.sh
sudo chmod a+x install_thousandeyes.sh
sudo ./install_thousandeyes.sh -f -b $TE_GROUP
sudo apt-add-repository https://apt.thousandeyes.com