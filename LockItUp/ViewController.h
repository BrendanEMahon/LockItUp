//
//  ViewController.h
//  LockItUp
//
//  Created by Brutus on 5/16/16.
//  Copyright © 2016 Extremal Tech. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController

@property (nonatomic, retain) IBOutlet NSTextField *folderNameTextField;
@property (nonatomic, retain) IBOutlet NSTextField *remainingSpace;
@property (nonatomic, retain) IBOutlet NSSlider *sizeSlider;
@property (nonatomic, retain) IBOutlet NSPathControl *pathControl;
@property (nonatomic, retain) NSString *folderName;
@property (nonatomic, retain) NSNumber *folderSize;

- (IBAction)sendFileButtonAction:(id)sender;
- (IBAction)updateFolderSizeLabel:(id)sender;
- (IBAction)createEncryptedFolder:(id)sender;

@end

