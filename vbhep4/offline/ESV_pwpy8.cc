// Keywords: matching; merging; powheg;
// Example how to perform merging with POWHEG-BOX events,
// based on the code found in include/Pythia8Plugins/PowhegHooks.h.

//g++ ESV_pwpy8.cc -o ESV_pwpy8 -I../include -O2 -std=c++11 -pedantic -W -Wall -Wshadow -fPIC -DGZIP -lz -L../lib -Wl,-rpath,../lib -lpythia8 -ldl -I/home/soumyadip/Package/HepMC2/2.06.09/include -L/home/soumyadip/Package/HepMC2/2.06.09/lib -Wl,-rpath,/home/soumyadip/Package/HepMC2/2.06.09/lib -lHepMC -DHEPMC2

#include "Pythia8/Pythia.h"
#include "Pythia8Plugins/PowhegHooks.h"
#ifndef HEPMC2
#include "Pythia8Plugins/HepMC3.h"
#else
#include "Pythia8Plugins/HepMC2.h"
#endif

using namespace Pythia8;

//==========================================================================

int main(int argc, char* argv[]) {

	// Check that correct number of command-line arguments
  if (argc != 3) {
    cerr << " Unexpected number of command-line arguments. \n You are"
         << " expected to provide one input and one output file name. \n"
         << " Program stopped! " << endl;
    return 1;
  }

  // Confirm that external files will be used for input and output.
  cout << "\n >>> PYTHIA settings will be read from file " << argv[1]
       << " <<< \n >>> HepMC events will be written to file "
       << argv[2] << " <<< \n" << endl;

  // Interface for conversion from Pythia8::Event to HepMC event.
  // Specify file where HepMC events will be stored.
  Pythia8ToHepMC toHepMC(argv[2]);

  // Generator
  Pythia pythia;

  // Read in commands from external file.
  pythia.readFile(argv[1]);

  // Read in main settings
  int nEvent      = pythia.settings.mode("Main:numberOfEvents");
  int nError      = pythia.settings.mode("Main:timesAllowErrors");
  // Read in key POWHEG merging settings
  int vetoMode    = pythia.settings.mode("POWHEG:veto");
  int MPIvetoMode = pythia.settings.mode("POWHEG:MPIveto");
  bool loadHooks  = (vetoMode > 0 || MPIvetoMode > 0);

  // Add in user hooks for shower vetoing
  shared_ptr<PowhegHooks> powhegHooks;
  if (loadHooks) {

    // Set ISR and FSR to start at the kinematical limit
    if (vetoMode > 0) {
      pythia.readString("SpaceShower:pTmaxMatch = 2");
      pythia.readString("TimeShower:pTmaxMatch = 2");
    }

    // Set MPI to start at the kinematical limit
    if (MPIvetoMode > 0) {
      pythia.readString("MultipartonInteractions:pTmaxMatch = 2");
    }

    powhegHooks = make_shared<PowhegHooks>();
    pythia.setUserHooksPtr((UserHooksPtr)powhegHooks);
  }

  // Initialise and list settings
  pythia.init();

  // Counters for number of ISR/FSR emissions vetoed
  unsigned long int nISRveto = 0, nFSRveto = 0;

  // Begin event loop; generate until nEvent events are processed
  // or end of LHEF file
  int iEvent = 0, iError = 0;
  while (true) {

    // Generate the next event
    if (!pythia.next()) {

      // If failure because reached end of file then exit event loop
      if (pythia.info.atEndOfFile()) break;

      // Otherwise count event failure and continue/exit as necessary
      cout << "Warning: event " << iEvent << " failed" << endl;
      if (++iError == nError) {
        cout << "Error: too many event failures.. exiting" << endl;
        break;
      }

      continue;
    }

    // Construct new empty HepMC event, fill it and write it out.
    toHepMC.writeNextEvent( pythia );

    /*
     * Process dependent checks and analysis may be inserted here
     */

    // Update ISR/FSR veto counters
    if (loadHooks) {
      nISRveto += powhegHooks->getNISRveto();
      nFSRveto += powhegHooks->getNFSRveto();
    }

    // If nEvent is set, check and exit loop if necessary
    ++iEvent;
    if (nEvent != 0 && iEvent == nEvent) break;

  } // End of event loop.

  // Statistics, histograms and veto information
  pythia.stat();
  cout << "Number of ISR emissions vetoed: " << nISRveto << endl;
  cout << "Number of FSR emissions vetoed: " << nFSRveto << endl;
  cout << endl;

  // Done.
  return 0;
}
