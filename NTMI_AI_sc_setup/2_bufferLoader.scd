/// load global buffers

var globalBufFolder = q.prefs.active.bufferFolder;
var bufsName = \global;
if (globalBufFolder.notNil) {

	// if present, load global bufferfolder into q.bufs.global when booting
	MFdef('reloadBufs').add(bufsName, {
		MFdef(\bufLoad).value(
			globalBufFolder,
			{|buffers| // global doneFunc
				"*** % global buffers loaded.\n".postf(q.bufs[bufsName].size);
				"// assign with:\n"
				"MFdef('setBufRange').(Ndef('xyz'), q.bufs[%], %);\n"
				.postf(bufsName.cs, bufsName.cs);
			},
			'global'
		);
	});

	// and do it once when the file runs
	MFdef('reloadBufs').funcDict[bufsName].value;

};
