
package {
	[SWF(width="640",height="480",frameRate="60",backgroundColor="#FFFFFF")]
	import com.adobe.utils.*;
	import flash.display.*;
	import flash.display3D.*;
	import flash.display3D.textures.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.utils.*;
	import flash.text.*;
	import utils.Stage3dObjParser;
	
	public class Stage3dGame extends Sprite {
// used by the GUI
		private var fpsLast:uint = getTimer();
		private var fpsTicks:uint = 0;
		private var fpsTf:TextField;
		private var scoreTf:TextField;
		private var score:uint = 0;
// constants used during inits
		private const swfWidth:int = 640;
		private const swfHeight:int = 480;
// for this demo, ensure ALL textures are 512x512
		private const textureSize:int = 512;
// the 3d graphics window on the stage
		private var context3D:Context3D;
// the compiled shaders used to render our mesh
		private var shaderProgram1:Program3D;
		private var shaderProgram2:Program3D;
		private var shaderProgram3:Program3D;
		private var shaderProgram4:Program3D;
// matrices that affect the mesh location and camera angles
		private var projectionmatrix:PerspectiveMatrix3D = new PerspectiveMatrix3D();
		private var modelmatrix:Matrix3D = new Matrix3D();
		private var viewmatrix:Matrix3D = new Matrix3D();
		private var terrainviewmatrix:Matrix3D = new Matrix3D();
		private var modelViewProjection:Matrix3D = new Matrix3D();
// a simple frame counter used for animation
		private var t:Number = 0;
// a reusable loop counter
		private var looptemp:int = 0;
		[Embed(source="../models/zero/A6M_ZERO_D.png")]
		private var myTextureBitmap:Class;
		private var myTextureData:Bitmap = new myTextureBitmap();
		[Embed(source="../models/terrain/terrain.png")]
		private var terrainTextureBitmap:Class;
		private var terrainTextureData:Bitmap = new terrainTextureBitmap();
		// The Stage3d Texture that uses the above myTextureData
		private var myTexture:Texture;
		private var terrainTexture:Texture;
// The spaceship mesh data
		[Embed(source="../models/zero/A6M_ZERO.obj",mimeType="application/octet-stream")]
		private var myObjData:Class;
		private var myMesh:Stage3dObjParser;
// The terrain mesh data
		[Embed(source="../models/terrain/untitled.obj",mimeType="application/octet-stream")]
		private var terrainObjData:Class;
		private var terrainMesh:Stage3dObjParser;
		
		public function Stage3dGame() {
			if (stage != null)
				init();
			else
				addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void {
			if (hasEventListener(Event.ADDED_TO_STAGE))
				removeEventListener(Event.ADDED_TO_STAGE, init);
// class constructor - sets up the stage
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
// add some text labels
			initGUI();
// and request a context3D from Stage3d
			stage.stage3Ds[0].addEventListener(Event.CONTEXT3D_CREATE, onContext3DCreate);
			stage.stage3Ds[0].requestContext3D();
		}
		
		private function updateScore():void {
// for now, you earn points over time
			score++;
// padded with zeroes
			if (score < 10)
				scoreTf.text = 'Score: 00000' + score;
			else if (score < 100)
				scoreTf.text = 'Score: 0000' + score;
			else if (score < 1000)
				scoreTf.text = 'Score: 000' + score;
			else if (score < 10000)
				scoreTf.text = 'Score: 00' + score;
			else if (score < 100000)
				scoreTf.text = 'Score: 0' + score;
			else
				scoreTf.text = 'Score: ' + score;
		}
		
		private function initGUI():void {
// a text format descriptor used by all gui labels
			var myFormat:TextFormat = new TextFormat();
			myFormat.color = 0xFFFFFF;
			myFormat.size = 13;
// create an FPSCounter that displays the framerate on screen
			fpsTf = new TextField();
			fpsTf.x = 0;
			fpsTf.y = 0;
			fpsTf.selectable = false;
			fpsTf.autoSize = TextFieldAutoSize.LEFT;
			fpsTf.defaultTextFormat = myFormat;
			fpsTf.text = "Initializing Stage3d...";
			addChild(fpsTf);
// create a score display
			scoreTf = new TextField();
			scoreTf.x = 560;
			scoreTf.y = 0;
			scoreTf.selectable = false;
			scoreTf.autoSize = TextFieldAutoSize.LEFT;
			scoreTf.defaultTextFormat = myFormat;
			scoreTf.text = "000000";
			addChild(scoreTf);
// add some labels to describe each shader
			var label1:TextField = new TextField();
			label1.x = 100;
			label1.y = 180;
			label1.selectable = false;
			label1.autoSize = TextFieldAutoSize.LEFT;
			label1.defaultTextFormat = myFormat;
			label1.text = "Shader 1: Textured";
			addChild(label1);
			var label2:TextField = new TextField();
			label2.x = 400;
			label2.y = 180;
			label2.selectable = false;
			label2.autoSize = TextFieldAutoSize.LEFT;
			label2.defaultTextFormat = myFormat;
			label2.text = "Shader 2: Vertex RGB";
			addChild(label2);
			var label3:TextField = new TextField();
			label3.x = 80;
			label3.y = 440;
			label3.selectable = false;
			label3.autoSize = TextFieldAutoSize.LEFT;
			label3.defaultTextFormat = myFormat;
			label3.text = "Shader 3: Vertex RGB + Textured";
			addChild(label3);
			var label4:TextField = new TextField();
			label4.x = 340;
			label4.y = 440;
			label4.selectable = false;
			label4.autoSize = TextFieldAutoSize.LEFT;
			label4.defaultTextFormat = myFormat;
			label4.text = "Shader 4: Textured + setProgramConstants";
			addChild(label4);
		}
		
		public function uploadTextureWithMipmaps(dest:Texture, src:BitmapData):void {
			var ws:int = src.width;
			var hs:int = src.height;
			var level:int = 0;
			var tmp:BitmapData;
			var transform:Matrix = new Matrix();
			var tmp2:BitmapData;
			tmp = new BitmapData(src.width, src.height, true, 0x00000000);
			tmp.draw(src, transform, null, null, null, true);
			dest.uploadFromBitmapData(tmp, level);
			/*while (ws >= 1 && hs >= 1) {
				tmp.draw(src, transform, null, null, null, true);
				dest.uploadFromBitmapData(tmp, level);
				transform.scale(0.5, 0.5);
				level++;
				ws >>= 1;
				hs >>= 1;
				if (hs && ws) {
					tmp.dispose();
					tmp = new BitmapData(ws, hs, true, 0x00000000);
				}
			}*/
			tmp.dispose();
		}
		
		private function onContext3DCreate(event:Event):void {
// Remove existing frame handler. Note that a context
// loss can occur at any time which will force you
// to recreate all objects we create here.
// A context loss occurs for instance if you hit
// CTRL-ALT-DELETE on Windows.
// It takes a while before a new context is available
// hence removing the enterFrame handler is important!
			if (hasEventListener(Event.ENTER_FRAME))
				removeEventListener(Event.ENTER_FRAME, enterFrame);
// Obtain the current context
			var t:Stage3D = event.target as Stage3D;
			context3D = t.context3D;
			if (context3D == null) {
// Currently no 3d context is available (error!)
				return;
			}
// Disabling error checking will drastically improve performance.
// If set to true, Flash sends helpful error messages regarding
// AGAL compilation errors, uninitialized program constants, etc.
			context3D.enableErrorChecking = true;
// Initialize our mesh data
			initData();
// The 3d back buffer size is in pixels (2=antialiased)
			context3D.configureBackBuffer(swfWidth, swfHeight, 2, true);
// assemble all the shaders we need
			initShaders();
			myTexture = context3D.createTexture(textureSize, textureSize, Context3DTextureFormat.BGRA, false);
			uploadTextureWithMipmaps(myTexture, myTextureData.bitmapData);
			terrainTexture = context3D.createTexture(textureSize, textureSize, Context3DTextureFormat.BGRA, false);
			uploadTextureWithMipmaps(terrainTexture, terrainTextureData.bitmapData);
// create projection matrix for our 3D scene
			projectionmatrix.identity();
// 45 degrees FOV, 640/480 aspect ratio, 0.1=near, 100=far
			projectionmatrix.perspectiveFieldOfViewRH(45.0, swfWidth / swfHeight, 0.01, 5000.0);
// create a matrix that defines the camera location
			viewmatrix.identity();
// move the camera back a little so we can see the mesh
			viewmatrix.appendTranslation(0, 0, -3);
// tilt the terrain a little so it is coming towards us
			terrainviewmatrix.identity();
			terrainviewmatrix.appendRotation(-60, Vector3D.X_AXIS);
// start the render loop!
			addEventListener(Event.ENTER_FRAME, enterFrame);
		}
		
		// create four different shaders
		private function initShaders():void {
			// A simple vertex shader which does a 3D transformation
			// for simplicity, it is used by all four shaders
			var vertexShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
			vertexShaderAssembler.assemble(Context3DProgramType.VERTEX, 
				// 4x4 matrix multiply to get camera angle
				"m44 op, va0, vc0\n" + 
				// tell fragment shader about XYZ
				"mov v0, va0\n" + 
				// tell fragment shader about UV
				"mov v1, va1\n" + 
				// tell fragment shader about RGBA
				"mov v2, va2\n");
			// textured using UV coordinates
			var fragmentShaderAssembler1:AGALMiniAssembler = new AGALMiniAssembler();
			fragmentShaderAssembler1.assemble(Context3DProgramType.FRAGMENT, 
				// grab the texture color from texture 0
				// and uv coordinates from varying register 1
				// and store the interpolated value in ft0
				"tex ft0, v1, fs0 <2d,repeat,mipnone>\n" +
				// move this value to the output color
				"mov oc, ft0\n");
			// no texture, RGBA from the vertex buffer data
			var fragmentShaderAssembler2:AGALMiniAssembler = new AGALMiniAssembler();
			fragmentShaderAssembler2.assemble(Context3DProgramType.FRAGMENT, 
				// grab the color from the v2 register
				// which was set in the vertex program
				"mov oc, v2\n");
			// textured using UV coordinates AND colored by vertex RGB
			var fragmentShaderAssembler3:AGALMiniAssembler = new AGALMiniAssembler();
			fragmentShaderAssembler3.assemble(Context3DProgramType.FRAGMENT, 
				// grab the texture color from texture 0
				// and uv coordinates from varying register 1
				"tex ft0, v1, fs0 <2d,repeat,mipnone>\n" + 
				// multiply by the value stored in v2 (the vertex rgb)
				"mul ft1, v2, ft0\n" + 
				// move this value to the output color
				"mov oc, ft1\n");
			// textured using UV coordinates and
			// tinted using a fragment constant
			var fragmentShaderAssembler4:AGALMiniAssembler = new AGALMiniAssembler();
			fragmentShaderAssembler4.assemble(Context3DProgramType.FRAGMENT, 
				// grab the texture color from texture 0
				// and uv coordinates from varying register 1
				"tex ft0, v1, fs0 <2d,repeat,mipnone>\n" + 
				// multiply by the value stored in fc0
				"mul ft1, fc1, ft0\n" + 
				// move this value to the output color
				"mov oc, ft1\n");
			// combine shaders into a program which we then upload to the GPU
			shaderProgram1 = context3D.createProgram();
			shaderProgram1.upload(vertexShaderAssembler.agalcode, fragmentShaderAssembler1.agalcode);
			shaderProgram2 = context3D.createProgram();
			shaderProgram2.upload(vertexShaderAssembler.agalcode, fragmentShaderAssembler2.agalcode);
			shaderProgram3 = context3D.createProgram();
			shaderProgram3.upload(vertexShaderAssembler.agalcode, fragmentShaderAssembler3.agalcode);
			shaderProgram4 = context3D.createProgram();
			shaderProgram4.upload(vertexShaderAssembler.agalcode, fragmentShaderAssembler4.agalcode);
		}
		
		private function initData():void {
// parse the OBJ file and create buffers
			myMesh = new Stage3dObjParser(myObjData, context3D, .05, true, true);
// parse the terrain mesh as well
			terrainMesh = new Stage3dObjParser(terrainObjData, context3D, 10000, true, true);
		}
		
		private function renderTerrain():void {
			context3D.setTextureAt(0, terrainTexture);
// simple textured shader
			context3D.setProgram(shaderProgram1);
// position
			context3D.setVertexBufferAt(0, terrainMesh.positionsBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
// tex coord
			context3D.setVertexBufferAt(1, terrainMesh.uvBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
// vertex rgba
			context3D.setVertexBufferAt(2, terrainMesh.colorsBuffer, 0, Context3DVertexBufferFormat.FLOAT_4);
// set up camera angle
			modelmatrix.identity();
// make the terrain face the right way
			modelmatrix.appendRotation(-90, Vector3D.Y_AXIS);
// slowly move the terrain around
			modelmatrix.appendTranslation(Math.cos(t / 300) * 1000, Math.cos(t / 200) * 1000 -2000, -130);
// clear the matrix and append new angles
			modelViewProjection.identity();
			modelViewProjection.append(modelmatrix);
			modelViewProjection.append(terrainviewmatrix);
			modelViewProjection.append(projectionmatrix);
// pass our matrix data to the shader program
			context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, modelViewProjection, true);
			context3D.drawTriangles(terrainMesh.indexBuffer, 0, terrainMesh.indexBufferCount);
		}
		
		private function enterFrame(e:Event):void {
// clear scene before rendering is mandatory
			context3D.clear(0, 0, 0);
// move or rotate more each frame
			t += 2.0;
// scroll and render the terrain once
			renderTerrain();
// how far apart each of the 4 spaceships is
			var dist:Number = 0.8;
// loop through each mesh we want to draw
			for (looptemp = 0; looptemp < 1; looptemp++) {
				// clear the transformation matrix to 0,0,0
				modelmatrix.identity();
// each mesh has a different texture,
// shader, position and spin speed
				switch (looptemp) {
					case 0: 
						context3D.setTextureAt(0, myTexture);
						context3D.setProgram(shaderProgram1);
						//modelmatrix.appendRotation(t * 0.7, Vector3D.Y_AXIS);
						//modelmatrix.appendRotation(t * 0.6, Vector3D.X_AXIS);
						modelmatrix.appendRotation(90, Vector3D.Z_AXIS);
						modelmatrix.appendRotation(180, Vector3D.Y_AXIS);
						modelmatrix.appendTranslation(-dist, Math.cos(t / 50), 0);
						break;
					
						case 1: 
						context3D.setTextureAt(0, null);
						context3D.setProgram(shaderProgram2);
						modelmatrix.appendRotation(t * -0.2, Vector3D.Y_AXIS);
						modelmatrix.appendRotation(t * 0.4, Vector3D.X_AXIS);
						modelmatrix.appendRotation(t * 0.7, Vector3D.Y_AXIS);
						modelmatrix.appendTranslation(dist, dist, 0);
						break;
					case 2: 
						context3D.setTextureAt(0, myTexture);
						context3D.setProgram(shaderProgram3);
						modelmatrix.appendRotation(t * 1.0, Vector3D.Y_AXIS);
						modelmatrix.appendRotation(t * -0.2, Vector3D.X_AXIS);
						modelmatrix.appendRotation(t * 0.3, Vector3D.Y_AXIS);
						modelmatrix.appendTranslation(-dist, -dist, 0);
						break;
					case 3:
						
						context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, Vector.<Number>([1, Math.abs(Math.cos(t / 50)), 0, 1]));
						context3D.setTextureAt(0, myTexture);
						context3D.setProgram(shaderProgram4);
						modelmatrix.appendRotation(t * 0.3, Vector3D.Y_AXIS);
						modelmatrix.appendRotation(t * 0.3, Vector3D.X_AXIS);
						modelmatrix.appendRotation(t * -0.3, Vector3D.Y_AXIS);
						modelmatrix.appendTranslation(dist, -dist, 0);
						break;
						
				}
// clear the matrix and append new angles
				modelViewProjection.identity();
				modelViewProjection.append(modelmatrix);
				modelViewProjection.append(viewmatrix);
				modelViewProjection.append(projectionmatrix);
// pass our matrix data to the shader program
				context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, modelViewProjection, true);
// draw a spaceship mesh
// position
				context3D.setVertexBufferAt(0, myMesh.positionsBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
// tex coord
				context3D.setVertexBufferAt(1, myMesh.uvBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
// vertex rgba
				context3D.setVertexBufferAt(2, myMesh.colorsBuffer, 0, Context3DVertexBufferFormat.FLOAT_4);
// render it
				context3D.drawTriangles(myMesh.indexBuffer, 0, myMesh.indexBufferCount);
			}
// present/flip back buffer
// now that all meshes have been drawn
			context3D.present();
// update the FPS display
			fpsTicks++;
			var now:uint = getTimer();
			var delta:uint = now - fpsLast;
// only update the display once a second
			if (delta >= 1000) {
				var fps:Number = fpsTicks / delta * 1000;
				fpsTf.text = fps.toFixed(1) + " fps";
				fpsTicks = 0;
				fpsLast = now;
			}
// update the rest of the GUI
			updateScore();
		}
	} // end of class
} // end of package