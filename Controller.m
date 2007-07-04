#import "Controller.h"

@implementation Controller
//***Main Methods***
- (void)awakeFromNib
{
    firstLaunch = NO;
    
    [self loadPrefsFromFile];
    
    if (floor(NSAppKitVersionNumber) <= NSAppKitVersionNumber10_2)
    {
        [prefsMenuDisplayList setState:NO];
        [prefsMenuDisplayList setEnabled:NO];
        [prefsMenuAlertField setStringValue:[textMenuDisable stringValue]];
    }
    
    [mainWindow setFrameOrigin:NSMakePoint(windowY, windowX)];
    [mainWindow setContentSize:NSMakeSize(windowWidth, windowHeight)];
    
    [addSessionButton setEnabled:NO];
    [deleteSessionButton setEnabled:NO];
    [editSessionButton setEnabled:NO];
    [deleteJobButton setEnabled:NO];
    [editJobButton setEnabled:NO];
    
    if (firstLaunch)    [mainWindow center];
    
    [prefsWindow center];
    
    jobData             =   [[NSMutableArray alloc] init];
    tableActive         =   [NSImage imageNamed:@"jobActive"];
    tableInactive       =   [NSImage imageNamed:@"jobInactive"];
    tablePaused         =   [NSImage imageNamed:@"jobPause"];
    
    pauseYes            =   [NSImage imageNamed:@"stst_pause"];
    pauseNo             =   [NSImage imageNamed:@"stst_pause2"];
    startStopGray       =   [NSImage imageNamed:@"stst_null"];
    startStopGreen      =   [NSImage imageNamed:@"stst_start"];
    startStopRed        =   [NSImage imageNamed:@"stst_stop"];
    
    menuStartStopGray   =   [NSImage imageNamed:@"stst_nullMB"];
    menuStartStopRed    =   [NSImage imageNamed:@"stst_stopMB"];
    menuStartStopGreen  =   [NSImage imageNamed:@"stst_startMB"];
    menuPauseYes        =   [NSImage imageNamed:@"stst_playMB"];
    menuPauseNo         =   [NSImage imageNamed:@"stst_pause2MB"];
    menuPauseNull       =   [NSImage imageNamed:@"stst_nullPauseMB"];
    menuJobListIcon     =   [NSImage imageNamed:@"MBjobSelector3"];
    menuJobListAltIcon  =   [NSImage imageNamed:@"MBjobSelector3Alt"];
    
    updateTimer = [[NSTimer scheduledTimerWithTimeInterval:(1.0) target:self selector:@selector(updateLoop) userInfo:nil repeats:YES] retain];
    [[NSRunLoop currentRunLoop] addTimer:updateTimer forMode:NSEventTrackingRunLoopMode];
    [[NSRunLoop currentRunLoop] addTimer:updateTimer forMode:NSModalPanelRunLoopMode];
    saveTimer = 0;
    autoDeleteTime = 0;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    
    if ([fileManager fileExistsAtPath:[@"~/Library/Application Support/Khronos/khronosData.khd" stringByExpandingTildeInPath]])
        [jobData setArray:[dataHandler createJobListFromFile:[@"~/Library/Application Support/Khronos/khronosData.khd" stringByExpandingTildeInPath]]];
    else if ([fileManager fileExistsAtPath:@"/Library/Application Support/KhronosHelp/khronosData.khd"])
        [jobData setArray:[dataHandler createJobListFromFile:@"/Library/Application Support/KhronosHelp/khronosData.khd"]];
    //else
        //[jobData setArray:[dataHandler createJobListFromFile:@"nil"]];
    
    /*if (firstLaunch)
    {
        if ([fileManager fileExistsAtPath:@"/Library/Application Support/KhronosHelp/khronosData.khd"] &&
            ![fileManager fileExistsAtPath:[@"~/Library/Application Support/Khronos/khronosData.khd" stringByExpandingTildeInPath]])    
            [jobData setArray:[dataHandler createJobListFromFile:@"/Library/Application Support/KhronosHelp/khronosData.khd"]];
        else if ([fileManager fileExistsAtPath:[@"~/Library/Application Support/Khronos/khronosData.khd" stringByExpandingTildeInPath]])
            [jobData setArray:[dataHandler createJobListFromFile:[@"~/Library/Application Support/Khronos/khronosData.khd" stringByExpandingTildeInPath]]];
        else    [jobData setArray:[dataHandler createJobListFromFile:[@"~/Library/Application Support/Khronos/khronosData.khd" stringByExpandingTildeInPath]]];
    }
    else if ([fileManager fileExistsAtPath:[@"~/Library/Application Support/Khronos/khronosData.khd" stringByExpandingTildeInPath]])
    {
        [jobData setArray:[dataHandler createJobListFromFile:[@"~/Library/Application Support/Khronos/khronosData.khd" stringByExpandingTildeInPath]]];
    }
    else    [jobData setArray:[dataHandler createJobListFromFile:[@"~/Library/Application Support/Khronos/khronosData.khd" stringByExpandingTildeInPath]]];*/
    
    int i = 0;
    int count = [jobData count];
    while (i < count)
    {
        [self computeJobTime:i];
        i++;
    }
    
    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_2)
    {
        lastJobSorter = [[NSSortDescriptor alloc] initWithKey:@"jobNumber" ascending:YES];
        lastSessionSorter = [[NSSortDescriptor alloc] initWithKey:@"sessionNumber" ascending:YES];
        lastJobSortAscending = YES;
        lastSessionSortAscending = YES;
    }
    
    printInfo = [NSPrintInfo sharedPrintInfo];
    
    [self buildStatusItem];
    [self updateMenuBarJobList];
    [self buildJobTable];
    [self buildSessionTable];
    
    [jobTable setTarget:self];
    [jobTable setDoubleAction:@selector(tableDoubleClick:)];
    [sessionTable setTarget:self];
    [sessionTable setDoubleAction:@selector(tableDoubleClick:)];
    
    [startStopField setStringValue:@""];
    [mainWindow makeKeyAndOrderFront:nil];
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
    [self saveLoop];
}

- (void)createNewJob:(NSString *)name client:(NSString *)client rate:(double)rate
{
    NSMutableDictionary *tempJob = [[NSMutableDictionary alloc] init];
    [tempJob setObject:[NSNumber numberWithInt:[self getHighestJobNumber]] forKey:@"jobNumber"];
    [tempJob setObject:@"No" forKey:@"jobActive"];
    [tempJob setObject:name forKey:@"jobName"];
    [tempJob setObject:client forKey:@"clientName"];
    cuDateTime *tempTimeLogged = [[cuDateTime alloc] initWithTimeString:@"0:00:00"];
    [tempJob setObject:tempTimeLogged forKey:@"jobTimeLogged"];
    [tempJob setObject:[NSNumber numberWithDouble:rate] forKey:@"hourlyRate"];
    [tempJob setObject:[NSNumber numberWithDouble:0] forKey:@"jobCharges"];
    NSMutableArray *tempSessionList = [[NSMutableArray alloc] init];
    [tempJob setObject:tempSessionList forKey:@"sessionList"];
    
    [jobData addObject:tempJob];
}

- (void)createNewSession:(cuDateTime *)startDateTime endDateTime:(cuDateTime *)endDateTime job:(int)whichJob active:(BOOL)active
{
    NSMutableDictionary *tempSession = [[NSMutableDictionary alloc] init];
    [tempSession setObject:[NSNumber numberWithInt:[self getHighestSessionNumber:whichJob]] forKey:@"sessionNumber"];
    if (active)     [tempSession setObject:@"Yes" forKey:@"sessionActive"];
    else            [tempSession setObject:@"No" forKey:@"sessionActive"];
    [tempSession setObject:startDateTime forKey:@"startDateTime"];
    [tempSession setObject:endDateTime forKey:@"endDateTime"];
    cuDateTime *pauseTime = [[cuDateTime alloc] init];
    [tempSession setObject:pauseTime forKey:@"pauseTime"];
    [tempSession setObject:pauseTime forKey:@"tempPauseTime"];
    [[[jobData objectAtIndex:whichJob] objectForKey:@"sessionList"] addObject:tempSession];
    [self computeJobTime:whichJob];
}

- (void)computeJobTime:(int)job
{
    cuDateTime *newTime = [[[cuDateTime alloc] init] autorelease];
    id sessionList = [[jobData objectAtIndex:job] objectForKey:@"sessionList"];
    
    cuDateTime *mathTime = [[cuDateTime alloc] init];
    cuDateTime *mathTimeTwo = [[cuDateTime alloc] init];
    cuDateTime *mathTimeThree = [[cuDateTime alloc] init];
    
    int i = 0;
    int count = [sessionList count];
    while (i < count)
    {
        [mathTime setValues:[[[[jobData objectAtIndex:job] objectForKey:@"sessionList"] objectAtIndex:i] objectForKey:@"endDateTime"]];
        [mathTimeTwo setValues:[[[[jobData objectAtIndex:job] objectForKey:@"sessionList"] objectAtIndex:i] objectForKey:@"startDateTime"]];
        [mathTimeThree setValues:[[[[jobData objectAtIndex:job] objectForKey:@"sessionList"] objectAtIndex:i] objectForKey:@"pauseTime"]];
        
        [newTime setValues:[newTime addInterval:[mathTimeTwo getTimeInterval:mathTime]]];
        [newTime setValues:[newTime subtractInterval:mathTimeThree]];
    
        i++;
    }
    
    [[jobData objectAtIndex:job] setObject:newTime forKey:@"jobTimeLogged"];
    
    [mathTime release];
    [mathTimeTwo release];
    [mathTimeThree release];
}

- (void)loadPrefsFromFile
{
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *prefPath = [bundle pathForResource:@"prefs" ofType:@"txt"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:prefPath]){
    NSString *prefsData = [NSString stringWithContentsOfFile:prefPath];
    
    int i = 0;
    int count = [prefsData length];
    int dataCount = 0;
    int lowCount = 0;
    while (i < count)
    {
        if ([prefsData characterAtIndex:i] == '\n')
        {
            if (dataCount == 0)
                windowX = [[prefsData substringToIndex:i] intValue];
            if (dataCount == 1)
                windowY = [[prefsData substringWithRange:NSMakeRange(lowCount + 1, i - lowCount - 1)] intValue];
            if (dataCount == 2)
                windowWidth = [[prefsData substringWithRange:NSMakeRange(lowCount + 1, i - lowCount - 1)] intValue];
            if (dataCount == 3)
                windowHeight = [[prefsData substringWithRange:NSMakeRange(lowCount + 1, i - lowCount - 1)] intValue];
            if (dataCount == 4)
                [prefs2412Radio setState:YES atRow:[[prefsData substringWithRange:NSMakeRange(lowCount + 1, i - lowCount - 1)] intValue] column:0];
            if (dataCount == 5 && [[prefsData substringWithRange:NSMakeRange(lowCount + 1, i - lowCount - 1)] isEqualTo:@"Yes"])
                [prefsAskDeleteJob setState:YES];
            if (dataCount == 6 && [[prefsData substringWithRange:NSMakeRange(lowCount + 1, i - lowCount - 1)] isEqualTo:@"Yes"])
                [prefsAskDeleteSession setState:YES];
            if (dataCount == 7)
            {
                saveTimer = [[prefsData substringWithRange:NSMakeRange(lowCount + 1, i - lowCount - 1)] intValue] * 60;
                [prefsAutoSaveTime setStringValue:[prefsData substringWithRange:NSMakeRange(lowCount + 1, i - lowCount - 1)]];
            }
            if (dataCount == 8)
            {
                autoDeleteTime = [[prefsData substringWithRange:NSMakeRange(lowCount + 1, i - lowCount - 1)] intValue];
                [prefsAutoDeleteSetting setStringValue:[prefsData substringWithRange:NSMakeRange(lowCount + 1, i - lowCount - 1)]];
            }
            if (dataCount == 9)
            {
                [prefsMonetaryUnit setStringValue:[prefsData substringWithRange:NSMakeRange(lowCount + 1, i - lowCount - 1)]];
            }
            if (dataCount == 10)
                [prefsUpdateEveryRadio setState:YES atRow:[[prefsData substringWithRange:NSMakeRange(lowCount + 1, i - lowCount - 1)] intValue] column:0];
            
            if (dataCount == 12 && [[prefsData substringWithRange:NSMakeRange(lowCount + 1, i - lowCount - 1)] isEqualTo:@"Yes"])
                [prefsJobDisplayNumber setState:YES];
            if (dataCount == 13 && [[prefsData substringWithRange:NSMakeRange(lowCount + 1, i - lowCount - 1)] isEqualTo:@"Yes"])
                [prefsJobDisplayName setState:YES];
            if (dataCount == 14 && [[prefsData substringWithRange:NSMakeRange(lowCount + 1, i - lowCount - 1)] isEqualTo:@"Yes"])
                [prefsJobDisplayClient setState:YES];
            if (dataCount == 15 && [[prefsData substringWithRange:NSMakeRange(lowCount + 1, i - lowCount - 1)] isEqualTo:@"Yes"])
                [prefsJobDisplayRate setState:YES];
            if (dataCount == 16 && [[prefsData substringWithRange:NSMakeRange(lowCount + 1, i - lowCount - 1)] isEqualTo:@"Yes"])
                [prefsJobDisplayTime setState:YES];
            if (dataCount == 17 && [[prefsData substringWithRange:NSMakeRange(lowCount + 1, i - lowCount - 1)] isEqualTo:@"Yes"])
                [prefsJobDisplayCharges setState:YES];
                
            if (dataCount == 19 && [[prefsData substringWithRange:NSMakeRange(lowCount + 1, i - lowCount - 1)] isEqualTo:@"Yes"])
                [prefsSessionDisplayNumber setState:YES];
            if (dataCount == 20 && [[prefsData substringWithRange:NSMakeRange(lowCount + 1, i - lowCount - 1)] isEqualTo:@"Yes"])
                [prefsSessionDisplaySDate setState:YES];
            if (dataCount == 21 && [[prefsData substringWithRange:NSMakeRange(lowCount + 1, i - lowCount - 1)] isEqualTo:@"Yes"])
                [prefsSessionDisplaySTime setState:YES];
            if (dataCount == 22 && [[prefsData substringWithRange:NSMakeRange(lowCount + 1, i - lowCount - 1)] isEqualTo:@"Yes"])
                [prefsSessionDisplayEDate setState:YES];
            if (dataCount == 23 && [[prefsData substringWithRange:NSMakeRange(lowCount + 1, i - lowCount - 1)] isEqualTo:@"Yes"])
                [prefsSessionDisplayETime setState:YES];
            if (dataCount == 24 && [[prefsData substringWithRange:NSMakeRange(lowCount + 1, i - lowCount - 1)] isEqualTo:@"Yes"])
                [prefsSessionDisplayPause setState:YES];
            if (dataCount == 25 && [[prefsData substringWithRange:NSMakeRange(lowCount + 1, i - lowCount - 1)] isEqualTo:@"Yes"])
                [prefsSessionDisplayTotalTime setState:YES];
            if (dataCount == 26 && [[prefsData substringWithRange:NSMakeRange(lowCount + 1, i - lowCount - 1)] isEqualTo:@"Yes"])
                [prefsSessionDisplayCharges setState:YES];
            if (dataCount == 27 && [[prefsData substringWithRange:NSMakeRange(lowCount + 1, i - lowCount - 1)] isEqualTo:@"Yes"])
                [prefsSessionDisplaySummary setState:YES];
            
            if (dataCount == 29 && [[prefsData substringWithRange:NSMakeRange(lowCount + 1, i - lowCount - 1)] isEqualTo:@"Yes"])
                [prefsMenuPauseButton setState:YES];
            if (dataCount == 30 && [[prefsData substringWithRange:NSMakeRange(lowCount + 1, i - lowCount - 1)] isEqualTo:@"Yes"])
                [prefsMenuDisplayButton setState:YES];
            if (dataCount == 31 && [[prefsData substringWithRange:NSMakeRange(lowCount + 1, i - lowCount - 1)] isEqualTo:@"Yes"])
                [prefsMenuDisplayList setState:YES];
            if (dataCount == 32 && [[prefsData substringWithRange:NSMakeRange(lowCount + 1, i - lowCount - 1)] isEqualTo:@"Yes"])
                [prefsMenuDisplayTime setState:YES];
            if (dataCount == 33 && [[prefsData substringWithRange:NSMakeRange(lowCount + 1, i - lowCount - 1)] isEqualTo:@"Yes"])
                [prefsMenuDisplayCharges setState:YES];
            
            if (dataCount == 35) [prefsInvoiceIndex setStringValue:[prefsData substringWithRange:NSMakeRange(lowCount + 1, i - lowCount - 1)]];
            if (dataCount == 36) [prefsInvoiceIndexHeader setStringValue:[prefsData substringWithRange:NSMakeRange(lowCount + 1, i - lowCount - 1)]];
            if (dataCount == 37) [prefsInvoiceIndexLink setStringValue:[prefsData substringWithRange:NSMakeRange(lowCount + 1, i - lowCount - 1)]];
            if (dataCount == 38) [prefsInvoiceTitle setStringValue:[prefsData substringWithRange:NSMakeRange(lowCount + 1, i - lowCount - 1)]];
            if (dataCount == 39) [prefsInvoiceHeader setStringValue:[prefsData substringWithRange:NSMakeRange(lowCount + 1, i - lowCount - 1)]];
            if (dataCount == 40) [prefsInvoiceBodyFont selectItemAtIndex:[[prefsData substringWithRange:NSMakeRange(lowCount + 1, i - lowCount - 1)] intValue]];
            if (dataCount == 41) [prefsInvoiceHeaderFont selectItemAtIndex:[[prefsData substringWithRange:NSMakeRange(lowCount + 1, i - lowCount - 1)] intValue]];
            if (dataCount == 42) [prefsInvoiceSize setIntValue:[[prefsData substringWithRange:NSMakeRange(lowCount + 1, i - lowCount - 1)] intValue]];
            
            if (dataCount == 44 && [[prefsData substringWithRange:NSMakeRange(lowCount + 1, i - lowCount - 1)] isEqualTo:@"Yes"])
                firstLaunch = YES;
                
            dataCount++;
            lowCount = i;
        }
        i++;
    }}
    else
    {
        windowX = 100;
        windowY = 100;
        windowWidth = 545;
        windowHeight = 240;
        [prefs2412Radio setState:YES atRow:0 column:0];
        [prefsAskDeleteJob setState:YES];
        [prefsAskDeleteSession setState:YES];
        saveTimer = 5;
        [prefsAutoSaveTime setStringValue:@"5"];
        autoDeleteTime = 0;
        [prefsAutoDeleteSetting setStringValue:@"0"];
        [prefsMonetaryUnit setStringValue:@"$"];
        [prefsUpdateEveryRadio setState:YES atRow:0 column:0];
        [prefsJobDisplayNumber setState:YES];
        [prefsJobDisplayName setState:YES];
        [prefsJobDisplayClient setState:YES];
        [prefsJobDisplayRate setState:YES];
        [prefsJobDisplayTime setState:YES];
        [prefsJobDisplayCharges setState:YES];
        [prefsSessionDisplayNumber setState:YES];
        [prefsSessionDisplaySDate setState:YES];
        [prefsSessionDisplaySTime setState:YES];
        [prefsSessionDisplayEDate setState:NO];
        [prefsSessionDisplayETime setState:YES];
        [prefsSessionDisplayPause setState:NO];
        [prefsSessionDisplayTotalTime setState:YES];
        [prefsSessionDisplayCharges setState:NO];
        [prefsSessionDisplaySummary setState:YES];
        [prefsMenuPauseButton setState:YES];
        [prefsMenuDisplayButton setState:YES];
        [prefsMenuDisplayList setState:YES];
        [prefsMenuDisplayTime setState:YES];
        [prefsMenuDisplayCharges setState:YES];
        firstLaunch = YES;
    }
}

