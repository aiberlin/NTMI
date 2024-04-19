/*
OSCdef.trace(true, true);
OSCdef.trace(false);
MKtl.all.nUFO; // exists?

nUFO startup logic:
When an Airborne Instruments nUFO boots,it makes its own WLAN with
SSID name: NTMI-00x -- (serial number)
password: NTMINTMI

its router address is NetAddr(169.254.1.1, 57120),
and it immediately sends /ntmi/caps and /ntmi/imu messages.
So nUFO needs NetAddr to be 57120!

OSCdef(\nUFOdetectIMU) listens for /ntmi/imu,
and loads all nUFO files when a nUFO message is detected;
then MKtl(\nUFO) is created, and Tdef(\allLEDs)
plays its little light patterns on the nUFO LEDs;
then it sends NTMI playing state for display.

// re-enable detection with:
OSCdef(\nUFOdetectIMU).enable;

*/

NTMI.nUFO = NTMI.nUFO ? ();
NTMI.nUFO.waitFornUFO = true;

NTMI.nUFO.loadnUFO = { |dict, force = false|
	var senderAddr = NTMI.nUFO.senderAddr;
	if (force or: NTMI.nUFO.waitFornUFO) {
		defer {
			if (MKtl.all.nUFO.isNil) {
				"*** loading nUFO interface:".postln;
				LoadMe(NTMI.dir.setup +/+ "3_interfaces/nUFO/*nUFO*.scd");
			};
			if (senderAddr.notNil) {

				MKtl.all.nUFO.device.updateSrcDstAddr(senderAddr.ip, senderAddr.port)
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

