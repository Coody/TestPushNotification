//
//  ApplicationDelegate.m
//  PushMeBaby
//
//  Created by Stefan Hafeneger on 07.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

/*
 
 *dev 环境
 result = MakeServerConnection("gateway.sandbox.push.apple.com", 2195, &socket, &peer);
 result = SSLSetPeerDomainName(context, "gateway.sandbox.push.apple.com", 30);
 
 *ADHOC
 result = MakeServerConnection("gateway.push.apple.com", 2195, &socket, &peer);
 result = SSLSetPeerDomainName(context, "gateway.push.apple.com", 22); 
 
 */

#import "ApplicationDelegate.h"


//NSString * const O8AppTargetTypeNotSet = @"NotSet";
//NSString * const O8AppTargetTypeAllInOne = @"O8AppAllInOne";
//NSString * const O8AppTargetTypeElectronic = @"O8AppElectronic";
//NSString * const O8AppTargetTypePachin = @"O8AppPachin";
//NSString * const O8AppTargetTypeReal = @"O8AppReal";
//NSString * const O8AppTargetSlot = @"O8AppSlot";

#define D_Dev_Ver

// *.cer 檔案名稱
#ifdef D_Dev_Ver
#define CER_NAME @"TTQRCode_Apns_Development"
#else
#define CER_NAME @"TTQRCode_Apns_Distribution"
#endif

// Product 名稱
#define PRODUCT_NAME @"TTQRCode"

// 預設推播憑證路徑（絕對路徑）
#define CER_PATH @"/Users/coodychou/Desktop/TaiwanTaxi/GitLab/iOS_Shared/Data/TTQRCode/PushNotification"
// 預設 Token
#define TEST_TOKEN @"fc908a75 5fc28bae d19bcb68 f733d2a5 c11f40fc 133a3219 b577bfb4 fa8d758f"

#include <Carbon/Carbon.h>

@interface ApplicationDelegate ()


#pragma mark Properties
@property (nonatomic , strong) NSString *payload, *certificate , *deviceToken;
/** 記住 App Target 並且對應該 .cer File */
@property (nonatomic , strong) NSMutableString *appTarget;
@property (nonatomic , strong) NSMutableDictionary *targetKeyDeviceTokenValue;
#pragma mark Private
- (void)connect;
- (void)disconnect;
@end


@implementation ApplicationDelegate
#pragma mark Properties
@synthesize keyTextField;
@synthesize valueTextField;
@synthesize tokenTextField;
@synthesize payLoadTextField;
@synthesize pathTextField;
@synthesize savePath;
@synthesize devicePopButton;
@synthesize deviceToken = _deviceToken;
@synthesize payload = _payload;
@synthesize certificate = _certificate;


#pragma mark Allocation
- (id)init {
    self = [super init];
    if(self != nil) {
        
        if( _targetKeyDeviceTokenValue == nil ){
            _targetKeyDeviceTokenValue = [[NSMutableDictionary alloc] init];
        }
        _appTarget = [[NSMutableString alloc] initWithString:CER_NAME];
        _deviceToken = [[NSString alloc] initWithString:TEST_TOKEN];
        [_targetKeyDeviceTokenValue setObject:[_deviceToken copy] forKey:PRODUCT_NAME];
        
        _payload = @"{\"aps\":{\"sound\":\"normal.wav\",\"badge\":1,\"alert\":\"台灣大車隊測試推撥\"},\"type\":0}";
        
#ifdef D_Dev_Ver
        _certificate = [[NSString stringWithFormat:@"%@/Development/%@.cer", CER_PATH , _appTarget ] copy];
#else
        _certificate = [[NSString stringWithFormat:@"%@/Distribution/%@.cer", CER_PATH , _appTarget ] copy];
#endif
        
    }
    return self;
}


- (void)dealloc {
    
    // Release objects.
    self.deviceToken = nil;
    self.payload = nil;
    self.certificate = nil;
    
    // Call super.
    [super dealloc];
}

#pragma mark Inherent

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    [self load];
    [self loadPathInBundle];
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    [self disconnect];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)application {
    return YES;
}

