//
//  SaveFileTools.m
//  PushMeBaby
//
//  Created by Coody on 2016/6/3.
//
//

#import "SaveFileTools.h"

@implementation SaveFileTools

/** 
 * 初始化，帶入此存檔系統的辨識碼
 */
-(nonnull instancetype)initWithIdentifier:(nonnull NSString *)tempIdentifier 
                                 withPath:(NSString *)tempPath{
    self = [super init];
    if ( self ) {
        
        // 這裡是檔案名稱（唯一識別碼）
        _fileIdentify = [tempIdentifier copy];
        
        // 這裡是檔案路徑（包含檔案）
        _saveFilePath = [NSString stringWithFormat:@"%@/%@" , tempPath , _fileIdentify];
        
    }
    return self;
}

-(void)loadModelWithJsonFilePath:(nonnull NSString *)tempFilePath{
    NSError *getFilePatherror;
    NSString *fileContents = [NSString stringWithContentsOfFile:tempFilePath 
                                                       encoding:NSUTF8StringEncoding 
                                                          error:&getFilePatherror];
    if( getFilePatherror == nil ){
        NSError *getJsonError;
        id data = [NSJSONSerialization JSONObjectWithData:[fileContents dataUsingEncoding:NSUTF8StringEncoding] 
                                                  options:NSJSONReadingMutableContainers 
                                                    error:&getJsonError];
        if( getJsonError == nil ){
            if ( [self respondsToSelector:@selector(receiveJsonData:)] ) {
                [self receiveJsonData:data];
            }
        }
        else{
            NSLog(@"load json File fail! (Error : %@)" , getJsonError);
        }
    }
    else{
        NSLog(@"load json File fail! (Error : %@)" , getFilePatherror);
    }
}

-(BOOL)save{
    if ( [self respondsToSelector:@selector(checkData)] ) {
        [self checkData];
    }
    BOOL isSuccess = [NSKeyedArchiver archiveRootObject:_Model toFile:_saveFilePath];
    return isSuccess;
}

-(BOOL)load{
    BOOL isSuccess = NO;
    BOOL hasFile = [[NSFileManager defaultManager] fileExistsAtPath:_saveFilePath];
    if ( hasFile ) {
        id tempModel = _Model;
        _Model = [NSKeyedUnarchiver unarchiveObjectWithFile:_saveFilePath];
        if ( _Model == nil ) {
            _Model = tempModel;
        }
        else{
            if ( [self respondsToSelector:@selector(checkData)] ) {
                [self checkData];
            }
            isSuccess = YES;
        }
    }
    return isSuccess;
}

#pragma mark - Override
-(NSData *)transformModelToData{
    NSLog(@"繼承此類別時，請覆寫此方法！");
    return nil;
}

@end
