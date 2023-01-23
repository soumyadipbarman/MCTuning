// Input and output files are specified on the command line, e.g. like
//./ESV_py8.exe ESV_py8.cmnd ESV_py8.hepmc > ESV_py8.log

//g++ ESV_py8.cc -o ESV_py8 -I../include -O2 -std=c++11 -pedantic -W -Wall -Wshadow -fPIC -DGZIP -lz -L../lib -Wl,-rpath,../lib -lpythia8 -ldl -I/home/soumyadip/Package/HepMC2/2.06.09/include -L/home/soumyadip/Package/HepMC2/2.06.09/lib -Wl,-rpath,/home/soumyadip/Package/HepMC2/2.06.09/lib -lHepMC -DHEPMC2

#include "Pythia8/Pythia.h"
#ifndef HEPMC2
#include "Pythia8Plugins/HepMC3.h"
#else
#include "Pythia8Plugins/HepMC2.h"
#endif

using namespace Pythia8;

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

  // Generator.
  Pythia pythia;

  // Read in commands from external file.
  pythia.readFile(argv[1]);

  // Extract settings to be used in the main program.
  int    nEvent    = pythia.mode("Main:numberOfEvents");
  int    nAbort    = pythia.mode("Main:timesAllowErrors");

  // Initialization.
  pythia.init();

  // Begin event loop.
  int iAbort = 0;
  for (int iEvent = 0; iEvent < nEvent; ++iEvent) {

    // Generate event.
    if (!pythia.next()) {

      // First few failures write off as "acceptable" errors, then quit.
      if (++iAbort < nAbort) continue;
      cout << " Event generation aborted prematurely, owing to error!\n";
      break;
    }

    // Construct new empty HepMC event, fill it and write it out.
    toHepMC.writeNextEvent( pythia );

  // End of event loop. Statistics.
  }
  pythia.stat();

  // Done.
  return 0;
}