#pragma mark Private

- (void)connect {
    
    if(self.certificate == nil) {
        return;
    }
    
    // Define result variable.
    OSStatus result;
    
    // Establish connection to server.
    PeerSpec peer;
    result = MakeServerConnection("gateway.sandbox.push.apple.com", 2195, &socket, &peer);// NSLog(@"MakeServerConnection(): %d", result);
    
    // Create new SSL context.
    result = SSLNewContext(false, &context);// NSLog(@"SSLNewContext(): %d", result);
    
    // Set callback functions for SSL context.
    result = SSLSetIOFuncs(context, SocketRead, SocketWrite);// NSLog(@"SSLSetIOFuncs(): %d", result);
    
    // Set SSL context connection.
    result = SSLSetConnection(context, socket);// NSLog(@"SSLSetConnection(): %d", result);
    
    // Set server domain name.
    result = SSLSetPeerDomainName(context, "gateway.sandbox.push.apple.com", 30);// NSLog(@"SSLSetPeerDomainName(): %d", result);
    
    // Open keychain.
    result = SecKeychainCopyDefault(&keychain);// NSLog(@"SecKeychainOpen(): %d", result);
    
    // Create certificate.
    NSData *certificateData = [NSData dataWithContentsOfFile:self.certificate];
    
    
    certificate = SecCertificateCreateWithData(kCFAllocatorDefault, (CFDataRef)certificateData);
    if (certificate == NULL)
        NSLog (@"SecCertificateCreateWithData failled");
    
    // Create identity.
    result = SecIdentityCreateWithCertificate(keychain, certificate, &identity);// NSLog(@"SecIdentityCreateWithCertificate(): %d", result);
    
    // Set client certificate.
    CFArrayRef certificates = CFArrayCreate(NULL, (const void **)&identity, 1, NULL);
    result = SSLSetCertificate(context, certificates);// NSLog(@"SSLSetCertificate(): %d", result);
    CFRelease(certificates);
    
    // Perform SSL handshake.
    do {
        result = SSLHandshake(context);// NSLog(@"SSLHandshake(): %d", result);
    } while(result == errSSLWouldBlock);
    
    
}

- (void)disconnect {
    
    if(self.certificate == nil) {
        return;
    }
    
    // Define result variable.
    OSStatus result;
    
    // Close SSL session.
    result = SSLClose(context);// NSLog(@"SSLClose(): %d", result);
    
    // Release identity.
    if (identity != NULL)
        CFRelease(identity);
    
    // Release certificate.
    if (certificate != NULL)
        CFRelease(certificate);
    
    // Release keychain.
    if (keychain != NULL)
        CFRelease(keychain);
    
    // Close connection to server.
    close((int)socket);
    
    // Delete SSL context.
    result = SSLDisposeContext(context);// NSLog(@"SSLDisposeContext(): %d", result);
    
}

#pragma mark IBAction

- (IBAction)push:(id)sender {
    
    [self connect];
    
    
    if(self.certificate == nil) {
        NSLog(@"you need the APNS Certificate for the app to work");
        exit(1);
    }
    
    // Validate input.
    if(self.deviceToken == nil || self.payload == nil) {
        return;
    }
    
    // Convert string into device token data.
    NSMutableData *deviceToken = [NSMutableData data];
    unsigned value;
    NSScanner *scanner = [NSScanner scannerWithString:self.deviceToken];
    while(![scanner isAtEnd]) {
        [scanner scanHexInt:&value];
        value = htonl(value);
        [deviceToken appendBytes:&value length:sizeof(value)];
    }
    
    // Create C input variables.
    char *deviceTokenBinary = (char *)[deviceToken bytes];
    char *payloadBinary = (char *)[self.payload UTF8String];
    size_t payloadLength = strlen(payloadBinary);
    
    // Define some variables.
    uint8_t command = 0;
    char message[293];
    char *pointer = message;
    uint16_t networkTokenLength = htons(32);
    uint16_t networkPayloadLength = htons(payloadLength);
    
    // Compose message.
    memcpy(pointer, &command, sizeof(uint8_t));
    pointer += sizeof(uint8_t);
    memcpy(pointer, &networkTokenLength, sizeof(uint16_t));
    pointer += sizeof(uint16_t);
    memcpy(pointer, deviceTokenBinary, 32);
    pointer += 32;
    memcpy(pointer, &networkPayloadLength, sizeof(uint16_t));
    pointer += sizeof(uint16_t);
    memcpy(pointer, payloadBinary, payloadLength);
    pointer += payloadLength;
    
    // Send message over SSL.
    size_t processed = 0;
    OSStatus result = SSLWrite(context, &message, (pointer - message), &processed);
    if (result != noErr)
        NSLog(@"SSLWrite(): %d %zd", result, processed);
    
}

