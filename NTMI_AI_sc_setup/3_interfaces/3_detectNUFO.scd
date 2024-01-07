/*
OSCdef.trace(true, true);
OSCdef.trace(false);
MKtl.all.nUFO; // exists?
*/

NTMI.nUFO = NTMI.nUFO ? ();
NTMI.nUFO.waitFornUFO = true;

NTMI.nUFO.loadnUFO = { |dict, force = false|
	var senderAddr = NTMI.nUFO.senderAddr;
	if (force or: NTMI.nUFO.waitFornUFO) {
		defer {
			"*** loading nUFO interface:".postln;
			LoadMe(NTMI.dir.setup +/+ "3_interfaces/nUFO/*nUFO*.scd");
			if (senderAddr.notNil) {

				MKtl.all.nUFO.device.updateSrcAddr(senderAddr.ip, senderAddr.port)
			};
			"*** nUFO loaded! .".postln;
		};
	}
};

// detect nUFO presence, assuming nUFO always sends imu:
OSCdef(\nUFOdetectIMU, { |msg, time, senderAddr|
	NTMI.nUFO.senderAddr = senderAddr;
	NTMI.nUFO.loadnUFO(true);
	// disable detector when loaded.
	// reopen with OSCdef(\nUFOdetectIMU).enable;
	OSCdef(\nUFOdetectIMU).disable;
}, "/ntmi/imu").enable;

// still hypothetical, use when multiple nUFOs in the same network.
/*
NTMI.nUFO.knownnUFOs = [];
// wait for nUFO ID, decide whether to connect:
OSCdef(\nUFOdetectID, { |msg|
var newID = msg[1];
if (NTMI.nUFO.knownnUFOs.includes(newID).not) {
NTMI.nUFO.knownnUFOs = NTMI.nUFO.knownnUFOs.add(newID);
"*** NTMI.knownnUFOs : %\n\n".postf(NTMI.nUFO.knownnUFOs.cs);
if (NTMI.nUFO.myExpectedID != newID) {
if (MKtl.all.nUFO.isNil) {
NTMI.nUFO.loadnUFO
};
};
msg.postln;
}, "/ntmi/ID")
*/

