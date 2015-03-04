//
//  GLFunView.h
//  GLFun
//

#import <UIKit/UIKit.h>
#import "Texture2D.h"
#import "OpenGLES2DView.h"

@interface GLFunView : OpenGLES2DView <UIAccelerometerDelegate> {
	//Textures
	Texture2D *baseTexture;
	Texture2D *overlayTexture;
	Texture2D *brushTexture;
	Texture2D *sideSteam;
	
	//Framebuffer objects
	GLuint overlayFBO;
	
	//Timers
	NSTimer *timerScene;
	NSTimer *randomDrops;
	
	//Switches
	bool dropsEnabled;
	bool wavesEnabled;
	bool drawingEnabled;
	bool userIsBlowing;
	
	//Finger touches
	int pointX[1000];
	int pointY[1000];
	int crtPoint;
	int drawPoint;
	
	//Drops
	float drops[1000];
	int lastDrop;
	
	//Steam waves
	int waveLevel1;
	int waveLevel2;
	
	//Brush
	float brushRadius;
	
	//Blow
	int blowTimeout;
	
	//Accelerometer values
	UIAccelerationValue accelerations[3];
	float deviceUngle;
}

//Properties

@property (nonatomic, retain) Texture2D *baseTexture;
@property (nonatomic, retain) Texture2D *overlayTexture;
@property (nonatomic, retain) Texture2D *brushTexture;
@property (nonatomic, retain) Texture2D *sideSteam;

//Internal

-(void) start;

-(void) drawSteam;

-(void) drawScene;

-(void) drawBlow;

-(void) drawDrops;

-(void) drawBrushLines;

-(void) drawBrushLineCX: (int) cx CY: (int) cy LX: (int) lx LY: (int) ly;

-(void) startDropPosX: (int) posX PosY: (int) posY;

//External

-(void) loadCurrentTexture: (int) photoID;

-(void) enableDrawing: (bool) value;

-(void) enableDrops: (bool) value;

-(void) enableWaves: (bool) value;

-(void) enableBlowing: (bool) value;

@end

#define kAccelerometerFrequency 100.0
#define kFilteringFactor 0.1
#define degreesToRadians(x) (M_PI * x / 180.0)
#define radiansToDegrees(x) (180 * x / M_PI)