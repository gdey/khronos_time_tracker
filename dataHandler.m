#import "dataHandler.h"

@implementation dataHandler
+ (NSMutableArray *)createJobListFromFile:(NSString *)dataPath
{
    NSMutableArray *jobData = [[NSMutableArray alloc] init];
    
    NSString *theData = [NSString stringWithContentsOfFile:dataPath];

    int i = 0;
    int lowRange = 0;
    int count = [theData length];
    
    while (i < count)
    {
        if ([theData characterAtIndex:i] == '\n' && [theData characterAtIndex:i - 1] == '\n')
        {
            [jobData addObject:[self createJobFromString:[theData substringWithRange:NSMakeRange(lowRange, i - lowRange)]]];
            lowRange = i + 1;
        }
    
        i++;
    }
    
    return jobData;
}

+ (void)saveJobListToFile:(NSArray *)jobData
{
    NSMutableString *jobDataString = [[[NSMutableString alloc] init] autorelease];
    [jobDataString setString:[self generateSaveString:jobData]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:[@"~/Library/Application Support/Khronos" stringByExpandingTildeInPath]])
        [fileManager createDirectoryAtPath:[@"~/Library/Application Support/Khronos/" stringByExpandingTildeInPath] attributes:nil];
    
    [jobDataString writeToFile:[@"~/Library/Application Support/Khronos/khronosData.khd" stringByExpandingTildeInPath] atomically:NO];
}

+ (void)exportData:(NSArray *)jobData text:(NSString *)textForPanel
{
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    [savePanel setTitle:textForPanel];
    int i = [savePanel runModal];
    if (i == NSOKButton)
    {
        NSMutableString *dataPath = [[[NSMutableString alloc] init] autorelease];
        [dataPath setString:[savePanel filename]];
        NSMutableString *jobDataString = [[[NSMutableString alloc] init] autorelease];
        
        [jobDataString setString:[self generateSaveString:jobData]];
        
        [dataPath appendString:@".khd"];
        [jobDataString writeToFile:dataPath atomically:NO];
    }
}
+ (NSString *)generateSaveString:(NSArray *)jobData
{   
    NSMutableString *jobDataString = [[[NSMutableString alloc] init] autorelease];
    int i = 0;
    int count = [jobData count];
    int j = 0;
    int sessionCount = 0;
    NSString *summary;
    NSMutableArray *sessionList = [[[NSMutableArray alloc] init] autorelease];
    while (i < count)
    {
        [jobDataString appendString:[[[jobData objectAtIndex:i] objectForKey:@"jobNumber"] stringValue]];
        [jobDataString appendString:@"\t"];
        [jobDataString appendString:[[jobData objectAtIndex:i] objectForKey:@"jobName"]];
        [jobDataString appendString:@"\t"];
        [jobDataString appendString:[[jobData objectAtIndex:i] objectForKey:@"clientName"]];
        [jobDataString appendString:@"\t"];
        [jobDataString appendString:[[[jobData objectAtIndex:i] objectForKey:@"hourlyRate"] stringValue]];
        [jobDataString appendString:@"\t"];
        [jobDataString appendString:@"\n"];
        
        sessionCount = [[[jobData objectAtIndex:i] objectForKey:@"sessionList"] count];
        [sessionList setArray:[[jobData objectAtIndex:i] objectForKey:@"sessionList"]];
        while (j < sessionCount)
        {
            [jobDataString appendString:[[[sessionList objectAtIndex:j] objectForKey:@"sessionNumber"] stringValue]];
            [jobDataString appendString:@"\t"];
            [jobDataString appendString:[[[sessionList objectAtIndex:j] objectForKey:@"startDateTime"] getDateString]];
            [jobDataString appendString:@"\t"];
            [jobDataString appendString:[[[sessionList objectAtIndex:j] objectForKey:@"startDateTime"] getTimeString]];
            [jobDataString appendString:@"\t"];
            [jobDataString appendString:[[[sessionList objectAtIndex:j] objectForKey:@"endDateTime"] getDateString]];
            [jobDataString appendString:@"\t"];
            [jobDataString appendString:[[[sessionList objectAtIndex:j] objectForKey:@"endDateTime"] getTimeString]];
            [jobDataString appendString:@"\t"];
            [jobDataString appendString:[[[sessionList objectAtIndex:j] objectForKey:@"pauseTime"] getTimeString]];
            [jobDataString appendString:@"\t"];
            summary = [[sessionList objectAtIndex:j] objectForKey:@"sessionSummary"];
            if ([summary length] == 0) [jobDataString appendString:@" "];
            else [jobDataString appendString:[[sessionList objectAtIndex:j] objectForKey:@"sessionSummary"]];
            [jobDataString appendString:@"\t"];
            [jobDataString appendString:@"\n"];
            
            j++;
        }
        
        [jobDataString appendString:@"\n"];
        
        i++;
        j = 0;
    }
    
    return jobDataString;
}

