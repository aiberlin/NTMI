// same as basic2 but 8 channels and less commentary:

s.latency = 0.05;

// // Hardware setup first:
/* // could check which devices are found:
ServerOptions.devices.postcs
*/

// "Setting server options: ".postln;
if (s.serverRunning) {
	q.warnWin(
		"Server options are being set when s is running already!"
		" Settings will not take effect until server is rebooted:".warn,
		"\ns.reboot;",
		"Server options!"
	);
};

/////// set to a specific device here by name
// s.options.device_("Fireface 400 (297)");

// set number of hardware input and output bus channels
s.options.numInputBusChannels_(8);		//
s.options.numOutputBusChannels_(8);		//

s.options.blockSize_(64);
s.options.hardwareBufferSize_(64*2);

s.options.memSize_(8192 * 16);

///// set plugins path to very self-contained:
s.options.ugenPluginsPath =
([ String.scDir +/+ "plugins" ]
++ [Standalone.internalExtDir]).join($:);

// recording options:
s
.recChannels_(q.numChans ? 8)			// record numChans
.recSampleFormat_("float"); // in float to recover from clipping

"*** to see server settings, do: \nq.postServerOptions;\n".postln;

q.postServerOptions = {
	"********** Server info : **********".postln;
	"s.name: % \n"
	"s.address: % \n"
	"s.latency: % \n"
	.postf(s.name, s.addr, s.latency);
	"server options:".postln;
	s.options.dump;
	"********************".postln;
	"serverConfig loaded.".postln;
	"********************".postln;
};


