//cuDateTime.h begins here

#import <Cocoa/Cocoa.h>

@interface cuDateTime : NSObject
{
	int year;
	int month;
	int day;
	int hour;
	int minute;
	int second;
}

//Init Methods
- (cuDateTime *)init;
- (cuDateTime *)initWithCurrentDateAndTime;
- (cuDateTime *)initWithStrings:(NSString *)dateString time:(NSString *)timeString;
- (cuDateTime *)initWithStrings:(NSString *)dateString time:(NSString *)timeString timeFormat:(int)timeFormat;
- (cuDateTime *)initWithTimeString:(NSString *)timeString;
- (cuDateTime *)initWithTwelveHourTimeString:(NSString*)timeString;

//Getting Strings
- (NSString *)getDateString;
- (NSString *)getTimeStringFor:(int)minutes;
- (NSString *)getTimeString;
- (NSString *)getTimeString:(BOOL)withSeconds;
- (NSString *)getFormattedTimeString:(NSString *)formatter;
- (NSString *)getTwelveHourTimeString;
- (NSString *)getTwelveHourTimeString:(BOOL)withSeconds;
- (NSString *)getFormattedTwelveHourTimeString:(NSString *)formatter;

//Getting Data
- (int)getYear;
- (int)getMonth;
- (int)getDay;
- (int)getHour;
- (int)getMinute;
- (int)getSecond;

//Setting Data
- (void)setValues:(cuDateTime *)secondDateTime;
- (void)setDataWithInts:(int)theYear month:(int)theMonth day:(int)theDay hour:(int)theHour minute:(int)theMinute second:(int)theSecond;
- (void)setDataWithStrings:(NSString *)dateString time:(NSString *)timeString;
- (void)setDateWithString:(NSString *)dateString;
- (void)setTimeWithString:(NSString *)timeString;
- (void)setTimeWithTwelveHourString:(NSString *)timeString;

//Math
- (NSComparisonResult)compare:(cuDateTime *)secondTime;
- (void)updateToCurrent;
- (cuDateTime *)getTimeInterval:(cuDateTime *)secondTime;
- (cuDateTime *)addInterval:(cuDateTime *)timeToAdd;
- (cuDateTime *)subtractInterval:(cuDateTime *)timeToSubtract;
- (double)calculateCharges:(double)hourlyRate format:(NSString *)formatter;
- (void)addDays:(int)howMany;

//Checking Strings for Init Methods
+ (BOOL)checkStringForDate:(NSString *)theString;
+ (BOOL)checkStringForTime:(NSString *)theString;
+ (BOOL)checkStringForTwelveHourTime:(NSString *)theString;
+ (BOOL)checkStringForTimeNoSeconds:(NSString *)theString;
+ (BOOL)checkStringForTwelveHourTimeNoSeconds:(NSString *)theString;
@end