+ (NSArray *)importData:(NSArray *)jobData text:(NSString *)textForPanel
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setTitle:textForPanel];
    [openPanel setCanChooseDirectories:YES];
    [openPanel setCanChooseFiles:YES];
    
    int i = [openPanel runModal];
    
    if (i == NSOKButton)
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSMutableArray *originalData = [[[NSMutableArray alloc] init] autorelease];
        NSMutableArray *newData = [[[NSMutableArray alloc] init] autorelease];
        [originalData setArray:jobData];
    
        NSString *targetFilePath = [openPanel filename];
        BOOL directoryBool = NO;
        if ([fileManager fileExistsAtPath:targetFilePath isDirectory:&directoryBool] && directoryBool)
        {
            NSArray *targetContents = [fileManager directoryContentsAtPath:targetFilePath];
            BOOL jobDataFound = NO;
            
            int k = 0;
            int fileCount = [targetContents count];
            while (k < fileCount)
            {
                if ([[targetContents objectAtIndex:k] isEqualTo:@"jobData.txt"])    jobDataFound = YES;
                k++;
            }
            
            if (!jobDataFound)  NSRunAlertPanel(@"Arr", @"No usable job data file found in this directory.", @"OK", nil, nil);
            else
            {
                NSMutableString *jobDataPath = [[[NSMutableString alloc] init] autorelease];
                [jobDataPath setString:[targetFilePath stringByAppendingString:@"/jobData.txt"]];
                NSString *jobDataTextString = [NSString stringWithContentsOfFile:jobDataPath];
                
                int l = 0;
                int jobDataStringCount = [jobDataTextString length];
                int jobDataStringLowRange = 0;
                while (l < jobDataStringCount)
                {
                    if ([jobDataTextString characterAtIndex:l] == '\n')
                    {
                        [newData addObject:[dataHandler createJobFrom11String:[jobDataTextString substringWithRange:NSMakeRange(jobDataStringLowRange, l - jobDataStringLowRange)]]];
                        jobDataStringLowRange = l + 1;
                    }
                    l++;
                }
                
                NSMutableString *sessionDataString = [[[NSMutableString alloc] init] autorelease];
                [sessionDataString setString:[targetFilePath stringByAppendingString:@"/"]];
                l = 0;
                int newJobDataCount = [newData count];
                while (l < newJobDataCount)
                {
                    [[newData objectAtIndex:l] setObject:[self createSessionListFrom11Data:
                        [sessionDataString stringByAppendingString:[[newData objectAtIndex:l] objectForKey:@"jobName"]]]
                        forKey:@"sessionList"];
                    l++;
                }
            }
        }
        else if ([fileManager fileExistsAtPath:targetFilePath isDirectory:&directoryBool] && !directoryBool)
        {
            if (![[targetFilePath substringFromIndex:[targetFilePath length] - 4] isEqualTo:@".khd"])
            {
                NSRunAlertPanel(@"Arr", @"Data must be of type khd or a directory.", @"OK", nil, nil);
            }
            else    [newData setArray:[dataHandler createJobListFromFile:targetFilePath]];
        }
        
        int i = 0;
        int testInt = 1;
        int count = [originalData count];
        while (i < count)
        {
            if ([[[originalData objectAtIndex:i] objectForKey:@"jobNumber"] intValue] >= testInt)
                testInt = [[[originalData objectAtIndex:i] objectForKey:@"jobNumber"] intValue] + 1;
            i++;
        }
        
        int j = 0;
        int newCount = [newData count];
        while (j < newCount)
        {
            [[newData objectAtIndex:j] setObject:[NSNumber numberWithInt:testInt] forKey:@"jobNumber"];
            [originalData addObject:[newData objectAtIndex:j]];
            testInt++;
            j++;
        }
        
        return originalData;
    }
    else
    {
        return jobData;
    }
}

