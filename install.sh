#!/bin/bash
make dir DIR=../media
make distclean
# Enable some staging drivers
make stagingconfig || exit

# Disable RC/IR support
sed -i -r 's/(^CONFIG.*_RC.*=)./\1n/g' v4l/.config
sed -i -r 's/(^CONFIG.*_IR.*=)./\1n/g' v4l/.config
sed -i -r 's/(^CONFIG.*_BT87X.*=)./\1n/g' v4l/.config
sed -i -r 's/(^CONFIG.*_MXL603.*=)./\1n/g' v4l/.config
sed -i -r 's/(^CONFIG.*_MTV23X.*=)./\1n/g' v4l/.config
sed -i -r 's/(^CONFIG.*_GX1503.*=)./\1n/g' v4l/.config

# Disable RC/IR support
sed -i -r 's/(^CONFIG.*_RC.*=)./\1n/g' v4l/.config
sed -i -r 's/(^CONFIG.*_IR.*=)./\1n/g' v4l/.config

echo "V4L drivers building..."
make -j$(nproc) &&  echo "V4L drivers installing..."  && sudo make install

echo "V4L drivers installation done"
echo "You need to reboot..."
