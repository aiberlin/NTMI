*** HOW_TO_PERSONALIZE - 3a user_POOL.scd

// The userPOOL folder is the best place to keep all the resources
// you want to use with NTMI, so you can personalize it to your wishes.
// It is located here:

NTMI.dir.userPOOL
NTMI.dir.userPOOL.openOS

/*
It has several subfolders for code files with customized:
server setups,
sound processes and setups,
interfaces to connect,
effects patches to add,
and startup file examples.

So far, this is used to choose the sound processes you want to use.
By default, NTMI loads all sound processes in ... /2_process/:
*/

(NTMI.dir.userPOOL +/+ "/2_process/*.scd").pathMatch.printAll.size;

// You can set these by hand in your startup file,
// before you run NTMI, e.g. load just these ndefs:
NTMI.process.namesToLoad = [
	'bleepo', 'filterFB', 'granbuf', 'formSing',
	'beatX', \revFB, 'rjkChaos', 'varsawFB', 'xFMSH',
];

// you can also set which presets some processes should load
NTMI.initialPresetNames = [
	'bleepo' -> 'vocca',
	'xFMSH' -> 'border',
	\revFB -> \slolo,
	'rjkChaos' -> 89, // can also be an index number
	// or a function that generates an index number:
	\robTron -> { |pre| 2000.rand },
];
