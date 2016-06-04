//
//  ApplicationDelegate.h
//  PushMeBaby
//
//  Created by Stefan Hafeneger on 07.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "ioSock.h"

@interface ApplicationDelegate : NSObject {
	NSString *_deviceToken, *_payload, *_certificate;
	otSocket socket;
	SSLContextRef context;
	SecKeychainRef keychain;
	SecCertificateRef certificate;
	SecIdentityRef identity;
    
    NSTextField *keyTextField;
    NSTextField *valueTextField;
    NSTextField *tokenTextField;
    NSTextField *payLoadTextField;
    NSTextField *pathTextField;
    NSTextField *targetTextField;
    NSButton *savePath;
    NSPopUpButtonCell *devicePopButton;
    NSButton *saveTargetButton;
}
@property (assign) IBOutlet NSTextField *keyTextField;
@property (assign) IBOutlet NSTextField *valueTextField;
@property (assign) IBOutlet NSTextField *tokenTextField;
@property (assign) IBOutlet NSTextField *payLoadTextField;
@property (assign) IBOutlet NSTextField *pathTextField;
@property (assign) IBOutlet NSTextField *targetTextField;

@property (assign) IBOutlet NSButton *savePath;
@property (assign) IBOutlet NSPopUpButtonCell *devicePopButton;
@property (assign) IBOutlet NSButton *saveTargetButton;

#pragma mark IBAction
- (IBAction)push:(id)sender;

- (IBAction)selectEenuButton:(id)sender;

- (IBAction)change:(id)sender;

- (IBAction)addKeyValue:(id)sender;

- (IBAction)savePathWithUserPath:(id)sender;

- (IBAction)selectedDevicePopButton:(id)sender;

- (IBAction)saveTarget:(id)sender;

@end
