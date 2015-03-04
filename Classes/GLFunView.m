//
//  GLFunView.m
//  GLFun
//

#import <UIKit/UIKit.h>
#import "GLFunView.h"
#import "SteamyBikiniAppDelegate.h"



@implementation GLFunView

@synthesize baseTexture;
@synthesize overlayTexture;
@synthesize brushTexture;
@synthesize sideSteam;

//Initialization

- (void)start {
	//Init locals
	crtPoint = -1;
	drawPoint = 0;
    lastDrop = 0;
	brushRadius = 14;
	waveLevel1 = 0;
	waveLevel2 = -backingHeight; // -480;
	blowTimeout = 0;
	drawingEnabled = TRUE;
	userIsBlowing = FALSE;
	
    
	//Seed random generator
	srandom(time(NULL));
	
	//Reset transformations
	glLoadIdentity();
	
	//Setup def color and texturing
	glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
	glColor4f(0.0f, 0.0f, 0.0f, 0.0f);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	
	//Load opengl textures
	baseTexture = [[Texture2D alloc] initWithImage: [UIImage imageNamed: @"img1.jpg"]];
	brushTexture =  [[Texture2D alloc] initWithImage: [UIImage imageNamed: @"brush.png"]];
    
    SteamyBikiniAppDelegate * delegate = (SteamyBikiniAppDelegate*) [UIApplication sharedApplication].delegate;
    if (delegate.bIPHONE5) {
        overlayTexture = [[Texture2D alloc] initWithImage: [UIImage imageNamed: @"steam.png"]];
        sideSteam = [[Texture2D alloc] initWithImage: [UIImage imageNamed: @"sidesteam.png"]];
    }
    else {
        overlayTexture = [[Texture2D alloc] initWithImage: [UIImage imageNamed: @"steam_1.png"]];
//        overlayTexture = [[Texture2D alloc] initWithImage: [UIImage imageNamed: @"overlay.png"]];
        sideSteam = [[Texture2D alloc] initWithImage: [UIImage imageNamed: @"sidesteam_.png"]];
    }
	
    
	//Setup FBO
	glGenFramebuffersOES(1, &overlayFBO);
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, overlayFBO);
	glFramebufferTexture2DOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_TEXTURE_2D, overlayTexture.name, 0);
	
    
	//Draw initial scene
	blowTimeout = 1;
	[self drawBlow];
	[self drawScene];
	
	//Start timer
	timerScene = [NSTimer scheduledTimerWithTimeInterval: 1.0f/30.0f target:self selector:@selector(drawScene) userInfo:nil repeats: YES];
	randomDrops = [NSTimer scheduledTimerWithTimeInterval: (float) (5 + random() % 15) target:self selector:@selector(startRandomDrops) userInfo:nil repeats: YES];
	
	//Start accelerometer capture
	[[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / kAccelerometerFrequency)];
	[[UIAccelerometer sharedAccelerometer] setDelegate:self];
}

-(void) drawSteam {
	//Simulate blow for 10 frames
	blowTimeout = 10;
}

//OpenGL ES Drawing

- (void)drawScene {
	//No drawing right now
	if (drawingEnabled == FALSE)
		return;
	
	//Draw drops
	[self drawDrops];
	
	//Draw brush lines
	[self drawBrushLines];
	
	//Draw blow
	[self drawBlow];
	
	//Draw on framebuffer
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);

	//Draw background
	glEnable(GL_TEXTURE_2D);
	glDisable(GL_BLEND);
	glColorMask(1, 1, 1, 1);
	[baseTexture drawAtPoint:CGPointMake(backingWidth / 2, backingHeight / 2)];
	
    
	//Enable blending
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	
	//Draw steam waves
	if (wavesEnabled) {
        
		[sideSteam drawInRect: CGRectMake(0, waveLevel1, 320, backingHeight+2)];
		[sideSteam drawInRect: CGRectMake(0, waveLevel2, 320, backingHeight+2)];
		
		//Move waves upward
		waveLevel1+=10;
		if (waveLevel1 >= backingHeight)
			waveLevel1 = -backingHeight;
		
		waveLevel2+=10;
		if (waveLevel2 >= backingHeight)
			waveLevel2 = -backingHeight;
	}

	//Draw overlay
	[overlayTexture drawAtPoint:CGPointMake(backingWidth / 2, backingHeight / 2)];

    
	//Render framebuffer to screen
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
	[context presentRenderbuffer:GL_RENDERBUFFER_OES];
}

