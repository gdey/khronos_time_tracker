#import "cuDateTime.h"
          
@implementation cuDateTime
//Init Methods
- (cuDateTime *)init
{
	self = [super init];
	
	[self setDataWithStrings:@"00/00/0000" time:@"00:00:00"];
	
	return self;
}

- (cuDateTime *)initWithCurrentDateAndTime
{
	self = [super init];
	
	NSCalendarDate *tempCalendarDate = [NSCalendarDate calendarDate];
	
	month = [tempCalendarDate monthOfYear];
	day = [tempCalendarDate dayOfMonth];
	year = [tempCalendarDate yearOfCommonEra];
	
	hour = [tempCalendarDate hourOfDay];
	minute = [tempCalendarDate minuteOfHour];
	second = [tempCalendarDate secondOfMinute];
	
	return self;
}

- (cuDateTime *)initWithStrings:(NSString *)dateString time:(NSString *)timeString
{
	self = [super init];
	
	[self setDataWithStrings:dateString time:timeString];
	
	return self;
}

- (cuDateTime *)initWithStrings:(NSString *)dateString time:(NSString *)timeString timeFormat:(int)timeFormat
{
	self = [super init];
	
	//1 - regular
	//2 - twelve hour
	//3 - regular, no seconds
	//4 - twelve hour, no seconds
	
	NSMutableString *newTimeString = [[[NSMutableString alloc] init] autorelease];
	[newTimeString setString:timeString];
	
	if (timeFormat == 1)
	{
		[self setDataWithStrings:dateString time:timeString];
	}
	if (timeFormat == 2)
	{
		[self setTimeWithTwelveHourString:newTimeString];
		[self setDateWithString:dateString];
	}
	if (timeFormat == 3)
	{
		[newTimeString appendString:@":00"];
		[self setDataWithStrings:dateString time:newTimeString];
	}
	if (timeFormat == 4)
	{
		[newTimeString insertString:@":00" atIndex:[newTimeString length] - 3];
		[self setTimeWithTwelveHourString:newTimeString];
		[self setDateWithString:dateString];
	}
	
	return self;
}

- (cuDateTime *)initWithTimeString:(NSString *)timeString
{
	self = [super init];
	
	[self setTimeWithString:timeString];
	
	return self;
}

- (cuDateTime *)initWithTwelveHourTimeString:(NSString*)timeString
{
	self = [super init];
	
	[self setTimeWithTwelveHourString:timeString];
	
	return self;
}

//Getting Strings
- (NSString *)getDateString
{
	NSMutableString *tempDateString = [[[NSMutableString alloc] init] autorelease];
	
	[tempDateString appendString:[[NSNumber numberWithInt:month] stringValue]];
	[tempDateString appendString:@"/"];
	[tempDateString appendString:[[NSNumber numberWithInt:day] stringValue]];
	[tempDateString appendString:@"/"];
	[tempDateString appendString:[[NSNumber numberWithInt:year] stringValue]];
	
	return tempDateString;
}

- (NSString *)getTimeStringFor:(int)minutes
{
    if( minutes == 1  ) return [self getTimeString:NO];
    if( minutes == 15 ) return [self getFormattedTimeString:@"quarter"];
    if( minutes == 30 ) return [self getFormattedTimeString:@"half"];
    if( minutes == 60 ) return [self getFormattedTimeString:@"hour"];
    return [self getTimeString];
}

- (NSString *)getTimeString
{
	NSMutableString *tempTimeString = [[[NSMutableString alloc] init] autorelease];
	
	[tempTimeString appendString:[[NSNumber numberWithInt:hour] stringValue]];
	[tempTimeString appendString:@":"];
	if (minute < 10)	[tempTimeString appendString:@"0"];
	[tempTimeString appendString:[[NSNumber numberWithInt:minute] stringValue]];
	[tempTimeString appendString:@":"];
	if (second < 10)	[tempTimeString appendString:@"0"];
	[tempTimeString appendString:[[NSNumber numberWithInt:second] stringValue]];
	
	return tempTimeString;
}

