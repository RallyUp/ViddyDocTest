//
//  VDTViewController.m
//  ViddyDocTest
//
//  Created by Ethan Nagel on 6/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VDTViewController.h"

@interface VDTViewController () <UIDocumentInteractionControllerDelegate>

@property (strong,readwrite)    UIDocumentInteractionController *docController;

@end

@implementation VDTViewController

@synthesize docController;


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


#define LLog NSLog
#define LError NSLog


-(BOOL)preValidate:(NSURL *)url
{
    LLog(@"preValidate:%@", url);
    
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:url 
                                                            cachePolicy:NSURLRequestUseProtocolCachePolicy 
                                                        timeoutInterval:30.0];
    
    NSURLResponse* response = nil; 
    NSError *error = nil;
    [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];
    
    if ( error )
        LError(@"    sendSynchronousRequest failed: %@", error);
    
    if ( !response )
        LError(@"    response is nil!");
    
    LLog(@"    MIMEType: %@", response.MIMEType);
    
    if ([[response MIMEType] isEqualToString:@"video/mp4"] || [[response MIMEType] isEqualToString:@"video/m4v"]) 
    {
        LLog(@"    Valid MIMEType!");
        return YES;
    }
    
    LError(@"    Invalid MIMEType");
    return NO;
}


-(BOOL)shareOnViddy:(NSString *)filename
{
    // The file must have a .viddy extension...
    
    //    NSString *viddyFilename = [NSString stringWithFormat:@"%@video.viddy", [FileUtility tempFolder]];
    NSString *viddyFilename = [NSString stringWithFormat:@"%@video.mp4", NSTemporaryDirectory()];
    
    [[NSFileManager defaultManager] removeItemAtPath:viddyFilename error:nil]; // make sure the file doesn't currently exist
    
    if ( ![[NSFileManager defaultManager] copyItemAtPath:filename toPath:viddyFilename error:nil] )
    {
        LError(@"Error copying file!");
        return NO;
    }
    
    NSURL *url = [NSURL fileURLWithPath:viddyFilename];
    
    if ( ![self preValidate:url] )
    {
        //        return NO;  CONTINUE ON FOR NOW OR WE WOULD NEVER LAUNCH VIDDY!
    }
    
    if ( !self.docController )
    {
        self.docController = [UIDocumentInteractionController interactionControllerWithURL:url];
        self.docController.delegate = self;
        self.docController.UTI = @"com.viddy.media";
    }
    else 
    {
        self.docController.URL = [NSURL fileURLWithPath:viddyFilename];
    }
    
    /* This works the same way but isn't a great experience at all...  
     if ( ![self.docController presentPreviewAnimated:YES] )
     {
     LError(@"Preview Failed");
     return NO;
     }
     */
    
    // This experience is a little better...
    if ( ![self.docController presentOpenInMenuFromRect:self.view.bounds inView:self.view animated:YES] )
    {
        LError(@"presentOpenInMenuFromRect Failed");
        return NO;
    }
    
    return YES;
    
}


- (IBAction)doTest:(id)sender 
{
    NSString *filename = [[NSBundle mainBundle] pathForResource:@"sample" ofType:@"mp4"];
    
    [self shareOnViddy:filename];
}


#pragma mark UIDocumentInteractionControllerDelegate methods


-(UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller
{
    LLog(@"documentInteractionControllerViewControllerForPreview");
    return self;
}


@end
