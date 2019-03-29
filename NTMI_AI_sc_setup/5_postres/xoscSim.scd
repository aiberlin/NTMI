q.addrSC = NetAddr.localAddr;

OSCdef.trace(false);
// turn off the internal ones for now;
x.device.oscFuncDictionary.do(_.disable);

// run just the external ones:
OSCdef(\imu).enable;

/* TEST IMU
// - very different ranges on these, accels very low - why?
q.addrSC.sendMsg(\imu, * ({ 1.0.rand } ! 9 ++ 100.rand));
*/

OSCdef(\imuAlive).enable;
/*
OSCdef.trace(true, true);
q.addrSC.sendMsg(\imuAlive, );
*/

/* test buttons from remote:
q.addrSC.sendMsg('/inputs/digital', 0, 2.rand);
q.addrSC.sendMsg('/inputs/digital', 1, 2.rand);
q.addrSC.sendMsg('/inputs/digital', 2, 2.rand);
q.addrSC.sendMsg('/inputs/digital', 3, 2.rand);
*/

OSCdef(\xana).enable;
/*
// has weird crosstalk compensation and bending curve on values
q.addrSC.sendMsg('/inputs/analogue', *(0!16));
q.addrSC.sendMsg('/inputs/analogue', *(0.5!16));
q.addrSC.sendMsg('/inputs/analogue', *({0.75.rand}!16));
*/

Tdef(\xoscSim).set(\dt, 0.2);

Tdef(\xoscSim, { |ev|
	var imuvals = 0 ! 9;
	var anavals = 0 ! 16;
	var tempval = 20;

	inf.do { |i|
		// send OSC messages for analog and imu at typical rates,
		// random drift unless played otherwise by some sim interface.

		imuvals = imuvals.collectInPlace { |val| (val + 0.2.rand2 * 0.95).fold2(8.0).round(0.01) };
		tempval = (tempval + 3.rand2).fold(0, 100);

		anavals = anavals.collectInPlace { |val, i| (val + 0.05.rand2 * 0.95).fold(0, 1).round(0.01) };

		// zoom - pretend pot rand jitter to be filtered
		anavals.put(7, q.zoom);

		q.addrSC.sendMsg(\imu, *(imuvals ++ tempval));
		q.addrSC.sendMsg('/inputs/analogue', *anavals);

		ev.dt.wait;

	}
});

//////// start simulation from xosc GUI:
x.elAt(\sw, \15).action = { |bt|
	if (bt.value > 0) {
		"*** starting sim: ".post;
		Tdef(\xoscSim).postln.play;
	}
};
x.elAt(\sw, \16).action = { |bt|
	if (bt.value > 0) {
		"*** stopping sim: ".post;
		Tdef(\xoscSim).stop;
	}
};