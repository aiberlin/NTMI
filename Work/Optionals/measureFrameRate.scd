
/// measure incoming imu speed:
/*** sketch:
q.accelcount = 0;
q.times = List[];
q.times.size;

MFdef(\ntmiImuFunc).add(\counter, {
	var el = MKtl(\ntmi).elAt(\accel, \x);
	q.times.add (el.lastUpdateTime);
	if (q.accelcount >= 1000) {
		"done".postln;
		MFdef(\ntmiImuFunc).remove(\counter);
	};
	q.accelcount = q.accelcount + 1;Pw
});
***/

/////// not working yet:PP
/// measure incoming imu speed:
q.speedTest = q.speedTest ? ();
q.speedTest.imuRun = { |dict, time = 10|
	q.speedTest.imuCount = 0;
	q.speedTest.imuTimes = List[];
	q.speedTest.imuElem = MKtl(\ntmi).elAt(\accel, \x);
	MFdef(\ntmiImuFunc).add(\counter, {
		q.speedTest.imuTimes (q.speedTest.imuElem.lastUpdateTime);
	});
	defer ({
		MFdef(\ntmiImuFunc).remove(\counter);
		"q.speedTest imu done: % imu msgs in % secs.".postf(q.speedTest.imuTimes, time);
		"see also q.speedTest.imuTimes;".postln
	}, 10);
};


q.speedTest.imuRun;