- (void)buildJobTable
{   
    NSArray *jobTableColumns = [jobTable tableColumns];
    int i = [jobTableColumns count];
    
    while (i > 0)
    {
        [jobTable removeTableColumn:[jobTableColumns objectAtIndex:i - 1]];
        i--;
    }
    
    //Add Columns
                                            [jobTable addTableColumn:[tableGenerator createJobActiveColumn:[textJobActive stringValue]]];
    if ([prefsJobDisplayNumber state])      [jobTable addTableColumn:[tableGenerator createJobNumberColumn:[textJobNumber stringValue]]];
    if ([prefsJobDisplayName state])        [jobTable addTableColumn:[tableGenerator createJobNameColumn:[textJobName stringValue]]];
    if ([prefsJobDisplayClient state])      [jobTable addTableColumn:[tableGenerator createJobClientColumn:[textClientName stringValue]]];
    if ([prefsJobDisplayRate state])        [jobTable addTableColumn:[tableGenerator createJobHourlyRateColumn:[textRate stringValue]]];
    if ([prefsJobDisplayTime state])        [jobTable addTableColumn:[tableGenerator createJobTimeLoggedColumn:[textTimeLogged stringValue]]];
    if ([prefsJobDisplayCharges state])     [jobTable addTableColumn:[tableGenerator createJobChargesColumn:[textCharges stringValue]]];

    [jobTable reloadData];
}

- (void)buildSessionTable
{
    NSArray *sessionTableColumns = [sessionTable tableColumns];
    int i = [sessionTableColumns count];
    
    while (i > 0)
    {
        [sessionTable removeTableColumn:[sessionTableColumns objectAtIndex:i - 1]];
        i--;
    }
    
    //Add Columns
                                                [sessionTable addTableColumn:[tableGenerator createSessionActiveColumn:[textSessionActive stringValue]]];
    if ([prefsSessionDisplayNumber state])      [sessionTable addTableColumn:[tableGenerator createSessionNumberColumn:[textSessionNumber stringValue]]];
    if ([prefsSessionDisplaySDate state])       [sessionTable addTableColumn:[tableGenerator createSessionSDateColumn:[textSessionDate stringValue]]];
    if ([prefsSessionDisplaySTime state])       [sessionTable addTableColumn:[tableGenerator createSessionSTimeColumn:[textSessionStart stringValue]]];
    if ([prefsSessionDisplayEDate state])       [sessionTable addTableColumn:[tableGenerator createSessionEDateColumn:[textSessionEndDate stringValue]]];
    if ([prefsSessionDisplayETime state])       [sessionTable addTableColumn:[tableGenerator createSessionETimeColumn:[textSessionEnd stringValue]]];
    if ([prefsSessionDisplayPause state])       [sessionTable addTableColumn:[tableGenerator createSessionPauseTimeColumn:[textPauses stringValue]]];
    if ([prefsSessionDisplayTotalTime state])   [sessionTable addTableColumn:[tableGenerator createSessionTotalTimeColumn:[textSessionTime stringValue]]];
    if ([prefsSessionDisplayCharges state])     [sessionTable addTableColumn:[tableGenerator createSessionChargesColumn:[textSessionCharges stringValue]]];
    if ([prefsSessionDisplaySummary state])     [sessionTable addTableColumn:[tableGenerator createSessionSummaryColumn:[textSessionSummary stringValue]]];

    [sessionTable reloadData];
}

- (void)buildPrintTable
{
    NSArray *tableColumns = [printTable tableColumns];
    int i = [tableColumns count];
    
    while (i > 0)
    {
        [printTable removeTableColumn:[tableColumns objectAtIndex:i - 1]];
        i--;
    }
    
    if ([prefsSessionDisplayNumber state])      [printTable addTableColumn:[tableGenerator createSessionNumberColumn:[textSessionNumber stringValue]]];
    if ([prefsSessionDisplaySDate state])       [printTable addTableColumn:[tableGenerator createSessionSDateColumn:[textSessionDate stringValue]]];
    if ([prefsSessionDisplaySTime state])       [printTable addTableColumn:[tableGenerator createSessionSTimeColumn:[textSessionStart stringValue]]];
    if ([prefsSessionDisplayEDate state])       [printTable addTableColumn:[tableGenerator createSessionEDateColumn:[textSessionEndDate stringValue]]];
    if ([prefsSessionDisplayETime state])       [printTable addTableColumn:[tableGenerator createSessionETimeColumn:[textSessionEnd stringValue]]];
    if ([prefsSessionDisplayPause state])       [printTable addTableColumn:[tableGenerator createSessionPauseTimeColumn:[textPauses stringValue]]];
    if ([prefsSessionDisplayTotalTime state])   [printTable addTableColumn:[tableGenerator createSessionTotalTimeColumn:[textSessionTime stringValue]]];
    if ([prefsSessionDisplayCharges state])     [printTable addTableColumn:[tableGenerator createSessionChargesColumn:[textSessionCharges stringValue]]];
    if ([prefsSessionDisplaySummary state])     [printTable addTableColumn:[tableGenerator createSessionSummaryColumn:[textSessionSummary stringValue]]];

    [printTable reloadData];
}

- (void)updatePrintWindowFields
{
    [printJobName setStringValue:[[jobData objectAtIndex:[jobTable selectedRow]] objectForKey:@"jobName"]];
    [printClientName setStringValue:[[jobData objectAtIndex:[jobTable selectedRow]] objectForKey:@"clientName"]];
    
    NSMutableString *hourlyRateFormatted = [[NSMutableString alloc] init];
    [hourlyRateFormatted appendString:[prefsMonetaryUnit stringValue]];
    [hourlyRateFormatted appendString:[[[jobData objectAtIndex:[jobTable selectedRow]] objectForKey:@"hourlyRate"] stringValue]];
    [printHourlyRate setStringValue:hourlyRateFormatted];
    
    
    cuDateTime *tempTimeLogged = [[cuDateTime alloc] init];
    [tempTimeLogged setValues:[[jobData objectAtIndex:[jobTable selectedRow]] objectForKey:@"jobTimeLogged"]];
        
    if ([prefsUpdateEveryRadio selectedRow] == 0)   [printTotalTimeLogged setStringValue:[tempTimeLogged getTimeString]];
    if ([prefsUpdateEveryRadio selectedRow] == 1)   [printTotalTimeLogged setStringValue:[tempTimeLogged getTimeString:NO]];
    if ([prefsUpdateEveryRadio selectedRow] == 2)   [printTotalTimeLogged setStringValue:[tempTimeLogged getFormattedTimeString:@"quarter"]];
    if ([prefsUpdateEveryRadio selectedRow] == 3)   [printTotalTimeLogged setStringValue:[tempTimeLogged getFormattedTimeString:@"half"]];
    if ([prefsUpdateEveryRadio selectedRow] == 4)   [printTotalTimeLogged setStringValue:[tempTimeLogged getFormattedTimeString:@"hour"]];
    
    NSNumber *rate = [[jobData objectAtIndex:[jobTable selectedRow]] objectForKey:@"hourlyRate"];
                
    NSString *formatterString = @"second";
    if ([prefsUpdateEveryRadio selectedRow] == 1)   formatterString = @"minute";
    if ([prefsUpdateEveryRadio selectedRow] == 2)   formatterString = @"quarter";
    if ([prefsUpdateEveryRadio selectedRow] == 3)   formatterString = @"half";
    if ([prefsUpdateEveryRadio selectedRow] == 4)   formatterString = @"hour";
                
    NSMutableString *chargeNumberString = [[NSMutableString alloc] init];
    [chargeNumberString setString:[[NSNumber numberWithDouble:[tempTimeLogged calculateCharges:[rate doubleValue]
        format:formatterString]] stringValue]];
                
    [chargeNumberString setString:[self truncateChargeString:chargeNumberString]];
                
    NSMutableString *tempChargesString = [[NSMutableString alloc] init];
    [tempChargesString appendString:[prefsMonetaryUnit stringValue]];
    [tempChargesString appendString:chargeNumberString];
                
    [printTotalCharges setStringValue:tempChargesString];
    
    [printWindow setContentSize:NSMakeSize(482, 235)];
    
    int i = 0;
    int count = [[[jobData objectAtIndex:[jobTable selectedRow]] objectForKey:@"sessionList"] count];
    while (i < count)
    {
        [printWindow setContentSize:NSMakeSize(482, i * 19 + 235)];
        i++;
    }
}

- (void)buildStatusItem
{
    [[NSStatusBar systemStatusBar] removeStatusItem:menuPauseButton];
    [[NSStatusBar systemStatusBar] removeStatusItem:menuStartStopButton];
    [[NSStatusBar systemStatusBar] removeStatusItem:jobPullDownMenu];
    [[NSStatusBar systemStatusBar] removeStatusItem:menuChargeDisplay];
    [[NSStatusBar systemStatusBar] removeStatusItem:menuTimeDisplay];
    
    if ([prefsMenuDisplayButton state])
    {
        menuStartStopButton = [[[NSStatusBar systemStatusBar] statusItemWithLength:25] retain];
        [menuStartStopButton setHighlightMode:NO];
        [menuStartStopButton setImage:menuStartStopGray];
        [menuStartStopButton setTarget:self];
        [menuStartStopButton setAction:@selector(startStopRecording:)];
        [menuStartStopButton setEnabled:YES];
    }
    
    if ([prefsMenuPauseButton state])
    {
        menuPauseButton = [[[NSStatusBar systemStatusBar] statusItemWithLength:25] retain];
        [menuPauseButton setHighlightMode:NO];
        [menuPauseButton setImage:menuPauseNull];
        [menuPauseButton setTarget:self];
        [menuPauseButton setAction:@selector(pauseUnpause:)];
        [menuPauseButton setEnabled:YES];
    }
    
    if ([prefsMenuDisplayList state] && floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_2)
    {
        jobPullDownMenu = [[[NSStatusBar systemStatusBar] statusItemWithLength:25] retain];
        [jobPullDownMenu setHighlightMode:YES];
        [jobPullDownMenu setImage:menuJobListIcon];
        [jobPullDownMenu setAlternateImage:menuJobListAltIcon];
        [jobPullDownMenu setMenu:menuJobList];
        [jobPullDownMenu setEnabled:YES];
    }
    
    if ([prefsMenuDisplayTime state])
    {
        menuTimeDisplay = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
        [menuTimeDisplay setHighlightMode:NO];
        [menuTimeDisplay setTitle:@""]; 
        [menuTimeDisplay setEnabled:YES];
    }
    
    if ([prefsMenuDisplayCharges state])
    {
        menuChargeDisplay = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
        [menuChargeDisplay setHighlightMode:NO];
        [menuChargeDisplay setTitle:@""]; 
        [menuChargeDisplay setEnabled:YES];
    }
}

- (void)updateLoop
{
    saveTimer++;
    if (saveTimer > [prefsAutoSaveTime intValue] * 60)      [self saveLoop];
    
    int i = 0;
    int count = [jobData count];
    int j = 0;
    int sessionCount = 0;
    
    while (i < count)
    {
        if ([[[jobData objectAtIndex:i] objectForKey:@"jobActive"] isEqualTo:@"Yes"])
        {
            sessionCount = [[[jobData objectAtIndex:i] objectForKey:@"sessionList"] count];
            while (j < sessionCount)
            {
                if ([[[[[jobData objectAtIndex:i] objectForKey:@"sessionList"] objectAtIndex:j] objectForKey:@"sessionActive"] isEqualTo:@"Yes"])
                {
                    [[[[jobData objectAtIndex:i] objectForKey:@"sessionList"] objectAtIndex:j] 
                        setObject:[[[cuDateTime alloc] initWithCurrentDateAndTime] autorelease] forKey:@"endDateTime"];
                }
                
                j++;
            }
            
            [self computeJobTime:i];
            [jobTable reloadData];
            [sessionTable reloadData];
        }
        if ([[[jobData objectAtIndex:i] objectForKey:@"jobActive"] isEqualTo:@"Paused"])
        {
            sessionCount = [[[jobData objectAtIndex:i] objectForKey:@"sessionList"] count];
            while (j < sessionCount)
            {
                if ([[[[[jobData objectAtIndex:i] objectForKey:@"sessionList"] objectAtIndex:j] objectForKey:@"sessionActive"] isEqualTo:@"Paused"])
                {
                    [[[[jobData objectAtIndex:i] objectForKey:@"sessionList"] objectAtIndex:j] 
                        setObject:[[[cuDateTime alloc] initWithCurrentDateAndTime] autorelease] forKey:@"pauseStop"];
                
                    cuDateTime *tempStartTime = [[cuDateTime alloc] init];
                    [tempStartTime setValues:[[[[jobData objectAtIndex:i] objectForKey:@"sessionList"] objectAtIndex:j] 
                        objectForKey:@"pauseStart"]];
                    cuDateTime *tempEndTime = [[cuDateTime alloc] init];
                    [tempEndTime setValues:[[[[jobData objectAtIndex:i] objectForKey:@"sessionList"] objectAtIndex:j] 
                        objectForKey:@"pauseStop"]];
                    
                    [[[[jobData objectAtIndex:i] objectForKey:@"sessionList"] objectAtIndex:j] 
                        setObject:[tempStartTime getTimeInterval:tempEndTime] forKey:@"tempPauseTime"];
                        
                    [tempStartTime release];
                    [tempEndTime release];
                }
                
                j++;
            }
            
            [self computeJobTime:i];
            [jobTable reloadData];
            [sessionTable reloadData];
        }
        
        j = 0;
        i++;
    }
    
    [self updateMenuBarData];
}

