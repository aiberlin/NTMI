/*
OSCdef.trace(true, true);
OSCdef.trace(false);
MKtl.all.nUFO; // exists?
*/

NTMI.nufo = NTMI.nufo ? ();
NTMI.nufo.waitForNufo = true;


// detect nUFO presence, assuming nufo always sends imu:
OSCdef(\nUFOdetectIMU, { |msg|
	if (NTMI.nufo.waitForNufo) {
		"*** nUFO detected!".postln;
		NTMI.nufo.waitForNufo = false;
		if (MKtl.all.nUFO.isNil) {
			"*** loading nUFO interface.".postln;
			LoadMe(NTMI.dir.setup +/+ "3_interfaces/optionals/*nufo*.scd");
			"*** nUFO loaded! .".postln;
		};

	};
}, "/ntmi/imu").permanent;

NTMI.nufo.knownNUFOs = [];
// wait for nUFO ID, decide whether to connect:
OSCdef(\nUFOdetectID, { |msg|
	var newID = msg[1];
	if (NTMI.nufo.knownNUFOs.includes(newID).not) {
		NTMI.nufo.knownNUFOs = NTMI.nufo.knownNUFOs.add(newID);
		"*** NTMI.knownNUFOs : %\n\n".postf(NTMI.nufo.knownNUFOs.cs);
		if (MKtl.all.nUFO.isNil) {
			LoadMe(NTMI.dir.setup +/+ "3_interfaces/optionals/*nufo*.scd");
		};
	};
	msg.postln;
}, "/ntmi/ID")


