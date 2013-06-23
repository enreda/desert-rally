var xRotation = 0;
var yRotation = 0;

var frameNo = 0;

for (var z = -20; z <= 20; z += 2) {
	for (var x = 0; x <= 20; x+= 2) {
		++ frameNo;
		Rotate(null, x, 0, z, siAbsolute, siGlobal, siObj, siXYZ, null, null, null, null, null, null, null, 0, null);
		SaveKey("Audi.kine.local.rotx,Audi.kine.local.roty,Audi.kine.local.rotz", frameNo, null, null, null, false, null);
	}
}