- (void)updateMenuBarData
{   
    if ([jobTable selectedRow] != -1)
    {
        id tempMenuTime = [[jobData objectAtIndex:[jobTable selectedRow]] objectForKey:@"jobTimeLogged"];
        
        if ([prefsMenuDisplayTime state])
        {
            if ([prefsUpdateEveryRadio selectedRow] == 0)   [menuTimeDisplay setTitle:[tempMenuTime getTimeString]];
            if ([prefsUpdateEveryRadio selectedRow] == 1)   [menuTimeDisplay setTitle:[tempMenuTime getTimeString:NO]];
            if ([prefsUpdateEveryRadio selectedRow] == 2)   [menuTimeDisplay setTitle:[tempMenuTime getFormattedTimeString:@"quarter"]];
            if ([prefsUpdateEveryRadio selectedRow] == 3)   [menuTimeDisplay setTitle:[tempMenuTime getFormattedTimeString:@"half"]];
            if ([prefsUpdateEveryRadio selectedRow] == 4)   [menuTimeDisplay setTitle:[tempMenuTime getFormattedTimeString:@"hour"]];
        }
        if ([prefsMenuDisplayCharges state])
        {
            NSNumber *rate = [[jobData objectAtIndex:[jobTable selectedRow]] objectForKey:@"hourlyRate"];
                
            NSString *formatterString = @"second";
            if ([prefsUpdateEveryRadio selectedRow] == 1)   formatterString = @"minute";
            if ([prefsUpdateEveryRadio selectedRow] == 2)   formatterString = @"quarter";
            if ([prefsUpdateEveryRadio selectedRow] == 3)   formatterString = @"half";
            if ([prefsUpdateEveryRadio selectedRow] == 4)   formatterString = @"hour";
            
            NSMutableString *chargeNumberString = [[[NSMutableString alloc] init] autorelease];
            [chargeNumberString setString:[[NSNumber numberWithDouble:[tempMenuTime calculateCharges:[rate doubleValue]
                format:formatterString]] stringValue]];
            
            [chargeNumberString setString:[self truncateChargeString:chargeNumberString]];
            
            NSMutableString *tempChargesString = [[[NSMutableString alloc] init] autorelease];
            [tempChargesString appendString:[prefsMonetaryUnit stringValue]];
            [tempChargesString appendString:chargeNumberString];

            [menuChargeDisplay setTitle:tempChargesString];
        }
        
        int i = [menuJobList numberOfItems] - 1;
        while (i >= 0)
        {
            [[menuJobList itemAtIndex:i] setState:NSOffState];
            i--;
        }
            
        [[menuJobList itemAtIndex:[jobTable selectedRow]] setState:NSOnState];
    }
    else
    {
        [menuTimeDisplay setTitle:@""];
        [menuChargeDisplay setTitle:@""];
        
        int i = [menuJobList numberOfItems] - 1;
        while (i >= 0)
        {
            [[menuJobList itemAtIndex:i] setState:NSOffState];
            i--;
        }
    }
}

- (void)updateMenuBarJobList
{
    int i = [menuJobList numberOfItems] - 1;
    while (i >= 0)
    {
        [menuJobList removeItemAtIndex:i];
        i--;
    }
    
    int j = [jobData count] - 1;
    while (j >= 0)
    {
        [self addJobToMenuList:[[jobData objectAtIndex:j] objectForKey:@"jobName"]];
        j--;
    }
}

- (void)updateMenuBarButtons
{
    if ([jobTable selectedRow] == -1)
    {
        [menuStartStopButton setImage:menuStartStopGray];
        [menuPauseButton setImage:menuPauseNull];
    }
    else
    {
        if ([[[jobData objectAtIndex:[jobTable selectedRow]] objectForKey:@"jobActive"] isEqualTo:@"Yes"])
        {
            [menuStartStopButton setImage:menuStartStopRed];
            [menuPauseButton setImage:menuPauseNo];
        }
        else if ([[[jobData objectAtIndex:[jobTable selectedRow]] objectForKey:@"jobActive"] isEqualTo:@"No"])
        {
            [menuStartStopButton setImage:menuStartStopGreen];
            [menuPauseButton setImage:menuPauseNull];
        }
        else if ([[[jobData objectAtIndex:[jobTable selectedRow]] objectForKey:@"jobActive"] isEqualTo:@"Paused"])
        {
            [menuStartStopButton setImage:menuStartStopRed];
            [menuPauseButton setImage:menuPauseYes];
        }
    }
}

- (void)addJobToMenuList:(NSString *)jobName
{
    NSMenuItem *tempMenuItem = [[NSMenuItem alloc] initWithTitle:jobName action:@selector(jobMenuListSelectionChanged:) keyEquivalent:@""];
    [tempMenuItem setTarget:self];
    
    [menuJobList insertItem:tempMenuItem atIndex:0];
}

- (void)jobMenuListSelectionChanged:(id)sender
{
    if ([sender state] == NSOffState)   
    {
        [sender setState:NSOnState];
        [jobTable selectRowIndexes:[NSIndexSet indexSetWithIndex:[menuJobList indexOfItem:sender]] byExtendingSelection:YES];
    }
}

- (void)saveLoop
{
    saveTimer = 0;
    
    [dataHandler saveJobListToFile:jobData];
    [self savePrefs];
}

- (void)savePrefs
{
    NSMutableString *prefsData = [[[NSMutableString alloc] init] autorelease];
    
    [prefsData appendString:[[NSNumber numberWithInt:[mainWindow frame].origin.y] stringValue]];
    [prefsData appendString:@"\n"];
    [prefsData appendString:[[NSNumber numberWithInt:[mainWindow frame].origin.x] stringValue]];
    [prefsData appendString:@"\n"];
    [prefsData appendString:[[NSNumber numberWithInt:[mainWindow frame].size.width] stringValue]];
    [prefsData appendString:@"\n"];
    [prefsData appendString:[[NSNumber numberWithInt:[mainWindow frame].size.height - 22] stringValue]];
    [prefsData appendString:@"\n"];
    [prefsData appendString:[[NSNumber numberWithInt:[prefs2412Radio selectedRow]] stringValue]];
    [prefsData appendString:@"\n"];
    if ([prefsAskDeleteJob state])          [prefsData appendString:@"Yes\n"];
    else                                    [prefsData appendString:@"No\n"];
    if ([prefsAskDeleteSession state])      [prefsData appendString:@"Yes\n"];
    else                                    [prefsData appendString:@"No\n"];
    [prefsData appendString:[prefsAutoSaveTime stringValue]];
    [prefsData appendString:@"\n"];
    [prefsData appendString:[prefsAutoDeleteSetting stringValue]];
    [prefsData appendString:@"\n"];
    [prefsData appendString:[prefsMonetaryUnit stringValue]];
    [prefsData appendString:@"\n"];
    [prefsData appendString:[[NSNumber numberWithInt:[prefsUpdateEveryRadio selectedRow]] stringValue]];
    [prefsData appendString:@"\n\n"];
    if ([prefsJobDisplayNumber state])      [prefsData appendString:@"Yes\n"];
    else                                    [prefsData appendString:@"No\n"];
    if ([prefsJobDisplayName state])        [prefsData appendString:@"Yes\n"];
    else                                    [prefsData appendString:@"No\n"];
    if ([prefsJobDisplayClient state])      [prefsData appendString:@"Yes\n"];
    else                                    [prefsData appendString:@"No\n"];
    if ([prefsJobDisplayRate state])        [prefsData appendString:@"Yes\n"];
    else                                    [prefsData appendString:@"No\n"];
    if ([prefsJobDisplayTime state])        [prefsData appendString:@"Yes\n"];
    else                                    [prefsData appendString:@"No\n"];
    if ([prefsJobDisplayCharges state])     [prefsData appendString:@"Yes\n\n"];
    else                                    [prefsData appendString:@"No\n\n"];
    if ([prefsSessionDisplayNumber state])  [prefsData appendString:@"Yes\n"];
    else                                    [prefsData appendString:@"No\n"];
    if ([prefsSessionDisplaySDate state])   [prefsData appendString:@"Yes\n"];
    else                                    [prefsData appendString:@"No\n"];
    if ([prefsSessionDisplaySTime state])   [prefsData appendString:@"Yes\n"];
    else                                    [prefsData appendString:@"No\n"];
    if ([prefsSessionDisplayEDate state])   [prefsData appendString:@"Yes\n"];
    else                                    [prefsData appendString:@"No\n"];
    if ([prefsSessionDisplayETime state])   [prefsData appendString:@"Yes\n"];
    else                                    [prefsData appendString:@"No\n"];
    if ([prefsSessionDisplayPause state])   [prefsData appendString:@"Yes\n"];
    else                                    [prefsData appendString:@"No\n"];
    if ([prefsSessionDisplayTotalTime state])[prefsData appendString:@"Yes\n"];
    else                                    [prefsData appendString:@"No\n"];
    if ([prefsSessionDisplayCharges state]) [prefsData appendString:@"Yes\n"];
    else                                    [prefsData appendString:@"No\n"];
    if ([prefsSessionDisplaySummary state]) [prefsData appendString:@"Yes\n\n"];
    else                                    [prefsData appendString:@"No\n\n"];
    if ([prefsMenuPauseButton state])       [prefsData appendString:@"Yes\n"];
    else                                    [prefsData appendString:@"No\n"];
    if ([prefsMenuDisplayButton state])     [prefsData appendString:@"Yes\n"];
    else                                    [prefsData appendString:@"No\n"];
    if ([prefsMenuDisplayList state])       [prefsData appendString:@"Yes\n"];
    else                                    [prefsData appendString:@"No\n"];
    if ([prefsMenuDisplayTime state])       [prefsData appendString:@"Yes\n"];
    else                                    [prefsData appendString:@"No\n"];
    if ([prefsMenuDisplayCharges state])    [prefsData appendString:@"Yes\n"];
    else                                    [prefsData appendString:@"No\n"];
    
    [prefsData appendString:@"\n"];
    [prefsData appendString:[prefsInvoiceIndex stringValue]];
    [prefsData appendString:@"\n"];
    [prefsData appendString:[prefsInvoiceIndexHeader stringValue]];
    [prefsData appendString:@"\n"];
    [prefsData appendString:[prefsInvoiceIndexLink stringValue]];
    [prefsData appendString:@"\n"];
    [prefsData appendString:[prefsInvoiceTitle stringValue]];
    [prefsData appendString:@"\n"];
    [prefsData appendString:[prefsInvoiceHeader stringValue]];
    [prefsData appendString:@"\n"];
    [prefsData appendString:[[NSNumber numberWithInt:[prefsInvoiceBodyFont indexOfSelectedItem]] stringValue]];
    [prefsData appendString:@"\n"];
    [prefsData appendString:[[NSNumber numberWithInt:[prefsInvoiceHeaderFont indexOfSelectedItem]] stringValue]];
    [prefsData appendString:@"\n"];
    [prefsData appendString:[[NSNumber numberWithInt:[prefsInvoiceSize intValue]] stringValue]];
    [prefsData appendString:@"\n"];
    
    NSBundle *bundle = [NSBundle mainBundle];
    NSMutableString *dataPath = [[[NSMutableString alloc] init] autorelease];
    [dataPath setString:[bundle pathForResource:@"minus" ofType:@"gif"]];
    [dataPath deleteCharactersInRange:NSMakeRange([dataPath length] - 9, 9)];
    [dataPath appendString:@"prefs.txt"];
    [prefsData writeToFile:dataPath atomically:NO];
}

- (int)getHighestJobNumber
{
    if ([jobData count] == 0)   return 1;
    else
    {
        int testInt = 2;
        
        int i = 0;
        int count = [jobData count];
        while (i < count)
        {
            if ([[[jobData objectAtIndex:i] objectForKey:@"jobNumber"] intValue] >= testInt)        
                testInt = [[[jobData objectAtIndex:i] objectForKey:@"jobNumber"] intValue] + 1;
            
            i++;
        }
        return testInt;
    }
}

- (int)getHighestSessionNumber:(int)whichJob
{
    id sessionList = [[jobData objectAtIndex:whichJob] objectForKey:@"sessionList"];
    if ([sessionList count] == 0)   return 1;
    else
    {
        int testInt = 2;
        
        int i = 0;
        int count = [sessionList count];
        while (i < count)
        {
            if ([[[sessionList objectAtIndex:i] objectForKey:@"sessionNumber"] intValue] >= testInt)        
                testInt = [[[sessionList objectAtIndex:i] objectForKey:@"sessionNumber"] intValue] + 1;
            
            i++;
        }
        return testInt;
    }
}

- (NSString *)truncateChargeString:(NSString *)originalString
{
    NSMutableString *tempString = [[[NSMutableString alloc] init] autorelease];
    [tempString setString:originalString];
    
    int i = 0;
    int count = [tempString length];
    int periodLocation = -1;
    while (i < count)
    {
        if ([tempString characterAtIndex:i] == '.')     periodLocation = i;
        i++;
    }
    
    if (periodLocation == 0)                                    [tempString insertString:@"0" atIndex:0];
    if (count - periodLocation > 2 && periodLocation != -1)     [tempString deleteCharactersInRange:NSMakeRange(periodLocation + 3, count - periodLocation - 3)];
    if (count - periodLocation == 2 && periodLocation != -1)    [tempString appendString:@"0"];
    return tempString;
}

