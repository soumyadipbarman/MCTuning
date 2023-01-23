#!/bin/bash

rm -rf hepmc1.fifo  # delete existing pipes
rm -rf pythia1.log
rm -rf rivet1.log

mkfifo hepmc1.fifo  # initiate pipe

./ESV_pwpy8 ESV_pwpy8.cmnd hepmc1.fifo >> pythia1.log &

rivet hepmc.fifo -a ATLAS_2020_I1808726 -a ATLAS_2020_I1790256 -a ATLAS_2019_I1740909 -a ATLAS_2019_I1724098 -a ATLAS_2018_I1634970 -a CMS_2021_I1972986 -a CMS_2021_I1932460 -a CMS_2021_I1920187_DIJET -a CMS_2018_I1682495 -a CMS_2018_I1680318 -a CMS_2016_I1459051 -a MC_JETS -a MC_XS -o 22Dec2022.yoda &>>rivet1.log

rm -rf hepmc1.fifo
echo DONE
