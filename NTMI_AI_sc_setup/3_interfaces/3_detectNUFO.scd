/*
OSCdef.trace(true, true);
OSCdef.trace(false);
*/


q.waitForNufo = true;

// detect nUFO presence:
OSCdef(\nUFOdetectIMU, { |msg|
	if (q.waitForNufo) {
		"*** nUFO detected! loading nUFO interface.".postln;
		q.waitForNufo = false;
		(q.dir.user +/+ "3_interfaces/optionals/*nufo*.scd")
		.pathMatch.do(_.loadPaths);
		"*** nUFO loaded! .".postln;

	};
}, "/ntmi/imu").permanent;

q.knownNUFOs = [];
// wait for nUFO ID, decide whether to connect:
OSCdef(\nUFOdetectID, { |msg|
	var newID = msg[1];
	if (q.knownNUFOs.includes(newID).not) {
		q.knownNUFOs = q.knownNUFOs.add(newID);
		"*** q.knownNUFOs : %\n\n".postf(q.knownNUFOs.cs);

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
// q.nufoPresent = false;
//

