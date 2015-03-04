//
//  GLFunViewController.h
//  GLFun
//

#import <UIKit/UIKit.h>
#import "GLFunView.h"
#import <AudioToolbox/AudioToolbox.h>
#import "SCListener.h"
#import "GBMusicTrack.h"
#import <MessageUI/MessageUI.h>
#import <RevMobAds/RevMobAds.h>
#import "GADBannerViewDelegate.h"
#import "CustomView.h"


@class GADBannerView, GADRequest;

@class GLFunView;
@class GBMusicTrack;

@interface GLFunViewController : UIViewController < MFMailComposeViewControllerDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate,RevMobAdsDelegate,GADBannerViewDelegate> {

//    GADBannerView *adBanner_;

    IBOutlet CustomView * mainView;
    
    
	//Image status
	int currentImg;
	int minImages;
	int maxImages;

	//OpenGL ES View
	IBOutlet GLFunView *glView;
	
	//Actionsheets
	int currentSheet;
	
	//Audio sound effects
	SystemSoundID sndToogle, sndClick;
	
	//Audio player
	GBMusicTrack *audioPlayer;
	
	//Audio recorder
	SCListener *listener;
	bool userIsBlowing;
	NSTimer *soundTimer;
	
	//Preferences
	NSUserDefaults *prefs;
	bool opDrops;
	bool opSteam;
	bool opWaves;
	bool opMusic;
	int opPic;
	
	//Flags
	bool hasOpenGLES2;
    
    
    // Start
    BOOL bStarted;
}

//Internal

-(void) readUserSettings;

-(void) captureOpenGLImage: (bool) sendMail;

-(void) emailImage: (UIImage *) outputImage;

-(NSString *) base64Encoding: (NSData *) imageData;

-(void) loadCrtTexture;

//UI Actions

-(IBAction) prevScene;

-(IBAction) showActions;

-(IBAction) showOptions;

-(IBAction) nextScene;

//@property (nonatomic,retain) RevMobFullscreen * revmob;
//@property(nonatomic, retain) GADBannerView *adBanner;

- (GADRequest *)createRequest;


@end