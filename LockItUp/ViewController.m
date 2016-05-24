//
//  ViewController.m
//  LockItUp
//
//  Created by Brendan E. Mahon on 5/16/16.
//  Copyright © 2016 Extremal Tech. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

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
    
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    [openDlg setCanChooseFiles:NO];
    [openDlg setCanChooseDirectories:YES];
    
    [progressIndicator startAnimation:self];
    NSURL *oldFolderURL;
    if ( [openDlg runModal] == NSModalResponseOK )  // See #1
    {
        for( NSURL* URL in [openDlg URLs] )  // See #2, #4
        {
            oldFolderURL = URL;
            NSURL *newFolderURL = URL;
            folderPathString = newFolderURL.path;
            NSLog(@"folderPathString: %@",folderPathString);
        }
    }
    
    NSString *folderName;
    folderName = oldFolderURL.lastPathComponent;
    
    NSString  *thePassword;
    if ([secureTextOne.stringValue isEqualToString:secureTextTwo.stringValue]) {
        
        NSString *filePathPlist = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/Contents/Resources/LockedUp.app/Contents/Resources/Scripts/Locations.plist"];
        [[NSFileManager defaultManager] createFileAtPath:filePathPlist contents:nil attributes:nil];
        NSMutableDictionary *plistDict = [[NSMutableDictionary alloc] init];
        [plistDict setValue:folderName forKey:@"DiskName"];
        NSNumber *zeroNumber = [[NSNumber alloc] initWithInt:0];
        [plistDict setValue:zeroNumber forKey:@"ImageSize"];
        [plistDict writeToFile:filePathPlist atomically: YES];
        
        
        
        NSString *filePath2 = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/Contents/Resources/LockedUp.app"];
        NSError *error2;
        NSString *newPath = [folderPathString stringByAppendingString:@".app"];
        
        [[NSFileManager defaultManager] copyItemAtPath:filePath2 toPath:newPath error:&error2];
        
        NSError *error3;
        NSString *unencryptedFolder = [oldFolderURL.path stringByAppendingString:@"_Unencrypted"];
        [[NSFileManager defaultManager] moveItemAtPath:oldFolderURL.path toPath:unencryptedFolder error:&error3];
        
        thePassword = secureTextOne.stringValue;
    
        NSTask *task1;
        task1 = [[NSTask alloc] init];
        [task1 setLaunchPath: @"/usr/bin/hdiutil"];
        NSArray *arguments1;
        arguments1 = [NSArray arrayWithObjects:@"create", [[folderPathString stringByAppendingString:@".app/Contents/Resources/Scripts/"] stringByAppendingString:folderName],@"-encryption",@"-volname",folderName,@"-size",[folderSize.stringValue stringByAppendingString:@"g"],@"-type",@"SPARSEBUNDLE",@"-passphrase",thePassword,@"-fs",@"HFS+J", nil];
        [task1 setArguments:arguments1];
        
        NSPipe *pipe1;
        pipe1 = [NSPipe pipe];
        [task1 setStandardOutput: pipe1];
        NSFileHandle *file1;
        file1 = [pipe1 fileHandleForReading];
        [task1 launch];
        NSData *data1;
        data1 = [file1 readDataToEndOfFile];
        NSString *string1;
        string1 = [[NSString alloc] initWithData: data1 encoding: NSUTF8StringEncoding];
        
        NSTask *task2;
        task2 = [[NSTask alloc] init];
        [task2 setLaunchPath: @"/usr/bin/hdiutil"];
        NSArray *arguments2;
        arguments2 = [NSArray arrayWithObjects:@"attach", [[[folderPathString stringByAppendingString:@".app/Contents/Resources/Scripts/"] stringByAppendingString:folderName] stringByAppendingString:@".sparsebundle/"],@"-passphrase",thePassword, nil];
        [task2 setArguments:arguments2];
        
        NSPipe *pipe2;
        pipe2 = [NSPipe pipe];
        [task2 setStandardOutput: pipe2];
        NSFileHandle *file2;
        file2 = [pipe2 fileHandleForReading];
        [task2 launch];
        NSData *data2;
        data2 = [file2 readDataToEndOfFile];
        NSString *string2;
        string2 = [[NSString alloc] initWithData: data2 encoding: NSUTF8StringEncoding];
        
        // Get all the files at ~/Documents/user
        NSError *error4;
        NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:unencryptedFolder error:&error4];
        NSError *differentError;
        for (NSString *file in files) {
            NSString *oldPath2 = [unencryptedFolder stringByAppendingPathComponent:file];
            NSString *toPath2 = [[[@"/Volumes/" stringByAppendingString:folderName] stringByAppendingString:@"/"]stringByAppendingPathComponent:file];
            NSLog(@"O:%@ N:%@",oldPath2,toPath2);
            [[NSFileManager defaultManager] copyItemAtPath:oldPath2 toPath:toPath2 error:&differentError];
        }
        
        NSTask *task3;
        task3 = [[NSTask alloc] init];
        [task3 setLaunchPath: @"/usr/bin/hdiutil"];
        NSArray *arguments3;
        arguments3 = [NSArray arrayWithObjects:@"detach", [[@"/Volumes/" stringByAppendingString:folderName] stringByAppendingString:@"/"], nil];
        [task3 setArguments:arguments3];
        
        NSPipe *pipe3;
        pipe3 = [NSPipe pipe];
        [task3 setStandardOutput: pipe3];
        NSFileHandle *file3;
        file3 = [pipe3 fileHandleForReading];
        [task3 launch];
        NSData *data3;
        data2 = [file3 readDataToEndOfFile];
        NSString *string3;
        string3 = [[NSString alloc] initWithData: data3 encoding: NSUTF8StringEncoding];
    
        
    thePassword = nil;
    

    }
    else {
        folderButton.title = @"Passwords did not match.";
    }
    
    [progressIndicator stopAnimation:self];

}



@end
