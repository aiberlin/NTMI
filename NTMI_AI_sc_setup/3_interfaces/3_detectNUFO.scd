/*
OSCdef.trace(true, true);
OSCdef.trace(false);
MKtl.all.nUFO; // exists?
*/

NTMI.nufo = NTMI.nufo ? ();
NTMI.nufo.waitForNufo = true;

NTMI.nufo.loadNufo = { |dict, force = false|
	var senderAddr = NTMI.nufo.senderAddr;
	if (force or: NTMI.nufo.waitForNufo) {
		defer {
			"*** loading nUFO interface:".postln;
			LoadMe(NTMI.dir.setup +/+ "3_interfaces/nufo/*nufo*.scd");
			if (senderAddr.notNil) {

				MKtl.all.nUFO.device.updateSrcAddr(senderAddr.ip, senderAddr.port)
			};
			"*** nUFO loaded! .".postln;
		};
	}
};

// detect nUFO presence, assuming nufo always sends imu:
OSCdef(\nUFOdetectIMU, { |msg, time, senderAddr|
	NTMI.nufo.senderAddr = senderAddr;
	NTMI.nufo.loadNufo(true);
	// disable detector when loaded.
	// reopen with OSCdef(\nUFOdetectIMU).enable;
	OSCdef(\nUFOdetectIMU).disable;
}, "/ntmi/imu").enable;

// still hypothetical, use when multiple nUFOs in the same network.
/*
NTMI.nufo.knownNUFOs = [];
// wait for nUFO ID, decide whether to connect:
OSCdef(\nUFOdetectID, { |msg|
var newID = msg[1];
if (NTMI.nufo.knownNUFOs.includes(newID).not) {
NTMI.nufo.knownNUFOs = NTMI.nufo.knownNUFOs.add(newID);
"*** NTMI.knownNUFOs : %\n\n".postf(NTMI.nufo.knownNUFOs.cs);
if (NTMI.nufo.myExpectedID != newID) {
if (MKtl.all.nUFO.isNil) {
NTMI.nufo.loadNufo
};
};
msg.postln;
}, "/ntmi/ID")
*/

