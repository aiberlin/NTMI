//
// "\n**********  loading serverConfig:  **********".postln;

// tweak server latency for fast response and rare "late" complaints:
// default latency is 0.2 secs, which feels slow when playing;
// less than 0.03 may introduce many late messages from server.
// latency nil means do things immediately, but will compromise timing:
// it quantizes to the hardwareBufferSize border.

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
// s.options.device_("RME Babyface");

// set number of hardware input and output bus channels
s.options.numInputBusChannels_(2);		//
s.options.numOutputBusChannels_(2);		//
// set control rate blockSize, default 64 samples
s.options.blockSize_(64);
// set hardwareBufferSize to lowest power of two hardware allows before glitching
s.options.hardwareBufferSize_(64*2);

// reserve enough realtime memory (in kiloBytes) for delay lines etc
s.options.memSize_(8192 * 16);

///// set plugins path to very self-contained: read all internal plugins
///// PLUS any plugins found in the Standalone's internal Extensions dir:
///// so if we use any sc3-plugins, put them there ...
s.options.ugenPluginsPath =
([ String.scDir +/+ "plugins" ]
++ [Standalone.internalExtDir]).join($:);


// recording options:
s
.recChannels_(q.numChans ? 2)			// record numChans
.recSampleFormat_("float"); // in float to recover from clipping

"\n/// to see server settings, do: \nq.postServerOptions;".postln;