+ (NSMutableDictionary *)createJobFromString:(NSString *)jobDataString
{
    NSNumber *jobNumber = [NSNumber numberWithInt:0];
    NSMutableString *nameString = [[[NSMutableString alloc] init] autorelease];
    NSMutableString *clientString = [[[NSMutableString alloc] init] autorelease];
    NSNumber *hourlyRate = [NSNumber numberWithDouble:0];

    int i = 0;
    int count = [jobDataString length];
    int dataCount = 0;
    int lowRange = 0;
    while (i < count && [jobDataString characterAtIndex:i] != '\n')
    {
        if ([jobDataString characterAtIndex:i] == '\t')
        {
            if (dataCount == 0)     jobNumber = [NSNumber numberWithInt:[[jobDataString substringToIndex:i] intValue]];
            if (dataCount == 1)     [nameString setString:[jobDataString substringWithRange:NSMakeRange(lowRange, i - lowRange)]];
            if (dataCount == 2)     [clientString setString:[jobDataString substringWithRange:NSMakeRange(lowRange, i - lowRange)]];
            if (dataCount == 3)     hourlyRate = [NSNumber numberWithDouble:[[jobDataString substringWithRange:NSMakeRange(lowRange, i - lowRange)] doubleValue]];
            
            lowRange = i + 1;
            dataCount++;
        }
        i++;
    }
    
    NSMutableDictionary *tempJob = [[NSMutableDictionary alloc] init];
    [tempJob setObject:jobNumber forKey:@"jobNumber"];
    [tempJob setObject:@"No" forKey:@"jobActive"];
    [tempJob setObject:nameString forKey:@"jobName"];
    [tempJob setObject:clientString forKey:@"clientName"];
    cuDateTime *tempTimeLogged = [[[cuDateTime alloc] initWithTimeString:@"0:00:00"] autorelease];
    [tempJob setObject:tempTimeLogged forKey:@"jobTimeLogged"];
    [tempJob setObject:hourlyRate forKey:@"hourlyRate"];
    [tempJob setObject:[NSNumber numberWithDouble:0] forKey:@"jobCharges"];
    
    NSMutableArray *tempSessionList = [[NSMutableArray alloc] init];
    
    NSString *sessionDataString = [jobDataString substringFromIndex:i + 1];
    int subCount = [sessionDataString length];
    int j = 0;
    int subLowRange = 0;
    while (j < subCount)
    {
        if ([sessionDataString characterAtIndex:j] == '\n')
        {
            [tempSessionList addObject:[dataHandler createSessionFromString:[sessionDataString substringWithRange:NSMakeRange(subLowRange, j - subLowRange + 1)]]];
            subLowRange = j + 1;
        }
        j++;
    }
    [tempJob setObject:tempSessionList forKey:@"sessionList"];

    return tempJob;
}

