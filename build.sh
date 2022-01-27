set -o xtrace
cd /work
unzip -p plugin.jar plugin.yml > plugin.yml
export PLUGIN_NAME=$(yq e ".name" plugin.yml | sed -e 's/\(.*\)/\L\1/');
export PLUGIN_VERSION=$(yq e '.version' plugin.yml | sed -e 's/[^[:alnum:]\.\~\_-]\+/./g');
export WORKDIR="$PLUGIN_NAME"_"$PLUGIN_VERSION"-1-all;
mkdir $WORKDIR;
mkdir -p $WORKDIR/opt/spigot-plugins
cp plugin.jar $WORKDIR/opt/spigot-plugins/$PLUGIN_NAME-$PLUGIN_VERSION.jar
mkdir -p $WORKDIR/DEBIAN;
gomplate -d plugin.yml -f /ro/control.gomplate -o $WORKDIR/DEBIAN/control
dpkg-deb --build --root-owner-group $WORKDIR
export DEB_FILE_NAME=$(basename $(find . -name "*.deb"))
deb-s3 upload --arch all -l --bucket $APT_S3_BUCKET --codename spigot-plugins $DEB_FILE_NAME
echo "Done"
sleep 10