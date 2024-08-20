/*** Use your own soundfiles ****/

/// NTMI quark has a folder with some example soundfiles
// in the quark folder:
(NTMI.dir.setup +/+ "soundfiles").openOS;

// this folder is automagically copied to the user dir:
(NTMI.dir.user +/+ "soundfiles").openOS;
NTMI.dir.userSoundfiles.openOS;

// by default, NTMI loads these soundfiles into buffers,
// and puts them in a dictionary called q.bufs,
// under the name 'global':
q.bufs.global;
q.bufs.global.choose.play;

// you can put multiple collections of soundfiles
// into this userDir, and load them into q.bufs with this function:
MFdef(\bufLoad).((NTMI.dir.userSoundfiles +/+ "/myfavorites"));
// then they are available by name, such as
q.bufs.adcfaves;

// Currently the sound processes that use buffers are:
Ndef(\granbuf), Ndef(\bufRd)

// now you can switch the buffers to use in an Ndef like this:
// arguments are: which ndefs should use them, and name the buffers to use:
MFdef(\bufSetRange).([Ndef(\granbuf), Ndef(\bufRd)], q.bufs.global);
MFdef(\bufSetRange).([Ndef(\granbuf), Ndef(\bufRd)], q.bufs.myfavorites);

// to see how to write an Ndef that uses this, see Ndef(\granbuf)
Document.open(NTMI.process.procPath.replace("*", "granbuf"));


// Ndef(\wsetta) also uses soundfiles, but since it is based on Wavesets,
und
NTMI.wse.loadWSEs(NTMI.dir.userSoundfiles +/+ "myfavorites");
