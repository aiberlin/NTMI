/// load global buffers

var globalBufFolder = NTMI.globalBufFolder ? (NTMI.dir.userSFExamples +/+ "..");
var bufsName = \global;
var hasNoSFs = { |path|
	SoundFile.collect(globalBufFolder +/+ "*").isEmpty
};

NTMI.dir.scSoundfiles = Platform.resourceDir +/+ "sounds";

// buffers should be in global dict q, not in NTMI.bufs
q = q ? ();
q.bufs = q.bufs ? ();

if (globalBufFolder.isNil or: { hasNoSFs.(globalBufFolder) }) {
	globalBufFolder = NTMI.dir.userSFExamples;
	if (hasNoSFs.(globalBufFolder)) {
		globalBufFolder = NTMI.dir.scSoundfiles;
	};
};

// if present, load global bufferfolder into q.bufs.global when booting
MFdef('bufReload').add(bufsName, {
	MFdef(\bufLoad).value(
		globalBufFolder,
		{|buffers| // global doneFunc
			"*** % global buffers loaded from:\n%.\n"
			.postf(q.bufs[bufsName].size, globalBufFolder);
			"// assign with:\n"
			"MFdef('bufSetRange').(Ndef('xyz'), q.bufs[%], %);\n"
			.postf(bufsName.cs, bufsName.cs);
		},
		'global'
	);
});

// and do it once when the file runs
MFdef('bufReload').funcDict[bufsName].value;

