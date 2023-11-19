/*
// add a method: dict refers to NTI.q, then args
NTMI.boing = { |dict, a, b, c, d|
"boing: ".post; [a, b, c, d].postln;
};

// test
NTMI.boing(1, 2, 3, 4);

NTMI.run
*/

// flexible project class, redirects everything to internal dict:
NTMI {
	classvar <q;
	*initClass {
		q = (
			run: {|dict, path|
				path = (path ? Quark("NTMI").localPath +/+ "NTMI_AI_sc_setup/00_loadMe.scd");
				path.load
			},
		)
	}

	// redirect everything to NTMI.q:
	*doesNotUnderstand { |selector ... args|
		^q.performList(selector, args)
	}
}