//***TableView Methods***
- (int)numberOfRowsInTableView:(NSTableView *)tableView
{
    if (tableView == jobTable)
        return [jobData count];
    else if ([jobTable selectedRow] != -1)
        return [[[jobData objectAtIndex:[jobTable selectedRow]] objectForKey:@"sessionList"] count];
    else
        return 0;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)rowIndex
{
    id theRow;
    id theValue = nil;
    
    if (tableView == jobTable)
    {
        theRow = [jobData objectAtIndex:rowIndex];
        
        if ([[tableColumn identifier] isEqualTo:@"jobActive"])
        {
            if ([[theRow objectForKey:@"jobActive"] isEqualTo:@"No"])           theValue = tableInactive;
            else if ([[theRow objectForKey:@"jobActive"] isEqualTo:@"Yes"])     theValue = tableActive;
            else if ([[theRow objectForKey:@"jobActive"] isEqualTo:@"Paused"])  theValue = tablePaused;
        }
        else if ([[tableColumn identifier] isEqualTo:@"hourlyRate"])
        {
            NSMutableString *hourlyRateString = [[[NSMutableString alloc] init] autorelease];
            [hourlyRateString appendString:[prefsMonetaryUnit stringValue]];
            [hourlyRateString appendString:[[[jobData objectAtIndex:rowIndex] objectForKey:@"hourlyRate"] stringValue]];
            [hourlyRateString appendString:[textHourSuffix stringValue]];
            theValue = hourlyRateString;
        }
        else if ([[tableColumn identifier] isEqualTo:@"jobTimeLogged"] || [[tableColumn identifier] isEqualTo:@"jobCharges"])
        {
            cuDateTime *tempTimeLogged = [[[cuDateTime alloc] init] autorelease];
            [tempTimeLogged setValues:[[jobData objectAtIndex:rowIndex] objectForKey:@"jobTimeLogged"]];
        
            if ([[tableColumn identifier] isEqualTo:@"jobTimeLogged"])
            {
                if ([prefsUpdateEveryRadio selectedRow] == 0)   theValue = [tempTimeLogged getTimeString];
                if ([prefsUpdateEveryRadio selectedRow] == 1)   theValue = [tempTimeLogged getTimeString:NO];
                if ([prefsUpdateEveryRadio selectedRow] == 2)   theValue = [tempTimeLogged getFormattedTimeString:@"quarter"];
                if ([prefsUpdateEveryRadio selectedRow] == 3)   theValue = [tempTimeLogged getFormattedTimeString:@"half"];
                if ([prefsUpdateEveryRadio selectedRow] == 4)   theValue = [tempTimeLogged getFormattedTimeString:@"hour"];
            }
            else
            {
                NSNumber *rate = [[jobData objectAtIndex:rowIndex] objectForKey:@"hourlyRate"];
                
                NSString *formatterString = @"second";
                if ([prefsUpdateEveryRadio selectedRow] == 1)   formatterString = @"minute";
                if ([prefsUpdateEveryRadio selectedRow] == 2)   formatterString = @"quarter";
                if ([prefsUpdateEveryRadio selectedRow] == 3)   formatterString = @"half";
                if ([prefsUpdateEveryRadio selectedRow] == 4)   formatterString = @"hour";
                
                NSMutableString *chargeNumberString = [[[NSMutableString alloc] init] autorelease];
                [chargeNumberString setString:[[NSNumber numberWithDouble:[tempTimeLogged calculateCharges:[rate doubleValue]
                    format:formatterString]] stringValue]];
                
                [chargeNumberString setString:[self truncateChargeString:chargeNumberString]];
                
                NSMutableString *tempChargesString = [[[NSMutableString alloc] init] autorelease];
                [tempChargesString appendString:[prefsMonetaryUnit stringValue]];
                [tempChargesString appendString:chargeNumberString];
                
                theValue = tempChargesString;
            }
        }
        else theValue = [theRow objectForKey:[tableColumn identifier]];
    }
    else if ([jobTable selectedRow] != -1)
    {
        if (rowIndex < [[[jobData objectAtIndex:[jobTable selectedRow]] objectForKey:@"sessionList"] count]){
    
        theRow = [[[jobData objectAtIndex:[jobTable selectedRow]] objectForKey:@"sessionList"] objectAtIndex:rowIndex];
        
        if ([[tableColumn identifier] isEqualTo:@"sessionActive"])
        {
            if ([[theRow objectForKey:@"sessionActive"] isEqualTo:@"No"])           theValue = tableInactive;
            else if ([[theRow objectForKey:@"sessionActive"] isEqualTo:@"Yes"])     theValue = tableActive;
            else if ([[theRow objectForKey:@"sessionActive"] isEqualTo:@"Paused"])  theValue = tablePaused;
        } 
        else if ([[tableColumn identifier] isEqualTo:@"startDate"])
        {
            theValue = [[theRow objectForKey:@"startDateTime"] getDateString];
        }
        else if ([[tableColumn identifier] isEqualTo:@"startTime"])
        {
            if ([prefs2412Radio selectedRow] == 0)  theValue = [[theRow objectForKey:@"startDateTime"] getTimeString];
            else                                    theValue = [[theRow objectForKey:@"startDateTime"] getTwelveHourTimeString];
                
        }
        else if ([[tableColumn identifier] isEqualTo:@"endDate"])
        {
            theValue = [[theRow objectForKey:@"endDateTime"] getDateString];
        }
        else if ([[tableColumn identifier] isEqualTo:@"endTime"])
        {
            if ([prefs2412Radio selectedRow] == 0)  theValue = [[theRow objectForKey:@"endDateTime"] getTimeString];
            else                                    theValue = [[theRow objectForKey:@"endDateTime"] getTwelveHourTimeString];
        }
        else if ([[tableColumn identifier] isEqualTo:@"totalTime"] || [[tableColumn identifier] isEqualTo:@"sessionCharges"])
        {
            cuDateTime *tempInterval = [[[cuDateTime alloc] init] autorelease];
            [tempInterval setValues:[[theRow objectForKey:@"startDateTime"] getTimeInterval:[theRow objectForKey:@"endDateTime"]]];
            [tempInterval setValues:[tempInterval subtractInterval:[theRow objectForKey:@"pauseTime"]]];
            
            NSString *formatterString = @"second";
            if ([prefsUpdateEveryRadio selectedRow] == 1)   formatterString = @"minute";
            if ([prefsUpdateEveryRadio selectedRow] == 2)   formatterString = @"quarter";
            if ([prefsUpdateEveryRadio selectedRow] == 3)   formatterString = @"half";
            if ([prefsUpdateEveryRadio selectedRow] == 4)   formatterString = @"hour";
            
            if ([[tableColumn identifier] isEqualTo:@"totalTime"])
            {
                if ([formatterString isEqualTo:@"second"])      theValue = [tempInterval getTimeString];
                else if ([formatterString isEqualTo:@"minute"]) theValue = [tempInterval getTimeString:NO];
                else theValue = [tempInterval getFormattedTimeString:formatterString];
            }
            else if ([[tableColumn identifier] isEqualTo:@"sessionCharges"])
            {
                NSNumber *rate = [[jobData objectAtIndex:[jobTable selectedRow]] objectForKey:@"hourlyRate"];
            
                NSMutableString *chargeNumberString = [[[NSMutableString alloc] init] autorelease];
                [chargeNumberString setString:[[NSNumber numberWithDouble:[tempInterval calculateCharges:[rate doubleValue]
                    format:formatterString]] stringValue]];
                
                [chargeNumberString setString:[self truncateChargeString:chargeNumberString]];
                
                NSMutableString *tempChargesString = [[[NSMutableString alloc] init] autorelease];
                [tempChargesString appendString:[prefsMonetaryUnit stringValue]];
                [tempChargesString appendString:chargeNumberString];
            
                theValue = tempChargesString;
            }
        }
        else if ([[tableColumn identifier] isEqualTo:@"pauseTime"])
        {
            cuDateTime *tempPauseTime = [[[cuDateTime alloc] init] autorelease];
            [tempPauseTime setValues:[theRow objectForKey:@"pauseTime"]];
            [tempPauseTime setValues:[tempPauseTime addInterval:[theRow objectForKey:@"tempPauseTime"]]];
            
            theValue = [tempPauseTime getTimeString];
        }
        else    theValue = [theRow objectForKey:[tableColumn identifier]];
    }}
    
    return theValue;
}

- (void)tableView:(NSTableView *)tableView mouseDownInHeaderOfTableColumn:(NSTableColumn *)tableColumn
{
    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_2)
    {
        if (tableView == jobTable)
        {
            NSSortDescriptor *newSorter = [[NSSortDescriptor alloc] initWithKey:[tableColumn identifier] ascending:lastJobSortAscending];
            NSMutableArray *sortDescriptors = [[NSMutableArray alloc] init];
            [sortDescriptors addObject:newSorter];
            [sortDescriptors addObject:lastJobSorter];
        
            [jobData setArray:[jobData sortedArrayUsingDescriptors:sortDescriptors]];
        
            lastJobSortAscending = !lastJobSortAscending;
            if (![[lastJobSorter key] isEqualTo:[tableColumn identifier]])
                lastJobSorter = [[NSSortDescriptor alloc] initWithKey:[tableColumn identifier] ascending:lastJobSortAscending];
        
            [jobTable reloadData];
            [sessionTable reloadData];
        
            [self updateMenuBarJobList];
        }
        if (tableView == sessionTable && [jobTable selectedRow] != -1)
        {
            NSSortDescriptor *newSorter = [[NSSortDescriptor alloc] initWithKey:[tableColumn identifier] ascending:lastJobSortAscending];
            NSMutableArray *sortDescriptors = [[NSMutableArray alloc] init];
            [sortDescriptors addObject:newSorter];
            [sortDescriptors addObject:lastSessionSorter];
        
            [[[jobData objectAtIndex:[jobTable selectedRow]] objectForKey:@"sessionList"] setArray:[[[jobData objectAtIndex:[jobTable selectedRow]] 
                objectForKey:@"sessionList"] sortedArrayUsingDescriptors:sortDescriptors]];
        
            lastSessionSortAscending = !lastSessionSortAscending;
            if (![[lastSessionSorter key] isEqualTo:[tableColumn identifier]])
                lastSessionSorter = [[NSSortDescriptor alloc] initWithKey:[tableColumn identifier] ascending:lastSessionSortAscending];
        
            [jobTable reloadData];
            [sessionTable reloadData];
        }
    }
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    if ([notification object] == jobTable)
    {
        if ([jobTable selectedRow] != -1)
        {
            [addSessionButton setEnabled:YES];   [deleteJobButton setEnabled:YES];  [editJobButton setEnabled:YES];
            
            if ([[[jobData objectAtIndex:[jobTable selectedRow]] objectForKey:@"jobActive"] isEqualTo:@"No"])
            {
                [pauseButton setImage:nil];
                [pauseButton setAlternateImage:nil];
                [startStopButton setImage:startStopGreen];
                [startStopButton setAlternateImage:startStopGreen];
                
                [self updateMenuBarButtons];
                                
                [startStopField setStringValue:[textStartRecording stringValue]];
            }
            else if ([[[jobData objectAtIndex:[jobTable selectedRow]] objectForKey:@"jobActive"] isEqualTo:@"Yes"])
            {
                [pauseButton setImage:pauseNo];
                [pauseButton setAlternateImage:pauseNo];
                [startStopButton setImage:startStopRed];
                [startStopButton setAlternateImage:startStopRed];
                
                [self updateMenuBarButtons];
                
                [startStopField setStringValue:[textStopRecording stringValue]];
            }
            else if ([[[jobData objectAtIndex:[jobTable selectedRow]] objectForKey:@"jobActive"] isEqualTo:@"Paused"])
            {
                [startStopButton setImage:startStopRed];
                [startStopButton setAlternateImage:startStopRed];
                [pauseButton setImage:pauseYes];
                [pauseButton setAlternateImage:pauseYes];
                
                [self updateMenuBarButtons];
                
                [startStopField setStringValue:[textStopRecording stringValue]];
            }
            
            [self updateMenuBarData];
        }
        else
        {
            [addSessionButton setEnabled:NO];  [deleteJobButton setEnabled:NO];   [editJobButton setEnabled:NO];
            [startStopButton setImage:startStopGray];
            [startStopButton setAlternateImage:startStopGray];
            [pauseButton setImage:nil];
            [pauseButton setAlternateImage:nil];
            
            [self updateMenuBarButtons];
            [menuChargeDisplay setTitle:@""];
            [menuTimeDisplay setTitle:@""];
            
            int i = [menuJobList numberOfItems] - 1;
            while (i >= 0)
            {
                [[menuJobList itemAtIndex:i] setState:NSOffState];
                i--;
            }
            
            [startStopField setStringValue:@""];
        }
        
        [sessionTable reloadData];
    }
    else if ([notification object] == sessionTable)
    {
        if ([sessionTable selectedRow] == -1)
        {
            [deleteSessionButton setEnabled:NO];    [editSessionButton setEnabled:NO];
        }
        else
        {
            [deleteSessionButton setEnabled:YES];   [editSessionButton setEnabled:YES];
        }
    }
}

- (void)tableDoubleClick:(NSTableView *)tableView
{
    if (tableView == jobTable)  [self editJob];
    else                        [self editSession];
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)tableColumn row:(int)rowIndex
{
    if (tableView == sessionTable)
        [[[[jobData objectAtIndex:[jobTable selectedRow]] objectForKey:@"sessionList"] objectAtIndex:rowIndex] setObject:anObject forKey:@"sessionSummary"];
}

- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(int)row
{
    if (floor(NSAppKitVersionNumber) <= NSAppKitVersionNumber10_2)
    {
        if (![[tableColumn identifier] isEqualTo:@"jobActive"] && ![[tableColumn identifier] isEqualTo:@"sessionActive"])
        {
            [cell setDrawsBackground:YES];
            if (row % 2)    [cell setBackgroundColor:[NSColor whiteColor]];
            else            [cell setBackgroundColor:[NSColor colorWithCalibratedRed:0.9 green:0.9 blue:0.9 alpha:1.0]];
            
            [tableView setIntercellSpacing:NSMakeSize(0, 0)];
        }
    }
}

//***Buttons***
//Main Window
- (IBAction)startStopRecording:(id)sender
{
    if ([jobTable selectedRow] != -1)
    {
        if ([[[jobData objectAtIndex:[jobTable selectedRow]] objectForKey:@"jobActive"] isEqualTo:@"No"])
        {
            [[jobData objectAtIndex:[jobTable selectedRow]] setObject:@"Yes" forKey:@"jobActive"];
            
            cuDateTime *newStart = [[[cuDateTime alloc] initWithCurrentDateAndTime] autorelease];
            cuDateTime *newEnd = [[[cuDateTime alloc] initWithCurrentDateAndTime] autorelease];
            
            [self createNewSession:newStart endDateTime:newEnd job:[jobTable selectedRow] active:YES];
            
            [startStopButton setImage:startStopRed];
            [startStopButton setAlternateImage:startStopRed];
            [pauseButton setImage:pauseNo];
            [pauseButton setAlternateImage:pauseNo];
            
            [self updateMenuBarButtons];
            
            [startStopField setStringValue:[textStopRecording stringValue]];
            
            [jobTable reloadData];
            [sessionTable reloadData];
        }
        else if ([[[jobData objectAtIndex:[jobTable selectedRow]] objectForKey:@"jobActive"] isEqualTo:@"Yes"] ||
                 [[[jobData objectAtIndex:[jobTable selectedRow]] objectForKey:@"jobActive"] isEqualTo:@"Paused"])
        {
            [[jobData objectAtIndex:[jobTable selectedRow]] setObject:@"No" forKey:@"jobActive"];
            
            int count = [[[jobData objectAtIndex:[jobTable selectedRow]] objectForKey:@"sessionList"] count];
            
            [[[[jobData objectAtIndex:[jobTable selectedRow]] objectForKey:@"sessionList"] objectAtIndex:count - 1] 
                setObject:@"No" forKey:@"sessionActive"];
                
            [startStopButton setImage:startStopGreen];
            [startStopButton setAlternateImage:startStopGreen];
            [pauseButton setImage:nil];
            [pauseButton setAlternateImage:nil];
            
            [self updateMenuBarButtons];
            
            [startStopField setStringValue:[textStartRecording stringValue]];
            
            cuDateTime *tempStart = [[[[jobData objectAtIndex:[jobTable selectedRow]] objectForKey:@"sessionList"] objectAtIndex:count - 1] objectForKey:@"startDateTime"];
            cuDateTime *tempEnd = [[[[jobData objectAtIndex:[jobTable selectedRow]] objectForKey:@"sessionList"] objectAtIndex:count - 1] objectForKey:@"endDateTime"];
            
            if ([[tempStart getTimeInterval:tempEnd] getHour] < 1 && [[tempStart getTimeInterval:tempEnd] getMinute] < [prefsAutoDeleteSetting intValue])
            {
                [[[jobData objectAtIndex:[jobTable selectedRow]] objectForKey:@"sessionList"] removeObjectAtIndex:count - 1];
                [self computeJobTime:[jobTable selectedRow]];
                [self updateMenuBarData];
            }
            
            [jobTable reloadData];
            [sessionTable reloadData];
        }
    }
}

