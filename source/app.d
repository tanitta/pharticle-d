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
			ar.Vector3f polyPosition = cast(ar.Vector3f)particle.position;
			polyPosition[2] = -particle.radius;
			ar.translate(polyPosition);
			ar.scale(particle.radius*1.0);
			auto c = ar.map(particle.radius, 1.0, 15.0, 0.0, 255.0);
			ar.setColor(c);
			mesh.drawFill;
			ar.setColor(255, 255, 255);
		ar.popMatrix;
	}
}

class TestApp : ar.BaseApp{
	pharticle.Engine _engine;
	Point[] _points;
	ar.Vector3d mousePosition = ar.Vector3d(0, 0, 0);
	bool isHeating = true;
	this(){
		_engine = new pharticle.Engine;
	}
	
	void setup(){
		ar.enableDepthTest;
		ar.disableFbo;
		ar.targetFps = 30;
		_engine.unitTime = 0.05;
		
		_points = [];
		for (int x = 0; x < 70; x++) {
			for (int y = 0; y < 70; y++) {
				_points ~= Point(ar.Vector3d(x*10+10, y*10+10, 0));
			}
		}
		
		_engine.setReactionForceFunction = (ref pharticle.Particle p1, ref pharticle.Particle p2){
			ar.Vector3d d = p2.position - p1.position;
			double d_length = d.norm;
			double depth = d_length - ( p1.radius + p2.radius );
			if(depth < 0){
				ar.Vector3d vab = p2.velocity - p1.velocity;
				double cd = 50;
				double e = 0.0;
				double c = (p1.mass * p2.mass)/(p1.mass+p2.mass) * ( (1.0+e) * vab.dotProduct(d.normalized) + cd * depth );
				p2.addForce( -d.normalized*c);
				p2.addForce(-vab*0.005);
			}
			
			p2.radius = p2.radius - (p2.radius-p1.radius)/(d_length )*0.01*_engine.unitTime;
		};

	}
	
	void update(){
		for (int i = 0; i < 1; i++) {
			foreach (ref point; _points) {
				point.particle.addForce(-point.particle.velocity*0.5);
				double d = ( mousePosition - point.particle.position ).norm;
				point.particle.addForce(( mousePosition - point.particle.position ).normalized*100.0*point.particle.mass);
				
				if(isHeating){
					point.particle.radius = ar.clamp(point.particle.radius + ( 240.0-d )*0.0025*_engine.unitTime, 1.0, 15.0);
				}else{
					point.particle.radius = ar.clamp(point.particle.radius - 0.1, 2, 15);
				}
				
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
	
	void keyPressed(int key){
		isHeating = !isHeating;
	}
	
	void mousePressed(ar.Vector2f position, int button){
		mousePosition = ar.Vector3d(position[0], position[1], 0);
	}
}

void main(){
	ar.run(new TestApp);
}
