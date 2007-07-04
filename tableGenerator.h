#import <Foundation/Foundation.h>

@interface tableGenerator : NSObject 
{
}

+ (NSTableColumn *)createJobNumberColumn:(NSString *)headerText;
+ (NSTableColumn *)createJobActiveColumn:(NSString *)headerText;
+ (NSTableColumn *)createJobNameColumn:(NSString *)headerText;
+ (NSTableColumn *)createJobClientColumn:(NSString *)headerText;
+ (NSTableColumn *)createJobHourlyRateColumn:(NSString *)headerText;
+ (NSTableColumn *)createJobTimeLoggedColumn:(NSString *)headerText;
+ (NSTableColumn *)createJobChargesColumn:(NSString *)headerText;

+ (NSTableColumn *)createSessionNumberColumn:(NSString *)headerText;
+ (NSTableColumn *)createSessionActiveColumn:(NSString *)headerText;
+ (NSTableColumn *)createSessionSDateColumn:(NSString *)headerText;
+ (NSTableColumn *)createSessionSTimeColumn:(NSString *)headerText;
+ (NSTableColumn *)createSessionEDateColumn:(NSString *)headerText;
+ (NSTableColumn *)createSessionETimeColumn:(NSString *)headerText;
+ (NSTableColumn *)createSessionPauseTimeColumn:(NSString *)headerText;
+ (NSTableColumn *)createSessionTotalTimeColumn:(NSString *)headerText;
+ (NSTableColumn *)createSessionChargesColumn:(NSString *)headerText;
+ (NSTableColumn *)createSessionSummaryColumn:(NSString *)headerText;
@end
