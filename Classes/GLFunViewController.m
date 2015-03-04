//
//  GLFunAppDelegate.m
//  GLFun
//

#import <MessageUI/MessageUI.h>
#import "GLFunViewController.h"
#import "GLFunView.h"
#import <AudioToolbox/AudioToolbox.h>
#import "SCListener.h"
#import "GBMusicTrack.h"
#import "GADBannerView.h"
#import "GADRequest.h"
#import "Appirater.h"


@implementation GLFunViewController


//@synthesize adBanner = adBanner_;


static inline double radians (double degrees)
{
	return degrees * M_PI/180;
}

// google add integration////////////////////////////////////////////////


#pragma mark GADRequest generation
/*
// Here we're creating a simple GADRequest and whitelisting the simulator
// and two devices for test ads. You should request test ads during development
// to avoid generating invalid impressions and clicks.
- (GADRequest *)createRequest
{
    GADRequest *request = [GADRequest request];
    
    //Make the request for a test ad
    request.testDevices = [NSArray arrayWithObjects:
                           GAD_SIMULATOR_ID,                               // Simulator
                           nil];
    
    return request;
}

#pragma mark GADBannerViewDelegate impl

// Since we've received an ad, let's go ahead and set the frame to display it.
- (void)adViewDidReceiveAd:(GADBannerView *)adView
{
    NSLog(@"Received ad");
    
    [UIView animateWithDuration:1.0 animations:^
     {
         adView.frame = CGRectMake(0,390,320,50);
         
     }];
    
}
- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error
{
    NSLog(@"Failed to receive ad with error: %@", [error localizedFailureReason]);
}


#pragma mark -

-(void)revmobAdDidFailWithError:(NSError *)error
{
    NSLog(@"error...");
}

-(void)revmobAdDidReceive
{
    NSLog(@"Ad loaded successfullly");
}

-(void)revmobAdDisplayed
{
    NSLog(@"Ad displayed");
}

-(void)revmobUserClickedInTheAd
{
    NSLog(@"User clicked in the ad");
}

-(void)revmobUserClosedTheAd
{
    NSLog(@"User closed the ad");
}
*/

-(void) viewDidLoad {
  
    // add revmob full screen////////////////////////////////////////////////////////////////


    [RevMobAds startSessionWithAppID:@"529470af4d5852d5bd000030"];
    [[RevMobAds session] showFullscreen];

/*

	RevMobFullscreen *ad = [[[RevMobAds session] fullscreen] retain]; // you must retain this object
    ad.delegate = self;
    
    [ad loadWithSuccessHandler:^(RevMobFullscreen *fs)
     {
         [fs showAd];
         NSLog(@"Ad loaded");
     } andLoadFailHandler:^(RevMobFullscreen *fs, NSError *error) {
         NSLog(@"Ad error: %@",error);
     } onClickHandler:^{
         NSLog(@"Ad clicked");
     } onCloseHandler:^{
         NSLog(@"Ad closed");
     }];
    
    [ad loadAd];
    
    if (ad)
    {
        [ad showAd];
    }
    
    /////////////////////////////////////////////////////////////////////////////////////////

    //google add integration////////////////////////////////////////////////////////////////
    
    self.adBanner = [[[GADBannerView alloc] initWithFrame:CGRectMake(0.0,
                                                                     0,
                                                                     320,
                                                                     50)] autorelease];
    // Note: Edit SampleConstants.h to provide a definition for kSampleAdUnitID
    // before compiling.
    self.adBanner.adUnitID =@"a151971458f1083";
    self.adBanner.delegate = self;
    [self.adBanner setRootViewController:self];
    [self.view addSubview:self.adBanner];
    [self.adBanner loadRequest:[self createRequest]];
*/
    
    //////////////////////////////////////////////////////////////////////////////////////////
    

	//Init preferences object
	prefs = [NSUserDefaults standardUserDefaults];
	
	//Read user settings
	[self readUserSettings];
	 
	//Load Audio Player
	audioPlayer = [GBMusicTrack alloc];
	
	//Load audio listener
	listener = [SCListener sharedListener];
	
	if (opMusic) {
		[audioPlayer initWithPath:[[NSBundle mainBundle] pathForResource: @"loop" ofType:@"mp3"]];
		[audioPlayer setRepeat: YES];
		[audioPlayer setGain: 1];
		[audioPlayer play];
	} else {
		[listener listen];
		userIsBlowing = FALSE;
	}
    
    bStarted = FALSE;
    
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!bStarted) {
        
        //OpenGL ES View
        NSLog(@"self.view : width = %f, height = %f", mainView.bounds.size.width, mainView.bounds.size.height);
        
//        glView = (GLFunView *) self.view;
        
        glView = [[GLFunView alloc] initWithFrame:mainView.bounds];
        [mainView addSubview:glView];
        glView.userInteractionEnabled = TRUE;
        
        
        NSLog(@"0 backingWidth = %i, backingHeight = %i", glView->backingWidth, glView->backingHeight);

        //Init local vars
        minImages = 1;
        maxImages = 6;
        currentImg = opPic > 0 ? opPic : minImages;
        
        //Start and setup OpenGL View
        [glView start];
        [glView loadCurrentTexture: currentImg];
        [glView enableDrops: opDrops];
        [glView enableWaves: opWaves];
        
        //Start sound timer
        soundTimer = [NSTimer scheduledTimerWithTimeInterval: 1.0f/5.0f target:self selector:@selector(updateSound) userInfo:nil repeats: YES];
        
        bStarted = TRUE;

    }
}

