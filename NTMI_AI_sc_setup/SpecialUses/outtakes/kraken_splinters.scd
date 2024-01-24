
//////////////////// Now attach to NTMI - quick and dirty
/****
(
// raw influx - ugly but would work
// influx first:
MFdef(\kr_pots).add(\influx, { |rawvals|
	var values = rawvals.linlin(0, 1023, -1, 1);
	var inNames = NTMI.inphlux.inNames.keep(values.size);
	NTMI.inphlux.set(*[inNames, values].flop.flat);
});

MFdef(\kr_ribs).add(\influx, { |rawvals|
	var values = rawvals.linlin(0, 1023, 0, 1) * [-1, 1];
	var inNames = NTMI.inphlux.inNames.drop(10).keep(values.size);
	NTMI.inphlux.set(*[inNames, values].flop.flat);
});
);

// and turn them off again:
(
MFdef(\kr_ribs).disable(\influx);
MFdef(\kr_pots).disable(\influx);
);
****/