/// load global buffers on startup

var globalBufFolder = q.prefs.active.bufferFolder;
// if present, load global bufferfolder into q.bufs.global
if (globalBufFolder.notNil) {
	MFdef(\bufLoad).value(
		globalBufFolder,
		{|buffers| // global doneFunc
			"*** % global buffers loaded.\n".postf(q.samplo.size);
			"// assign with:\n"
			"MFdef('setBufRange').(Ndef('xyz'), q.samplo, 'samplo');\n".postln;
		},
		'global'
	);
};