-(void) drawBlow {
	//IF nobody is blowing exit quickly
	if (!userIsBlowing && blowTimeout == 0)
		return;
	
	//Decrement and normalize blowTimeout
	blowTimeout--;
	if (blowTimeout < 0)
		blowTimeout = 0;
	 
	//Draw on texture
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, overlayFBO);
	
	//Enable blending and rgb channel masking
	glEnable(GL_BLEND);
	glBlendFunc(GL_ONE, GL_ONE);
	glColorMask(0, 0, 0, 1);
	glColor4f(0.0f, 0.0f, 0.0f, 0.150f);
	glDisable(GL_TEXTURE_2D);
	
	//Define rect bounds
	GLfloat vertices[8];
	
	GLfloat minX = 0;
	GLfloat minY = 0;
	GLfloat maxX = backingWidth;
	GLfloat maxY = backingHeight;
	
	vertices[0] = maxX;
	vertices[1] = maxY;
	vertices[2] = minX;
	vertices[3] = maxY;
	vertices[4] = minX;
	vertices[5] = minY;
	vertices[6] = maxX;
	vertices[7] = minY;
	
	//Add 0.150 to alpha channel
	glVertexPointer (2, GL_FLOAT , 0, vertices);	
	glDrawArrays (GL_TRIANGLE_FAN, 0, 4);
	
	//Change blending again
	glBlendFunc(GL_ZERO, GL_ONE_MINUS_SRC_ALPHA);
	glColor4f(0.0f, 0.0f, 0.0f, 0.075f);
	
	//Substract 0.075 from alpha channel
	glVertexPointer (2, GL_FLOAT , 0, vertices);	
	glDrawArrays (GL_TRIANGLE_FAN, 0, 4);
}

-(void) drawDrops {
	//Nothing to draw now
	if (dropsEnabled == FALSE)
		return;
	
	//Draw on texture
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, overlayFBO);
	
	//Enable blending and rgb channel masking
	glEnable(GL_BLEND);
	glBlendFunc(GL_ZERO, GL_ONE_MINUS_SRC_ALPHA);
	glColorMask(0, 0, 0, 1);
	glColor4f(0.0f, 0.0f, 0.0f, 0.25f);
	glDisable(GL_TEXTURE_2D);
	
	//Go through all drops
	for (int i=0; i<lastDrop; i+=4) {
		//Read old values
		float dropX = drops[i + 0];
		float dropY = drops[i + 1];
		
		if (dropX > 0 && dropX < backingWidth && dropY > 0 && dropY < backingHeight) {
			float dropU = drops[i + 2];
			float dropL = drops[i + 3];
			
			//Randomize speed
			float speed = 3 + dropL;
			
			//Obey accelerometer target ungle
			float target = deviceUngle + 90;
			
			//Normalize target ungle
			if (target < 0)
				target += 360;
			if (target > 360)
				target -= 360;
			
			//Compute next drop ungle
			float diff = ABS(target - dropU);
			float step = diff / 3;
			
			if (dropU < target) {
				if (diff <= 180)
					dropU += step;
				else
					dropU -= step;
			} else if (dropU > target) {
				if (diff <= 180)
					dropU -= step;
				else
					dropU += step;
			}
			
			//Normalize dropU
			if (dropU < 0)
				dropU += 360;
			if (dropU > 360)
				dropU -= 360;
			
			//New values
			float ungleRandom = 10 - random() % 20;
			float newDropU = dropU + ungleRandom;
			float newDropL = dropL + 0.05;
			float newDropX = dropX + cos(degreesToRadians(newDropU)) * speed;
			float newDropY = dropY + sin(degreesToRadians(newDropU)) * speed;
			
			//Compute vertices
			GLfloat vertices[4];
			
			vertices[0] = dropX;
			vertices[1] = dropY;
			vertices[2] = newDropX;
			vertices[3] = newDropY;
			
			//Draw line
			glLineWidth(newDropL);
			glVertexPointer (2, GL_FLOAT , 0, vertices);	
			glDrawArrays (GL_LINES, 0, 2);
			
			//Store new values
			drops[i + 0] = newDropX;
			drops[i + 1] = newDropY;
			drops[i + 2] = newDropU;
			drops[i + 3] = newDropL;
		}
	}
}