- (IBAction)pauseUnpause:(id)sender;
{
    if ([jobTable selectedRow] != -1 && ![[[jobData objectAtIndex:[jobTable selectedRow]] objectForKey:@"jobActive"] isEqualTo:@"No"])
    {
        int i = 0;
        int count = [[[jobData objectAtIndex:[jobTable selectedRow]] objectForKey:@"sessionList"] count];
    
        if ([[[jobData objectAtIndex:[jobTable selectedRow]] objectForKey:@"jobActive"] isEqualTo:@"Yes"])
        {
            [[jobData objectAtIndex:[jobTable selectedRow]] setObject:@"Paused" forKey:@"jobActive"];
            
            while (i < count)
            {
                if ([[[[[jobData objectAtIndex:[jobTable selectedRow]] objectForKey:@"sessionList"] objectAtIndex:i] 
                    objectForKey:@"sessionActive"] isEqualTo:@"Yes"])
                {
                    [[[[jobData objectAtIndex:[jobTable selectedRow]] objectForKey:@"sessionList"] objectAtIndex:i] 
                        setObject:@"Paused" forKey:@"sessionActive"];
                    
                    [[[[jobData objectAtIndex:[jobTable selectedRow]] objectForKey:@"sessionList"] objectAtIndex:i] 
                        setObject:[[cuDateTime alloc] initWithCurrentDateAndTime] forKey:@"pauseStart"];
                        
                    [[[[jobData objectAtIndex:[jobTable selectedRow]] objectForKey:@"sessionList"] 
                        objectAtIndex:i] setObject:[[[cuDateTime alloc] initWithCurrentDateAndTime] autorelease] forKey:@"pauseStop"];
                }
        
                i++;
            }
            
            [pauseButton setImage:pauseYes];
            [pauseButton setAlternateImage:pauseYes];
            
            [self updateMenuBarButtons];
            
            [jobTable reloadData];
            [sessionTable reloadData];
        }
        else if ([[[jobData objectAtIndex:[jobTable selectedRow]] objectForKey:@"jobActive"] isEqualTo:@"Paused"])
        {
            [[jobData objectAtIndex:[jobTable selectedRow]] setObject:@"Yes" forKey:@"jobActive"];
            
            while (i < count)
            {
                if ([[[[[jobData objectAtIndex:[jobTable selectedRow]] objectForKey:@"sessionList"] objectAtIndex:i] 
                    objectForKey:@"sessionActive"] isEqualTo:@"Paused"])
                {
                    [[[[jobData objectAtIndex:[jobTable selectedRow]] objectForKey:@"sessionList"] objectAtIndex:i] 
                        setObject:@"Yes" forKey:@"sessionActive"];
                        
                    cuDateTime *tempInterval = [[cuDateTime alloc] init];
                    [tempInterval setValues:[[[[jobData objectAtIndex:[jobTable selectedRow]] objectForKey:@"sessionList"] objectAtIndex:i] 
                        objectForKey:@"pauseTime"]];
                    cuDateTime *tempIntervalTwo = [[cuDateTime alloc] init];
                    [tempIntervalTwo setValues:[[[[jobData objectAtIndex:[jobTable selectedRow]] objectForKey:@"sessionList"] objectAtIndex:i] 
                        objectForKey:@"tempPauseTime"]];
                        
                    [[[[jobData objectAtIndex:[jobTable selectedRow]] objectForKey:@"sessionList"] 
                        objectAtIndex:i] setObject:[[[cuDateTime alloc] init] autorelease] forKey:@"pauseStop"];
                    [[[[jobData objectAtIndex:[jobTable selectedRow]] objectForKey:@"sessionList"] 
                        objectAtIndex:i] setObject:[[[cuDateTime alloc] init] autorelease] forKey:@"pauseStart"];
                    
                    [[[[jobData objectAtIndex:[jobTable selectedRow]] objectForKey:@"sessionList"] objectAtIndex:i] 
                        setObject:[tempIntervalTwo addInterval:tempInterval] forKey:@"pauseTime"];
                        
                    [tempInterval release];
                    [tempIntervalTwo release];  
                }
        
                i++;
            }
            [pauseButton setImage:pauseNo];
            [pauseButton setAlternateImage:pauseNo];
            
            [self updateMenuBarButtons];
            
            [jobTable reloadData];
            [sessionTable reloadData];
        }
    }
}

- (IBAction)addJobButton:(id)sender
{
    [NSApp beginSheet:addJobPanel modalForWindow:mainWindow modalDelegate:self didEndSelector:NULL contextInfo:nil];
}

- (IBAction)deleteJobButton:(id)sender
{
    if ([prefsAskDeleteJob state])
    {
        int i = NSRunAlertPanel([textDeleteJobShort stringValue], [textDeleteJobLong stringValue], @"Delete Project", @"Cancel", nil);
        
        if (i == NSOKButton)
        {
            [jobData removeObjectAtIndex:[jobTable selectedRow]];
            [jobTable reloadData];
            [sessionTable reloadData];
            [self updateMenuBarJobList];
        }
    }
    else
    {
        [jobData removeObjectAtIndex:[jobTable selectedRow]];
        [jobTable reloadData];
        [sessionTable reloadData];
        [self updateMenuBarJobList];
    }
}

- (IBAction)editJobButton:(id)sender
{
    [self editJob];
}

- (void)editJob
{
    [editJobJobName setStringValue:[[jobData objectAtIndex:[jobTable selectedRow]] objectForKey:@"jobName"]];
    [editJobClient setStringValue:[[jobData objectAtIndex:[jobTable selectedRow]] objectForKey:@"clientName"]];
    [editJobHourlyRate setStringValue:[[[jobData objectAtIndex:[jobTable selectedRow]] objectForKey:@"hourlyRate"] stringValue]];
    
    [NSApp beginSheet:editJobPanel modalForWindow:mainWindow modalDelegate:self didEndSelector:NULL contextInfo:nil];
}

//Drawer
- (IBAction)addSessionButton:(id)sender
{
    [NSApp beginSheet:addSessionPanel modalForWindow:mainWindow modalDelegate:self didEndSelector:NULL contextInfo:nil];
}

- (IBAction)deleteSessionButton:(id)sender
{
    if ([prefsAskDeleteSession state])
    {
        int i = NSRunAlertPanel([textDeleteSessionShort stringValue], [textDeleteSessionLong stringValue], @"Delete Session", @"Cancel", nil);
        
        if (i == NSOKButton)
        {
            [[[jobData objectAtIndex:[jobTable selectedRow]] objectForKey:@"sessionList"] removeObjectAtIndex:[sessionTable selectedRow]];
            [self computeJobTime:[jobTable selectedRow]];
            [jobTable reloadData];
            [self updateMenuBarData];
            [sessionTable reloadData];
        }
    }
    else
    {
        [[[jobData objectAtIndex:[jobTable selectedRow]] objectForKey:@"sessionList"] removeObjectAtIndex:[sessionTable selectedRow]];
        [self computeJobTime:[jobTable selectedRow]];
        [jobTable reloadData];
        [self updateMenuBarData];
        [sessionTable reloadData];
    }
}

- (IBAction)editSessionButton:(id)sender
{
    [self editSession];
}

- (void)editSession
{
    [editSessionStartDate setStringValue:[[[[[jobData objectAtIndex:[jobTable selectedRow]] objectForKey:@"sessionList"] 
        objectAtIndex:[sessionTable selectedRow]] objectForKey:@"startDateTime"] getDateString]];
    [editSessionStartTime setStringValue:[[[[[jobData objectAtIndex:[jobTable selectedRow]] objectForKey:@"sessionList"] 
        objectAtIndex:[sessionTable selectedRow]] objectForKey:@"startDateTime"] getTimeString]];
    [editSessionEndDate setStringValue:[[[[[jobData objectAtIndex:[jobTable selectedRow]] objectForKey:@"sessionList"] 
        objectAtIndex:[sessionTable selectedRow]] objectForKey:@"endDateTime"] getDateString]];
    [editSessionEndTime setStringValue:[[[[[jobData objectAtIndex:[jobTable selectedRow]] objectForKey:@"sessionList"] 
        objectAtIndex:[sessionTable selectedRow]] objectForKey:@"endDateTime"] getTimeString]];

    [NSApp beginSheet:editSessionPanel modalForWindow:mainWindow modalDelegate:self didEndSelector:NULL contextInfo:nil];
}

//AddJobPanel
- (IBAction)addJobCancel:(id)sender
{
    [addJobPanel orderOut:nil];
    [NSApp endSheet:addJobPanel];
    
    [addJobClient setStringValue:@""];
    [addJobJobName setStringValue:@""];
    [addJobHourlyRate setStringValue:@""];  // TODO: we should set this based on some default $(cstuart 2007-07-03)
}

- (IBAction)addJobSave:(id)sender
{   
    NSMutableString *jobName = [[NSMutableString alloc] init];
    NSMutableString *clientName = [[NSMutableString alloc] init];
    [jobName setString:[addJobJobName stringValue]];
    [clientName setString:[addJobClient stringValue]];

    int i = [jobName length] - 1;
    while (i > 0)
    {
        if ([jobName characterAtIndex:i] == '\n' || [jobName characterAtIndex:i] == '\t' || [jobName characterAtIndex:i] == '\\')
            [jobName deleteCharactersInRange:NSMakeRange(i, 1)];
        i--;
    }
    i = [clientName length] - 1;
    while (i > 0)
    {
        if ([clientName characterAtIndex:i] == '\n' || [clientName characterAtIndex:i] == '\t' || [clientName characterAtIndex:i] == '\\')
            [clientName deleteCharactersInRange:NSMakeRange(i, 1)];
        i--;
    }

    [self createNewJob:jobName client:clientName rate:[addJobHourlyRate doubleValue]];
    [jobTable reloadData];
    [self updateMenuBarJobList];

    [addJobPanel orderOut:nil];
    [NSApp endSheet:addJobPanel];
    
    [addJobClient setStringValue:@""];
    [addJobJobName setStringValue:@""];
    [addJobHourlyRate setStringValue:@""];
}

//EditJobPanel
- (IBAction)editJobCancel:(id)sender
{
    [editJobPanel orderOut:nil];
    [NSApp endSheet:editJobPanel];
    
    [editJobClient setStringValue:@""];
    [editJobJobName setStringValue:@""];
    [editJobHourlyRate setStringValue:@""];
}

- (IBAction)editJobSave:(id)sender
{
    if ([[editJobHourlyRate stringValue] length] != 0)
    {
        NSMutableString *jobName = [[NSMutableString alloc] init];
        NSMutableString *clientName = [[NSMutableString alloc] init];
        [jobName setString:[editJobJobName stringValue]];
        [clientName setString:[editJobClient stringValue]];
    
        int i = [jobName length] - 1;
        while (i > 0)
        {
            if ([jobName characterAtIndex:i] == '\n' || [jobName characterAtIndex:i] == '\t' || [jobName characterAtIndex:i] == '\\')
                [jobName deleteCharactersInRange:NSMakeRange(i, 1)];
            i--;
        }
        i = [clientName length] - 1;
        while (i > 0)
        {
            if ([clientName characterAtIndex:i] == '\n' || [clientName characterAtIndex:i] == '\t' || [clientName characterAtIndex:i] == '\\')
                [clientName deleteCharactersInRange:NSMakeRange(i, 1)];
            i--;
        }
    
        [[jobData objectAtIndex:[jobTable selectedRow]] setObject:jobName forKey:@"jobName"];
        [[jobData objectAtIndex:[jobTable selectedRow]] setObject:clientName forKey:@"clientName"];
        [[jobData objectAtIndex:[jobTable selectedRow]] setObject:[NSNumber numberWithDouble:[editJobHourlyRate doubleValue]] forKey:@"hourlyRate"];
        [self computeJobTime:[jobTable selectedRow]];
    
        [jobTable reloadData];
        [sessionTable reloadData];
        [self updateMenuBarJobList];
    
        [editJobPanel orderOut:nil];
        [NSApp endSheet:editJobPanel];
    
        [editJobClient setStringValue:@""];
        [editJobJobName setStringValue:@""];
        [editJobHourlyRate setStringValue:@""];
    }
    else {NSBeep(); [editJobHourlyRate selectText:self];}
}

//AddSessionPanel
- (IBAction)addSessionCancel:(id)sender
{
    [addSessionPanel orderOut:nil];
    [NSApp endSheet:addSessionPanel];
    
    [addSessionEndDate setStringValue:@""];
    [addSessionEndTime setStringValue:@""];
    [addSessionStartDate setStringValue:@""];
    [addSessionStartTime setStringValue:@""];
}

- (IBAction)addSessionSave:(id)sender
{
    int startTimeFormat = 0;
    int endTimeFormat   = 0;
    
    NSCalendarDate *theDate         = [NSCalendarDate calendarDate];
    NSCalendarDate *tomorrowsDate   = [NSCalendarDate calendarDate];
    NSCalendarDate *yesterdaysDate  = [NSCalendarDate calendarDate];
    tomorrowsDate = [tomorrowsDate dateByAddingYears:0 months:0 days:1 hours:0 minutes:0 seconds:0];
    yesterdaysDate = [yesterdaysDate dateByAddingYears:0 months:0 days:-1 hours:0 minutes:0 seconds:0];
    
    if ([[[addSessionStartDate stringValue] lowercaseString] isEqualTo:@"today"])
    {
        NSMutableString *builtStartDate = [[[NSMutableString alloc] init] autorelease];
        [builtStartDate appendString:[[NSNumber numberWithInt:[theDate monthOfYear]] stringValue]];
        [builtStartDate appendString:@"/"];
        [builtStartDate appendString:[[NSNumber numberWithInt:[theDate dayOfMonth]] stringValue]];
        [builtStartDate appendString:@"/"];
        [builtStartDate appendString:[[NSNumber numberWithInt:[theDate yearOfCommonEra]] stringValue]];
        
        [addSessionStartDate setStringValue:builtStartDate];
    }
    
    if ([[[addSessionEndDate stringValue] lowercaseString] isEqualTo:@"today"])
    {
        NSMutableString *builtEndDate = [[[NSMutableString alloc] init] autorelease];
        [builtEndDate appendString:[[NSNumber numberWithInt:[theDate monthOfYear]] stringValue]];
        [builtEndDate appendString:@"/"];
        [builtEndDate appendString:[[NSNumber numberWithInt:[theDate dayOfMonth]] stringValue]];
        [builtEndDate appendString:@"/"];
        [builtEndDate appendString:[[NSNumber numberWithInt:[theDate yearOfCommonEra]] stringValue]];
        
        [addSessionEndDate setStringValue:builtEndDate];
    }
    
    if ([[[addSessionStartDate stringValue] lowercaseString] isEqualTo:@"yesterday"])
    {
        NSMutableString *builtStartDate = [[[NSMutableString alloc] init] autorelease];
        [builtStartDate appendString:[[NSNumber numberWithInt:[yesterdaysDate monthOfYear]] stringValue]];
        [builtStartDate appendString:@"/"];
        [builtStartDate appendString:[[NSNumber numberWithInt:[yesterdaysDate dayOfMonth]] stringValue]];
        [builtStartDate appendString:@"/"];
        [builtStartDate appendString:[[NSNumber numberWithInt:[yesterdaysDate yearOfCommonEra]] stringValue]];
        
        [addSessionStartDate setStringValue:builtStartDate];
    }
    
    if ([[[addSessionEndDate stringValue] lowercaseString] isEqualTo:@"yesterday"])
    {
        NSMutableString *builtEndDate = [[[NSMutableString alloc] init] autorelease];
        [builtEndDate appendString:[[NSNumber numberWithInt:[yesterdaysDate monthOfYear]] stringValue]];
        [builtEndDate appendString:@"/"];
        [builtEndDate appendString:[[NSNumber numberWithInt:[yesterdaysDate dayOfMonth]] stringValue]];
        [builtEndDate appendString:@"/"];
        [builtEndDate appendString:[[NSNumber numberWithInt:[yesterdaysDate yearOfCommonEra]] stringValue]];
        
        [addSessionEndDate setStringValue:builtEndDate];
    }
    
    if ([[[addSessionStartDate stringValue] lowercaseString] isEqualTo:@"tomorrow"])
    {
        NSMutableString *builtStartDate = [[[NSMutableString alloc] init] autorelease];
        [builtStartDate appendString:[[NSNumber numberWithInt:[tomorrowsDate monthOfYear]] stringValue]];
        [builtStartDate appendString:@"/"];
        [builtStartDate appendString:[[NSNumber numberWithInt:[tomorrowsDate dayOfMonth]] stringValue]];
        [builtStartDate appendString:@"/"];
        [builtStartDate appendString:[[NSNumber numberWithInt:[tomorrowsDate yearOfCommonEra]] stringValue]];
        
        [addSessionStartDate setStringValue:builtStartDate];
    }
    
    if ([[[addSessionEndDate stringValue] lowercaseString] isEqualTo:@"tomorrow"])
    {
        NSMutableString *builtEndDate = [[[NSMutableString alloc] init] autorelease];
        [builtEndDate appendString:[[NSNumber numberWithInt:[tomorrowsDate monthOfYear]] stringValue]];
        [builtEndDate appendString:@"/"];
        [builtEndDate appendString:[[NSNumber numberWithInt:[tomorrowsDate dayOfMonth]] stringValue]];
        [builtEndDate appendString:@"/"];
        [builtEndDate appendString:[[NSNumber numberWithInt:[tomorrowsDate yearOfCommonEra]] stringValue]];
        
        [addSessionEndDate setStringValue:builtEndDate];
    }
    
    if ([[[addSessionStartTime stringValue] lowercaseString] isEqualTo:@"now"])
        [addSessionStartTime setStringValue:[[[[cuDateTime alloc] initWithCurrentDateAndTime] autorelease] getTimeString]];
    if ([[[addSessionEndTime stringValue] lowercaseString] isEqualTo:@"now"])
        [addSessionEndTime setStringValue:[[[[cuDateTime alloc] initWithCurrentDateAndTime] autorelease] getTimeString]];
    
    if ([cuDateTime checkStringForTime:[addSessionStartTime stringValue]])                      startTimeFormat = 1;
    if ([cuDateTime checkStringForTime:[addSessionEndTime stringValue]])                        endTimeFormat   = 1;
    if ([cuDateTime checkStringForTwelveHourTime:[addSessionStartTime stringValue]])            startTimeFormat = 2;
    if ([cuDateTime checkStringForTwelveHourTime:[addSessionEndTime stringValue]])              endTimeFormat   = 2;
    if ([cuDateTime checkStringForTimeNoSeconds:[addSessionStartTime stringValue]])             startTimeFormat = 3;
    if ([cuDateTime checkStringForTimeNoSeconds:[addSessionEndTime stringValue]])               endTimeFormat   = 3;
    if ([cuDateTime checkStringForTwelveHourTimeNoSeconds:[addSessionStartTime stringValue]])   startTimeFormat = 4;
    if ([cuDateTime checkStringForTwelveHourTimeNoSeconds:[addSessionEndTime stringValue]])     endTimeFormat   = 4;


    if ([cuDateTime checkStringForDate:[addSessionStartDate stringValue]])
    {
        if (startTimeFormat != 0)
        {
            if ([cuDateTime checkStringForDate:[addSessionEndDate stringValue]])
            {
                if (endTimeFormat != 0)
                {
                    cuDateTime *tempEndDateTime = [[cuDateTime alloc] initWithStrings:[addSessionEndDate stringValue] time:[addSessionEndTime stringValue]
                        timeFormat:endTimeFormat];
                    cuDateTime *tempStartDateTime = [[cuDateTime alloc] initWithStrings:[addSessionStartDate stringValue] time:[addSessionStartTime stringValue]
                        timeFormat:startTimeFormat];
    
                    if ([tempStartDateTime compare:tempEndDateTime] == NSOrderedDescending)
                    {
                        [self createNewSession:tempStartDateTime endDateTime:tempEndDateTime job:[jobTable selectedRow] active:NO];
                        [self computeJobTime:[jobTable selectedRow]];
                        [jobTable reloadData];
                        [sessionTable reloadData];

                        [addSessionPanel orderOut:nil];
                        [NSApp endSheet:addSessionPanel];
    
                        [addSessionEndDate setStringValue:@""];
                        [addSessionEndTime setStringValue:@""];
                        [addSessionStartDate setStringValue:@""];
                        [addSessionStartTime setStringValue:@""];

                    }
                    else NSRunAlertPanel([textBah stringValue], [textEndLater stringValue], @"OK", nil, nil);
                }
                else {NSBeep(); [addSessionEndTime selectText:self];}
            }
            else {NSBeep();  [addSessionEndDate selectText:self];}
        }
        else {NSBeep(); [addSessionStartTime selectText:self];}
    }
    else {NSBeep(); [addSessionStartDate selectText:self];}
}

