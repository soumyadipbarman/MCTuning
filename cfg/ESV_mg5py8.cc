// Keywords: matching; merging; MLM;
// for Madgraph LHEF event files.

//g++ ESV_mg5py8.cc -o ESV_mg5py8 -I../include -O2 -std=c++11 -pedantic -W -Wall -Wshadow -fPIC -DGZIP -lz -L../lib -Wl,-rpath,../lib -lpythia8 -ldl -I/home/soumyadip/Package/HepMC2/2.06.09/include -L/home/soumyadip/Package/HepMC2/2.06.09/lib -Wl,-rpath,/home/soumyadip/Package/HepMC2/2.06.09/lib -lHepMC -DHEPMC2


// Includes and namespace
#include "Pythia8/Pythia.h"
#include "Pythia8Plugins/CombineMatchingInput.h"
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

  // Extract settings to be used in the main program.
  int nEvent = pythia.mode("Main:numberOfEvents");
  int nAbort = pythia.mode("Main:timesAllowErrors");
  int nSkip  = pythia.mode("Main:spareMode1");

  // Create UserHooks pointer. Stop if it failed. Pass pointer to Pythia.
  CombineMatchingInput combined;
  combined.setHook(pythia);

  // Initialise Pythia.
  if (!pythia.init()) {
    cout << "Error: could not initialise Pythia" << endl;
    return 1;
  };

  // Optionally skip ahead in LHEF.
  pythia.LHAeventSkip( nSkip );

  // Begin event loop. Optionally quit it before end of file.
  int iAbort = 0;
  for (int iEvent = 0; ;  ++iEvent) {
    if (nEvent > 0 && iEvent >= nEvent) break;

    // Generate events. Quit if at end of file or many failures.
    if (!pythia.next()) {
      if (pythia.info.atEndOfFile()) {
        cout << "Info: end of input file reached" << endl;
        break;
      }
      if (++iAbort < nAbort) continue;
      cout << "Abort: too many errors in generation" << endl;
      break;
    }

    // Construct new empty HepMC event, fill it and write it out.
    toHepMC.writeNextEvent( pythia );
    // Event analysis goes here.

  // End of event loop.
  }

  // Final statistics and done.
  pythia.stat();

  return 0;
}
