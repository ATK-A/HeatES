#!/bin/bash

echo "Unzipping data if required"
tar xfv /data/inputs/Climate/*.tar.gz -C /data/inputs/Climate
unzip /data/inputs/Climate/*.zip -d /data/inputs/Climate
echo " "

echo "Copying and unzipping PreProcessedData to working directory"
cp -r /data/inputs/PreProcessedData /code/
cp /data/inputs/PreProcessedData/PreProcessedData.tar.gz /code/PreProcessedData.tar.gz
tar -xf /code/PreProcessedData.tar.gz -C /code/PreProcessedData/
echo " "

echo "Removing climate data from nested directory, if necessary"
cp /data/inputs/Climate/Climate/* /data/inputs/Climate/ 
echo "Copying in any stray netCDF from data/inputs"
mkdir /data/inputs/Climate/
cp /data/inputs/*.nc /data/inputs/Climate/
echo "This is the data"
ls /data/
echo " "

echo "This is the inputs data"
ls /data/inputs/
echo " "

echo "This is the Climate input data"
ls /data/inputs/Climate/
echo " "
echo " "

echo "Running containerised model"
/usr/bin/mlrtapp/HeatES
