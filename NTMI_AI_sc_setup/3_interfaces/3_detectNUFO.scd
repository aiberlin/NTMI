/*
OSCdef.trace(true, true);
OSCdef.trace(false);
*/


NTMI.waitForNufo = true;

// detect nUFO presence:
OSCdef(\nUFOdetectIMU, { |msg|
	if (NTMI.waitForNufo) {
		"*** nUFO detected! loading nUFO interface.".postln;
		NTMI.waitForNufo = false;
		(NTMI.dir.user +/+ "3_interfaces/optionals/*nufo*.scd")
		.pathMatch.do(_.loadPaths);
		"*** nUFO loaded! .".postln;

	};
}, "/ntmi/imu").permanent;

NTMI.knownNUFOs = [];
// wait for nUFO ID, decide whether to connect:
OSCdef(\nUFOdetectID, { |msg|
	var newID = msg[1];
	if (NTMI.knownNUFOs.includes(newID).not) {
		NTMI.knownNUFOs = NTMI.knownNUFOs.add(newID);
		"*** NTMI.knownNUFOs : %\n\n".postf(NTMI.knownNUFOs.cs);

	};
	msg.postln;
}, "/ntmi/ID")




// // when imu message detected, alive;
// // keep imu messages in 5-sec buffer,
// // count as framerate, when framerate is too low,
// // consider dead.
// // also check nufoID!
// Tdef('nufoDetect').set(\nufoPresent, false);
// Tdef('nufoDetect', { |env|
//
// }).play;
//
// NTMI.nufoPresent = false;
//

