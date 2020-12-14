# Steps to build and install tmux from source on Ubuntu.
# Takes < 25 seconds on EC2 env [even on a low-end config instance].
# Based on https://gist.github.com/P7h/91e14096374075f5316e
VERSION=3.1

sudo apt-get update
sudo apt-get -y remove tmux
sudo apt-get -y install wget tar libevent-dev libncurses-dev build-essential

echo "****"
echo "**** Downloading tmux-${VERSION} ****"
echo "****"
wget https://github.com/tmux/tmux/releases/download/${VERSION}/tmux-${VERSION}.tar.gz
tar xf tmux-${VERSION}.tar.gz
rm -f tmux-${VERSION}.tar.gz

pushd tmux-${VERSION}

echo "****"
echo "**** Building tmux-${VERSION} ****"
echo "****"
./configure && make

echo "****"
echo "**** Installing tmux-${VERSION} ****"
echo "****"
if sudo make install ; then
    echo "Installation complete. Enjoy the beauty of tmux!"
else
    echo "Installation failed. Recheck directory permissions."
fi

popd