- (NSString *)getTimeString:(BOOL)withSeconds
{
	NSMutableString *tempTimeString = [[[NSMutableString alloc] init] autorelease];
	
	[tempTimeString appendString:[[NSNumber numberWithInt:hour] stringValue]];
	[tempTimeString appendString:@":"];
	if (minute < 10)	[tempTimeString appendString:@"0"];
	[tempTimeString appendString:[[NSNumber numberWithInt:minute] stringValue]];
	
	if (withSeconds)
	{
		[tempTimeString appendString:@":"];
		if (second < 10)	[tempTimeString appendString:@"0"];
		[tempTimeString appendString:[[NSNumber numberWithInt:second] stringValue]];
	}
	
	return tempTimeString;
}

- (NSString *)getFormattedTimeString:(NSString *)formatter
{
	NSMutableString *tempTimeString = [[[NSMutableString alloc] init] autorelease];
	
	[tempTimeString appendString:[[NSNumber numberWithInt:hour] stringValue]];
	
	if (![formatter isEqualTo:@"hour"])
	{
		[tempTimeString appendString:@":"];
		
		if ([formatter isEqualTo:@"quarter"])
		{
			if (minute < 15)	[tempTimeString appendString:@"00"];
			else [tempTimeString appendString:[[NSNumber numberWithInt:(minute / 15) * 15] stringValue]];
		}
		else if ([formatter isEqualTo:@"half"])
		{
			if (minute < 30)	[tempTimeString appendString:@"00"];
			else [tempTimeString appendString:[[NSNumber numberWithInt:(minute / 30) * 30] stringValue]];
		}
	}
	else
		[tempTimeString appendString:@"h"];
	
	return tempTimeString;
}

- (NSString *)getTwelveHourTimeString
{
	NSMutableString *tempTimeString = [[[NSMutableString alloc] init] autorelease];
	BOOL isPM = NO;
	
	if (hour > 12)
	{
		[tempTimeString appendString:[[NSNumber numberWithInt:hour - 12] stringValue]];
		isPM = YES;
	}
	else
		[tempTimeString appendString:[[NSNumber numberWithInt:hour] stringValue]];
	
	[tempTimeString appendString:@":"];
	if (minute < 10)	[tempTimeString appendString:@"0"];
	[tempTimeString appendString:[[NSNumber numberWithInt:minute] stringValue]];
	[tempTimeString appendString:@":"];
	if (second < 10)	[tempTimeString appendString:@"0"];
	[tempTimeString appendString:[[NSNumber numberWithInt:second] stringValue]];
	
	if (isPM)
		[tempTimeString appendString:@" pm"];
	else
		[tempTimeString appendString:@" am"];
	
	return tempTimeString;
}

- (NSString *)getTwelveHourTimeString:(BOOL)withSeconds
{
	NSMutableString *tempTimeString = [[[NSMutableString alloc] init] autorelease];
	BOOL isPM = NO;
	
	if (hour > 12)
	{
		[tempTimeString appendString:[[NSNumber numberWithInt:hour - 12] stringValue]];
		isPM = YES;
	}
	else
		[tempTimeString appendString:[[NSNumber numberWithInt:hour] stringValue]];
	
	[tempTimeString appendString:@":"];
	if (minute < 10)	[tempTimeString appendString:@"0"];
	[tempTimeString appendString:[[NSNumber numberWithInt:minute] stringValue]];
	
	if (withSeconds)
	{
		[tempTimeString appendString:@":"];
		if (second < 10)	[tempTimeString appendString:@"0"];
		[tempTimeString appendString:[[NSNumber numberWithInt:second] stringValue]];
	}
	
	if (isPM)
		[tempTimeString appendString:@" pm"];
	else
		[tempTimeString appendString:@" am"];
	
	return tempTimeString; 
}

