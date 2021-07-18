// only add wsetta to Butz if the gui func exists:
if (WinBounds.makeFuncs[\wsetta].notNil) {
	Butz.add(\wsetta, { WinBounds.showOrMake(\wsetta) });
};
