#ifdef GL_ES
precision mediump float;
#endif



void main() {
	fragCoord = position;
	gl_Position = vec4(position, 0, 1);
}