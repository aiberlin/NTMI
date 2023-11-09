
c = MKtlElementCollective(MKtl(\ntmi), \ledBk, (
	elements: (1..8).collect { |num, i|
		var name = num.asSymbol;
		(type: \pad, ioType: \out)
	};
));

MKtl(\ntmi).device.source.sendMsg("/ntmi/ledCtl/back", 0, 1, 1, 1);