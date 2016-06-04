//
//  SaveFileTools.h
//  PushMeBaby
//
//  Created by Coody on 2016/6/3.
//
//

#import <Foundation/Foundation.h>


@protocol SaveFileTools_Policy <NSObject>

//============
@required
/**
 * 存檔的辨識名稱（初始化後不可改）
 * Identify file name (Can not change after initial)
 *
 */
@property (nonnull , nonatomic , readonly) NSString *fileIdentify; 

/**
 * 存入您要的 Model object
 * Your custom model object
 *
 * warning - 請一定要去實作 NSCoding 的 protocol
 * warning - Custom Model must implement NSCoding protocol
 */
@property (nonnull , nonatomic , strong) id <NSCoding> Model;

/**
 * 存檔位置路徑（包含檔案）
 * Save File path (include file name)
 *
 */
@property (nonnull , nonatomic , readonly) NSString *saveFilePath;

/** 
 * 將 Model 轉成 NSData（目前沒用到）
 * 
 */
//-(nonnull NSData *)transformModelToData;

//============
@optional
/** 
 * 收到資料，並且存到 Model 的 property 內
 * Receive Data (NSArray or NSDictionary), and save data to Model.
 *
 */
-(void)receiveJsonData:(nonnull id)tempJsonData;

/**
 * 確認存檔資料是否合法
 * Check data is legal?
 *
 */
-(BOOL)checkData;

@end


@interface SaveFileTools : NSObject < SaveFileTools_Policy >

/**  */
@property (nonnull , nonatomic , readonly) NSString *fileIdentify;
@property (nonnull , nonatomic , strong) id <NSCoding> Model;
@property (nonnull , nonatomic , readonly) NSString *saveFilePath;

/** 
 * 初始化，帶入此存檔系統的辨識碼
 * Initial
 *
 * @param - tempIdentifier：可定義此存檔資料的辨識碼，如果傳空字串，會依照類別名稱產生獨一無二的識別碼。
 *
 * @warning 識別碼一定要獨一無二
 */
-(nonnull instancetype)initWithIdentifier:(nonnull NSString *)tempIdentifier 
                                 withPath:(nonnull NSString *)tempPath;
 
/** 直接從 Json 內取得遊戲資料（除錯用） */
-(void)loadModelWithJsonFilePath:(nonnull NSString *)tempFilePath;

/** 存檔 */
-(BOOL)save;
/** 讀檔 */
-(BOOL)load;

@end