- (NSString *)getFormattedTwelveHourTimeString:(NSString *)formatter
{
	NSMutableString *tempTimeString = [[[NSMutableString alloc] init] autorelease];
	BOOL isPM = NO;
	
	if (hour > 12)
	{
		[tempTimeString appendString:[[NSNumber numberWithInt:hour - 12] stringValue]];
		isPM = YES;
	}
	else
		[tempTimeString appendString:[[NSNumber numberWithInt:hour] stringValue]];
	
	if (![formatter isEqualTo:@"hour"])
	{
		[tempTimeString appendString:@":"];
		
		if ([formatter isEqualTo:@"quarter"])
		{
			if (minute < 15)	[tempTimeString appendString:@"00"];
			else [tempTimeString appendString:[[NSNumber numberWithInt:(minute / 15) * 15] stringValue]];
		}
		else if ([formatter isEqualTo:@"half"])
		{
			if (minute < 30)	[tempTimeString appendString:@"00"];
			else [tempTimeString appendString:[[NSNumber numberWithInt:(minute / 30) * 30] stringValue]];
		}
	}
	else
		[tempTimeString appendString:@"h"];
	
	if (isPM)
		[tempTimeString appendString:@" pm"];
	else
		[tempTimeString appendString:@" am"];
	
	return tempTimeString; 
}

//Setting Data
- (void)setValues:(cuDateTime *)secondDateTime
{
	year	=   [secondDateTime getYear];
	month   =   [secondDateTime getMonth];
	day		=   [secondDateTime getDay];
	hour	=   [secondDateTime getHour];
	minute  =	[secondDateTime getMinute];
	second  =	[secondDateTime getSecond];
}

- (void)setDataWithInts:(int)theYear month:(int)theMonth day:(int)theDay hour:(int)theHour minute:(int)theMinute second:(int)theSecond
{
	year = theYear;
	month = theMonth;
	day = theDay;
	hour = theHour;
	minute = theMinute;
	second = theSecond;
}
- (void)setDataWithStrings:(NSString *)dateString time:(NSString *)timeString
{
	int i = 0;
	int count = [dateString length];
	int firstDateSeparater = -1;
	int secondDateSeparater = -1;
	
	while (i < count)
	{
		if ([dateString characterAtIndex:i] > 57 || [dateString characterAtIndex:i] < 48)
		{
			if (firstDateSeparater == -1)			firstDateSeparater = i;
			else if (secondDateSeparater == -1)		secondDateSeparater = i;
		}
		
		i++;
	}
	
	month = [[dateString substringToIndex:firstDateSeparater] intValue];
	day = [[dateString substringWithRange:NSMakeRange(firstDateSeparater + 1, secondDateSeparater - firstDateSeparater - 1)] intValue];
	year = [[dateString substringFromIndex:secondDateSeparater + 1] intValue];
	
	int j = 0;
	int timeCount = [timeString length];
	int firstColon = -1;
	int secondColon = -1;
	
	while (j < timeCount)
	{
		if ([timeString characterAtIndex:j] == ':')
		{
			if (firstColon == -1)			firstColon = j;
			else if (secondColon == -1)		secondColon = j;
		}
		
		j++;
	}
	
	hour = [[timeString substringToIndex:firstColon] intValue];
	minute = [[timeString substringWithRange:NSMakeRange(firstColon + 1, secondColon - firstColon - 1)] intValue];
	second = [[timeString substringFromIndex:secondColon + 1] intValue];
}

- (void)setDateWithString:(NSString *)dateString
{
	int i = 0;
	int count = [dateString length];
	int firstDateSeparater = -1;
	int secondDateSeparater = -1;
	
	while (i < count)
	{
		if ([dateString characterAtIndex:i] > 57 || [dateString characterAtIndex:i] < 48)
		{
			if (firstDateSeparater == -1)			firstDateSeparater = i;
			else if (secondDateSeparater == -1)		secondDateSeparater = i;
		}
		
		i++;
	}
	
	month = [[dateString substringToIndex:firstDateSeparater] intValue];
	day = [[dateString substringWithRange:NSMakeRange(firstDateSeparater + 1, secondDateSeparater - firstDateSeparater - 1)] intValue];
	year = [[dateString substringFromIndex:secondDateSeparater + 1] intValue];
}

