//
//  ViewController.h
//  LockItUp
//
//  Created by Brendan E. Mahon on 5/16/16.
//  Copyright © 2016 Extremal Tech. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController

@property (nonatomic, retain) NSNumber *folderSize;
@property (nonatomic, retain) IBOutlet NSSecureTextField *secureTextOne;
@property (nonatomic, retain) IBOutlet NSSecureTextField *secureTextTwo;
@property (nonatomic, retain) IBOutlet NSButton *folderButton;
@property (nonatomic, retain) NSString *folderPathString;
@property (nonatomic, retain) IBOutlet NSProgressIndicator *progressIndicator;

- (IBAction)sendFileButtonAction:(id)sender;

@end