- (IBAction)selectEenuButton:(id)sender{
//    NSPopUpButton *tempMenuItem = (NSPopUpButton *)sender;
//    if ( [tempMenuItem.title isEqualToString:O8AppTargetTypeAllInOne] ) {
//
//    }
//    else if( [tempMenuItem.title isEqualToString:O8AppTargetTypeElectronic] ){
//        [_appTarget setString:@"development_com.gonline.O8AppElectronic"];
//        if ( [_targetKeyDeviceTokenValue objectForKey:O8AppTargetTypeElectronic] ) {
//            _deviceToken = [[_targetKeyDeviceTokenValue objectForKey:O8AppTargetTypeElectronic] copy];
//        }
//        else{
//            [_targetKeyDeviceTokenValue setObject:[_deviceToken copy] forKey:O8AppTargetTypeElectronic];
//        }
//    }
//    else if( [tempMenuItem.title isEqualToString:O8AppTargetTypePachin] ){
//        [_appTarget setString:@"development_com.gonline.O8AppPachin"];
//        if ( [_targetKeyDeviceTokenValue objectForKey:O8AppTargetTypePachin] ) {
//            _deviceToken = [[_targetKeyDeviceTokenValue objectForKey:O8AppTargetTypePachin] copy];
//        }
//        else{
//            [_targetKeyDeviceTokenValue setObject:[_deviceToken copy] forKey:O8AppTargetTypePachin];
//        }
//    }
//    else if( [tempMenuItem.title isEqualToString:O8AppTargetTypeReal] ){
//        [_appTarget setString:@"development_com.gonline.O8AppReal"];
//        if ( [_targetKeyDeviceTokenValue objectForKey:O8AppTargetTypeReal] ) {
//            _deviceToken = [[_targetKeyDeviceTokenValue objectForKey:O8AppTargetTypeReal] copy];
//        }
//        else{
//            [_targetKeyDeviceTokenValue setObject:[_deviceToken copy] forKey:O8AppTargetTypeReal];
//        }
//    }
//    else if( [tempMenuItem.title isEqualToString:O8AppTargetSlot] ){
//        [_appTarget setString:@"development_com.gonline.O8AppSlot"];
//        if ( [_targetKeyDeviceTokenValue objectForKey:O8AppTargetSlot] ) {
//            _deviceToken = [[_targetKeyDeviceTokenValue objectForKey:O8AppTargetSlot] copy];
//        }
//        else{
//            [_targetKeyDeviceTokenValue setObject:[_deviceToken copy] forKey:O8AppTargetSlot];
//        }
//    }
//    else{
//        [_appTarget setString:@"development_com.gonline.O8AppElectronic"];
//    }
    
    [_appTarget setString:CER_NAME];
//    if ( [_targetKeyDeviceTokenValue objectForKey:O8AppTargetTypeAllInOne] ) {
//        _deviceToken = [[_targetKeyDeviceTokenValue objectForKey:O8AppTargetTypeAllInOne] copy];
//    }
//    else{
//        [_targetKeyDeviceTokenValue setObject:[_deviceToken copy] forKey:O8AppTargetTypeAllInOne];
//    }
    
    
//    [self.tokenTextField setStringValue:_deviceToken];
#ifdef D_Dev_Ver
    _certificate = [[NSString stringWithFormat:@"%@/Development/%@.cer", CER_PATH , _appTarget ] copy];
#else
    _certificate = [[NSString stringWithFormat:@"%@/Distribution/%@.cer", CER_PATH , _appTarget ] copy];
#endif
}


