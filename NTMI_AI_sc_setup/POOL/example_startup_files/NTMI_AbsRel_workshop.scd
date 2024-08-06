/*** example for NTMI AbsRel workshop setup ***

// start oscar&xflux
NTMI.oscar.makeServer;
// activate flatcat simulation
defer ({ Tdef(\flatcatSim).stop.play }, 1);

*****/

// load all supported interfaces
NTMI.interfacesToLoad = [
	"nUFO",
	"uc4", "mu8",
	"nanoKtl",
	"dual_analog_3.2",
	"dual_analog_4",
	"ferrari",
	"xtm"
];


// now run NTMI setup:
NTMI.run;

