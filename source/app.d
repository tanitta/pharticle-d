import std.stdio;
import std.math;
import pharticle;
import armos;

struct Point{
	Particle particle;
	ar.Mesh mesh;
	this(ar.Vector3d position){
		particle = new Particle;
		particle.position = position;
		particle.radius = 15;
		particle.mass = 1;
		mesh = ar.circlePrimitive(0, 0, 0, 1);
	}

	void draw(double min, double max, ar.Image img){
		ar.pushMatrix;
			ar.Vector3f polyPosition = cast(ar.Vector3f)particle.position;
			polyPosition[2] = -particle.radius;
			ar.translate(polyPosition);
			
			auto c = ar.map(particle.radius, min, max, 0.0, 255.0);
			// ar.setColor(c, 0, 0, 32);
			
			ar.scale(particle.radius*1.0);
			// ar.pushMatrix;
			// 	ar.scale(particle.radius*1.0);
				ar.setColor(c, 0, 0, ( 255.0-c*200.0/255.0 ));
				ar.pushMatrix;
					ar.scale(4.0/cast(float)( img.width ), 4.0/cast(float)( img.height ), 1.0);
					ar.scale(0.1, 0.1, 1.0);
					ar.translate(-img.width/2, -img.height/2, 0);
					img.draw(0, 0);
				ar.popMatrix;
			// ar.popMatrix;
			mesh.drawFill;
			ar.setColor(255, 255, 255);
		ar.popMatrix;
	}
}

class TestApp : ar.BaseApp{
	ar.Gui gui;
	double guiUnitTime = 0.05;
	double guiAttractionForce = 100.0;
	double guiHeatingBorder = 240.0;
	double guiHeatingGain= 0.0025;
	double guiHeatingMin = 1.0;
	double guiHeatingMax= 15.0;
	double guiViscosity = 0.5;
	double guiHeatTransfar= 0.01;
	
	pharticle.Engine _engine;
	Point[] _points;
	ar.Vector3d mousePosition = ar.Vector3d(0, 0, 0);
	bool isHeating = true;
	ar.Image image;
	this(){
		image = new ar.Image;
		_engine = new pharticle.Engine;
	}

	void setup(){
		image.load("particle.png");
		// ar.enableDepthTest;
		// ar.setBackgroundAuto = false;
		ar.setBackground(255, 255, 255);
		ar.blendMode(ar.BlendMode.Add );
		ar.targetFps = 30;
		_engine.unitTime = 0.05;
		_engine.isAutoClear = false;

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

			p2.radius = p2.radius - (p2.radius-p1.radius)/(d_length )*guiHeatTransfar*_engine.unitTime;
		};
		
		gui = (new ar.Gui)
		.add(
			(new ar.List)
			.add(new ar.Partition(" "))
			.add(new ar.Label("pharticle"))
			.add(new ar.Partition)
			
			.add(new ar.Slider!double("unittime", guiUnitTime, 0.0, 0.1))
			.add(new ar.Slider!double("AttractionForce", guiAttractionForce, 0.0, 500.0))
			.add(new ar.Slider!double("Viscosity", guiViscosity, 0.0, 5.0))
			.add(new ar.Partition)
			
			.add(new ar.Label("heating"))
			.add(new ar.Slider!double("HeatingBorder", guiHeatingBorder, 0.0, 500.0))
			.add(new ar.Slider!double("HeatingGain", guiHeatingGain, 0.0, 0.025))
			.add(new ar.Slider!double("HeatingMin", guiHeatingMin, 0.1, 10.0))
			.add(new ar.Slider!double("HeatingMax", guiHeatingMax, 0.1, 50.0))
			.add(new ar.Slider!double("HeatTransfar", guiHeatTransfar, 0.0, 2.0))
			.add(new ar.Partition)
		);
	}

	void update(){
		_engine.unitTime = guiUnitTime;
		mousePosition = ar.Vector3d(ar.currentWindow.size[0]*0.5, ar.currentWindow.size[1]*0.5, 0);
		for (int i = 0; i < 1; i++) {
			foreach (ref point; _points) {
				point.particle.addForce(-point.particle.velocity*guiViscosity);
				double d = ( mousePosition - point.particle.position ).norm;
				point.particle.addForce(( mousePosition - point.particle.position ).normalized*guiAttractionForce*point.particle.mass);

				if(isHeating){
					point.particle.radius = ar.clamp(point.particle.radius + ( guiHeatingBorder-d )*guiHeatingGain*_engine.unitTime, guiHeatingMin, guiHeatingMax);
				}else{
					point.particle.radius = ar.clamp(point.particle.radius - 0.1, 2, 15);
				}

				_engine.add(point.particle);
			}

			_engine.update;
		}
	}

	void draw(){
		// ar.enableDepthTest;
		// ( ar.fpsUseRate*100 ).writeln;
		foreach (ref point; _points) {
			point.draw(guiHeatingMin, guiHeatingMax, image);
		}
		foreach (ref pair; _engine.constraintPairs) {
			double radiusAvg = ( pair.particlePtrs[0].radius+pair.particlePtrs[1].radius )*0.5;
			auto c = ar.map(radiusAvg, guiHeatingMin, guiHeatingMax, 0.0, 255.0);
			ar.setColor(c, 0, 0, c);
			ar.drawLine(pair.particlePtrs[0].position, pair.particlePtrs[1].position);
		}
		// ar.disableDepthTest;
		gui.draw;
		// ar.enableDepthTest;
		_engine.clear;
		image.height.writeln;
	}
}

void main(){
	ar.run(new TestApp);
}
