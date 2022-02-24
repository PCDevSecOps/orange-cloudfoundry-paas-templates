# this script will delete every yaml file present into template directory
# copy every file present into backup and share-operators/k3s
# to rebuild a full k3s from usual deployment and be able test new functionality
rm ../*.yml
cp ../skeleton/*.yml ../.
cp ../../../../shared-operators/k3s/*.yml ../.