- (void)setTimeWithString:(NSString *)timeString
{
	int j = 0;
	int timeCount = [timeString length];
	int firstColon = -1;
	int secondColon = -1;
	
	while (j < timeCount)
	{
		if ([timeString characterAtIndex:j] == ':')
		{
			if (firstColon == -1)			firstColon = j;
			else if (secondColon == -1)		secondColon = j;
		}
		
		j++;
	}
	
	hour = [[timeString substringToIndex:firstColon] intValue];
	minute = [[timeString substringWithRange:NSMakeRange(firstColon + 1, secondColon - firstColon - 1)] intValue];
	second = [[timeString substringFromIndex:secondColon + 1] intValue];
}

- (void)setTimeWithTwelveHourString:(NSString *)timeString
{
	int j = 0;
	int timeCount = [timeString length];
	int firstColon = -1;
	int secondColon = -1;
	NSString *amPM;
	
	while (j < timeCount)
	{
		if ([timeString characterAtIndex:j] == ':')
		{
			if (firstColon == -1)			firstColon = j;
			else if (secondColon == -1)		secondColon = j;
		}
		
		j++;
	}
	
	hour = [[timeString substringToIndex:firstColon] intValue];
	minute = [[timeString substringWithRange:NSMakeRange(firstColon + 1, secondColon - firstColon - 1)] intValue];
	second = [[timeString substringWithRange:NSMakeRange(secondColon + 1, 2)] intValue];
	
	amPM = [timeString substringFromIndex:secondColon + 4];
	if ([amPM isEqualTo:@"pm"] || [amPM isEqualTo:@"PM"] || [amPM isEqualTo:@"pM"] || [amPM isEqualTo:@"PM"])   hour += 12;
}

//Getting Data
- (int)getYear
{
	return year;
}

- (int)getMonth
{
	return month;
}

- (int)getDay
{
	return day;
}

- (int)getHour
{
	return hour;
}

- (int)getMinute
{
	return minute;
}

- (int)getSecond
{
	return second;
}

//Math
- (NSComparisonResult)compare:(cuDateTime *)secondTime
{
	if (year > [secondTime getYear])				
		return NSOrderedAscending;
	else if (year >= [secondTime getYear] && month > [secondTime getMonth])
		return NSOrderedAscending;
	else if (year >= [secondTime getYear] && month >= [secondTime getMonth] && day > [secondTime getDay])
		return NSOrderedAscending;
	else if (year >= [secondTime getYear] && month >= [secondTime getMonth] && day >= [secondTime getDay] && hour > [secondTime getHour])
		return NSOrderedAscending;
	else if (year >= [secondTime getYear] && month >= [secondTime getMonth] && day >= [secondTime getDay] && hour >= [secondTime getHour] 
		&& minute > [secondTime getMinute])
		return NSOrderedAscending;
	else if (year >= [secondTime getYear] && month >= [secondTime getMonth] && day >= [secondTime getDay] && hour >= [secondTime getHour] 
		&& minute >= [secondTime getMinute] && second > [secondTime getSecond])
		return NSOrderedAscending;
	else if (year == [secondTime getYear] && month == [secondTime getMonth] && day == [secondTime getDay] && hour == [secondTime getHour] 
		&& minute == [secondTime getMinute] && second == [secondTime getSecond])
		return NSOrderedSame;
	else return NSOrderedDescending;
}

- (void)updateToCurrent
{
	NSCalendarDate *tempCalendarDate = [NSCalendarDate calendarDate];
	
	month = [tempCalendarDate monthOfYear];
	day = [tempCalendarDate dayOfMonth];
	year = [tempCalendarDate yearOfCommonEra];
	
	hour = [tempCalendarDate hourOfDay];
	minute = [tempCalendarDate minuteOfHour];
	second = [tempCalendarDate secondOfMinute];
}