//User settings
-(void) readUserSettings {
	//Determine OpenGLES2 existence
	hasOpenGLES2 = FALSE;
	@try {
		EAGLContext *dummy = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
		if (dummy != nil) {
			hasOpenGLES2 = TRUE;
			[dummy release];
		}
	}
	@catch (id ex) {}
	
	//Default settings flag
	bool def = (bool) [prefs boolForKey:@"Default"];
	
	//Load defaults if first run
	if (!def) {
		//Set instance defaults
		opDrops = TRUE;
		opMusic = TRUE;
		opSteam = TRUE;
		opWaves = hasOpenGLES2 ? TRUE : FALSE;
		opPic = 1;
		
		//Save instance defaults
		[prefs setBool: TRUE forKey: @"Default"];
		
		[prefs setBool: opDrops forKey: @"Drops"];
		[prefs setBool: opMusic forKey: @"Music"];
		[prefs setBool: opSteam forKey: @"Steam"];
		[prefs setBool: opWaves forKey: @"Waves"];
		[prefs setInteger: opPic forKey: @"Picture"];
		
		[prefs synchronize];
	} else {
		opDrops = (bool) [prefs boolForKey: @"Drops"];
		opMusic = (bool) [prefs boolForKey: @"Music"];
		opSteam = (bool) [prefs boolForKey: @"Steam"];
		opWaves = (bool) [prefs boolForKey: @"Waves"];
		opPic = (int) [prefs integerForKey: @"Picture"];
	}
}

-(void) updateSound {
	//Is user blowing
	if ([listener isListening]) {
		//Debug
		NSLog(@"%@", [NSString stringWithFormat:@"Record levels = AVG: %f PEAK: %f", [listener averagePower], [listener peakPower]]);
		
		//Determine if user is blowing
		if ([listener averagePower] >= 0.9f && [listener peakPower] >= 0.9f)
			userIsBlowing = TRUE;
		else
			userIsBlowing = FALSE;
	} else
		userIsBlowing = FALSE;
	
	//Send message to GLView
	[glView enableBlowing: userIsBlowing];
}

//UI Actions

-(void) nextScene {
    
    [[RevMobAds session] showFullscreen];

    
	//Increment image
	currentImg++;
	if (currentImg > maxImages)
		currentImg = minImages;
	
	//Auto-steam
	if (opSteam) {
		[glView drawSteam];
		[self performSelector: @selector(loadCrtTexture) withObject: nil afterDelay: 0.33];
	} else 
		[glView loadCurrentTexture: currentImg];
}

-(void) prevScene {

    [[RevMobAds session] showFullscreen];

	//Decrement image
	currentImg--;
	if (currentImg < minImages)
		currentImg = maxImages;
	
	//Auto-steam
	if (opSteam) {
		[glView drawSteam];
		[self performSelector: @selector(loadCrtTexture) withObject: nil afterDelay: 0.33];
	} else 
		[glView loadCurrentTexture: currentImg];
}
		 
-(void) loadCrtTexture {
	[glView loadCurrentTexture: currentImg];
}

-(void) showOptions {
	//Disable OpenGL ES Rendering
	[glView enableDrawing: FALSE];
	
	//Display action sheet
	currentSheet = 1;
	UIActionSheet *actionSheet;
	
	NSString *op0 = opDrops ? @"Turn off drops" : @"Turn on drops";
	NSString *op1 = opWaves ? @"Turn off steam waves" : @"Turn on steam waves";
	NSString *op2 = opSteam ? @"Turn off auto-steam" : @"Turn on auto-steam";
	//NSString *op3 = opMusic ? @"Turn on mic-steam" : @"Turn on music";
	
	actionSheet = [[UIActionSheet alloc] initWithTitle: nil delegate:self
									 cancelButtonTitle: @"Cancel" destructiveButtonTitle: nil otherButtonTitles: op0, op1, op2/*, op3,*/, nil];
	
	actionSheet.actionSheetStyle = UIBarStyleBlackTranslucent;
	[actionSheet showInView: self.view];
	[actionSheet release];
}

