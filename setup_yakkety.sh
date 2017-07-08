
BOX=$HOME/box
CODE=$HOME/code
CODE_EXT=$CODE/ext
CODE_BEN=$CODE/ben
DOTFILES=$CODE_BEN/dotfiles
ORG=$HOME/org

mkdir -p $BOX
mkdir -p $CODE_BEN
mkdir -p $CODE_EXT

echo "Adding PPA for latest emacs"
sudo add-apt-repository ppa:kelleyk/emacs

echo "Adding docker repo"
sudo apt-get remove -y docker docker-engine
sudo apt-get install -y apt-transport-https ca-certificates software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

echo "Adding nodeJS PPA"
echo "Installing npm"
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -

echo "Installing apt packages"
sudo apt upgrade -y
sudo apt update

sudo apt install -y \
     cmake \
     nodejs \
     openssh-client \
     openssh-server \
     emacs25 \
     davfs2 \
     zsh git-core \
     docker-ce \
     python-pip \
     python-software-properties \
     htop \
     tmux \
     tmuxinator \
     silversearcher-ag \
     x11-xserver-utils \
     xterm \
     zsh

echo "Adding $USER to docker group"
sudo adduser $USER docker

echo "Installing Oh-my-zsh"
wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh
chsh -s `which zsh`

echo "Setting up Box.com WebDAV"
sudo sed -i 's/# use_locks       1/use_locks        0/' /etc/davfs2/davfs2.conf
sudo dpkg-reconfigure -fnoninteractive davfs2
sudo usermod -a -G davfs2 $USER
sudo echo "https://dav.box.com/dav $HOME/box davfs rw,user,noauto 0 0" >> /etc/fstab

echo "Mounting $HOME/box"
mount $BOX
echo "Symlinking $BOX/org to $ORG/ben"
ln -s $BOX/org $ORG/ben

echo "Installing dotfiles"
git clone https://github.com/gmoben/dotfiles.git $DOTFILES
pushd $DOTFILES
./install.sh
popd
source $HOME/.aliases

echo "Symlinkingsource $HOME/.aliases zsh everywhere"
sudo ln -s `which zsh` /usr/local/bin/zsh
mkdir -p $HOME/.local/bin
sudo ln -s `which zsh` $HOME/.local/bin/zsh

echo "Installing pip packages"
pip --upgrade pip
pip install \
    ipython
    virtualenv \
    virtualenvwrapper

echo "Installing i3-gaps dependencies"
sudo apt install -y \
    xcb-proto \
    libxcb1-dev \
    libxcb-keysyms1-dev \
    libpango1.0-dev \
    libxcb-util0-dev \
    libxcb-icccm4-dev \
    libyajl-dev \
    libstartup-notification0-dev \
    libxcb-randr0-dev \
    libev-dev \
    libxcb-cursor-dev \
    libxcb-xinerama0-dev \
    libxcb-xkb-dev \
    libxkbcommon-dev \
    libxkbcommon-x11-dev \
    autoconf \

sudo add-apt-repository ppa:aguignard/ppa
sudo apt-get update
sudo apt-get install libxcb-xrm-dev

echo "Installing i3-gaps"
mkdir -p $CODE_EXT
pushd $CODE_EXT
git clone https://www.github.com/Airblader/i3 i3-gaps
pushd i3-gaps
autoreconf --force --install
rm -rf build/
mkdir -p build && cd build/

../configure --prefix=/usr --sysconfdir=/etc --disable-sanitizers
make
sudo make install

echo "Installing i3 extras"

sudo apt install -y \
     libxcb-xrm-dev \
     libxcb-ewmh-dev \
     libjsoncpp-dev \
     libmpdclient-dev \
     libasound2-dev \
     libcurl4-openssl-dev \
     libiw-dev \
     wireless-tools \
     python-xcbgen

export XCB_EWMH_LIBRARY=/usr/lib/x86_64-linux-gnu
export XCB_EWMH_INCLUDE_DIR=/usr/include/xcb

pushd $CODE_EXT
git clone --branch 3.0.5 --recursive https://github.com/jaagr/polybar
cd polybar
./build.sh
popd

# If interactive
if [[ $- == *i* ]]; then
   read -p "Github email: " gh_email
   read -p "Github username: " gh_username
   git config --global user.email $gh_email
   git config --global user.username $gh_username
else
   echo "Skipping interactive setup"
fi

echo "Installation complete"
