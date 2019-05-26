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

///// If Standalone, set plugins path to very self-contained: read all internal plugins
///// PLUS any plugins found in the Standalone's internal Extensions dir:
///// so if we use any sc3-plugins, put them there ...
if (\Standalone.asClass.notNil) {
	"Standalone, so using special ugenPluginsPath:".postln;
	s.options.ugenPluginsPath =
	([ String.scDir +/+ "plugins" ]
		++ [\Standalone.asClass.internalExtDir]).join($:).postcs;
} {
	"no standalone, using default ugenPluginsPath.";
};

// recording options:
s
.recChannels_(q.numChans ? 8)			// record numChans
.recSampleFormat_("float"); // in float to recover from clipping

"\n/// to see server settings, do: \nq.postServerOptions;".postln;