//EditSessionPanel
- (IBAction)editSessionCancel:(id)sender
{
    [editSessionPanel orderOut:nil];
    [NSApp endSheet:editSessionPanel];
    
    [editSessionEndDate setStringValue:@""];
    [editSessionEndTime setStringValue:@""];
    [editSessionStartDate setStringValue:@""];
    [editSessionStartTime setStringValue:@""];
}

- (IBAction)editSessionSave:(id)sender
{
    int startTimeFormat = 0;
    int endTimeFormat   = 0;
    
    if ([cuDateTime checkStringForTime:[editSessionStartTime stringValue]])                     startTimeFormat = 1;
    if ([cuDateTime checkStringForTime:[editSessionEndTime stringValue]])                       endTimeFormat   = 1;
    if ([cuDateTime checkStringForTwelveHourTime:[editSessionStartTime stringValue]])           startTimeFormat = 2;
    if ([cuDateTime checkStringForTwelveHourTime:[editSessionEndTime stringValue]])             endTimeFormat   = 2;
    if ([cuDateTime checkStringForTimeNoSeconds:[editSessionStartTime stringValue]])            startTimeFormat = 3;
    if ([cuDateTime checkStringForTimeNoSeconds:[editSessionEndTime stringValue]])              endTimeFormat   = 3;
    if ([cuDateTime checkStringForTwelveHourTimeNoSeconds:[editSessionStartTime stringValue]])  startTimeFormat = 4;
    if ([cuDateTime checkStringForTwelveHourTimeNoSeconds:[editSessionEndTime stringValue]])    endTimeFormat   = 4;


    NSCalendarDate *theDate         = [NSCalendarDate calendarDate];
    NSCalendarDate *tomorrowsDate   = [NSCalendarDate calendarDate];
    NSCalendarDate *yesterdaysDate   = [NSCalendarDate calendarDate];
    tomorrowsDate = [tomorrowsDate dateByAddingYears:0 months:0 days:1 hours:0 minutes:0 seconds:0];
    yesterdaysDate = [yesterdaysDate dateByAddingYears:0 months:0 days:-1 hours:0 minutes:0 seconds:0];
    
    if ([[[editSessionStartDate stringValue] lowercaseString] isEqualTo:@"today"])
    {
        NSMutableString *builtStartDate = [[[NSMutableString alloc] init] autorelease];
        [builtStartDate appendString:[[NSNumber numberWithInt:[theDate monthOfYear]] stringValue]];
        [builtStartDate appendString:@"/"];
        [builtStartDate appendString:[[NSNumber numberWithInt:[theDate dayOfMonth]] stringValue]];
        [builtStartDate appendString:@"/"];
        [builtStartDate appendString:[[NSNumber numberWithInt:[theDate yearOfCommonEra]] stringValue]];
        
        [editSessionStartDate setStringValue:builtStartDate];
    }
    
    if ([[[editSessionEndDate stringValue] lowercaseString] isEqualTo:@"today"])
    {
        NSMutableString *builtEndDate = [[[NSMutableString alloc] init] autorelease];
        [builtEndDate appendString:[[NSNumber numberWithInt:[theDate monthOfYear]] stringValue]];
        [builtEndDate appendString:@"/"];
        [builtEndDate appendString:[[NSNumber numberWithInt:[theDate dayOfMonth]] stringValue]];
        [builtEndDate appendString:@"/"];
        [builtEndDate appendString:[[NSNumber numberWithInt:[theDate yearOfCommonEra]] stringValue]];
        
        [editSessionEndDate setStringValue:builtEndDate];
    }
    
    if ([[[editSessionStartDate stringValue] lowercaseString] isEqualTo:@"yesterday"])
    {
        NSMutableString *builtStartDate = [[[NSMutableString alloc] init] autorelease];
        [builtStartDate appendString:[[NSNumber numberWithInt:[yesterdaysDate monthOfYear]] stringValue]];
        [builtStartDate appendString:@"/"];
        [builtStartDate appendString:[[NSNumber numberWithInt:[yesterdaysDate dayOfMonth]] stringValue]];
        [builtStartDate appendString:@"/"];
        [builtStartDate appendString:[[NSNumber numberWithInt:[yesterdaysDate yearOfCommonEra]] stringValue]];
        
        [editSessionStartDate setStringValue:builtStartDate];
    }
    
    if ([[[editSessionEndDate stringValue] lowercaseString] isEqualTo:@"yesterday"])
    {
        NSMutableString *builtEndDate = [[[NSMutableString alloc] init] autorelease];
        [builtEndDate appendString:[[NSNumber numberWithInt:[yesterdaysDate monthOfYear]] stringValue]];
        [builtEndDate appendString:@"/"];
        [builtEndDate appendString:[[NSNumber numberWithInt:[yesterdaysDate dayOfMonth]] stringValue]];
        [builtEndDate appendString:@"/"];
        [builtEndDate appendString:[[NSNumber numberWithInt:[yesterdaysDate yearOfCommonEra]] stringValue]];
        
        [editSessionEndDate setStringValue:builtEndDate];
    }
    
    if ([[[editSessionStartDate stringValue] lowercaseString] isEqualTo:@"tomorrow"])
    {
        NSMutableString *builtStartDate = [[[NSMutableString alloc] init] autorelease];
        [builtStartDate appendString:[[NSNumber numberWithInt:[tomorrowsDate monthOfYear]] stringValue]];
        [builtStartDate appendString:@"/"];
        [builtStartDate appendString:[[NSNumber numberWithInt:[tomorrowsDate dayOfMonth]] stringValue]];
        [builtStartDate appendString:@"/"];
        [builtStartDate appendString:[[NSNumber numberWithInt:[tomorrowsDate yearOfCommonEra]] stringValue]];
        
        [editSessionStartDate setStringValue:builtStartDate];
    }
    
    if ([[[editSessionEndDate stringValue] lowercaseString] isEqualTo:@"tomorrow"])
    {
        NSMutableString *builtEndDate = [[[NSMutableString alloc] init] autorelease];
        [builtEndDate appendString:[[NSNumber numberWithInt:[tomorrowsDate monthOfYear]] stringValue]];
        [builtEndDate appendString:@"/"];
        [builtEndDate appendString:[[NSNumber numberWithInt:[tomorrowsDate dayOfMonth]] stringValue]];
        [builtEndDate appendString:@"/"];
        [builtEndDate appendString:[[NSNumber numberWithInt:[tomorrowsDate yearOfCommonEra]] stringValue]];
        
        [editSessionEndDate setStringValue:builtEndDate];
    }
    
    if ([[[editSessionStartTime stringValue] lowercaseString] isEqualTo:@"now"])
        [editSessionStartTime setStringValue:[[[[cuDateTime alloc] initWithCurrentDateAndTime] autorelease] getTimeString]];
    if ([[[editSessionEndTime stringValue] lowercaseString] isEqualTo:@"now"])
        [editSessionEndTime setStringValue:[[[[cuDateTime alloc] initWithCurrentDateAndTime] autorelease] getTimeString]];

    if ([cuDateTime checkStringForDate:[editSessionStartDate stringValue]])
    {
        if (startTimeFormat != 0)
        {
            if ([cuDateTime checkStringForDate:[editSessionEndDate stringValue]])
            {
                if (endTimeFormat != 0)
                {
                    cuDateTime *tempStartDateTime = [[cuDateTime alloc] initWithStrings:[editSessionStartDate stringValue] 
                        time:[editSessionStartTime stringValue] timeFormat:startTimeFormat];
                    cuDateTime *tempEndDateTime = [[cuDateTime alloc] initWithStrings:[editSessionEndDate stringValue] 
                        time:[editSessionEndTime stringValue] timeFormat:endTimeFormat];
                
                    if ([tempStartDateTime compare:tempEndDateTime] == NSOrderedDescending)
                    {
                        [[[[jobData objectAtIndex:[jobTable selectedRow]] objectForKey:@"sessionList"] objectAtIndex:[sessionTable selectedRow]] 
                        setObject:tempStartDateTime forKey:@"startDateTime"];
                        [[[[jobData objectAtIndex:[jobTable selectedRow]] objectForKey:@"sessionList"] objectAtIndex:[sessionTable selectedRow]] 
                        setObject:tempEndDateTime forKey:@"endDateTime"];
                
                        [self computeJobTime:[jobTable selectedRow]];
                        [jobTable reloadData];
                        [sessionTable reloadData];
                        
                        [editSessionPanel orderOut:nil];
                        [NSApp endSheet:editSessionPanel];
    
                        [editSessionEndDate setStringValue:@""];
                        [editSessionEndTime setStringValue:@""];
                        [editSessionStartDate setStringValue:@""];
                        [editSessionStartTime setStringValue:@""];
                    }
                    else NSRunAlertPanel([textBah stringValue], [textEndLater stringValue], @"OK", nil, nil);
                }
                else {NSBeep(); [editSessionEndTime selectText:self];}
            }
            else {NSBeep();  [editSessionEndDate selectText:self];}
        }
        else {NSBeep(); [editSessionStartTime selectText:self];}
    }
    else {NSBeep(); [editSessionStartDate selectText:self];}
}

//PrefsWindow
- (IBAction)prefsJobTableChange:(id)sender
{
    [self buildJobTable];
}

- (IBAction)prefsMenuChanged:(id)sender
{
    [self buildStatusItem];
    [self updateMenuBarData];
    [self updateMenuBarButtons];
}

- (IBAction)prefsSave:(id)sender
{
    [self savePrefs];
    [prefsWindow orderOut:nil];
    [prefsWindow center];
}

- (IBAction)prefsSessionTableChange:(id)sender
{
    [self buildSessionTable];
}

- (IBAction)prefsUpdateTimeChange:(id)sender
{
    [jobTable reloadData];
    [sessionTable reloadData];
}

- (IBAction)statusItemChanged:(id)sender
{
    [self buildStatusItem];
    [self updateMenuBarData];
    [self updateMenuBarButtons];
}

//***MenuItems***
- (IBAction)menuPauseAllJobs:(id)sender
{
    int i = 0;
    int j = 0;
    int sessionCount = 0;
    int count = [jobData count];
    while (i < count)
    {       
        if ([[[jobData objectAtIndex:i] objectForKey:@"jobActive"] isEqualTo:@"Yes"])
        {
            [[jobData objectAtIndex:i] setObject:@"Paused" forKey:@"jobActive"];
            
            sessionCount = [[[jobData objectAtIndex:i] objectForKey:@"sessionList"] count];
            while (j < sessionCount)
            {
                if ([[[[[jobData objectAtIndex:i] objectForKey:@"sessionList"] objectAtIndex:j] objectForKey:@"sessionActive"] isEqualTo:@"Yes"])
                {
                    [[[[jobData objectAtIndex:i] objectForKey:@"sessionList"] objectAtIndex:j] setObject:@"Paused" forKey:@"sessionActive"];
                    
                    [[[[jobData objectAtIndex:i]objectForKey:@"sessionList"] objectAtIndex:j] 
                        setObject:[[cuDateTime alloc] initWithCurrentDateAndTime] forKey:@"pauseStart"];
                    
                    [[[[jobData objectAtIndex:i]objectForKey:@"sessionList"] objectAtIndex:j] 
                        setObject:[[cuDateTime alloc] initWithCurrentDateAndTime] forKey:@"pauseStop"];
                }
                j++;
            }
        }
        i++;
        j = 0;
    }
    
    if ([jobTable selectedRow] != -1)
    {
        if ([[[jobData objectAtIndex:[jobTable selectedRow]] objectForKey:@"jobActive"] isEqualTo:@"Paused"])
        {
            [pauseButton setImage:pauseYes];
            [pauseButton setAlternateImage:pauseYes];
            [startStopButton setImage:startStopRed];
            [startStopButton setAlternateImage:startStopRed];
        }
    }
    
    [jobTable reloadData];
    [sessionTable reloadData];
}

- (IBAction)menuAddData:(id)sender
{
    NSMutableArray *tempData = [[NSMutableArray alloc] init];
    [tempData setArray:[dataHandler importData:jobData text:[textSelectFile stringValue]]];

    [jobData setArray:tempData];
    
    int i = 0;
    int count = [jobData count];
    while (i < count)
    {
        [self computeJobTime:i];
        i++;
    }
    
    [self updateMenuBarJobList];
    [jobTable reloadData];
    [sessionTable reloadData];
}

- (IBAction)menuBlatantAd:(id)sender
{
    NSWorkspace *workSpace = [NSWorkspace sharedWorkspace];
    [workSpace openURL:[NSURL URLWithString:@"mailto:khronos@enure.net?subject=Suggestion"]];
}

- (IBAction)menuDisplayHelp:(id)sender
{
    NSWorkspace *workSpace = [NSWorkspace sharedWorkspace];
    [workSpace openFile:@"/Library/Application Support/KhronosHelp/index.html" withApplication:@"Safari"];
}

