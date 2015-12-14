import std.stdio;
import std.math;
import pharticle;
import armos;

class TestApp : ar.BaseApp{
	this(){
	}
	
	void setup(){
	}
	
	void update(){
	}
	
	void draw(){
		( ar.fpsUseRate*100 ).writeln;
	}
}

void main(){
	ar.run(new TestApp);
}
