module pharticle.collisiondetector;
import pharticle;
import armos;
class CollisionDetector{
	public{
		this(){
			_reactionForceFunction = (ref pharticle.Particle p1, ref pharticle.Particle p2){
				ar.Vector3d d = p2.position - p1.position;
				double d_length = d.norm;
				double depth = d_length - ( p1.radius + p2.radius );
				if(depth < 0){
					p2.addForce(- depth*d.normalized*100.0);
				}
			};
		}

		void update(ref pharticle.Particle*[] particlePtrs, ref pharticle.ConstraintPair[] constraintPairs){
			if( particlePtrs.length > 1 ){
				_collidableTree = pharticle.CollidableNode(particlePtrs);
				foreach (ref particle; particlePtrs) {
					searchTree(particle, _collidableTree, constraintPairs);
				}
			}
		};
		unittest{
			import armos;
			pharticle.Particle*[] particlePtrs;
			particlePtrs ~= new pharticle.Particle;
			particlePtrs ~= new pharticle.Particle;
			particlePtrs ~= new pharticle.Particle;
			particlePtrs ~= new pharticle.Particle;
			particlePtrs[0].position = ar.Vector3d(0, 0, 0);
			particlePtrs[1].position = ar.Vector3d(1, 0, 0);
			particlePtrs[2].position = ar.Vector3d(9, 0, 0);
			particlePtrs[3].position = ar.Vector3d(10, 0, 0);
			
			auto collisionDetector = new pharticle.CollisionDetector();
			pharticle.ConstraintPair[] constraintPairs;
			collisionDetector.update(particlePtrs, constraintPairs);
			assert( constraintPairs.length == 4);
		}

		void setReactionForceFunction(void delegate(ref pharticle.Particle, ref pharticle.Particle) func){
			_reactionForceFunction = func;
		}
	}

	private{
		pharticle.CollidableNode _collidableTree;
		void delegate(ref pharticle.Particle, ref pharticle.Particle) _reactionForceFunction;
		
		void searchTree(ref pharticle.Particle* particle, ref pharticle.CollidableNode node, ref pharticle.ConstraintPair[] constraintPairs){
			if(checkParticleIsInBoundingBox(particle, node)){
				if (node.isLeef) {
					if(particle != node.particles[0] ){
						detectDetail(particle, node.particles[0], constraintPairs);
					}
				}else{
					foreach (ref nextNode; node.nextNodes) {
						searchTree(particle, nextNode, constraintPairs);
					}
				}
			}
		};

		bool checkParticleIsInBoundingBox(in pharticle.Particle* particle, in pharticle.CollidableNode node)const{
			bool isInside = true;
			for (int axis = 0; axis < 3; axis++) {
				if(particle.position[axis] + particle.radius < node.boxSizeMin[axis] || node.boxSizeMax[axis] < particle.position[axis] - particle.radius){
					isInside = false;
				}
			}
			return isInside;
		}

		void detectDetail(ref pharticle.Particle* particle1, ref pharticle.Particle* particle2, ref pharticle.ConstraintPair[] constraintPairs){
			bool isColliding= ( particle1.position - particle2.position ).norm < particle1.radius + particle2.radius;
			if(isColliding){
				constraintPairs ~= pharticle.ConstraintPair(particle1, particle2, _reactionForceFunction);
			}
		}
	}
}
