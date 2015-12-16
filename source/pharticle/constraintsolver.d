module pharticle.constraintsolver;
import pharticle;

class ConstraintSolver{
	public{
		void update(ref pharticle.ConstraintPair[] constraintPairs){
			foreach (pair; constraintPairs) {
				// pair.forceFunction(*pair.particles[0], *pair.particles[1]);
				pair.adaptForce;
			}
		}
	}
}
