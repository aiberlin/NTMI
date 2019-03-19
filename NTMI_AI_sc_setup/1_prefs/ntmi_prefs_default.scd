(
name: \default,
numChans: 2,
defaultActives: [ 'allArm', 'brushes', 'moogSing', 'xFMSH' ],
mfxFunc: {
	q.mFX.pxChain.add('3AdCVerb', 0.1);
	q.mFX.pxChain.add('3ring', 0.1);
	// q.mFX.pxChain.add('5HPF', 0.1);
}
)