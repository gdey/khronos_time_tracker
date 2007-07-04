#import <Foundation/Foundation.h>
#import "cuDateTime.h"


@interface dataHandler : NSObject 
{
}

+ (NSMutableArray *)createJobListFromFile:(NSString *)dataPath;
+ (void)saveJobListToFile:(NSArray *)jobData;
+ (void)exportData:(NSArray *)jobData text:(NSString *)textForPanel;
+ (NSString *)generateSaveString:(NSArray *)jobData;
+ (NSArray *)importData:(NSArray *)jobData text:(NSString *)textForPanel;

+ (NSMutableDictionary *)createJobFromString:(NSString *)jobDataString;
+ (NSMutableDictionary *)createSessionFromString:(NSString *)sessionDataString;
+ (NSMutableDictionary *)createJobFrom11String:(NSString *)dataString;
+ (NSMutableArray *)createSessionListFrom11Data:(NSString *)dataPath;
+ (NSMutableDictionary *)createSessionFrom11String:(NSString *)sessionDataString;
@end
