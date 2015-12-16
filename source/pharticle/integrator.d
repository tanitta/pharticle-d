module pharticle.integrator;
import pharticle;
import armos;
class Integrator {
	public{
		this(){
			_unitTime = 1.0;
		}
		
		void update(ref pharticle.Particle*[] particles){
			foreach (particle; particles) {
				euler(*particle);
			}
		}
		
		void unitTime(double time){
			_unitTime = time;
		}
		
		double unitTime()const{
			return _unitTime;
		}
	}
	
	private{
		void euler(ref pharticle.Particle particle){
			with(particle){
				velocity = velocity + acceleration * _unitTime;
				position = position + velocity * _unitTime;
				acceleration = ar.Vector3d(0, 0, 0);
			}
		}
		
		double _unitTime;
	}
}
