add-apt-repository -y universe
add-apt-repository -y multiverse
apt_get_update

# Ubuntu does not come with all media codecs by default (for example, codecs for MOV files), install all additional media codecs:
install_packages ubuntu-restricted-extras

# To allow extensions.gnome.org to install extensions for the user
install_packages gnome-browser-connector

# For FUSE, which is required to run AppImages. FFmpeg thumbnailer to allow Nautilus to show thumbnails for more file types
install_packages libfuse2t64 ffmpegthumbnailer