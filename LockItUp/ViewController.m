//
//  ViewController.m
//  LockItUp
//
//  Created by Brendan E. Mahon on 5/16/16.
//  Copyright © 2016 Extremal Tech. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

@synthesize folderNameTextField;
@synthesize folderName;
@synthesize remainingSpace;
@synthesize folderSize;
@synthesize secureTextOne;
@synthesize secureTextTwo;
@synthesize folderButton;
@synthesize folderPathString;
@synthesize progressIndicator;

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    NSError *error;
    NSDictionary* fileAttributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:@"/"
                                                                                           error:&error];
    unsigned long long freeSpace_1 = [[fileAttributes objectForKey:NSFileSystemFreeSize] longLongValue];
    NSNumber *freeSpace = [NSNumber numberWithFloat:(freeSpace_1 / 1000000000.)];
    
    folderSize = freeSpace;
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


- (IBAction)sendFileButtonAction:(id)sender{
    
    folderName = folderNameTextField.stringValue;
    
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    [openDlg setCanChooseFiles:NO];
    [openDlg setCanChooseDirectories:YES];
    
    [progressIndicator startAnimation:self];
    
    if ( [openDlg runModal] == NSModalResponseOK )  // See #1
    {
        for( NSURL* URL in [openDlg URLs] )  // See #2, #4
        {
            NSURL *newFolderURL = [URL URLByAppendingPathComponent: folderName];
            folderPathString = newFolderURL.path;
            NSLog(@"folderPathString: %@",folderPathString);
        }
    }
    
    NSString *thePassword;
    if ([secureTextOne.stringValue isEqualToString:secureTextTwo.stringValue]) {
        thePassword = secureTextOne.stringValue;
    
        NSTask *task;
        task = [[NSTask alloc] init];
        [task setLaunchPath: @"/usr/bin/hdiutil"];
        NSArray *arguments;
    
        arguments = [NSArray arrayWithObjects:@"create", folderPathString,@"-encryption",@"-volname",folderName,@"-size",[folderSize.stringValue stringByAppendingString:@"g"],@"-type",@"SPARSEBUNDLE",@"-passphrase",thePassword,@"-fs",@"HFS+J", nil];
        [task setArguments:arguments];
    
    NSPipe *pipe;
    pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
    NSFileHandle *file;
    file = [pipe fileHandleForReading];
    [task launch];
    NSData *data;
    data = [file readDataToEndOfFile];
    NSString *string;
    string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    
    thePassword = nil;
    
    NSString *filePathPlist = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/Contents/Resources/LockedUp.app/Contents/Resources/Scripts/Locations.plist"];
    [[NSFileManager defaultManager] createFileAtPath:filePathPlist contents:nil attributes:nil];
    NSMutableDictionary *plistDict = [[NSMutableDictionary alloc] init];
    [plistDict setValue:[folderPathString stringByAppendingString:@".sparsebundle"] forKey:@"DiskPath"];
    [plistDict setValue:folderName forKey:@"DiskName"];
    NSNumber *zeroNumber = [[NSNumber alloc] initWithInt:0];
    [plistDict setValue:zeroNumber forKey:@"ImageSize"];
    [plistDict writeToFile:filePathPlist atomically: YES];
    
        
    NSString *filePath2 = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/Contents/Resources/LockedUp.app"];
    NSError *error2;
    NSString *newPath = [folderPathString stringByAppendingString:@".app"];
    
    [[NSFileManager defaultManager] copyItemAtPath:filePath2 toPath:newPath error:&error2];
    }
    else {
        folderButton.title = @"Passwords did not match.";
    }
    
    [progressIndicator stopAnimation:self];

}



@end
