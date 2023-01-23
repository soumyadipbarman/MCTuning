#!/bin/bash

rm submit_mg5py8*
for((k=0; k<10; k++))
do
n=${k}
ME=$(printf '%02d' "$[k+1]")

cat>ESV_mg5py8_${n}.cmnd<<%
! 1) Settings used in the main program.
Main:numberOfEvents   = -1         ! number of events to generate (-1 for all)
Main:timesAllowErrors = 10000      ! how many aborts before run stops
!Main:spareMode1 = 0                ! skip n events at beginning of file

! 2) Settings related to output in init(), next() and stat().
Init:showChangedSettings = on      ! list changed settings
Init:showChangedParticleData = on  ! list changed particle data
Init:showAllSettings = off         ! list all settings
Init:showAllParticleData = off     ! list all particle data
Next:numberCount       = 1000      ! print message every n events
Next:numberShowInfo    = 1         ! print event information n times
Next:numberShowProcess = 1         ! print process record n times
Next:numberShowEvent   = 1         ! print event record n times
Next:numberShowLHA = 1             ! print LHA information n times
Stat:showPartonLevel = off         ! additional statistics on MPI

! 3) Enable Madgraph MLM matching
JetMatching:merge = on
JetMatching:scheme = 1
JetMatching:setMad = off
JetMatching:qCut = 45
JetMatching:coneRadius = 1
JetMatching:etaJetMax = 5
JetMatching:nJetMax = 4

!JetMatching:jetAlgorithm = 2
!JetMatching:slowJetPower = 1
!JetMatching:nQmatch = 5
!JetMatching:doShowerKt = off

Beams:frameType = 4
Beams:LHEF = /home/soumyadip/Package/Madgraph/QCD/MG5_aMC_v3_4_1/QCD_4j_LO_MLM_v2/Events/run_${ME}/unweighted_events.lhe.gz

! 6) Other settings. Can be expanded as desired.
! Note: may overwrite some of the values above, so watch out.
!Tune:pp = 14
!Tune:ee = 7
!Tune:preferLHAPDF = 2

!ParticleDecays:limitTau0 = on      ! set long-lived particle stable ...
!ParticleDecays:tau0Max = 10        ! ... if c*tau0 > 10 mm
!ParticleDecays:allowPhotonRadiation = on

Check:epTolErr = 1e-2
!Beams:setProductionScalesFromLHEF = off

!SLHA:keepSM = on
!SLHA:minMassSM = 1000.

!MultipartonInteractions:ecmPow=0.03344
!MultipartonInteractions:bProfile=2
!MultipartonInteractions:pT0Ref=1.41
!MultipartonInteractions:coreRadius=0.7634
!MultipartonInteractions:coreFraction=0.63
!MultipartonInteractions:alphaSvalue=0.118
!MultipartonInteractions:alphaSorder=2

!ColourReconnection:range=5.176

!SpaceShower:alphaSorder=2
!SpaceShower:alphaSvalue=0.118

!TimeShower:alphaSorder=2
!TimeShower:alphaSvalue=0.118

!SigmaProcess:alphaSvalue=0.118
!SigmaProcess:alphaSorder=2

!SigmaTotal:mode = 0
!SigmaTotal:sigmaEl = 21.89
!SigmaTotal:sigmaTot = 100.309
!SigmaTotal:zeroAXB=off

!PDF:pSet=NNPDF31_nnlo_as_0118_mc_hessian_pdfas
%

cat>submit_mg5py8_${n}.sh<<%
rm pythia_mg5py8_$n.log
rm rivet_mg5py8_$n.log
rm mg5py8_$n.yoda

mkfifo hepmc_mg5py8_$n.fifo

./ESV_mg5py8 ESV_mg5py8_$n.cmnd hepmc_mg5py8_$n.fifo >> pythia_mg5py8_$n.log &

rivet hepmc_mg5py8_$n.fifo -a ATLAS_2020_I1808726 -a ATLAS_2020_I1790256 -a ATLAS_2019_I1740909 -a ATLAS_2019_I1724098 -a ATLAS_2018_I1634970 -a CMS_2021_I1972986 -a CMS_2021_I1932460 -a CMS_2018_I1682495 -a CMS_2018_I1680318 -a CMS_2016_I1459051 -a MC_JETS -a MC_XS -o mg5py8_$n.yoda &>>rivet_mg5py8_$n.log

rm hepmc_mg5py8_${n}.fifo
echo DONE
%

chmod +x *sh
done
