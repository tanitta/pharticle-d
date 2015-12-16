import std.stdio;
import std.math;
import pharticle;
import armos;

struct Point{
	pharticle.Particle particle;
	ar.Mesh mesh;
	this(ar.Vector3d position){
		particle.position = position;
		particle.radius = 15;
		particle.mass = 1;
		mesh = ar.circlePrimitive(0, 0, 0, 1);
	}
	
	void draw(){
		ar.pushMatrix;
			ar.translate(cast(ar.Vector3f)particle.position);
			ar.scale(particle.radius*0.5);
			ar.setColor(255, 255, 255);
			mesh.drawFill;
			ar.setColor(255, 255, 255);
		ar.popMatrix;
	}
}

class TestApp : ar.BaseApp{
	pharticle.Engine _engine;
	Point[] _points;
	this(){
		_engine = new pharticle.Engine;
	}
	
	void setup(){
		ar.targetFps = 30;
		_engine.unitTime = 0.01;
		_points = [];
		_points ~= Point(ar.Vector3d(100, 150, 0));
		for (int x = 0; x < 10; x++) {
			for (int y = 0; y < 80; y++) {
				_points ~= Point(ar.Vector3d(x*10, y*10, 0));
			}
		}
		
		_points[0].particle.isStatic = true;
	}
	
	void update(){
		for (int i = 0; i < 10; i++) {
			foreach (ref point; _points) {
				point.particle.addForce(-point.particle.velocity*0.1);
				double d = ( _points[0].particle.position - point.particle.position ).norm;
				point.particle.addForce(( _points[0].particle.position - point.particle.position ).normalized*pow(d, 1.5)*0.001);
				// point.particle.radius = ar.clamp(15.0 - point.particle.velocity.norm*0.02, 0.1, 100);
				point.particle.radius =  ar.clamp( 50.0 - ( _points[0].particle.position - point.particle.position ).norm*0.11, 1, 50 )*0.7;
				_engine.add(point.particle);
			}
			_engine.update;
			
		}
	}	
	
	void draw(){
		( ar.fpsUseRate*100 ).writeln;
		foreach (ref point; _points) {
			point.draw();
		}
	}
	
	void mouseMoved(ar.Vector2f position, int button){
		_points[0].particle.position = ar.Vector3d(position[0], position[1], 0);
	}
}

void main(){
	ar.run(new TestApp);
}
