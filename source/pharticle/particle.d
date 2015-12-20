module pharticle.particle;
import armos;
class Particle
{
	double mass = 1.0;
	double radius = 1.0;
	ar.Vector3d position;
	ar.Vector3d velocity;
	ar.Vector3d acceleration;
	bool isStatic = false;

	void addForce(ar.Vector3d force){
		acceleration = acceleration + force / mass;
	}
}
