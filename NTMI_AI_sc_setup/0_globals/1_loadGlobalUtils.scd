// RUN this entire file from elsewhere to have convenience functions //

q = q ? ();

// limit to sounding ndefs
q.getNdefs = { Ndef.dictFor(s).envir.select({ |ndef| ndef.rate == \audio }).asArray.sort { |px1, px2| px1.key < px2.key } };
q.getTdefs = { Tdef.all.values.asArray.sort { |px1, px2| px1.key < px2.key } };
q.getPdefs = { Pdef.all.values.asArray.sort { |px1, px2| px1.key < px2.key } };

q.getInfluxDestins = {
	// automagically attach all existing proxies to GUI Buttons. (max. 5 for now..)
	q.getNdefs ++ q.getTdefs ++ q.getPdefs
};

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

///////////// Buffery:

/// a global place for all buffer lists
q.bufs = ();

// function to load a list of buffers from soundfile paths
MFdef(\bufLoad).add(\loadFiles, { |folderPath, doneFunc, buflistname|
	if (s.serverRunning.not) {
		warn("cannot load buffers when server not running.");
	} {
		forkIfNeeded {
			var buffers;
			var paths = (folderPath +/+ "*.*").pathMatch.select { |path|
				["WAV", "wav", "AIF", "aif", "AIFF", "aiff" ]
				.includesEqual( path.split($.).last )
			};

			if (paths.isEmpty) {
				"*** MFdef('bufLoad') : no files found at path %\n".postf(folderPath);
				"*** not loading any buffers! ***\n".postln;
			} {

				"/// loading % files from Folder'%'\n ... ".postf(paths.size, folderPath.basename);
				buffers = paths.collect { |path|
					// check for valid soundfile !
					Buffer.readChannel(s, path, channels: [0])
				};

				s.sync;

				buflistname = buflistname ?? buffers.first.path.dirname.basename.asSymbol;
				q.bufs.put(buflistname.asSymbol, buffers);

				// make them available globally like this:
				// Spec.add(\buf, [buffers.first.bufnum, buffers.last.bufnum]);
				// if need rebuilding, if changing to new buffers in runtime,
				// so we use the latest num.
				// Ndef(\x_samplo).rebuild;
				"/// buffers '%' loaded - access with: \n".postf(folderPath.basename);
				"q.bufs.%;\n\n".postf(buflistname);
				doneFunc.value(buffers, buflistname);

				s.sync;
			}
		}
	}
});

MFdef(\setBufRange).add(\setNdefs, { |ndefs, buffers, buflistname|
	var range;
	////// assuming contiguous numbers
	if (buffers.size < 1) {
		"*** setBufRange: no buffers given, cannot set bufRange!".postln;
	} {
		range = [ buffers.first.bufnum, buffers.last.bufnum ];
		ndefs.do { |ndef|
			"// % now uses % buffers in q.bufs.%, sndBufRange %.\n"
			.postf(ndef, buffers.size, buflistname, range);
			ndef.addHalo(\sndBufRange, range);
			ndef.rebuild;
		};
	}
});

/*
// example/test - load specific samples for Ndef(\granbuf):
MFdef(\bufLoad).value(
	"~/Seafile/AI_CC/granulatspeach/textbuffers/",
	{ |buffers, buflistname|
		// tell a specific Ndef to use these buffers:
		MFdef(\setBufRange).(Ndef(\granbuf), buffers, buflistname);
	},
	\texts // name of buffer list within q.bufs
);

/// point an Ndef to some buffers:
MFdef(\setBufRange).(Ndef(\granbuf), q.bufs.texts, \texts);

/// or several at once:
MFdef(\setBufRange).([ Ndef(\granbuf), Ndef(\xyz)], q.bufs.texts, \texts);
Ndef(\granbuf).getHalo.sndBufRange;

*/

// q.bufs.texts.size;
// q.bufs.textbuffers.choose.play;
//