+ (NSMutableDictionary *)createSessionFromString:(NSString *)sessionDataString
{
    NSMutableDictionary *tempSession = [[[NSMutableDictionary alloc] init] autorelease];
    NSNumber *sessionNumber = [NSNumber numberWithInt:0];
    NSMutableString *sessionSummary = [[[NSMutableString alloc] init] autorelease];
    NSMutableString *startDate = [[[NSMutableString alloc] init] autorelease];
    NSMutableString *startTime = [[[NSMutableString alloc] init] autorelease];
    NSMutableString *endDate = [[[NSMutableString alloc] init] autorelease];
    NSMutableString *endTime = [[[NSMutableString alloc] init] autorelease];
    NSMutableString *pauseString = [[[NSMutableString alloc] init] autorelease];

    
    int i = 0;
    int count = [sessionDataString length];
    int dataCount = 0;
    int lowRange = 0;
    while (i < count)
    {
        if ([sessionDataString characterAtIndex:i] == '\t')
        {
            if (dataCount == 0)     sessionNumber = [NSNumber numberWithInt:[[sessionDataString substringToIndex:i] intValue]];
            if (dataCount == 1)     [startDate setString:[sessionDataString substringWithRange:NSMakeRange(lowRange, i - lowRange)]];
            if (dataCount == 2)     [startTime setString:[sessionDataString substringWithRange:NSMakeRange(lowRange, i - lowRange)]];
            if (dataCount == 3)     [endDate setString:[sessionDataString substringWithRange:NSMakeRange(lowRange, i - lowRange)]];
            if (dataCount == 4)     [endTime setString:[sessionDataString substringWithRange:NSMakeRange(lowRange, i - lowRange)]];
            if (dataCount == 5)     [pauseString setString:[sessionDataString substringWithRange:NSMakeRange(lowRange, i - lowRange)]];
            if (dataCount == 6)     [sessionSummary setString:[sessionDataString substringWithRange:NSMakeRange(lowRange, i - lowRange)]];
            
            lowRange = i + 1;
            dataCount++;
        }
    
        i++;
    }
    
    cuDateTime *startDateTime = [[cuDateTime alloc] initWithStrings:startDate time:startTime];
    cuDateTime *endDateTime = [[cuDateTime alloc] initWithStrings:endDate time:endTime];
    cuDateTime *pauseTime = [[cuDateTime alloc] initWithTimeString:pauseString];
    
    [tempSession setObject:[[cuDateTime alloc] init] forKey:@"tempPauseTime"];
    [tempSession setObject:pauseTime forKey:@"pauseTime"];
    [tempSession setObject:@"No" forKey:@"sessionActive"];
    [tempSession setObject:sessionNumber forKey:@"sessionNumber"];
    [tempSession setObject:sessionSummary forKey:@"sessionSummary"];
    [tempSession setObject:startDateTime forKey:@"startDateTime"];
    [tempSession setObject:endDateTime forKey:@"endDateTime"];
    
    return tempSession;
}

+ (NSMutableDictionary *)createJobFrom11String:(NSString *)dataString
{
    NSMutableDictionary *tempJob = [[NSMutableDictionary alloc] init];
    NSMutableString *jobName = [[NSMutableString alloc] init];
    NSMutableString *clientName = [[NSMutableString alloc] init];
    NSNumber *hourlyRate = [NSNumber numberWithDouble:0];
    NSMutableArray *sessionList = [[NSMutableArray alloc] init];
    
    int i = 0;
    int count = [dataString length];
    int dataCount = 0;
    int lowRange = 0;
    while (i < count)
    {
        if ([dataString characterAtIndex:i] == ';')
        {
            if (dataCount == 1)     [jobName setString:[dataString substringWithRange:NSMakeRange(lowRange, i - lowRange)]];
            if (dataCount == 2)     [clientName setString:[dataString substringWithRange:NSMakeRange(lowRange, i - lowRange)]];
            if (dataCount == 3)     hourlyRate = [NSNumber numberWithDouble:[[dataString substringWithRange:NSMakeRange(lowRange, i - lowRange)] doubleValue]];
            
            dataCount++;
            lowRange = i + 1;
        }
        i++;
    }
    
    [tempJob setObject:jobName forKey:@"jobName"];
    [tempJob setObject:clientName forKey:@"clientName"];
    [tempJob setObject:hourlyRate forKey:@"hourlyRate"];
    [tempJob setObject:@"No" forKey:@"jobActive"];
    cuDateTime *tempTimeLogged = [[cuDateTime alloc] initWithTimeString:@"0:00:00"];
    [tempJob setObject:tempTimeLogged forKey:@"jobTimeLogged"];
    [tempJob setObject:[NSNumber numberWithDouble:0] forKey:@"jobCharges"];
    
    [tempJob setObject:sessionList forKey:@"sessionList"];
    
    return tempJob;
}

