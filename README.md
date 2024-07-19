# What is this?
This repository is a clone of tbs/media_build to support building the neumoDVB drivers.
The neumoDVB drivers in question can be found in the linux_media tree available on this site.

# Installation

First install the required compilers, git ...
You may also need libproc-processtable-perl (e.g., on ubuntu)

```
mkdir ~/blindscan_kernel
cd  ~/blindscan_kernel
```

Check out the actual drivers. This uses the default branch which is called deepthought

```
git clone --depth=1  https://github.com/deeptho/linux_media.git ./media
```

Then  check out a copy of DeepThought's media_build (try tbs media_build if it does not work)

```
git clone https://github.com/deeptho/neumo_media_build
```

Make sure software for kernel compilation is installed.
For instance on fedora:

```
sudo dnf install -y patchutils
sudo dnf install -y ccache
sudo dnf install -y kernel-devel-`uname -r`
sudo dnf install -y perl-File-Copy #not needed?
sudo dnf install -y perl
sudo dnf install -y perl-Proc-ProcessTable

cd neumo_media_build
git checkout deepthought
git reset --hard
make dir DIR=../media
make distclean
./install.sh
```

Last but not least, install rsyslog so that kernel debug messages are stored in the file system
in /var/log/debug:

```
sudo dnf install -y rsyslog
sudo vi /etc/rsyslog.conf # add "kern.debug /var/log/debug" line
sudo systemctl enable rsyslog
sudo systemctl start rsyslog #to have log messages in /var/log/debug
```

Now install the firmware (if needed):

```
wget http://www.tbsdtv.com/download/document/linux/tbs-tuner-firmwares_v1.0.tar.bz2
sudo tar jxvf tbs-tuner-firmwares_v1.0.tar.bz2 -C /lib/firmware/
```

If you cannot find the 6909 firmware:

```
wget http://www.tbsdtv.com/download/document/linux/dvb-fe-mxl5xx.fw
sudo cp dvb-fe-mxl5xx.fw /lib/firmware/
```

Now load the drivers: either reboot, or try loading the proper module for your card, e.g., tbsecp3
for many cards:

```
sudo modprobe tbsecp3
```

Check /var/log/debug for messages. If there are i2c_xfer error messages, try editing
the file tbsecp3-cards.c. In that file lcate the entry for your card and change i2c_speed
to 9.

If you have this problem then report it. Also report if the solution works,