- (IBAction)menuDonate:(id)sender // FIXME $(cstuart 2007-07-03)
{
    NSWorkspace *workSpace = [NSWorkspace sharedWorkspace];
    [workSpace openURL:[NSURL URLWithString:@"http://khronos.enure.net/"]];
}

- (IBAction)menuExport:(id)sender
{
    [self saveLoop];
    [dataHandler exportData:jobData text:[textExportTo stringValue]];
}

- (IBAction)menuOpenWindow:(id)sender
{
    [mainWindow makeKeyAndOrderFront:nil];
}

- (IBAction)showPagePanel:(id)sender
{
    printInfo = [NSPrintInfo sharedPrintInfo];
    NSPageLayout *pageLayout = [NSPageLayout pageLayout];
    [pageLayout runModalWithPrintInfo:(NSPrintInfo *)printInfo];
}

- (IBAction)menuPrintInvoice:(id)sender
{
    if ([jobTable selectedRow] != -1)
    {
        [self buildPrintTable];
        [self updatePrintWindowFields];
        
        NSPrintOperation *printOperation;
        printOperation = [NSPrintOperation printOperationWithView:[printWindow contentView] printInfo:printInfo];
        
        [printOperation setShowPanels:YES];
        [printOperation runOperation];
    }
    else
    {
        NSRunAlertPanel([textBah stringValue], [textSelectJob stringValue], @"OK", nil, nil);
    }
}

- (IBAction)menuHTML:(id)sender
{
    if ([jobTable selectedRow] != -1)
    {
        NSSavePanel *savePanel = [NSSavePanel savePanel];
        [savePanel setTitle:[textExportTo stringValue]];
        int i = [savePanel runModal];
        if (i == NSOKButton)
        {
            NSMutableString *compiledString = [[[NSMutableString alloc] init] autorelease];
            cuDateTime *tempTimeLogged = [[[cuDateTime alloc] init] autorelease];
            [tempTimeLogged setValues:[[jobData objectAtIndex:[jobTable selectedRow]] objectForKey:@"jobTimeLogged"]];
            NSMutableString *dataPath = [[[NSMutableString alloc] init] autorelease];
            [dataPath setString:[savePanel filename]];
            
            [compiledString setString:[self generateHTMLForJob:[jobTable selectedRow]]];
            
            [dataPath appendString:@".html"];
            [compiledString writeToFile:dataPath atomically:NO];
        }
    }
    else    NSRunAlertPanel([textBah stringValue], [textSelectJob stringValue], @"OK", nil, nil);
}

- (IBAction)menuHTMLAll:(id)sender
{
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    [savePanel setTitle:[textExportTo stringValue]];
    int i = [savePanel runModal];
    if (i == NSOKButton)
    {
        NSMutableString *dataPath = [[[NSMutableString alloc] init] autorelease];
        [dataPath setString:[savePanel filename]];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager createDirectoryAtPath:dataPath attributes:nil];
        NSMutableString *fileToSave = [[[NSMutableString alloc] init] autorelease];
        
        int i = 0;
        int count = [jobData count];
        while (i < count)
        {   
            [fileToSave setString:dataPath];
            [fileToSave appendString:@"/"];
            [fileToSave appendString:[[[jobData objectAtIndex:i] objectForKey:@"jobNumber"] stringValue]];
            [fileToSave appendString:@".html"];
            
            [[self generateHTMLForJob:i] writeToFile:fileToSave atomically:NO];
            
            i++;
        }
        
        [dataPath appendString:@"/"];
        [dataPath appendString:@"index.html"];
        [[self generateIndexHTML] writeToFile:dataPath atomically:NO];
    }
}

