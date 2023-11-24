/*
OSCdef.trace(true, true);
OSCdef.trace(false);
MKtl.all.nUFO; // exists?
*/

NTMI.waitForNufo = true;

// detect nUFO presence, assuming nufo always sends imu:
OSCdef(\nUFOdetectIMU, { |msg|
	if (NTMI.waitForNufo) {
		"*** nUFO detected!".postln;
		NTMI.waitForNufo = false;
		if (MKtl.all.nUFO.isNil) {
			"*** loading nUFO interface.".postln;
			LoadMe(NTMI.dir.setup +/+ "3_interfaces/optionals/*nufo*.scd");
			"*** nUFO loaded! .".postln;
		};

	};
}, "/ntmi/imu").permanent;

NTMI.knownNUFOs = [];
// wait for nUFO ID, decide whether to connect:
OSCdef(\nUFOdetectID, { |msg|
	var newID = msg[1];
	if (NTMI.knownNUFOs.includes(newID).not) {
		NTMI.knownNUFOs = NTMI.knownNUFOs.add(newID);
		"*** NTMI.knownNUFOs : %\n\n".postf(NTMI.knownNUFOs.cs);
		if (MKtl.all.nUFO.isNil) {
			LoadMe(NTMI.dir.setup +/+ "3_interfaces/optionals/*nufo*.scd");
		};
	};
	msg.postln;
}, "/ntmi/ID")