- (cuDateTime *)getTimeInterval:(cuDateTime *)secondTime
{
	cuDateTime *timeInterval = [[[cuDateTime alloc] init] autorelease];

	BOOL selfIsGreater = NO;
	int newYear = year;
	int newMonth = month;
	int newDay = day;
	int newHour = hour;
	int newMinute = minute;
	int newSecond = second;
	
	int dayOfYearSelf = 0;
	int dayOfYearSecond = 0;
	int dayOfYearList[12] = {0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334};  
	
	if (year > [secondTime getYear])
		selfIsGreater = YES;
	if (year >= [secondTime getYear] && month > [secondTime getMonth])
		selfIsGreater = YES;
	if (year >= [secondTime getYear] && month >= [secondTime getMonth] && day > [secondTime getDay])	
		selfIsGreater = YES;
	if (year >= [secondTime getYear] && month >= [secondTime getMonth] && day >= [secondTime getDay] && hour > [secondTime getHour])	
		selfIsGreater = YES;
	if (year >= [secondTime getYear] && month >= [secondTime getMonth] && day >= [secondTime getDay] && 
		hour >= [secondTime getHour] && minute > [secondTime getMinute])	
		selfIsGreater = YES;
	if (year >= [secondTime getYear] && month >= [secondTime getMonth] && day >= [secondTime getDay] && 
		hour >= [secondTime getHour] && minute >= [secondTime getMinute] && second > [secondTime getSecond])	
		selfIsGreater = YES;
		
	dayOfYearSelf = dayOfYearList[newMonth - 1] + newDay;
	if (newYear % 4 == 0 && dayOfYearSelf > 59)	dayOfYearSelf++;
		
	dayOfYearSecond = dayOfYearList[[secondTime getMonth] - 1] + [secondTime getDay];
	if ([secondTime getYear] % 4 == 0 && dayOfYearSecond > 59)	dayOfYearSecond++;	
	
	if (selfIsGreater)
	{	
		newYear -= [secondTime getYear];
		
		dayOfYearSelf += 365 * newYear;
		dayOfYearSelf += (newYear % 4);
		
		dayOfYearSelf -= dayOfYearSecond;
		
		newSecond -= [secondTime getSecond];
		if (newSecond < 0)
		{
			newMinute--;
			newSecond += 60;
		}
		
		newMinute -= [secondTime getMinute];
		if (newMinute < 0)
		{	
			newHour--;
			newMinute += 60;
		}
		
		newHour -= [secondTime getHour];
		if (newHour < 0)
		{
			dayOfYearSelf--;
			newHour += 24;
		}
		
		newHour += dayOfYearSelf * 24;
		
		[timeInterval setDataWithInts:0 month:0 day:0 hour:newHour minute:newMinute second:newSecond];
	}
	else
	{
		int secondSecond = [secondTime getSecond];
		int secondMinute = [secondTime getMinute];
		int secondHour = [secondTime getHour];
	
		newYear = [secondTime getYear] - newYear;
		
		dayOfYearSecond += 365 * newYear;
		dayOfYearSelf += (newYear % 4);
		
		dayOfYearSecond -= dayOfYearSelf;
		
		secondSecond -= newSecond;
		if (secondSecond < 0)
		{
			secondMinute--;
			secondSecond += 60;
		}
		
		secondMinute -= newMinute;
		if (secondMinute < 0)
		{
			secondHour--;
			secondMinute += 60;
		}
		
		secondHour -= newHour;
		if (secondHour < 0)
		{
			dayOfYearSecond--;
			secondHour += 24;
		}
		
		secondHour += 24 * dayOfYearSecond;
		
		[timeInterval setDataWithInts:0 month:0 day:0 hour:secondHour minute:secondMinute second:secondSecond];
	}
	
	return timeInterval;
}

