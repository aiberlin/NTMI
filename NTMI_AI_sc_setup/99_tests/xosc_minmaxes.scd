[ '/imu', -1.9512195587158, 2.3170733451843, 0.24390244483948, -0.63916015625, -0.1494140625, 0.7666015625, 0.3282051384449, 0.0051282052882016, -0.26410257816315, 45.379413604736 ]

OSCdef.all(_.disable);
OSCdef.trace(false);

q.osc = q.osc ? ();
q.osc.imuMax = 0!10;
q.osc.imuMin = 0!10;

thisProcess.openUDPPort(8000);

OSCdef(\imuMax, { |msg|
	msg.drop(1).do { |val, i|
		if(q.osc.imuMax[i] < val) {
			q.osc.imuMax[i] = val;
			q.osc.imuMax.round(0.0001).postln;
		};
		if(q.osc.imuMin[i] > val) {
			q.osc.imuMin[i] = val;
			q.osc.imuMin.round(0.0001).postln;
		};
	};
}, '/imu').enable;

/////// max/mins with wild shaking:
q.osc.imuMax.max(q.osc.imuMin.abs);
[ -990.12194824219, -1172.2561035156, -770.18292236328, -8.05615234375, -5.896484375, -6.95458984375, -0.553846180439, -0.82564103603363, -0.5, 0 ]

q.osc.imuMin;

[ 1417.4391, 1460.3658, 761.5854, 6.4185, 3.0757, 9.8003, 0.4256, 0.2128, 0.4795, 59.0265 ].size