-(void) showActions {
	//Disable OpenGL ES Rendering
	[glView enableDrawing: FALSE];
	
	//Display action sheet
	currentSheet = 2;
	UIActionSheet *actionSheet;
	
	NSString *op0 = @"Set default photo";
	NSString *op1 = @"Get steam on screen";
	NSString *op2 = @"Save photo to library";
	NSString *op3 = @"Send photo via e-mail";
	
	actionSheet = [[UIActionSheet alloc] initWithTitle: nil delegate:self
		cancelButtonTitle: @"Cancel" destructiveButtonTitle: nil otherButtonTitles: op0, op1, op2, op3, nil];	
	
	actionSheet.actionSheetStyle = UIBarStyleBlackTranslucent;
	[actionSheet showInView: self.view];
	[actionSheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (currentSheet == 1) {
		if (buttonIndex == 0) {
			opDrops = !opDrops;
			[glView enableDrops: opDrops];
		} else if (buttonIndex == 1) {
			opWaves = !opWaves;
			[glView enableWaves: opWaves];
		} else if (buttonIndex == 2) {
			opSteam = !opSteam;
		} else if (buttonIndex == 3) {
			/*opMusic = !opMusic;
			if (opMusic) {
				//Stop listener
				[listener stop];
				
				//Load music
				[audioPlayer initWithPath:[[NSBundle mainBundle] pathForResource: @"loop" ofType:@"mp3"]];
				[audioPlayer setRepeat: YES];
				[audioPlayer setGain: 1];
				[audioPlayer play];
			} else {
				//Stop music
				[audioPlayer close];
				
				//Start listener
				[listener listen];
				userIsBlowing = FALSE;
				
				//Intro message
				bool intro = (bool) [prefs boolForKey:@"Blow"];
				
				if (!intro) {
					UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Blow on your microphone to get more steam onto the screen...\r\n(Available on iPhone)" delegate:nil cancelButtonTitle: nil otherButtonTitles: @"Ok", nil];
					[alert show];
					[alert release];
				}
				
				[prefs setBool: TRUE forKey: @"Blow"];
				[prefs synchronize];
			}*/
		}
		
		//Save new preferences
		[prefs setBool: opDrops forKey: @"Drops"];
		[prefs setBool: opSteam forKey: @"Steam"];
		[prefs setBool: opWaves forKey: @"Waves"];
		[prefs setBool: opMusic forKey: @"Music"];
		[prefs setInteger: opPic forKey: @"Picture"];
		
		[prefs synchronize];
	} else if (currentSheet == 2) {
		if (buttonIndex == 0) {
			opPic = currentImg;
			[prefs setInteger: opPic forKey: @"Picture"];
			
			[prefs synchronize];
		} else if (buttonIndex == 1) {
			[glView drawSteam];
		} else if (buttonIndex == 2) {
			[self captureOpenGLImage: FALSE];
		} else if (buttonIndex == 3) {
			[self captureOpenGLImage: TRUE];			
		}
	}
	
	//Re-enable OpenGL ES Rendering
	[glView enableDrawing: TRUE];
}

//Email picture base64 encoding
static const char encodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

-(NSString *) base64Encoding: (NSData *) imageData {
	if ([imageData length] == 0)
		return @"";
	
    char *characters = malloc((([imageData length] + 2) / 3) * 4);
	if (characters == NULL)
		return nil;
	NSUInteger length = 0;
	
	NSUInteger i = 0;
	while (i < [imageData length])
	{
		char buffer[3] = {0,0,0};
		short bufferLength = 0;
		while (bufferLength < 3 && i < [imageData length])
			buffer[bufferLength++] = ((char *)[imageData bytes])[i++];
		
		//  Encode the bytes in the buffer to four characters, including padding "=" characters if necessary.
		characters[length++] = encodingTable[(buffer[0] & 0xFC) >> 2];
		characters[length++] = encodingTable[((buffer[0] & 0x03) << 4) | ((buffer[1] & 0xF0) >> 4)];
		if (bufferLength > 1)
			characters[length++] = encodingTable[((buffer[1] & 0x0F) << 2) | ((buffer[2] & 0xC0) >> 6)];
		else characters[length++] = '=';
		if (bufferLength > 2)
			characters[length++] = encodingTable[buffer[2] & 0x3F];
		else characters[length++] = '=';	
	}
	
	return [[[NSString alloc] initWithBytesNoCopy:characters length:length encoding:NSASCIIStringEncoding freeWhenDone:YES] autorelease];
}

-(void) emailImage: (UIImage *) outputImage {
    NSData *imageData = UIImageJPEGRepresentation(outputImage, 0.9);
	
    if ([MFMailComposeViewController canSendMail]){
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        mailer.mailComposeDelegate = self;
        [mailer setSubject: @"Check out this cool picture made with SteamyBikini!!"];
        [mailer addAttachmentData:imageData mimeType:@"image/png" fileName:@"photo"];
        [self presentModalViewController:mailer animated:YES];
        [mailer release];
    }
}

#pragma mark - Email Delegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error{
    [self dismissModalViewControllerAnimated:YES];
}