- (cuDateTime *)addInterval:(cuDateTime *)timeToAdd
{
	cuDateTime *newTimeInterval = [[[cuDateTime alloc] init] autorelease];
	
	int newHour = hour;
	int newMinute = minute;
	int newSecond = second;
	
	newHour += [timeToAdd getHour];
	newMinute += [timeToAdd getMinute];
	newSecond += [timeToAdd getSecond];
	
	if (newSecond > 59)
	{
		newMinute++;
		newSecond -= 60;
	}
	if (newMinute > 59)
	{
		newHour++;
		newMinute -= 60;
	}
	
	[newTimeInterval setDataWithInts:0 month:0 day:0 hour:newHour minute:newMinute second:newSecond];
	
	return newTimeInterval;
}

- (cuDateTime *)subtractInterval:(cuDateTime *)timeToSubtract
{
	cuDateTime *newTimeInterval = [[[cuDateTime alloc] init] autorelease];
	
	int newHour = hour;
	int newMinute = minute;
	int newSecond = second;
	
	newHour -= [timeToSubtract getHour];
	newMinute -= [timeToSubtract getMinute];
	newSecond -= [timeToSubtract getSecond];
	
	if (newSecond < 0)
	{
		newMinute--;
		newSecond += 60;
	}
	if (newMinute < 0)
	{
		newHour--;
		newMinute += 60;
	}
	
	[newTimeInterval setDataWithInts:0 month:0 day:0 hour:newHour minute:newMinute second:newSecond];
	
	return newTimeInterval;
}

- (double)calculateCharges:(double)hourlyRate format:(NSString *)formatter
{
	int newHour = hour;
	int newMinute = minute;
	int newSecond = second;
	
	if (![formatter isEqualTo:@"second"])		newSecond = 0;
	if ([formatter isEqualTo:@"quarter"])		newMinute = (newMinute / 15) * 15;
	if ([formatter isEqualTo:@"half"])			newMinute = (newMinute / 30) * 30;
	if ([formatter isEqualTo:@"hour"])			newMinute = 0;
	
	double charge = newHour * hourlyRate;
	charge += newMinute * hourlyRate / 60;
	charge += newSecond * hourlyRate / 3600;
	
	return charge;
}

- (void)addDays:(int)howMany
{
	day += howMany;
}

//Checking Strings for Init Methods
+ (BOOL)checkStringForDate:(NSString *)theString
{
	BOOL testBool = YES;
	
	int i = 0;
	int count = [theString length];
	int firstSeparater = -1;
	int secondSeparater = -1;
	
	while (i < count)
	{
		if ([theString characterAtIndex:i] < 48 || [theString characterAtIndex:i] > 57)
		{
			if (firstSeparater == -1)	firstSeparater = i;
			else if (secondSeparater == -1)	secondSeparater = i;
			else testBool = NO;
		}
			
		i++;
	}
	
	if (firstSeparater != -1 && secondSeparater != -1)
	{
		int proposedMonth = [[theString substringToIndex:firstSeparater] intValue];
		int proposedDay = [[theString substringWithRange:NSMakeRange(firstSeparater + 1, secondSeparater - firstSeparater - 1)] intValue];
		int proposedYear = [[theString substringFromIndex:secondSeparater + 1] intValue];
		int daysInMonth[12] = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
	
		if (proposedMonth > 12)	testBool = NO;
	
		if (proposedDay > daysInMonth[proposedMonth - 1] && proposedMonth != 2)	testBool = NO;
		else if (proposedDay > 28 && proposedYear % 4 != 0 && proposedMonth == 2)	testBool = NO;
		else if (proposedDay > 29 && proposedYear % 4 == 0 && proposedMonth == 2) testBool = NO;
	}
	else	
		testBool = NO;
	
	return testBool;
}

+ (BOOL)checkStringForTime:(NSString *)theString
{
	BOOL testBool = YES;
	
	int i = 0;
	int count = [theString length];
	int firstColon = -1;
	int secondColon = -1;
	
	while (i < count)
	{
		if ([theString characterAtIndex:i] == ':' && firstColon == -1)							firstColon = i;
		else if ([theString characterAtIndex:i] == ':' && secondColon == -1)					secondColon = i;
		else if ([theString characterAtIndex:i] == ':' && secondColon != -1)					testBool = NO;
		else if ([theString characterAtIndex:i] > 57 || [theString characterAtIndex:i] < 48)	testBool = NO;
		
		i++;
	}
	
	if (secondColon - firstColon != 3)			testBool = NO;
	if (firstColon == -1 || secondColon == -1)  testBool = NO;
	
	return testBool;
}

