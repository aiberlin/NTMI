// Send send influx values to an external process.

q.forwardAddr = NetAddr.localAddr.port_(4711);

NTMI.inphlux.action.add(\forward, {
	// get all outVals in order
	var outVals = NTMI.inphlux.outNames.collect { |name|
		NTMI.inphlux.outValDict[name]
	};
	// // uncomment this line to debug
	// outVals.postln;
	q.forwardAddr.sendMsg(\influxOuts, *outVals);
});

/*
//// test receiving influx forward:
thisProcess.openUDPPort(q.forwardAddr.port);
OSCdef(\testInfluxRecv, { |msg|
	msg.round(0.001).postcs;
}, \influxOuts);
*/