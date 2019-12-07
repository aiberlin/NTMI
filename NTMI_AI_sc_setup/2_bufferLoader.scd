var globalBufFolder = q.prefs.active.bufferFolder;
// load the ones for now
if (globalBufFolder.notNil) {
	MFdef(\bufLoad).value(
		globalBufFolder,
		{|buffers| // global doneFunc
			q.samplo = buffers;
			"*** q.samplo: % global buffers loaded.\n".postf(q.samplo.size);
			"// assign with:\n"
			"MFdef('setBufRange').(Ndef('xyz'), q.samplo, 'samplo');\n".postln;
		}
	);
};

