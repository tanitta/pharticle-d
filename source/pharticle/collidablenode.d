module pharticle.collidablenode;
import pharticle;
import armos;
import std.algorithm;

struct CollidableNode{
	public{
		ar.Vector3d boxSizeMin()const{return _boxSizeMin;};
		ar.Vector3d boxSizeMax()const{return _boxSizeMax;};
		CollidableNode[] nextNodes(){return _nextNodes;}
		pharticle.Particle[] particles(){return _particlePtrs;}
		ulong numNextNodes()const{return _nextNodes.length;}
		ulong numParticles()const{return _particlePtrs.length;}
		bool isLeef()const{return ( numParticles == 1 ); }

		this(pharticle.Particle[] particlePtrs){
			_particlePtrs = particlePtrs;
			fitBox();
			if(particlePtrs.length > 1){
				sortParticles(mostLargeAxis);
				devideParticles(mostLargeAxis);
			}
		}
		unittest{
			pharticle.Particle[] particlePtrs;
			particlePtrs ~= new pharticle.Particle;
			particlePtrs ~= new pharticle.Particle;
			particlePtrs ~= new pharticle.Particle;
			particlePtrs ~= new pharticle.Particle;
			particlePtrs[0].position = ar.Vector3d(0, 0, 0);
			particlePtrs[1].position = ar.Vector3d(1, 0, 0);
			particlePtrs[2].position = ar.Vector3d(2, 0, 0);
			particlePtrs[3].position = ar.Vector3d(3, 0, 0);
			auto node = CollidableNode(particlePtrs);
			assert( node.numParticles == 4);
			assert( node.numNextNodes== 2);
			assert( node.nextNodes[0].numParticles == 2);
			assert( node.nextNodes[1].numParticles == 2);
		}
	}

	private{
		ar.Vector3d _boxSizeMin;
		ar.Vector3d _boxSizeMax;
		pharticle.Particle[] _particlePtrs;
		CollidableNode[] _nextNodes;

		int mostLargeAxis()const{
			int most_large_axis = 0;
			double distance = _boxSizeMax[0] - _boxSizeMin[0];
			for(int axis = 1; axis < 3; axis++){
				immutable currentDistance = _boxSizeMax[axis] - _boxSizeMin[axis];
				if (currentDistance>distance) {
					distance = currentDistance;
					most_large_axis = axis;
				}
			}
			return most_large_axis;
		}
		unittest{
			pharticle.Particle[] particlePtrs;
			particlePtrs ~= new pharticle.Particle;
			particlePtrs ~= new pharticle.Particle;
			particlePtrs ~= new pharticle.Particle;
			particlePtrs ~= new pharticle.Particle;
			particlePtrs[0].position = ar.Vector3d(0, 0, 0);
			particlePtrs[1].position = ar.Vector3d(0, 1, 0);
			particlePtrs[2].position = ar.Vector3d(0, 2, 0);
			particlePtrs[3].position = ar.Vector3d(0, 3, 0);
			auto node = CollidableNode(particlePtrs);
			assert( node.mostLargeAxis == 1);
			assert( node.nextNodes[0].mostLargeAxis == 1);
			assert( node.nextNodes[1].mostLargeAxis == 1);
		}

		void fitBox(){
			_boxSizeMin = _particlePtrs[0].position - _particlePtrs[0].radius;
			_boxSizeMax = _particlePtrs[0].position + _particlePtrs[0].radius;

			foreach (particle; _particlePtrs) {
				immutable currentMin = particle.position - particle.radius;
				immutable currentMax = particle.position + particle.radius;

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
		unittest{
			pharticle.Particle[] particlePtrs;
			particlePtrs ~= new pharticle.Particle;
			particlePtrs ~= new pharticle.Particle;
			particlePtrs ~= new pharticle.Particle;
			particlePtrs ~= new pharticle.Particle;
			particlePtrs[0].position = ar.Vector3d(0, 2, 0);
			particlePtrs[1].position = ar.Vector3d(0, 0, 0);
			particlePtrs[2].position = ar.Vector3d(0, 3, 0);
			particlePtrs[3].position = ar.Vector3d(0, 1, 0);
			auto node = CollidableNode(particlePtrs);
			assert( node.boxSizeMin == ar.Vector3d(-1, -1, -1));
			assert( node.boxSizeMax == ar.Vector3d(1, 4, 1));
		}

		void sortParticles(in int axis){
			bool less(pharticle.Particle a, pharticle.Particle b){
				return a.position[axis] < b.position[axis];
			}
			sort!(less)(_particlePtrs);
		}
		unittest{
			pharticle.Particle[] particlePtrs;
			particlePtrs ~= new pharticle.Particle;
			particlePtrs ~= new pharticle.Particle;
			particlePtrs ~= new pharticle.Particle;
			particlePtrs ~= new pharticle.Particle;
			particlePtrs[0].position = ar.Vector3d(0, 2, 0);
			particlePtrs[1].position = ar.Vector3d(0, 0, 0);
			particlePtrs[2].position = ar.Vector3d(0, 3, 0);
			particlePtrs[3].position = ar.Vector3d(0, 1, 0);
			auto node = CollidableNode(particlePtrs);
			assert( node.particles[0].position == ar.Vector3d(0, 0, 0) );
			assert( node.particles[1].position == ar.Vector3d(0, 1, 0) );
			assert( node.particles[2].position == ar.Vector3d(0, 2, 0) );
			assert( node.particles[3].position == ar.Vector3d(0, 3, 0) );
		}

		void devideParticles(in int axis){
			immutable splitLength = _particlePtrs.length / 2;
			_nextNodes ~= CollidableNode(_particlePtrs[0 .. splitLength]);
			_nextNodes ~= CollidableNode(_particlePtrs[splitLength .. $]);
		};
		unittest{
			pharticle.Particle[] particlePtrs;
			particlePtrs ~= new pharticle.Particle;
			particlePtrs ~= new pharticle.Particle;
			particlePtrs ~= new pharticle.Particle;
			particlePtrs ~= new pharticle.Particle;
			particlePtrs[0].position = ar.Vector3d(0, 0, 0);
			particlePtrs[1].position = ar.Vector3d(1, 0, 0);
			particlePtrs[2].position = ar.Vector3d(2, 0, 0);
			particlePtrs[3].position = ar.Vector3d(3, 0, 0);
			auto node = CollidableNode(particlePtrs);
			assert( node.numParticles == 4);
			assert( node.numNextNodes== 2);
			assert( node.nextNodes[0].numParticles == 2);
			assert( node.nextNodes[0].numNextNodes == 2);
			assert( node.nextNodes[1].numParticles == 2);
			assert( node.nextNodes[1].numNextNodes == 2);
		}
	}
}
