module pharticle.constraintpair;
struct ConstraintPair {
	public{
		pharticle.Particle*[] particles(){return _particlePtrs;}
		void delegate(ref pharticle.Particle, ref pharticle.Particle) forceFunction(){return _forceFunction;}
		
		this(ref pharticle.Particle* p1, ref pharticle.Particle* p2, void delegate(ref pharticle.Particle, ref pharticle.Particle) func){
			_particlePtrs[0] = p1;
			_particlePtrs[1] = p2;
			_forceFunction = func;
		}
		
		this(ref pharticle.Particle p1, ref pharticle.Particle p2, void delegate(ref pharticle.Particle, ref pharticle.Particle) func){
			_particlePtrs[0] = &p1;
			_particlePtrs[1] = &p2;
			_forceFunction = func;
		}
		
		void adaptForce(){
			_forceFunction(*( particles[0] ), *( particles[1] ));
		}
	}
	
	private{
		pharticle.Particle*[2] _particlePtrs;
		void delegate(ref pharticle.Particle, ref pharticle.Particle) _forceFunction;
	}	
}
