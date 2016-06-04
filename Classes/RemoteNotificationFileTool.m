//
//  RemoteNotificationFileTool.m
//  PushMeBaby
//
//  Created by Coody on 2016/6/4.
//
//

#import "RemoteNotificationFileTool.h"

#define K_CER_KEY @"K_CER_KEY"
#define K_CER_PATH_KEY @"K_CER_PATH_KEY"
#define K_NUMBER_KEY @"K_NUMBER_KEY"

@implementation RemoteNotificationFileTool_Model

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.cer forKey:K_CER_KEY];
    [aCoder encodeObject:self.cer_path forKey:K_CER_PATH_KEY];
    [aCoder encodeInteger:self.number forKey:K_NUMBER_KEY];
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if ( self ) {
        self.cer = [aDecoder decodeObjectForKey:K_CER_KEY];
        self.cer_path = [aDecoder decodeObjectForKey:K_CER_PATH_KEY];
        self.number = (int)[aDecoder decodeIntegerForKey:K_NUMBER_KEY];
    }
    return self;
}

@end

@implementation RemoteNotificationFileTool

-(instancetype)initWithIdentifier:(NSString *)tempIdentifier withPath:(NSString *)tempPath{
    self = [super initWithIdentifier:tempIdentifier withPath:tempPath];
    if (self) {
//        self.Model = [[RemoteNotificationFileTool_Model alloc] init];
//        self.Model.cer = @"test";
//        self.Model.cer_path = @"test2";
//        self.Model.number = 9876;
    }
    return self;
}

@end
