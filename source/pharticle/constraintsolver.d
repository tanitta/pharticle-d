module pharticle.constraintsolver;
import pharticle;

class ConstraintSolver{
	public{
		void update(ref pharticle.ConstraintPair[] constraintPairs){
			foreach (ref pair; constraintPairs) {
				pair.adaptForce;
			}
		}
	}
}
