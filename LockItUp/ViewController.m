//
//  ViewController.m
//  LockItUp
//
//  Created by Brutus on 5/16/16.
//  Copyright © 2016 Extremal Tech. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

@synthesize folderNameTextField;
@synthesize folderName;
@synthesize remainingSpace;
@synthesize folderSize;
@synthesize sizeSlider;
@synthesize pathControl;

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    NSError *error;
    NSDictionary* fileAttributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:@"/"
                                                                                           error:&error];
    unsigned long long freeSpace_1 = [[fileAttributes objectForKey:NSFileSystemFreeSize] longLongValue];
    NSNumber *freeSpace = [NSNumber numberWithFloat:(freeSpace_1 / 1000000000.)];
    remainingSpace.stringValue = [NSString stringWithFormat:@"Maximum Folder Size: %.1f GB\n(Space Remaining on Disk: %.2f GB)", 0.0, freeSpace.floatValue];
    
    folderSize = [NSNumber numberWithFloat:(0.0*freeSpace.floatValue)];
    sizeSlider.minValue = 0.0;
    sizeSlider.maxValue = freeSpace.doubleValue;
    sizeSlider.doubleValue = folderSize.doubleValue;
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (IBAction)updateFolderSizeLabel:(id)sender{
    
    NSError *error;
    NSDictionary* fileAttributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:@"/"
                                                                                           error:&error];
    unsigned long long freeSpace_1 = [[fileAttributes objectForKey:NSFileSystemFreeSize] longLongValue];
    NSNumber *freeSpace = [NSNumber numberWithFloat:(freeSpace_1 / 1000000000.)];
    remainingSpace.stringValue = [NSString stringWithFormat:@"Maximum Folder Size: %.1f GB\n(Space Remaining on Disk: %.2f GB)", sizeSlider.floatValue, freeSpace.floatValue];

    folderSize = [NSNumber numberWithDouble:sizeSlider.doubleValue];

}

/IS THIS HERE

- (IBAction)sendFileButtonAction:(id)sender{
    
    folderName = folderNameTextField.stringValue;
    
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    [openDlg setCanChooseFiles:NO];
    [openDlg setCanChooseDirectories:YES];
    
    if ( [openDlg runModal] == NSModalResponseOK )  // See #1
    {
        for( NSURL* URL in [openDlg URLs] )  // See #2, #4
        {
            NSURL *newFolderURL = [URL URLByAppendingPathComponent: folderName];
            [pathControl setURL:[newFolderURL path]];
        }
    }
}

- (IBAction)createEncryptedFolder:(id)sender{
    
    NSTask *task;
    task = [[NSTask alloc] init];
    [task setLaunchPath: @"/usr/bin/hdiutil"];
    NSArray *arguments;
    arguments = [NSArray arrayWithObjects:@"create", pathControl.stringValue,@"-encryption",@"-volname",folderName,@"-size",@"100m",@"-type",@"SPARSEBUNDLE",@"-passphrase",@"123",@"-fs",@"HFS+J", nil];
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
    NSLog(@"command returned:\n%@",string);
    
    //[self moveAppleScriptApplication];
    
    [self theAppleScript];

}

-(void)moveAppleScriptApplication {
    NSLog(@"Move Application");
    NSURL *bankURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Bank" ofType:@"app"]];
    NSLog(@"%@",bankURL.absoluteString);
    NSError *error;
    [[NSFileManager defaultManager] copyItemAtURL:bankURL toURL:[NSURL URLWithString:@"file:///Users/brutus/Desktop/Bank.app"] error:&error];
    NSLog(@"%@",error);
    NSLog(@"Application Moved");
}

-(void)setFolderIcon {

    NSImage *iconImage = [[NSImage alloc] initWithContentsOfFile:@"/Users/brutus/Desktop/Yosemite\Lock\Folder.icns"];
    BOOL didSetIcon = [[NSWorkspace sharedWorkspace] setIcon:iconImage forFile:@"/Users/brutus/Desktop/trashimage.sparsebundle" options:0];
    NSLog(@"%d", didSetIcon);

}

-(void)theAppleScript{

    NSString *headerOne = [[@"property diskname1 : \"" stringByAppendingString:folderName] stringByAppendingString:@"\"\r"];
    NSString *headerTwo = [[@"property diskpath1 : \"" stringByAppendingString:pathControl.stringValue] stringByAppendingString:@".sparsebundle\"\r"];
    
    //NSString *bodyOne = [[@"on run\r\r tell application \"Finder\" \r if not (exists the disk diskname1) then \r do shell script (\"hdiutil attach " stringByAppendingString:pathControl.stringValue] stringByAppendingString:@".sparsebundle"];
    NSString *bodyOne = [[@"tell current application \r -->on run\r\r tell application \"Finder\" \r if not (exists the disk diskname1) then \r do shell script (\"hdiutil attach " stringByAppendingString:pathControl.stringValue] stringByAppendingString:@".sparsebundle"];

    NSString *bodyTwo = [bodyOne stringByAppendingString:@"\") \r repeat until name of every disk contains diskname1 \r delay 1 \r end repeat \r end if \r set thePassword to \"none\" \r tell application \"Finder\" to open (\"/Volumes/"];
    NSString *bodyThree = [bodyTwo stringByAppendingString:folderName];
    //NSString *bodyFour = [bodyThree stringByAppendingString:@"/\" as POSIX file) \r tell the front window to set toolbar visible to true \r end tell \r end run"];
    NSString *bodyFour = [bodyThree stringByAppendingString:@"/\" as POSIX file) \r tell the front window to set toolbar visible to true \r end tell \r -->end run \r end tell"];

    NSString *complete = [[headerOne stringByAppendingString:headerTwo] stringByAppendingString:bodyFour];
    //NSString *filePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/LockItUp/Badfasdfa/Contents/MacOS/Resources/Scripts/main.scpt"];;
    //NSString *filePath = @"/Users/brutus/Documents/Extremal_Tech/Mac_App/LockItUp/test/Contents/Resources/Scripts/main2.scpt";
    NSString *filePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/Contents/Resources/LockedUp/Contents/Resources/Scripts/main.scpt"];
    [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
    [[complete dataUsingEncoding:NSUTF8StringEncoding] writeToFile:filePath atomically:YES];
    NSString *filePath2 = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/Contents/Resources/LockedUp"];
    NSError *error2;
    NSString *newPath = [pathControl.stringValue stringByAppendingString:@""];
                         
    [[NSFileManager defaultManager] copyItemAtPath:filePath2 toPath:newPath error:&error2];
}

@end
