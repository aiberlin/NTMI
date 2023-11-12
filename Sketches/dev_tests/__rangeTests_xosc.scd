// raw tests for xosc imu ranges

MKtl(\xosc).elAt(\accel)[0].deviceSpec;
MKtl(\xosc).elAt(\gyro)[0].deviceSpec;
MKtl(\xosc).elAt(\magnet)[0].deviceSpec;
MKtl(\xosc).elAt(\imu9).valueAction = 0.5!9
MKtl(\xosc).collectivesDict[\imu].value = 0.5!10
MKtl(\xosc).collectivesDict[\imu].valueAction = 0.6!10
MKtl(\xosc).collectivesDict[\imu];


MKtl(\xosc).collectivesDict[\imu].value = 0; MFdef(\imuFunc).value;
MKtl(\xosc).collectivesDict[\imu].value = 0.2; MFdef(\imuFunc).value;
MKtl(\xosc).collectivesDict[\imu].value = 0.5; MFdef(\imuFunc).value;
MKtl(\xosc).collectivesDict[\imu].value = 0.7; MFdef(\imuFunc).value;
MKtl(\xosc).collectivesDict[\imu].value = 1.0; MFdef(\imuFunc).value;

// test the raw message values:
n = NetAddr.localAddr;
// close to 1.0
n.sendMsg(\imu, 130, 130, 130, 1.65, 1.65, 1.65, 0.82, 0.82, 0.82);
n.sendMsg(\imu, 130, 130, 130, 1.65, 1.65, 1.65, 0.82, 0.82, 0.82);
// 0 centered:
n.sendMsg(\imu, *0.0!10);
// ca. 0.5
n.sendMsg(\imu, 65, 65, 65, 0.8, 0.8, 0.8, 0.4, 0.4, 0.4, 3.5);

q.inphlux.outOffsets;
q.inphlux.dump;
