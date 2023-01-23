#!/bin/bash

rm submit_py8*
randomnum=(1908 2345 9834 3768 4772 5128 6991 7590 8119 9056)

for((k=0; k<10; k++))
do
n=${k}

cat>ESV_py8_${n}.cmnd<<%
! File: ESV_py8.cmnd
! This file contains commands to be read in for a Pythia8 run.
! Lines not beginning with a letter or digit are comments.

! 1) Settings that will be used in a main program.
Main:numberOfEvents = 1000000      ! number of events to generate
Main:timesAllowErrors = 10000      ! abort run after this many flawed events

! 2) Settings related to output in init(), next() and stat().
Init:showChangedSettings = on      ! list changed settings
Init:showAllSettings = off         ! list all settings
Init:showChangedParticleData = on  ! list changed particle data
Init:showAllParticleData = off     ! list all particle data
Next:numberCount = 1000            ! print message every n events
Next:numberShowLHA = 1             ! print LHA information n times
Next:numberShowInfo = 1            ! print event information n times
Next:numberShowProcess = 1         ! print process record n times
Next:numberShowEvent = 1           ! print event record n times
Stat:showPartonLevel = off         ! additional statistics on MPI

! 3) Beam parameter settings. Values below agree with default ones.
Beams:idA = 2212                   ! first beam, p = 2212, pbar = -2212
Beams:idB = 2212                   ! second beam, p = 2212, pbar = -2212
Beams:eCM = 13000.                 ! CM energy of collision
Check:epTolErr = 0.01
Beams:setProductionScalesFromLHEF = off

! 4) PDF settings. Default is to use internal PDFs
PDF:pSet=20
PDF:pSet=LHAPDF6:NNPDF31_nnlo_as_0118
! PDF:pSet = LHAPDF5:MRST2001lo.LHgrid
! Allow extrapolation of PDF's beyond x and Q2 boundaries, at own risk.
! Default behaviour is to freeze PDF's at boundaries.
PDF:extrapolate = on

! 5) Pick processes and kinematics cuts.
HardQCD:all = on
PhaseSpace:pTHatMin = 20.          ! minimum pT of hard process
PhaseSpace:pTHatMax = 7000.0
PhaseSpace:bias2Selection = on
PhaseSpace:bias2SelectionPow = 4.0

! 6) Other settings. Can be expanded as desired.
! Note: may overwrite some of the values above, so watch out.
Tune:pp = 14
Tune:ee = 7
Tune:preferLHAPDF = 2

ParticleDecays:limitTau0 = on      ! set long-lived particle stable ...
ParticleDecays:tau0Max = 10        ! ... if c*tau0 > 10 mm
ParticleDecays:allowPhotonRadiation = on

!SLHA:keepSM = on
!SLHA:minMassSM = 1000.

MultipartonInteractions:ecmPow=0.03344
MultipartonInteractions:bProfile=2
MultipartonInteractions:pT0Ref=1.41
MultipartonInteractions:coreRadius=0.7634
MultipartonInteractions:coreFraction=0.63
MultipartonInteractions:alphaSvalue=0.118
MultipartonInteractions:alphaSorder=2

ColourReconnection:range=5.176

SpaceShower:alphaSorder=2
SpaceShower:alphaSvalue=0.118

TimeShower:alphaSorder=2
TimeShower:alphaSvalue=0.118

SigmaProcess:alphaSvalue=0.118
SigmaProcess:alphaSorder=2

SigmaTotal:mode = 0
SigmaTotal:sigmaEl = 21.89
SigmaTotal:sigmaTot = 100.309
SigmaTotal:zeroAXB=off

! 7) Random Seed
Random:setSeed = on
Random:seed = ${randomnum[$k-1]}
%

cat>submit_py8_${n}.sh<<%
rm pythia_py8_$n.log
rm rivet_py8_$n.log
rm py8_$n.yoda

mkfifo hepmc_py8_$n.fifo

./ESV_py8 ESV_py8_$n.cmnd hepmc_py8_$n.fifo >> pythia_py8_$n.log &

rivet hepmc_py8_$n.fifo -a ATLAS_2020_I1808726 -a ATLAS_2020_I1790256 -a ATLAS_2019_I1740909 -a ATLAS_2019_I1724098 -a ATLAS_2018_I1634970 -a CMS_2021_I1972986 -a CMS_2021_I1932460 -a CMS_2018_I1682495 -a CMS_2018_I1680318 -a CMS_2016_I1459051 -a MC_JETS -a MC_XS -o py8_$n.yoda &>>rivet_py8_$n.log

rm hepmc_py8_${n}.fifo
echo DONE
%

chmod +x *sh
done