-(void) captureOpenGLImage: (bool) sendMail {
/*
	//Allocate memory
	NSInteger myDataLength = 320 * 430 * 4;
	GLubyte *buffer1 = (GLubyte *) malloc(myDataLength);
	GLubyte *buffer2 = (GLubyte *) malloc(myDataLength);	
	
	//Read image memory form OpenGL
	glReadPixels(0, 50, 320, 430, GL_RGBA, GL_UNSIGNED_BYTE, buffer1);

	//Invert result image buffer into secondary buffer
	for(int y = 0; y < 430; y++)	{
		for(int x = 0; x < 320 * 4; x++) {
			buffer2[(429 - y) * 320 * 4 + x] = buffer1[y * 4 * 320 + x];
		}
	}
		
	//Create bitmap context
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef destContext = CGBitmapContextCreate(buffer2, 320, 430, 8, 320 * 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
	
	//Get image from context
	CGImageRef resultContext = CGBitmapContextCreateImage(destContext);
	UIImage *resultImg = [[UIImage imageWithCGImage: resultContext] retain];
	CGImageRelease(resultContext);
*/
    int nToolbar = 44;
    int nWidth = glView.frame.size.width;
    int nHeight = glView.frame.size.height - nToolbar;
    
    //Allocate memory
	NSInteger myDataLength = nWidth * nHeight * 4;
	GLubyte *buffer1 = (GLubyte *) malloc(myDataLength);
	GLubyte *buffer2 = (GLubyte *) malloc(myDataLength);
	
	//Read image memory form OpenGL
	glReadPixels(0, nToolbar, nWidth, nHeight, GL_RGBA, GL_UNSIGNED_BYTE, buffer1);
    
	//Invert result image buffer into secondary buffer
	for(int y = 0; y < nHeight; y++)	{
		for(int x = 0; x < nWidth * 4; x++) {
			buffer2[(nHeight-1 - y) * nWidth * 4 + x] = buffer1[y * 4 * nWidth + x];
		}
	}
    
	//Create bitmap context
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef destContext = CGBitmapContextCreate(buffer2, nWidth, nHeight, 8, nWidth * 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
	
	//Get image from context
	CGImageRef resultContext = CGBitmapContextCreateImage(destContext);
	UIImage *resultImg = [[UIImage imageWithCGImage: resultContext] retain];
	CGImageRelease(resultContext);

	
	//Send to mail or Save to PhotoLibrary
	if (sendMail) {
		[self emailImage: resultImg];
	} else {
		UIImageWriteToSavedPhotosAlbum(resultImg,
                                       self, // send the message to 'self' when calling the callback
                                       @selector(thisImage:hasBeenSavedInPhotoAlbumWithError:usingContextInfo:), // the selector to tell the method to call on completion
                                       NULL);
    }
	
	//Release allocated memory
	[resultImg release];
	free(buffer2);
	free(buffer1);
	CGContextRelease(destContext);
	CGColorSpaceRelease(colorSpace);
}

- (void)thisImage:(UIImage *)image hasBeenSavedInPhotoAlbumWithError:(NSError *)error usingContextInfo:(void*)ctxInfo {
    
    NSString * title = @"";
    NSString * message = @"";
    if (error) {
        // Do anything needed to handle the error or display it to the user
        title = (@"Save error");
        message = (@"That screenshot has not been saved to your album");
    } else {
        // .... do anything you want here to handle
        // .... when the image has been saved in the photo album
        title = (@"Saved to Album");
        message = (@"That screenshot has been saved to your album");
    }
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:title
                                                     message:message delegate:nil cancelButtonTitle:(@"OK") otherButtonTitles:nil, nil];
    [alert show];
}

//System

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}

- (void)dealloc {
	[super dealloc];
}

@end
