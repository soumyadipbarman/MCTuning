#!/bin/bash

rm submit_pwpy8*
for((k=0; k<10; k++))
do
n=${k}
ME=$(printf '%02d' "$[k+1]")

cat>ESV_pwpy8_${n}.cmnd<<%
! main31.cmnd.
! This file contains commands to be read in for a Pythia8 run.
! Lines not beginning with a letter or digit are comments.
! Names are case-insensitive  -  but spellings-sensitive!
! The settings here are illustrative, not always physics-motivated.
! You should carefully consider what changes need be done for the
! process you study currently, and consider some of the options
! as reasonable measures of uncertainties in the matching process.

! Number of events - use 0 for all LHEF events in the input file.
Main:numberOfEvents = 0

! Number of events to list and number of errors to allow.
Next:numberShowLHA = 1
Next:numberShowInfo = 1
Next:numberShowProcess = 1
Next:numberShowEvent = 1
Main:timesAllowErrors = 10

! List changed settings or particle data.
Init:showChangedSettings = on
Init:showChangedParticleData = off

! Input file.
Beams:frameType = 4
! t tbar pair production.
#Beams:LHEF = powheg-hvq.lhe
! QCD 2- and 3-jet events.
!Beams:LHEF = powheg-dijets.lhe
Beams:LHEF = offline/pwgevents.lhe

! Number of outgoing particles of POWHEG Born level process
! (i.e. not counting additional POWHEG radiation)
POWHEG:nFinal = 2

! How vetoing is performed:
!  0 - No vetoing is performed (userhooks are not loaded)
!  1 - Showers are started at the kinematical limit.
!      Emissions are vetoed if pTemt > pThard.
!      See also POWHEG:vetoCount below
POWHEG:veto = 1

! After 'vetoCount' accepted emissions in a row, no more emissions
! are checked. 'vetoCount = 0' means that no emissions are checked.
! Use a very large value, e.g. 10000, to have all emissions checked.
POWHEG:vetoCount = 3

! Selection of pThard (note, for events where there is no
! radiation, pThard is always set to be SCALUP):
!  0 - pThard = SCALUP (of the LHA/LHEF standard)
!  1 - the pT of the POWHEG emission is tested against all other
!      incoming and outgoing partons, with the minimal value chosen
!  2 - the pT of all final-state partons is tested against all other
!      incoming and outgoing partons, with the minimal value chosen
POWHEG:pThard = 2

! Selection of pTemt:
!  0 - pTemt is pT of the emitted parton w.r.t. radiating parton
!  1 - pT of the emission is checked against all incoming and outgoing
!      partons. pTemt is set to the minimum of these values
!  2 - the pT of all final-state partons is tested against all other
!      incoming and outgoing partons, with the minimal value chosen
! WARNING: the choice here can give significant variations in the final
! distributions, notably in the tail to large pT values.
POWHEG:pTemt = 0

! Selection of emitted parton for FSR
!  0 - Pythia definition of emitted
!  1 - Pythia definition of radiator
!  2 - Random selection of emitted or radiator
!  3 - Both are emitted and radiator are tried
POWHEG:emitted = 0

! pT definitions
!  0 - POWHEG ISR pT definition is used for both ISR and FSR
!  1 - POWHEG ISR pT and FSR d_ij definitions
!  2 - Pythia definitions
POWHEG:pTdef = 1

! MPI vetoing
!  0 - No MPI vetoing is done
!  1 - When there is no radiation, MPIs with a scale above pT_1 are vetoed,
!      else MPIs with a scale above (pT_1 + pT_2 + pT_3) / 2 are vetoed
POWHEG:MPIveto = 0
! Note that POWHEG:MPIveto = 1 should be combined with
! MultipartonInteractions:pTmaxMatch = 2
! which here is taken care of in main31.cc.

! QED vetoing
!  0 - No QED vetoing is done for pTemt > 0.
!  1 - QED vetoing is done for pTemt > 0.
!  2 - QED vetoing is done for pTemt > 0.   If a photon is found
!      with pT>pThard from the Born level process, the event is accepted
!      and no further veto of this event is allowed (for any pTemt).
POWHEG:QEDveto = 2

! Further options (optional, for tryout)
!PartonLevel:MPI = off
!HadronLevel:All = off
%

cat>submit_pwpy8_${n}.sh<<%
rm pythia_pwpy8_$n.log
rm rivet_pwpy8_$n.log
rm pwpy8_$n.yoda

mkfifo hepmc_pwpy8_$n.fifo

./ESV_pwpy8 ESV_pwpy8_$n.cmnd hepmc_pwpy8_$n.fifo >> pythia_pwpy8_$n.log &

rivet hepmc_pwpy8_$n.fifo -a ATLAS_2020_I1808726 -a ATLAS_2020_I1790256 -a ATLAS_2019_I1740909 -a ATLAS_2019_I1724098 -a ATLAS_2018_I1634970 -a CMS_2021_I1972986 -a CMS_2021_I1932460 -a CMS_2018_I1682495 -a CMS_2018_I1680318 -a CMS_2016_I1459051 -a MC_JETS -a MC_XS -o pwpy8_$n.yoda &>>rivet_pwpy8_$n.log

rm hepmc_pwpy8_${n}.fifo
echo DONE
%

chmod +x *sh
done
