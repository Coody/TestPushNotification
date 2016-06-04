//
//  SaveFileToolsManager.m
//  PushMeBaby
//
//  Created by Coody on 2016/6/3.
//
//

#import "SaveFileToolsManager.h"

#import "SaveFileTools.h"

NSString *const K_SAVE_FILE_PATH_PREFIX = @"SAVE_";
NSString *const K_SAVE_FILE_FOLDER_NAME = @"SaveFiles";


@interface SaveFileToolsManager()
{
    NSString *_documentsDirectory;
}
@property (nonnull , nonatomic , strong) NSString *totalFilePath;
@property (nonnull , nonatomic , strong) NSString *fileFolderName;
@property (nonnull , nonatomic , strong) NSMutableDictionary *saveFileToolsDic;
@end

@implementation SaveFileToolsManager

+(instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    static SaveFileToolsManager *saveFileToolsManager = nil;
    dispatch_once(&onceToken, ^{
        saveFileToolsManager = [[SaveFileToolsManager alloc] init];
    });
    return saveFileToolsManager;
}

-(instancetype)init{
    self = [super init];
    if ( self ) {
        _saveFileToolsDic = [[NSMutableDictionary alloc] init];
        // 預設為 App 本身的 main bundlePath 加上 /SaveFiles
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
        _documentsDirectory = [paths objectAtIndex:0];
        _totalFilePath = [NSString stringWithFormat:@"%@/%@" , _documentsDirectory , K_SAVE_FILE_FOLDER_NAME ];
    }
    return self;
}

-(void)setFilePath:(NSString *)tempFilePath{
    
    static BOOL hasAlreadySet = NO;
    if ( hasAlreadySet == NO ) {
        
        if ( tempFilePath == nil || [tempFilePath isEqualToString:@""] ) {
            // 預設為 App 本身的 main bundlePath 加上 /SaveFiles
            _totalFilePath = [NSString stringWithFormat:@"%@/%@" , _documentsDirectory , K_SAVE_FILE_FOLDER_NAME ];
        }
        else{
            if ( [[tempFilePath substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"/"] ) {
                _totalFilePath = [NSString stringWithFormat:@"%@%@" , _documentsDirectory , tempFilePath ];
            }
            else{
                _totalFilePath = [NSString stringWithFormat:@"%@/%@" , _documentsDirectory , tempFilePath ];
            }
        }
        
        NSError *error;
        if ( ![[NSFileManager defaultManager] fileExistsAtPath:_totalFilePath] ) {
            
            [[NSFileManager defaultManager] createDirectoryAtPath:_totalFilePath 
                                      withIntermediateDirectories:YES 
                                                       attributes:nil 
                                                            error:&error];
        }
        if ( error ) {
            NSLog(@"Create File Path FAIL !!!");
        }
        else{
            hasAlreadySet = YES;
        }
    }
    else{
        NSLog(@"You have already set the FILE PATH !!");
    }
}

-(void)setSaveFileToolsWithClassNameArray:(nullable NSArray<NSString *> *)tempArray
                                  withKey:(nonnull NSString *)tempKey{
    NSMutableArray *classArray = [[NSMutableArray alloc] initWithCapacity:[tempArray count]];
    _fileFolderName = [tempKey copy];
    NSString *allPath = [NSString stringWithFormat:@"%@/%@" , _totalFilePath , _fileFolderName];
    
    // 依照 tempKey 建立相對應資料夾（多存檔系統）
    NSError *error;
    if ( ![[NSFileManager defaultManager] fileExistsAtPath:allPath] ) {
        
        [[NSFileManager defaultManager] createDirectoryAtPath:allPath 
                                  withIntermediateDirectories:YES 
                                                   attributes:nil 
                                                        error:&error];
    }
    
    // 建立使用者所要的 SaveFileTools
    for ( NSString *unit in tempArray ) {
        id unitSaveFileTools = [[NSClassFromString(unit) alloc] initWithIdentifier:[NSString stringWithFormat:@"%@%@" , K_SAVE_FILE_PATH_PREFIX , unit] 
                                                                          withPath:allPath];
        [classArray addObject:unitSaveFileTools];
    }
    
    if ( [_saveFileToolsDic objectForKey:_fileFolderName] ) {
        // 警告使用此類別的人，多次設定同一個檔案並不安全
        [_saveFileToolsDic setValue:classArray forKey:_fileFolderName];
        NSLog(@"注意！不要多次設定同樣的存檔資料！");
    }
    else{
        [_saveFileToolsDic setObject:classArray forKey:_fileFolderName];
    }
}

-(BOOL)saveWithKey:(nonnull NSString *)tempKey{
    BOOL isOK = NO;
    // 如果有檔案，這裡照樣存，由外面自行控制有檔案的時候該詢問使用者是否要覆蓋，而不是這裡做。
    NSArray *saveFileToolsArray = [_saveFileToolsDic objectForKey:tempKey];
    if ( saveFileToolsArray != nil ) {
        for ( SaveFileTools <SaveFileTools_Policy> *unit in saveFileToolsArray ) {
            if ( [unit save] ) {
                isOK = YES;
            }
            else{
                NSLog(@"存檔失敗: %@" , unit.saveFilePath );
                isOK = NO;
                break;
            }
        }
    }
    return isOK;
}

-(BOOL)loadWithKey:(nonnull NSString *)tempKey{
    BOOL isOK = NO;
    /*
     如果沒有此檔案，直接結束
     有，讀取檔案，存到 _saveFileToolsDic
     */
    NSArray *loadFileToolsArray = [_saveFileToolsDic objectForKey:tempKey];
    if ( loadFileToolsArray != nil ) {
        for ( SaveFileTools <SaveFileTools_Policy> *unit in loadFileToolsArray ) {
            if ( [unit load] ) {
                isOK = YES;
            }
            else{
                NSLog(@"取檔失敗: %@" , unit.saveFilePath);
                isOK = NO;
                break;
            }
        }
    }
    return isOK;
}

#pragma mark - 私有方法
-(NSArray *)saveFileToolsArray{
    return [_saveFileToolsDic allValues];
}

-(NSString *)totalFilePath{
    [self setFilePath:@""];
    return _totalFilePath;
}

@end
