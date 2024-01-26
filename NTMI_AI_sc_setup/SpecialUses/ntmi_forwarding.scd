/****
The NTMI environment can be used to influence external processes,
such as visual patches or VR worlds running on the same network.
This file has some examples for how to forward
messages from the NTMI environment.

When using the nufo, you may want to forward all nufo
messages to an external address;
Or maybe you may want to forward influx values,
or other things within the NTMI environment.

For convenient forwarding to networks of SC clients,
see also the HyperDisCo quark:
"https://github.com/aiberlin/HyperDisCo".openOS

*****/

/// E.g. forward all interface messages from the nUFO:
/// get all osc message names coming from nUFO
q.nufoMsgNames = [ '/ntmi/btns', '/ntmi/caps', '/ntmi/enc', '/ntmi/imu' ];

// set the address to forward them to
q.forwardAddr = NetAddr("169.254.1.2", 51900);

// make listeners for all of them that send to the forward address.
"making nufo forward functions:".postln;
q.nufoRelays = q.nufoMsgNames.collect { |msgName|
	var name = ("fwd_" ++ msgName.asString.drop(6)).asSymbol.postln;
	OSCdef(name, { |msg|
		// msg.postln;
		q.forwardAddr.sendMsg(*msg);
	}, msgName);
};

/// Or you may want to send influx values to an external process.

q.inphlux.action.add(\forward, {
	// get all outVals in order
	var outVals = q.inphlux.outNames.collect { |name|
		q.inphlux.outValDict[name]
	};
	// // uncomment this line to debug
	// outVals.postln;
	q.forwardAddr.sendMsg(\influxOuts, *outVals);
});

