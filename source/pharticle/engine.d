module pharticle.engine;
import pharticle;
class Engine {
	public{
		this(){
			_unitTime = 1.0;
			_collisionDetector = new pharticle.CollisionDetector;
			_constraintSolver = new pharticle.ConstraintSolver;
			_integrator = new pharticle.Integrator;
		}
		
		void update(){
			_collisionDetector.update(_particlePtrs, _constraintPairs);
			_constraintSolver.update(_constraintPairs);
			_integrator.update(_particlePtrs);
			
			_particlePtrs = [];
			_constraintPairs = [];
		}
		
		void add(ref pharticle.Particle p){
			_particlePtrs ~= &p;
		}
		
		void add(ref pharticle.ConstraintPair pair){
			_constraintPairs ~= pair;
			pharticle.ConstraintPair pair2 = pharticle.ConstraintPair(pair.particles[1], pair.particles[0], pair.forceFunction);
			_constraintPairs ~= pair2;
		}
		
		void add(ref pharticle.Particle particle1, ref pharticle.Particle particle2, void delegate(ref pharticle.Particle, ref pharticle.Particle) func){
			pharticle.ConstraintPair pair1 = pharticle.ConstraintPair(particle1, particle2, func);
			pharticle.ConstraintPair pair2 = pharticle.ConstraintPair(particle2, particle1, func);
			_constraintPairs ~= pair1;
			_constraintPairs ~= pair2;
		}
		
		void unitTime(double time){
			_integrator.unitTime = time;
		}
		
		double unitTime()const{
			return _integrator.unitTime;
		}
		
		void setReactionForceFunction(void delegate(ref pharticle.Particle, ref pharticle.Particle) func){
			_collisionDetector.setReactionForceFunction(func);
		}
	}
	
	private{
		pharticle.CollisionDetector _collisionDetector;
		pharticle.ConstraintSolver _constraintSolver;
		pharticle.Integrator _integrator;
		
		pharticle.Particle*[] _particlePtrs;
		pharticle.ConstraintPair[] _constraintPairs;
		double _unitTime;
	}
}
