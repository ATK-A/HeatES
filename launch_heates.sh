#!/bin/bash

echo "Unzipping data if required"
tar xfv /data/inputs/Climate/*.tar.gz -C /data/inputs/Climate
unzip /data/inputs/Climate/*.zip -d /data/inputs/Climate

echo "Copying and unzipping PreProcessedData to working directory"
cp /data/inputs/PreProcessedData/PreProcessedData.tar.gz /code/PreProcessedData.tar.gz
tar -xf /code/PreProcessedData.tar.gz -C /code/PreProcessedData/

echo "Running containerised model"
/usr/bin/mlrtapp/HeatES
