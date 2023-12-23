/*** Use your own soundfiles ****/

/// there is a folder with some example files at:
(NTMI.dir.setup +/+ "soundfiles").openOS;

// by default, these are loaded here:
q.bufs.global;

// this folder is automagically copied to the user dir:
(NTMI.dir.user +/+ "soundfiles").openOS;

// you can put multiple collections of soundfiles there,
// and load them with this function:
MFdef(\bufLoad).((NTMI.dir.user +/+ "soundfiles/adcfaves"));
// then they are available as
q.bufs.adcfaves;

// now you can switch the buffers to use in an Ndef like this:
MFdef(\bufSetRange).(Ndef(\granbuf), q.bufs.global, \global);
MFdef(\bufSetRange).(Ndef(\granbuf), q.bufs.adcfaves, \global);

// to see how to write an Ndef so this works,
// take a look at Ndef(\granbuf)
Document.open(NTMI.process.procPath.replace("*", "granbuf"));