+ (BOOL)checkStringForTwelveHourTime:(NSString *)theString
{
	BOOL testBool = YES;
	
	int i = 0;
	int count = [theString length];
	int firstColon = -1;
	int secondColon = -1;
	
	while (i < count)
	{
		if ([theString characterAtIndex:i] == ':' && firstColon == -1)			firstColon = i;
		else if ([theString characterAtIndex:i] == ':' && secondColon == -1)	secondColon = i;
		else if ([theString characterAtIndex:i] == ':' && secondColon != -1)	testBool = NO;
		else if ([theString characterAtIndex:i] > 57 || [theString characterAtIndex:i] < 48)
		{
			if (i < count - 3)	testBool = NO;
		}
		
		i++;
	}
	
	if (secondColon - firstColon != 3)			testBool = NO;
	if (firstColon == -1 || secondColon == -1)  testBool = NO;
	if (![[theString substringFromIndex:count - 2] isEqualTo:@"am"] && ![[theString substringFromIndex:count - 3] isEqualTo:@"AM"] &&
		![[theString substringFromIndex:count - 2] isEqualTo:@"aM"] && ![[theString substringFromIndex:count - 3] isEqualTo:@"Am"] &&
		![[theString substringFromIndex:count - 2] isEqualTo:@"pm"] && ![[theString substringFromIndex:count - 3] isEqualTo:@"PM"] &&
		![[theString substringFromIndex:count - 2] isEqualTo:@"pM"] && ![[theString substringFromIndex:count - 3] isEqualTo:@"Pm"])
		testBool = NO;
	
	return testBool;
}

+ (BOOL)checkStringForTimeNoSeconds:(NSString *)theString
{
	BOOL testBool = YES;
	
	int i = 0;
	int count = [theString length];
	int firstColon = -1;
	
	while (i < count)
	{
		if ([theString characterAtIndex:i] == ':' && firstColon == -1)							firstColon = i;
		else if ([theString characterAtIndex:i] == ':' && firstColon != -1)						testBool = NO;
		else if ([theString characterAtIndex:i] > 57 || [theString characterAtIndex:i] < 48)	testBool = NO;
		
		i++;
	}
	
	if (count - firstColon != 3)			testBool = NO;
	if (firstColon == -1)  testBool = NO;
	
	return testBool;
}

+ (BOOL)checkStringForTwelveHourTimeNoSeconds:(NSString *)theString
{
	BOOL testBool = YES;
	
	int i = 0;
	int count = [theString length];
	int firstColon = -1;
	
	while (i < count)
	{
		if ([theString characterAtIndex:i] == ':' && firstColon == -1)			firstColon = i;
		else if ([theString characterAtIndex:i] == ':' && firstColon != -1)		testBool = NO;
		else if ([theString characterAtIndex:i] > 57 || [theString characterAtIndex:i] < 48)
		{
			if (i < count - 3)	testBool = NO;
		}
		
		i++;
	}
	
	if (count - 3 - firstColon != 3)	testBool = NO;
	if (firstColon == -1)				testBool = NO;
	if (![[theString substringFromIndex:count - 2] isEqualTo:@"am"] && ![[theString substringFromIndex:count - 3] isEqualTo:@"AM"] &&
		![[theString substringFromIndex:count - 2] isEqualTo:@"aM"] && ![[theString substringFromIndex:count - 3] isEqualTo:@"Am"] &&
		![[theString substringFromIndex:count - 2] isEqualTo:@"pm"] && ![[theString substringFromIndex:count - 3] isEqualTo:@"PM"] &&
		![[theString substringFromIndex:count - 2] isEqualTo:@"pM"] && ![[theString substringFromIndex:count - 3] isEqualTo:@"Pm"])
		testBool = NO;
	
	return testBool;
}
@end