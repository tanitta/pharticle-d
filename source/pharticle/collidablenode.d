module pharticle.collidablenode;
import pharticle;
import armos;
import std.algorithm;
// struct LessCenter
struct CollidableNode{
	public{
		ar.Vector3d boxSizeMin()const{return _boxSizeMin;};
		
		ar.Vector3d boxSizeMax()const{return _boxSizeMax;};
		
		this(ref pharticle.Particle*[] particlePtrs){
			if(particlePtrs.length > 0){
				this.particlePtrs = particlePtrs;
				make_node();
			}
		}
	}
	
	private{
		ar.Vector3d _boxSizeMin;
		ar.Vector3d _boxSizeMax;
		pharticle.Particle*[] particlePtrs;
		CollidableNode[] nextNodes;
		
		void clear(){}
		
		void make_node(){
			fitBox();
			sortParticles(mostLargeAxis);
			devideParticles(mostLargeAxis);
		}
		
		
		
		int mostLargeAxis(){
			int most_large_axis = 0;
			double distance = _boxSizeMax[0] - _boxSizeMin[0];
			for(int axis = 1; axis < 3; axis++){
				auto currentDistance = _boxSizeMax[axis] - _boxSizeMin[axis];
				if (currentDistance>distance) {
					distance = currentDistance;
					most_large_axis = axis;
				}
			}
			return most_large_axis;
		}
		
		void fitBox(){
			_boxSizeMin = particlePtrs[0].position - particlePtrs[0].radius;
			_boxSizeMax = particlePtrs[0].position + particlePtrs[0].radius;
			
			foreach (particle; particlePtrs) {
				auto currentMin = particle.position - particle.radius;
				auto currentMax = particle.position + particle.radius;
				
				for (int axis = 0; axis < 3; axis++) {
					if(currentMin[axis] < _boxSizeMin[axis]){
						_boxSizeMin[axis] = currentMin[axis];
					}
					if(currentMax[axis] > _boxSizeMax[axis]){
						_boxSizeMax[axis] = currentMax[axis];
					}
				}
			}
		}
		
		void sortParticles(in int axis){
			bool less(pharticle.Particle* a, pharticle.Particle* b){
				return a.position[axis] < b.position[axis];
			}
			sort!(less)(particlePtrs);
		}
		
		void devideParticles(in int axis){
			auto splitLength = particlePtrs.length/2;
			pharticle.Particle*[] splitedParticlePtrs1;
			pharticle.Particle*[] splitedParticlePtrs2;
			for (ulong i = 0; i < splitLength;i++){
				if(i<splitLength){
					splitedParticlePtrs1 ~= particlePtrs[i];
				}else{
					splitedParticlePtrs2 ~= particlePtrs[i];
				}
			}
			nextNodes ~= CollidableNode(splitedParticlePtrs1);
			nextNodes ~= CollidableNode(splitedParticlePtrs2);
		};
	}
}
