//
//  OpenGLES2DView.h
//  GLFun
//

#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>

@interface OpenGLES2DView : UIView {

@public
	EAGLContext *context;
	GLuint viewRenderbuffer, viewFramebuffer;
	GLint backingWidth, backingHeight;
}

@end
