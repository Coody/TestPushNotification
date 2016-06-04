//
//  RemoteNotificationFileTool.h
//  PushMeBaby
//
//  Created by Coody on 2016/6/4.
//
//

#import "SaveFileTools.h"

@interface RemoteNotificationFileTool_Model : NSObject <NSCoding>
/*
 // 預設推播憑證名稱
 #define CER @"development_com.digitalent.Prime"
 // 預設推播憑證讀取的路徑（絕對路徑）
 #define CER_PATH @"/Volumes/HGST_1T/iOS_Share/doc/digi-talent/憑證/推播/development"
 // 預設 Token
 #define TEST_TOKEN @""
 // Target Name
 #define TARGET_NAME @"Prime"
 */
@property (nonatomic , strong) NSString *cer;
@property (nonatomic , strong) NSString *cer_path;
@property (nonatomic , assign) int number;
@end

@interface RemoteNotificationFileTool : SaveFileTools <SaveFileTools_Policy>
/**
 * 存檔的辨識名稱（初始化後不可改）
 */
@property (nonnull , nonatomic , readonly) NSString *fileIdentify; 

/**
 * 存入您要的 Model object
 * warning - 請一定要去實作 NSCoding 的 protocol
 */
@property (nonnull , nonatomic , strong) RemoteNotificationFileTool_Model <NSCoding> *Model;

/**
 * 存檔位置路徑
 */
@property (nonnull , nonatomic , readonly) NSString *saveFilePath;
@end