-(void) drawBrushLines {
	//Nothing new to draw
	if (drawPoint >= crtPoint)
		return;
	
	//Draw on texture
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, overlayFBO);
	
	//Enable blending and rgb channel masking
	glEnable(GL_BLEND);
	glEnable(GL_TEXTURE_2D);
	glBlendFunc(GL_ZERO, GL_ONE_MINUS_SRC_ALPHA);
	glColorMask(0, 0, 0, 1);
	
	//Draw all points in buffer
	do {
		drawPoint++;
		
		int cx = pointX[drawPoint];
		int cy = pointY[drawPoint];
		
		int lx = drawPoint == 1 ? cx : pointX[drawPoint - 1];
		int ly = drawPoint == 1 ? cy : pointY[drawPoint - 1];
		
		[self drawBrushLineCX: cx CY: cy LX: lx LY: ly];
		
	} while (drawPoint < crtPoint);
}

-(void) drawBrushLineCX: (int) cx CY: (int) cy LX: (int) lx LY: (int) ly {
	//Calculate brush path
	float repeatFactor = brushRadius / 2;
	
	//Calculate difference between points
	int dx = cx - lx;
	int dy = cy - ly;
	float distance = sqrt((dx * dx) + (dy * dy));
	
	//Calculate stepts
	int steps = MAX(distance / repeatFactor, 1);
	float stepX = (float) dx / (float) steps;
	float stepY = (float) dy / (float) steps;
	
	//Draw brush on all points
	for (int s=0; s<steps; s++) {
		//Calculate current brush position
		int offsetX = lx + stepX * s;
		int offsetY = ly + stepY * s;
		
		//Draw brush
		[brushTexture drawAtPoint: CGPointMake(offsetX, offsetY)];
	}
}

//User interaction

- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration {
	//Get accelerations on x, y, z
	accelerations[0] = acceleration.x * kFilteringFactor + accelerations[0] * (1.0 - kFilteringFactor);
	accelerations[1] = acceleration.y * kFilteringFactor + accelerations[1] * (1.0 - kFilteringFactor);
	accelerations[2] = acceleration.z * kFilteringFactor + accelerations[2] * (1.0 - kFilteringFactor);
	
	//Get device ungle
	CGFloat zRot = (atan2(accelerations[0], accelerations[1]) + M_PI);
	deviceUngle = radiansToDegrees(zRot);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	//Get touch location
	UITouch *touch = [[touches anyObject] retain];
	CGPoint cgp = [touch locationInView: self];
	[touch release];
	
	//Fingers
	drawPoint = 0;
	crtPoint = 1;
	pointX[crtPoint] = cgp.x;
	pointY[crtPoint] = cgp.y;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	//Get touch location
	UITouch *touch = [[touches anyObject] retain];
	CGPoint cgp = [touch locationInView: self];
	[touch release];
	
	//Fingers
	crtPoint++;
	pointX[crtPoint] = cgp.x;
	pointY[crtPoint] = cgp.y;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	//Start water drop from last tap
	[self startDropPosX: pointX[crtPoint] PosY: pointY[crtPoint] + brushRadius];
	
	//Debug
	NSLog(@"%@", [NSString stringWithFormat: @"MaxPoints=%d", crtPoint]);
}

-(void) startRandomDrops {
	//No drops to start
	if (dropsEnabled == FALSE)
		return;
	
	//Start random drop
	[self startDropPosX: random() % backingWidth PosY: 1];
}

-(void) startDropPosX: (int) posX PosY: (int) posY {
	if (dropsEnabled == FALSE)
		return;
	
	//Accelerometer target ungle
	float target = deviceUngle + 90;
	
	//Normalize target ungle
	if (target < 0)
		target += 360;
	if (target > 360)
		target -= 360;
	
	//Set new drop in array
	drops[lastDrop + 0] = posX;
	drops[lastDrop + 1] = posY;
	drops[lastDrop + 2] = target;
	drops[lastDrop + 3] = 4;
	
	//Increment drop counter
	lastDrop += 4;
}

//External

-(void) loadCurrentTexture: (int) photoID {
	//Release old texture
	[baseTexture release];
	baseTexture = nil;
	
	//Load new texture file
	NSString *filename = [NSString stringWithFormat: @"img%d.jpg", photoID];
	baseTexture = [[Texture2D alloc] initWithImage: [UIImage imageNamed: filename]];
	
	//Debug
	NSLog(@"%@", filename);
}

-(void) enableDrops: (bool) value {
	dropsEnabled = value;
}

-(void) enableWaves: (bool) value {
	wavesEnabled = value;
}

-(void) enableDrawing: (bool) value {
	drawingEnabled = value;
}

-(void) enableBlowing: (bool) value {
	userIsBlowing = value;
}

//Memory management

- (void)dealloc {
	[baseTexture release];
	[overlayTexture release];
	[brushTexture release];
	
	[super dealloc];
}

@end