- (NSString *)generateIndexHTML
{
    NSMutableString *compiledString = [[[NSMutableString alloc] init] autorelease];
    
    [compiledString appendString:@"<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">"];
    [compiledString appendString:@"\n\n"];
    [compiledString appendString:@"<html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"en\" lang=\"en\">"];
    [compiledString appendString:@"\n\n"];
    [compiledString appendString:@"<head>"];
    [compiledString appendString:@"\n\n"];
    [compiledString appendString:@"<title>"];
    [compiledString appendString:[prefsInvoiceIndex stringValue]];
    [compiledString appendString:@"</title>"];
    [compiledString appendString:@"\n\n"];
    [compiledString appendString:@"<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />"];
    [compiledString appendString:@"\n\n"];
    [compiledString appendString:@"<style type=\"text/css\" media=\"all\">\n\n"];
    
    [compiledString appendString:@"body"];
    [compiledString appendString:@"\n{\n\t"];
    
    if ([prefsInvoiceSize intValue] == 1)  [compiledString appendString:@"font: 9pt/13pt "];
    if ([prefsInvoiceSize intValue] == 2)  [compiledString appendString:@"font: 10pt/13pt "];
    if ([prefsInvoiceSize intValue] == 3)  [compiledString appendString:@"font: 11pt/14pt "];
    if ([prefsInvoiceSize intValue] == 4)  [compiledString appendString:@"font: 12pt/15pt "];
    if ([prefsInvoiceSize intValue] == 5)  [compiledString appendString:@"font: 13pt/16pt "];

    if ([prefsInvoiceBodyFont indexOfSelectedItem] == 0)  [compiledString appendString:@"georgia, \"times new roman\", sans-serif;\n"];
    if ([prefsInvoiceBodyFont indexOfSelectedItem] == 1)  [compiledString appendString:@"helvetica, arial, serif;\n"];
    if ([prefsInvoiceBodyFont indexOfSelectedItem] == 2)  [compiledString appendString:@"\"lucida grande\", serif;\n"];
    if ([prefsInvoiceBodyFont indexOfSelectedItem] == 3)  [compiledString appendString:@"palatino, \"times new roman\", sans-serif;\n"];
    if ([prefsInvoiceBodyFont indexOfSelectedItem] == 4)  [compiledString appendString:@"verdana, tahoma, serif;\n"];
    
    [compiledString appendString:@"\n\t"];
    [compiledString appendString:@"color: #111;"];
    [compiledString appendString:@"\n\t"];
    [compiledString appendString:@"margin: 5%;"];
    [compiledString appendString:@"\n\t"];
    [compiledString appendString:@"background-color: white;"];
    [compiledString appendString:@"\n}\n\n"];
    
    [compiledString appendString:@".session td, th"];
    [compiledString appendString:@"\n{\n\t"];
    [compiledString appendString:@"border-bottom: 1px solid #ccc;"];
    [compiledString appendString:@"\n\t"];
    [compiledString appendString:@"padding: 2px 12px;"];
    [compiledString appendString:@"\n}\n\n"];
    
    [compiledString appendString:@"h2 { "];
    
    if ([prefsInvoiceSize intValue] == 1)  [compiledString appendString:@"font: 16pt/22pt "];
    if ([prefsInvoiceSize intValue] == 2)  [compiledString appendString:@"font: 17pt/23pt "];
    if ([prefsInvoiceSize intValue] == 3)  [compiledString appendString:@"font: 18pt/24pt "];
    if ([prefsInvoiceSize intValue] == 4)  [compiledString appendString:@"font: 19pt/25pt "];
    if ([prefsInvoiceSize intValue] == 5)  [compiledString appendString:@"font: 20pt/26pt "];

    if ([prefsInvoiceHeaderFont indexOfSelectedItem] == 0)  [compiledString appendString:@"georgia, \"times new roman\", sans-serif;}\n"];
    if ([prefsInvoiceHeaderFont indexOfSelectedItem] == 1)  [compiledString appendString:@"helvetica, arial, serif;}\n"];
    if ([prefsInvoiceHeaderFont indexOfSelectedItem] == 2)  [compiledString appendString:@"\"lucida grande\", serif;}\n"];
    if ([prefsInvoiceHeaderFont indexOfSelectedItem] == 3)  [compiledString appendString:@"palatino, \"times new roman\", sans-serif;}\n"];
    if ([prefsInvoiceHeaderFont indexOfSelectedItem] == 4)  [compiledString appendString:@"verdana, tahoma, serif;}\n"];
    
    [compiledString appendString:@"table, td, th { text-align: left; }\n"];
    [compiledString appendString:@"th { font-weight: bold; }\n"];
    [compiledString appendString:@"table.session { margin: 10px 0 40px; }\n"];
    [compiledString appendString:@"#dent { margin: 15px; }\n\n"];
    
    [compiledString appendString:@"a:link, a:visited { color: #111; font-weight: bold; text-decoration: none; border-bottom: 1px dotted #333; }\n"];
    [compiledString appendString:@"a:visited { color: #555; }\n"];
    [compiledString appendString:@"a:hover { border-bottom: 1px dotted #000; color: black;}\n\n</style>\n\n</head>\n\n<body>\n\n"];
    [compiledString appendString:@"<h2>"];
    [compiledString appendString:[prefsInvoiceIndexHeader stringValue]];
    [compiledString appendString:@"</h2>\n\n"];
    
    [compiledString appendString:@"<div id=\"dent\">\n\n\t"];
    [compiledString appendString:@"<p>"];
    [compiledString appendString:[prefsInvoiceIndexLink stringValue]];
    [compiledString appendString:@"</p>\n\n\t"];
    
    int i = 0;
    int count = [jobData count];
    
    if (count > 0)  
    {
        [compiledString appendString:@"<table class=\"session\">\n\t\t<tr>"];
        
        if ([prefsJobDisplayNumber state])
        {
            [compiledString appendString:@"<th>"];
            [compiledString appendString:[textJobNumber stringValue]];
            [compiledString appendString:@"</th>"];
        }
        
        [compiledString appendString:@"<th>"];
        [compiledString appendString:[textJobName stringValue]];
        [compiledString appendString:@"</th>"];
        
        if ([prefsJobDisplayClient state])
        {
            [compiledString appendString:@"<th>"];
            [compiledString appendString:[textClientName stringValue]];
            [compiledString appendString:@"</th>"];
        }
        
        if ([prefsJobDisplayRate state])
        {
            [compiledString appendString:@"<th>"];
            [compiledString appendString:[textRate stringValue]];
            [compiledString appendString:@"</th>"];
        }
        
        if ([prefsJobDisplayTime state])
        {
            [compiledString appendString:@"<th>"];
            [compiledString appendString:[textTimeLogged stringValue]];
            [compiledString appendString:@"</th>"];
        }
        
        if ([prefsJobDisplayCharges state])
        {
            [compiledString appendString:@"<th>"];
            [compiledString appendString:[textCharges stringValue]];
            [compiledString appendString:@"</th>"];
        }
        
        [compiledString appendString:@"</tr>\n\t\t"];
    }
    
    NSMutableString *hourlyRateString = [[[NSMutableString alloc] init] autorelease];
    id theJob;
    cuDateTime *tempTimeLogged = [[[cuDateTime alloc] init] autorelease];
    NSMutableString *chargeNumberString = [[[NSMutableString alloc] init] autorelease];
    NSMutableString *tempChargesString = [[[NSMutableString alloc] init] autorelease];
    
    NSNumber *rate;
    
    NSString *formatterString = @"second";
    if ([prefsUpdateEveryRadio selectedRow] == 1)   formatterString = @"minute";
    if ([prefsUpdateEveryRadio selectedRow] == 2)   formatterString = @"quarter";
    if ([prefsUpdateEveryRadio selectedRow] == 3)   formatterString = @"half";
    if ([prefsUpdateEveryRadio selectedRow] == 4)   formatterString = @"hour";
        
    while (i < count)
    {
        theJob = [jobData objectAtIndex:i];
        [hourlyRateString setString:@""];
        [tempTimeLogged setValues:[[jobData objectAtIndex:i] objectForKey:@"jobTimeLogged"]];
        [chargeNumberString setString:@""];
        [tempChargesString setString:@""];
        rate = [[jobData objectAtIndex:i] objectForKey:@"hourlyRate"];
        
        [compiledString appendString:@"<tr>"];
    
        if ([prefsJobDisplayNumber state])
        {
            [compiledString appendString:@"<td>"];
            [compiledString appendString:[[theJob objectForKey:@"jobNumber"] stringValue]];
            [compiledString appendString:@"</td>\t"];
        }
        
        [compiledString appendString:@"<td>"];
        [compiledString appendString:@"<a href=\""];
        [compiledString appendString:[[theJob objectForKey:@"jobNumber"] stringValue]];
        [compiledString appendString:@".html\""];
        [compiledString appendString:@" title=\"View the invoice for "];
        [compiledString appendString:[theJob objectForKey:@"jobName"]];
        [compiledString appendString:@"\">"];
        [compiledString appendString:[theJob objectForKey:@"jobName"]];
        [compiledString appendString:@"</a></td>\t"];
    
        if ([prefsJobDisplayClient state])
        {
            [compiledString appendString:@"<td>"];
            [compiledString appendString:[theJob objectForKey:@"clientName"]];
            [compiledString appendString:@"</td>\t"];
        }
        
        if ([prefsJobDisplayRate state])
        {
            [compiledString appendString:@"<td>"];
            [hourlyRateString appendString:[prefsMonetaryUnit stringValue]];
            [hourlyRateString appendString:[[[jobData objectAtIndex:i] objectForKey:@"hourlyRate"] stringValue]];
            [hourlyRateString appendString:[textHourSuffix stringValue]];
            [compiledString appendString:hourlyRateString];
            [compiledString appendString:@"</td>\t"];
        }
        
        if ([prefsJobDisplayTime state])
        {
            [compiledString appendString:@"<td>"];
            if ([prefsUpdateEveryRadio selectedRow] == 0)   [compiledString appendString:[tempTimeLogged getTimeString]];
            if ([prefsUpdateEveryRadio selectedRow] == 1)   [compiledString appendString:[tempTimeLogged getTimeString:NO]];
            if ([prefsUpdateEveryRadio selectedRow] == 2)   [compiledString appendString:[tempTimeLogged getFormattedTimeString:@"quarter"]];
            if ([prefsUpdateEveryRadio selectedRow] == 3)   [compiledString appendString:[tempTimeLogged getFormattedTimeString:@"half"]];
            if ([prefsUpdateEveryRadio selectedRow] == 4)   [compiledString appendString:[tempTimeLogged getFormattedTimeString:@"hour"]];
            [compiledString appendString:@"</td>\t"];
        }
        
        if ([prefsJobDisplayCharges state])
        {
            [compiledString appendString:@"<td>"];
            [chargeNumberString setString:[[NSNumber numberWithDouble:[tempTimeLogged calculateCharges:[rate doubleValue]
                format:formatterString]] stringValue]];
            
            [chargeNumberString setString:[self truncateChargeString:chargeNumberString]];
            
            [tempChargesString appendString:[prefsMonetaryUnit stringValue]];
            [tempChargesString appendString:chargeNumberString];
            
            [compiledString appendString:tempChargesString];
            [compiledString appendString:@"</td>\t"];
        }
        
        [compiledString appendString:@"</tr>\n\t\t"];
        
        i++;
    }
    
    if (count > 0)  [compiledString appendString:@"</table>"];
    
    [compiledString appendString:@"</div>\n\n</body>\n\n</html>\n\n"];

    return compiledString;
}

- (NSString *)generateHTMLForJob:(int)jobNumber
{
    NSMutableString *compiledString = [[[NSMutableString alloc] init] autorelease];
    cuDateTime *tempTimeLogged = [[[cuDateTime alloc] init] autorelease];
    [tempTimeLogged setValues:[[jobData objectAtIndex:jobNumber] objectForKey:@"jobTimeLogged"]];
    
    [compiledString appendString:@"<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">"];
    [compiledString appendString:@"\n\n"];
    [compiledString appendString:@"<html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"en\" lang=\"en\">"];
    [compiledString appendString:@"\n\n"];
    [compiledString appendString:@"<head>"];
    [compiledString appendString:@"\n\n"];
    [compiledString appendString:@"<title>"];
    [compiledString appendString:[prefsInvoiceTitle stringValue]];
    [compiledString appendString:@"</title>"];
    [compiledString appendString:@"\n\n"];
    [compiledString appendString:@"<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />"];
    [compiledString appendString:@"\n\n"];
    [compiledString appendString:@"<style type=\"text/css\" media=\"all\">"];
    
    [compiledString appendString:@"body"];
    [compiledString appendString:@"\n{\n\t"];

    if ([prefsInvoiceSize intValue] == 1)  [compiledString appendString:@"font: 9pt/13pt "];
    if ([prefsInvoiceSize intValue] == 2)  [compiledString appendString:@"font: 10pt/13pt "];
    if ([prefsInvoiceSize intValue] == 3)  [compiledString appendString:@"font: 11pt/14pt "];
    if ([prefsInvoiceSize intValue] == 4)  [compiledString appendString:@"font: 12pt/15pt "];
    if ([prefsInvoiceSize intValue] == 5)  [compiledString appendString:@"font: 13pt/16pt "];

    if ([prefsInvoiceBodyFont indexOfSelectedItem] == 0)  [compiledString appendString:@"georgia, \"times new roman\", sans-serif;\n"];
    if ([prefsInvoiceBodyFont indexOfSelectedItem] == 1)  [compiledString appendString:@"helvetica, arial, serif;\n"];
    if ([prefsInvoiceBodyFont indexOfSelectedItem] == 2)  [compiledString appendString:@"\"lucida grande\", serif;\n"];
    if ([prefsInvoiceBodyFont indexOfSelectedItem] == 3)  [compiledString appendString:@"palatino, \"times new roman\", sans-serif;\n"];
    if ([prefsInvoiceBodyFont indexOfSelectedItem] == 4)  [compiledString appendString:@"verdana, tahoma, serif;\n"];
        
    [compiledString appendString:@"\n\t"];
    [compiledString appendString:@"color: #111;"];
    [compiledString appendString:@"\n\t"];
    [compiledString appendString:@"margin: 5%;"];
    [compiledString appendString:@"\n\t"];
    [compiledString appendString:@"background-color: white;"];
    [compiledString appendString:@"\n}\n\n"];
    
    [compiledString appendString:@".session td, th"];
    [compiledString appendString:@"\n{\n\t"];
    [compiledString appendString:@"border-bottom: 1px solid #ccc;"];
    [compiledString appendString:@"\n\t"];
    [compiledString appendString:@"padding: 2px 12px;"];
    [compiledString appendString:@"\n}\n\n"];
    
    [compiledString appendString:@"h2 { "];
    
    if ([prefsInvoiceSize intValue] == 1)  [compiledString appendString:@"font: 16pt/22pt "];
    if ([prefsInvoiceSize intValue] == 2)  [compiledString appendString:@"font: 17pt/23pt "];
    if ([prefsInvoiceSize intValue] == 3)  [compiledString appendString:@"font: 18pt/24pt "];
    if ([prefsInvoiceSize intValue] == 4)  [compiledString appendString:@"font: 19pt/25pt "];
    if ([prefsInvoiceSize intValue] == 5)  [compiledString appendString:@"font: 20pt/26pt "];

    if ([prefsInvoiceHeaderFont indexOfSelectedItem] == 0)  [compiledString appendString:@"georgia, \"times new roman\", sans-serif;}\n"];
    if ([prefsInvoiceHeaderFont indexOfSelectedItem] == 1)  [compiledString appendString:@"helvetica, arial, serif;}\n"];
    if ([prefsInvoiceHeaderFont indexOfSelectedItem] == 2)  [compiledString appendString:@"\"lucida grande\", serif;}\n"];
    if ([prefsInvoiceHeaderFont indexOfSelectedItem] == 3)  [compiledString appendString:@"palatino, \"times new roman\", sans-serif;}\n"];
    if ([prefsInvoiceHeaderFont indexOfSelectedItem] == 4)  [compiledString appendString:@"verdana, tahoma, serif;}\n"];
    
    [compiledString appendString:@"table, td, th { text-align: left; }\n"];
    [compiledString appendString:@"th { font-weight: bold; }\n"];
    [compiledString appendString:@"table.session { margin: 10px 0 40px; }\n"];
    [compiledString appendString:@"#dent { margin: 15px; }\n\n"];
    
    [compiledString appendString:@"</style>\n\n</head>\n\n<body>\n\n"];
    [compiledString appendString:@"<h2>"];
    [compiledString appendString:[prefsInvoiceHeader stringValue]];
    [compiledString appendString:@"</h2>\n\n"];
    [compiledString appendString:@"<div id=\"dent\">\n\n\t"];
    
    //start job table
    [compiledString appendString:@"<table class=\"job\">\n\t\t"];
    
    [compiledString appendString:@"<tr><td>"];
    [compiledString appendString:[textJobName stringValue]];
    [compiledString appendString:@":</td>\t\t<td><b>"];
    [compiledString appendString:[[jobData objectAtIndex:jobNumber] objectForKey:@"jobName"]];
    [compiledString appendString:@"</b></td></tr>\n\t\t"];
    
    [compiledString appendString:@"<tr><td>"];
    [compiledString appendString:[textClientName stringValue]];
    [compiledString appendString:@":</td>\t\t<td><b>"];
    [compiledString appendString:[[jobData objectAtIndex:jobNumber] objectForKey:@"clientName"]];
    [compiledString appendString:@"</b></td></tr>\n\t\t"];
    
    [compiledString appendString:@"<tr><td>"];
    [compiledString appendString:[textRate stringValue]];
    [compiledString appendString:@":</td>\t\t<td><b>"];
    NSMutableString *hourlyRateString = [[[NSMutableString alloc] init] autorelease];
    [hourlyRateString appendString:[prefsMonetaryUnit stringValue]];
    [hourlyRateString appendString:[[[jobData objectAtIndex:jobNumber] objectForKey:@"hourlyRate"] stringValue]];
    [hourlyRateString appendString:[textHourSuffix stringValue]];
    [compiledString appendString:hourlyRateString];
    [compiledString appendString:@"</b></td></tr>\n\t\t"];
    
    [compiledString appendString:@"<tr><td>"];
    [compiledString appendString:[textTimeLogged stringValue]];
    [compiledString appendString:@":</td>\t\t<td><b>"];
    if ([prefsUpdateEveryRadio selectedRow] == 0)   [compiledString appendString:[tempTimeLogged getTimeString]];
    if ([prefsUpdateEveryRadio selectedRow] == 1)   [compiledString appendString:[tempTimeLogged getTimeString:NO]];
    if ([prefsUpdateEveryRadio selectedRow] == 2)   [compiledString appendString:[tempTimeLogged getFormattedTimeString:@"quarter"]];
    if ([prefsUpdateEveryRadio selectedRow] == 3)   [compiledString appendString:[tempTimeLogged getFormattedTimeString:@"half"]];
    if ([prefsUpdateEveryRadio selectedRow] == 4)   [compiledString appendString:[tempTimeLogged getFormattedTimeString:@"hour"]];
    [compiledString appendString:@"</b></td></tr>\n\t\t"];
    
    [compiledString appendString:@"<tr><td>"];
    [compiledString appendString:[textTotalDue stringValue]];
    [compiledString appendString:@":</td>\t\t<td><b>"];
    
    NSNumber *rate = [[jobData objectAtIndex:jobNumber] objectForKey:@"hourlyRate"];
            
    NSString *formatterString = @"second";
    if ([prefsUpdateEveryRadio selectedRow] == 1)   formatterString = @"minute";
    if ([prefsUpdateEveryRadio selectedRow] == 2)   formatterString = @"quarter";
    if ([prefsUpdateEveryRadio selectedRow] == 3)   formatterString = @"half";
    if ([prefsUpdateEveryRadio selectedRow] == 4)   formatterString = @"hour";
    
    NSMutableString *chargeNumberString = [[[NSMutableString alloc] init] autorelease];
    [chargeNumberString setString:[[NSNumber numberWithDouble:[tempTimeLogged calculateCharges:[rate doubleValue]
        format:formatterString]] stringValue]];
    
    [chargeNumberString setString:[self truncateChargeString:chargeNumberString]];
    
    NSMutableString *tempChargesString = [[[NSMutableString alloc] init] autorelease];
    [tempChargesString appendString:[prefsMonetaryUnit stringValue]];
    [tempChargesString appendString:chargeNumberString];
    
    [compiledString appendString:tempChargesString];
    
    [compiledString appendString:@"</table>\n\n"];
    //jobtable ended
    
    int i = 0;
    int count = [[[jobData objectAtIndex:jobNumber] objectForKey:@"sessionList"] count];
    
    if (count > 0)  
    {
        [compiledString appendString:@"<table class=\"session\">\n\t\t<tr>"];
        
        if ([prefsSessionDisplayNumber state])
        {
            [compiledString appendString:@"<th>"];
            [compiledString appendString:[textSessionNumber stringValue]];
            [compiledString appendString:@"</th>"];
        }
        if ([prefsSessionDisplaySDate state])
        {
            [compiledString appendString:@"<th>"];
            [compiledString appendString:[textSessionDate stringValue]];
            [compiledString appendString:@"</th>"];
        }
        
        if ([prefsSessionDisplaySTime state])
        {
            [compiledString appendString:@"<th>"];
            [compiledString appendString:[textSessionStart stringValue]];
            [compiledString appendString:@"</th>"];
        }
        
        if ([prefsSessionDisplayEDate state])
        {
            [compiledString appendString:@"<th>"];
            [compiledString appendString:[textSessionEndDate stringValue]];
            [compiledString appendString:@"</th>"];
        }
        
        if ([prefsSessionDisplayETime state])
        {
            [compiledString appendString:@"<th>"];
            [compiledString appendString:[textSessionEnd stringValue]];
            [compiledString appendString:@"</th>"];
        }
        
        if ([prefsSessionDisplayPause state])
        {
            [compiledString appendString:@"<th>"];
            [compiledString appendString:[textPauses stringValue]];
            [compiledString appendString:@"</th>"];
        }
        
        if ([prefsSessionDisplayTotalTime state])   
        {
            [compiledString appendString:@"<th>"];
            [compiledString appendString:[textSessionTime stringValue]];
            [compiledString appendString:@"</th>"];
        }
        
        if ([prefsSessionDisplayCharges state])     
        {
            [compiledString appendString:@"<th>"];
            [compiledString appendString:[textSessionCharges stringValue]];
            [compiledString appendString:@"</th>"];
        }
        
        if ([prefsSessionDisplaySummary state])
        {
            [compiledString appendString:@"<th>"];
            [compiledString appendString:[textSessionSummary stringValue]];
            [compiledString appendString:@"</th>"];
        }
        
        [compiledString appendString:@"</tr>"];
    }
    
    cuDateTime *tempInterval = [[[cuDateTime alloc] init] autorelease];
    NSMutableString *tempSessionChargeNumberString = [[[NSMutableString alloc] init] autorelease];
    NSMutableString *tempSessionChargesString = [[[NSMutableString alloc] init] autorelease];
    
    while (i < count)
    {
        [compiledString appendString:@"\n\t\t<tr>"];
        
        id theSession = [[[jobData objectAtIndex:jobNumber] objectForKey:@"sessionList"] objectAtIndex:i];
        
        [tempInterval setValues:[[theSession objectForKey:@"startDateTime"] getTimeInterval:[theSession objectForKey:@"endDateTime"]]];
        [tempInterval setValues:[tempInterval subtractInterval:[theSession objectForKey:@"pauseTime"]]];
        
        [tempSessionChargeNumberString setString:[[NSNumber numberWithDouble:[tempInterval calculateCharges:[rate doubleValue]
        format:formatterString]] stringValue]];
        [tempSessionChargeNumberString setString:[self truncateChargeString:tempSessionChargeNumberString]];
        [tempSessionChargesString appendString:[prefsMonetaryUnit stringValue]];
        [tempSessionChargesString appendString:tempSessionChargeNumberString];
        
        if ([prefsSessionDisplayNumber state])
        {
            [compiledString appendString:@"<td>"];
            [compiledString appendString:[[theSession objectForKey:@"sessionNumber"] stringValue]];
            [compiledString appendString:@"</td>\t"];
        }
        
        if ([prefsSessionDisplaySDate state])
        {
            [compiledString appendString:@"<td>"];
            [compiledString appendString:[[theSession objectForKey:@"startDateTime"] getDateString]];
            [compiledString appendString:@"</td>\t"];
        }
        
        if ([prefsSessionDisplaySTime state])
        {
            [compiledString appendString:@"<td>"];
            if ([formatterString isEqualTo:@"second"])      [compiledString appendString:[[theSession objectForKey:@"startDateTime"] getTimeString]];
            else if ([formatterString isEqualTo:@"minute"]) [compiledString appendString:[[theSession objectForKey:@"startDateTime"] getTimeString:NO]];
            else [compiledString appendString:[[theSession objectForKey:@"startDateTime"] getFormattedTimeString:formatterString]];             
            [compiledString appendString:@"</td>\t"];
        }
        
        if ([prefsSessionDisplayEDate state])
        {   
            [compiledString appendString:@"<td>"];
            [compiledString appendString:[[theSession objectForKey:@"endDateTime"] getDateString]];
            [compiledString appendString:@"</td>\t"];
        }
        
        if ([prefsSessionDisplayETime state])
        {
            [compiledString appendString:@"<td>"];
            if ([formatterString isEqualTo:@"second"])      [compiledString appendString:[[theSession objectForKey:@"endDateTime"] getTimeString]];
            else if ([formatterString isEqualTo:@"minute"]) [compiledString appendString:[[theSession objectForKey:@"endDateTime"] getTimeString:NO]];
            else [compiledString appendString:[[theSession objectForKey:@"endDateTime"] getFormattedTimeString:formatterString]];   
            [compiledString appendString:@"</td>\t"];
        }
        
        if ([prefsSessionDisplayPause state])
        {
            [compiledString appendString:@"<td>"];
            cuDateTime *tempPauseTime = [[[cuDateTime alloc] init] autorelease];
            [tempPauseTime setValues:[theSession objectForKey:@"pauseTime"]];
            [tempPauseTime setValues:[tempPauseTime addInterval:[theSession objectForKey:@"tempPauseTime"]]];
            [compiledString appendString:[tempPauseTime getTimeString]];
            [compiledString appendString:@"</td>\t"];
        }
        
        if ([prefsSessionDisplayTotalTime state])
        {
            [compiledString appendString:@"<td>"];
            
            if ([formatterString isEqualTo:@"second"])      [compiledString appendString:[tempInterval getTimeString]];
            else if ([formatterString isEqualTo:@"minute"]) [compiledString appendString:[tempInterval getTimeString:NO]];
            else [compiledString appendString:[tempInterval getFormattedTimeString:formatterString]];
            
            [compiledString appendString:@"</td>\t"];
        }
        
        if ([prefsSessionDisplayCharges state])
        {
            [compiledString appendString:@"<td>"];
            [compiledString appendString:tempSessionChargesString];
            [tempSessionChargesString setString:@""];
            [compiledString appendString:@"</td>\t"];
        }
        
        if ([prefsSessionDisplaySummary state])
        {
            [compiledString appendString:@"<td>"];
            [compiledString appendString:[theSession objectForKey:@"sessionSummary"]];
            [compiledString appendString:@"</td>\t"];
        }
        
        [compiledString appendString:@"</tr>"];
        
        i++;
    }

    if (count > 0)  [compiledString appendString:@"</table>"];
    [compiledString appendString:@"</div>\n\n</body>\n\n</html>\n\n"];

    return compiledString;
}

- (IBAction)menuSave:(id)sender
{
    [self saveLoop];
}

- (IBAction)menuSendEmail:(id)sender
{
    NSWorkspace *workSpace = [NSWorkspace sharedWorkspace];
    [workSpace openURL:[NSURL URLWithString:@"mailto:khronos@enure.net"]];
}

- (IBAction)menuVisitWebsite:(id)sender
{
    NSWorkspace *workSpace = [NSWorkspace sharedWorkspace];
    [workSpace openURL:[NSURL URLWithString:@"http://khronos.enure.net/"]];
}

- (IBAction)menuCheckForUpdates:(id)sender
{
    NSString *versionString = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://khronos.enure.net/"]];
    if ([versionString length] < 1 || [versionString length] > 5)
    {
        NSRunAlertPanel([textArr stringValue], [textProblemConnect stringValue], @"OK", nil, nil);
    }
    else if ([versionString doubleValue] > 1.22)
    {
        NSRunAlertPanel([textRejoice stringValue], [textNewVersion stringValue], @"OK", nil, nil);
    }
    else if ([versionString doubleValue] == 1.22)
    {
        NSRunAlertPanel([textYeargh stringValue], [textUpToDate stringValue], @"OK", nil, nil);
    }
}
@end