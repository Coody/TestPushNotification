//
//  SaveFileToolsManager.h
//  PushMeBaby
//
//  Created by Coody on 2016/6/3.
//
//

#import <Foundation/Foundation.h>

@protocol SaveFileTools_Policy;

/**  */
extern NSString *const K_SAVE_FILE_PATH_PREFIX;
/**  */
extern NSString *const K_SAVE_FILE_FOLDER_NAME;


@interface SaveFileToolsManager : NSObject

/**  */
@property (nonnull , nonatomic , readonly) NSArray *saveFileToolsArray;

+(nonnull instancetype)sharedInstance;

/** 
 *
 */
-(void)setFilePath:(nullable NSString *)tempFilePath;

/** 
 *
 */
-(void)setSaveFileToolsWithClassNameArray:(nullable NSArray<NSString *> *)tempArray 
                                  withKey:(nonnull NSString *)tempKey;

/** 
 *
 */
-(BOOL)saveWithKey:(nonnull NSString *)tempKey;

/** 
 *
 */
-(BOOL)loadWithKey:(nonnull NSString *)tempKey;

@end