+ (NSMutableArray *)createSessionListFrom11Data:(NSString *)dataPath
{
    NSMutableArray *tempSessionList = [[NSMutableArray alloc] init];

    NSString *sessionData = [NSString stringWithContentsOfFile:[dataPath stringByAppendingString:@".txt"]];
    int i = 0;
    int count = [sessionData length];
    int lowRange = 0;
    while (i < count)
    {
        if ([sessionData characterAtIndex:i] == '\n')
        {
            [tempSessionList addObject:[dataHandler createSessionFrom11String:[sessionData substringWithRange:NSMakeRange(lowRange, i - lowRange)]]];
            lowRange = i + 1;
        }
        i++;
    }
    return tempSessionList;
}

+ (NSMutableDictionary *)createSessionFrom11String:(NSString *)sessionDataString
{
    NSMutableDictionary *tempSession = [[NSMutableDictionary alloc] init];
    NSNumber *sessionNumber = [NSNumber numberWithInt:0];
    NSMutableString *sessionSummary = [[NSMutableString alloc] init];
    NSMutableString *startDate = [[NSMutableString alloc] init];
    NSMutableString *startTime = [[NSMutableString alloc] init];
    NSMutableString *endTime = [[NSMutableString alloc] init];
    
    int i = 0;
    int count = [sessionDataString length];
    int dataCount = 0;
    int lowRange = 0;
    while (i < count)
    {
        if ([sessionDataString characterAtIndex:i] == ';')
        {
            if (dataCount == 0)     sessionNumber = [NSNumber numberWithInt:[[sessionDataString substringToIndex:i] intValue]];
            if (dataCount == 1)     [startDate setString:[sessionDataString substringWithRange:NSMakeRange(lowRange, i - lowRange)]];
            if (dataCount == 2)     [startTime setString:[sessionDataString substringWithRange:NSMakeRange(lowRange, i - lowRange)]];
            if (dataCount == 3)     [endTime setString:[sessionDataString substringWithRange:NSMakeRange(lowRange, i - lowRange)]];
            if (dataCount == 4)     [sessionSummary setString:[sessionDataString substringWithRange:NSMakeRange(lowRange, i - lowRange)]];
            
            lowRange = i + 1;
            dataCount++;
        }
    
        i++;
    }

    cuDateTime *startDateTime = [[cuDateTime alloc] initWithStrings:startDate time:startTime];
    cuDateTime *endDateTime = [[cuDateTime alloc] initWithStrings:startDate time:endTime];
    
    if ([[[cuDateTime alloc] initWithStrings:startDate time:startTime] compare:[[cuDateTime alloc] initWithStrings:startDate time:endTime]] != NSOrderedDescending)
        [endDateTime addDays:1];
    
    
    cuDateTime *pauseTime = [[cuDateTime alloc] init];
    
    [tempSession setObject:[[cuDateTime alloc] init] forKey:@"tempPauseTime"];
    [tempSession setObject:pauseTime forKey:@"pauseTime"];
    [tempSession setObject:@"No" forKey:@"sessionActive"];
    [tempSession setObject:sessionNumber forKey:@"sessionNumber"];
    [tempSession setObject:sessionSummary forKey:@"sessionSummary"];
    [tempSession setObject:startDateTime forKey:@"startDateTime"];
    [tempSession setObject:endDateTime forKey:@"endDateTime"];
    
    return tempSession;
}   
@end