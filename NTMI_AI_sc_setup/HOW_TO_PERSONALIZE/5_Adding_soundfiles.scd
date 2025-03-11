/*** Use your own soundfiles ****/

/// NTMI has a folder with example soundfiles
// in the quark folder:
(NTMI.dir.setup +/+ "soundfiles").openOS;

// this folder is automagically copied to the user dir:
(NTMI.dir.user +/+ "soundfiles").openOS;
NTMI.dir.userSoundfiles.openOS;

// By default, NTMI loads these soundfiles into buffers,
// and puts them in a dictionary called q.bufs,
// under the name 'global':
q.bufs.global;
q.bufs.global.choose.play;

// you can put multiple collections of soundfiles
// into this userDir, and load them into q.bufs with this function:
MFdef(\bufLoad).((NTMI.dir.userSoundfiles +/+ "/myfavorites/"));
// then they are available by name, such as
q.bufs.myfavorites;
q.bufs.myfavorites.choose.play;

// Currently the sound processes that use buffers are:
Ndef(\granbuf)
Ndef(\bufRd)

// You can switch the buffers to use in an Ndef like this:
// arguments are: which ndefs should use them, and name the buffers to use:
MFdef(\bufSetRange).([Ndef(\granbuf), Ndef(\bufRd)], q.bufs.global);
MFdef(\bufSetRange).([Ndef(\granbuf), Ndef(\bufRd)], q.bufs.myfavorites);

// to see how to write an Ndef that uses this, see Ndef(\granbuf)
Document.open(NTMI.process.procPath.replace("*", "granbuf"));


// Ndef(\wsetta) uses soundfiles based on WavesetsEvents,
// and stores them in its own NTMI dict, at
NTMI.wse;
NTMI.wse.keys;
NTMI.wse.soundfiles;
NTMI.wse.wses;

// To load your preferred soundfiles for Wavesets/wsetta use, do:
NTMI.wse.loadWSEs(NTMI.dir.userSoundfiles +/+ "myfavorites");

NTMI.wse.soundfiles.choose.play;
NTMI.wse.wses;

// ToDo: it should be easy to keep muliple lists of wavesets
// loaded and switchable, as with q.bufs.<name>