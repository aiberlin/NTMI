/// load global buffers

var globalBufFolder = NTMI.dir.userSFExamples;
var bufsName = \global;

// buffers should be in global dict q, not in NTMI.bufs
q = q ? ();
q.bufs = q.bufs ? ();

if (globalBufFolder.notNil) {

	// if present, load global bufferfolder into q.bufs.global when booting
	MFdef('bufReload').add(bufsName, {
		MFdef(\bufLoad).value(
			globalBufFolder,
			{|buffers| // global doneFunc
				"*** % global buffers loaded from:\n%.\n"
				.postf(q.bufs[bufsName].size, globalBufFolder);
				"// assign with:\n"
				"MFdef('bufSetRange').(Ndef('xyz'), NTMI.bufs[%], %);\n"
				.postf(bufsName.cs, bufsName.cs);
			},
			'global'
		);
	});

	// and do it once when the file runs
	MFdef('bufReload').funcDict[bufsName].value;
};
