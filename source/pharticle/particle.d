module pharticle.particle;
import armos;
struct Particle{
	int id(){return _id;}
	double mass = 1.0;
	double radius = 1.0;
	ar.Vector3d position;
	ar.Vector3d velocity;
	ar.Vector3d acceleration;
	
	bool isStatic = false;

	private int _id;
	
	this(int id){}
}