- (IBAction)change:(id)sender{
    NSString *tempTargetString = [_appTarget pathExtension];
    [_targetKeyDeviceTokenValue setObject:[[self.tokenTextField stringValue] copy] forKey:tempTargetString];
    _deviceToken = [[self.tokenTextField stringValue] copy];
    [self save];
}

- (IBAction)savePathWithUserPath:(id)sender{
//    if ( [pathTextField.stringValue isEqualToString:@""] || pathTextField == nil ) {
//        [pathTextField setStringValue:@"/Users/coody/Desktop/iOS_Share/doc/gonline/憑證/推播/O8App/Exhibition"];
//    }
//    _certificate = [[NSString stringWithFormat:@"%@/%@/development/%@.cer", [pathTextField.stringValue copy] , [[self.appTarget pathExtension] stringByReplacingOccurrencesOfString:@"O8App" withString:@"AllInOne"] , _appTarget ] copy];
//    [self savePathInBundle];
}

- (IBAction)addKeyValue:(id)sender{
    
    NSMutableString *tempPayload = [[NSMutableString alloc] init];
    [tempPayload setString:[_payload stringByReplacingOccurrencesOfString:@" " withString:@""]];
    if ( [tempPayload characterAtIndex:([tempPayload length] - 1)] == '}' ) {
        NSString *tempKeyString = [self.keyTextField stringValue];
        NSString *tempValueString = [self.valueTextField stringValue];
        
        [tempPayload setString:[tempPayload substringToIndex:([tempPayload length]-1)]];
        if ((![tempValueString isEqualToString:@""] && tempValueString != nil)) {
            // @"{\"aps\":{\"sound\":\"default\",\"badge\":1,\"alert\":\"測試 O8App 推播！\"}}";
            [tempPayload setString:[tempPayload stringByAppendingString:[NSString stringWithFormat:@",\"%@\":\"%@\"}" , tempKeyString , tempValueString]]];
            _payload = [tempPayload copy];
            [payLoadTextField setStringValue:_payload];
        }
        else{
            return;
        }
        
    }
    // {\"aps\":{\"sound\":\"default\",\"badge\":1,\"alert\":\"測試 O8App 推播！\"}
}


-(void)save{
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSLog(@"\n\n********************************************************************\n bundle path save : %@ \n********************************************************************\n\n" , path);
    NSString *saveDateName = [path stringByAppendingPathComponent:@"deviceToken"];
    
    [NSKeyedArchiver archiveRootObject:_targetKeyDeviceTokenValue toFile:saveDateName];
}


-(void)load{
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSLog(@"\n\n********************************************************************\n bundle path load : %@ \n********************************************************************\n\n" , path);
    NSString *loadDataName = [path stringByAppendingPathComponent:@"deviceToken"];
    if ( ![[NSFileManager defaultManager] fileExistsAtPath:loadDataName] ) {
        return;
    }
    NSDictionary *tokenDic = [NSKeyedUnarchiver unarchiveObjectWithFile:loadDataName];
    _targetKeyDeviceTokenValue = [tokenDic mutableCopy];
    
}

-(void)savePathInBundle{
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSLog(@"\n\n********************************************************************\n bundle path save : %@ \n********************************************************************\n\n" , path);
    NSString *savePathName = [path stringByAppendingPathComponent:@"path"];
    
    [NSKeyedArchiver archiveRootObject:@{@"path":pathTextField.stringValue} toFile:savePathName];
}

-(void)loadPathInBundle{
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSLog(@"\n\n********************************************************************\n bundle path load : %@ \n********************************************************************\n\n" , path);
    NSString *loadPathName = [path stringByAppendingPathComponent:@"path"];
    if ( ![[NSFileManager defaultManager] fileExistsAtPath:loadPathName] ) {
        return;
    }
    NSDictionary *pathDic = [NSKeyedUnarchiver unarchiveObjectWithFile:loadPathName];
    [pathTextField setStringValue:[[pathDic objectForKey:@"path"] copy]];
}


@end
