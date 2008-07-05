//
//  CUPreferenceController.m
//  Khronos
//
//  Created by Gautam Dey on 6/29/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "CUPreferenceController.h"
#import <assert.h>

// These are the General Preferences.
NSString *const CUPreferencesAskDeleteProject    = @"Delete Project";
NSString *const CUPreferencesAskDeleteSession    = @"Delete Session" ;
NSString *const CUPreferencesAutoSaveTime        = @"Auto Save Time";
NSString *const CUPreferencesAutoDeleteSettings  = @"Delete Settings";
NSString *const CUPreferencesMonetaryUnit        = @"Monetary Unit";
NSString *const CUPreferencesClockSetting        = @"24 Hour Clock";

#define CU_PREF_CLOCK_12 12
#define CU_PREF_CLOCK_24 24

NSString *const CUPreferencesUpdateTime         = @"Update time";
#define CU_PREF_UPTIME_SEC   0
#define CU_PREF_UPTIME_MIN1  1
#define CU_PREF_UPTIME_MIN15 15
#define CU_PREF_UPTIME_MIN30 30
#define CU_PREF_UPTIME_MIN60 60

/*** Which columns in the Project table should be shown. ***/
// CUPreferencesProjectDisplay is a dictonary to hold the options for the Project Table.
NSString *const CUPreferencesProjectDisplay           = @"Project Display";
NSString *const CUPreferencesProjectDisplayNumber     = @"Number";
#define CU_PREF_PRJDSP_TAG_NUMBER     0
NSString *const CUPreferencesProjectDisplayName       = @"Name";
#define CU_PREF_PRJDSP_TAG_NAME       1
NSString *const CUPreferencesProjectDisplayClient     = @"Client";
#define CU_PREF_PRJDSP_TAG_CLIENT     2
NSString *const CUPreferencesProjectDisplayRate       = @"Rate";
#define CU_PREF_PRJDSP_TAG_RATE       3
NSString *const CUPreferencesProjectDisplayTime       = @"Time";
#define CU_PREF_PRJDSP_TAG_TIME       4
NSString *const CUPreferencesProjectDisplayCharges    = @"Charges";
#define CU_PREF_PRJDSP_TAG_CHARGES    5
#define CU_PREF_PRJDSP_MAX_TAG_NUMBER 5

/*** Which columns in the Session Table should be shown. ***/
// CUPreferencesSessionDisplay is a dictonary to hold the options for the Session Table.
NSString *const CUPreferencesSessionDisplay             = @"Sessions Display";
NSString *const CUPreferencesSessionDisplayStartDate    = @"Start Date";
#define CU_PREF_SESDSP_TAG_STARTDATE  0 
NSString *const CUPreferencesSessionDisplayEndDate      = @"End Date";
#define CU_PREF_SESDSP_TAG_ENDDATE    1
NSString *const CUPreferencesSessionDisplayStartTime    = @"Start Time";
#define CU_PREF_SESDSP_TAG_STARTTIME  2
NSString *const CUPreferencesSessionDisplayEndTime      = @"End Time";
#define CU_PREF_SESDSP_TAG_ENDTIME    3
NSString *const CUPreferencesSessionDisplayPauseTime    = @"Pause Time";
#define CU_PREF_SESDSP_TAG_PAUSETIME  4
NSString *const CUPreferencesSessionDisplayTotalTime    = @"Total Time";
#define CU_PREF_SESDSP_TAG_TOTALTIME  5
NSString *const CUPreferencesSessionDisplayCharges      = @"Charges";
#define CU_PREF_SESDSP_TAG_CHARGES    6
NSString *const CUPreferencesSessionDisplaySummary      = @"Summary";
#define CU_PREF_SESDSP_TAG_SUMMARY    7
NSString *const CUPreferencesSessionDisplayNumber      = @"Number";
#define CU_PREF_SESDSP_TAG_NUMBER     8
#define CU_PREF_SESDSP_MAX_TAG_NUMBER 8

/*** Options for the menu bar ***/
// CUPreferencesMenuDisplay dictonary to hold the options for the menu bar.
NSString *const CUPreferencesMenuDisplay                = @"Menubar Display";

NSString *const CUPreferencesMenuDisplayPauseButton     = @"Pause Button";
#define CU_PREF_MENUDSP_TAG_PAUSEBUTTON     0
NSString *const CUPreferencesMenuDisplayRecrodingButton = @"Recording Button";
#define CU_PREF_MENUDSP_TAG_RECRODINGBUTTON 1
NSString *const CUPreferencesMenuDisplayProjectList     = @"Projects List";
#define CU_PREF_MENUDSP_TAG_PROJECTLIST     2
NSString *const CUPreferencesMenuDisplayTotalTime       = @"Total Time";
#define CU_PREF_MENUDSP_TAG_TOTALTIME       3
NSString *const CUPreferencesMenuDisplayCharges         = @"Charges";
#define CU_PREF_MENUDSP_TAG_CHARGES         4
#define CU_PREF_MENUDSP_MAX_TAG_NUMBER      4


/*** Options for Invoice ***/
// CUPreferecncesInvoice is a dictonary to hold the options for creating the Invoice.
NSString *const CUPreferencesInvoice               = @"Invoice";
NSString *const CUPreferencesInvoiceIndexTitle     = @"Index Title";
NSString *const CUPreferencesInvoiceIndexHeading   = @"Index Heading";
NSString *const CUPreferencesInvoiceLinkHelp       = @"Link Help";
NSString *const CUPreferencesInvoiceTitle          = @"Title";
NSString *const CUPreferencesInvoiceHeading        = @"Heading";
NSString *const CUPreferencesInvoiceBodyFont       = @"Body Font";
NSString *const CUPreferencesInvoiceHeadingFont    = @"Headings Font";

@implementation CUPreferenceController

- (id)init
{
    if(![super initWithWindowNibName:@"Preferences"])
        return nil;
    return self;
}

- (void) updatePreferences
{
    NSDictionary *columns;
    int i;
    NSLog(@"Preferences NIB has loaded.");
    
    // Set the clock to the default.
    
    if([self is24HourClock]) {
        NSLog(@"Setting clock to 24 hour mode.");
        BOOL success = [clockSettings selectCellWithTag:CU_PREF_CLOCK_24];
        if( !success) NSLog(@"Failed to select cell with tag %d",CU_PREF_CLOCK_24);
    } else {
        NSLog(@"Setting clock to 12 hour mode.");
        BOOL success = [clockSettings selectCellWithTag:CU_PREF_CLOCK_12];
        if( !success ) NSLog(@"Failed to select cell with tag %d",CU_PREF_CLOCK_12);
    }
    
    NSLog(@"Setting update to every %d minutes.",[self updateTimeEvery]);
    [updateTime selectCellWithTag:[self updateTimeEvery]];
    NSLog(@"Setting monetaryUnit to %@",[self monetaryUnit]);
    [aMonetaryUnit setStringValue:[self monetaryUnit]];
    
    // Project Table Settings
    NSLog(@"Setting checkboxes for Project table.");
    columns = [self projectTableColumns];
    for(i=0; i <= CU_PREF_PRJDSP_MAX_TAG_NUMBER; i++){
        id cell = [projectTableColumns cellWithTag:i];
        [cell setState:[[columns objectForKey:[self projectTableColumnNameForTag:i]] boolValue]];
    }
    // Session Table Settings.
    NSLog(@"Setting checkboxes for Sesison Table.");
    columns = [self sessionTableColumns];
    for(i=0; i <= CU_PREF_SESDSP_MAX_TAG_NUMBER; i++){
        id cell = [sessionTableColumns cellWithTag:i];
        [cell setState:[[columns objectForKey:[self sessionTableColumnNameForTag:i]] boolValue]];
    }
    
    
    // Invoice Settings
    NSLog(@"Seeting the text for Invoice");
    [indexTitle setStringValue:[self invoiceIndexTitle]];
    [indexHeading setStringValue:[self invoiceIndexHeading]];
    [linkHelp setStringValue:[self invoiceLinkHelp]];
    [invoiceTitle setStringValue:[self invoiceTitle]];
    [invoiceHeading setStringValue:[self invoiceHeading]];
    [bodyFont setObjectValue:[self invoiceBodyFont]];
    [headingFont setObjectValue:[self invoiceHeadingFont]];
    
}
- (void) windowDidLoad
{
    [self updatePreferences];
    
}
#pragma mark General Options
- (BOOL) askDeleteProject
{
    NSLog(@"Return the defaults value for askDeleteProject option.");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:CUPreferencesAskDeleteProject];
}

- (BOOL) askDeleteSession
{
    NSLog(@"Return the defaults value for askDeleteSession option.");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:CUPreferencesAskDeleteSession];
}

- (BOOL) autoSaveTime
{
    NSLog(@"Returning the defaults value for autoSaveTime.");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:CUPreferencesAutoSaveTime];
}

- (BOOL) autoDeleteSettings
{
    NSLog(@"Returning the defaults value for autoDeleteSettings.");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:CUPreferencesAutoDeleteSettings];
}

- (BOOL) is24HourClock
{
    NSLog(@"Returning the default value for 24 hour clock.");
    return [[NSUserDefaults standardUserDefaults] boolForKey:CUPreferencesClockSetting];
}

-(int) updateTimeEvery
{
    NSLog(@"Returning the number of minutes that we update.");
    return [[NSUserDefaults standardUserDefaults] integerForKey:CUPreferencesUpdateTime];
}
- (NSString *)monetaryUnit
{
    NSLog(@"Returning the default value for monetary unit");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults stringForKey:CUPreferencesMonetaryUnit];
}


#pragma mark Project Table Options
- (NSDictionary *)projectTableColumns
{
    NSLog(@"Returning the default value for the project columns.");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults dictionaryForKey:CUPreferencesProjectDisplay];
}

- (NSString *)projectTableColumnNameForTag:(int)tag
{
    NSString *column = nil;
    switch (tag) {
        case CU_PREF_PRJDSP_TAG_NAME:
            column = CUPreferencesProjectDisplayName;
            break;
        case CU_PREF_PRJDSP_TAG_NUMBER:
            column = CUPreferencesProjectDisplayNumber;
            break;
        case CU_PREF_PRJDSP_TAG_CLIENT:
            column = CUPreferencesProjectDisplayClient;
            break;
        case CU_PREF_PRJDSP_TAG_RATE:
            column = CUPreferencesProjectDisplayRate;
            break;
        case CU_PREF_PRJDSP_TAG_TIME:
            column = CUPreferencesProjectDisplayTime;
            break;
        case CU_PREF_PRJDSP_TAG_CHARGES:
            column = CUPreferencesProjectDisplayCharges;
            break;
        default:
            // do nothing
            break;
    };
    return column;
}

- (void)setProjectTableColumn:(NSString *)column display:(BOOL)yn
{
    NSLog(@"Getting Project dictonary.");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *columns = [defaults dictionaryForKey:CUPreferencesProjectDisplay] ;
    NSMutableDictionary *change_columns = [columns mutableCopy];
    if(!change_columns)
    {
        NSLog(@"We did not get back a dictonary for '%@'",CUPreferencesSessionDisplay);
        return;
    }
    [change_columns setObject:[NSNumber numberWithBool:yn] forKey:column];
    [defaults setObject:change_columns forKey:CUPreferencesProjectDisplay];
}

- (BOOL)displayProjectTableColumn:(NSString *)column
{
    NSLog(@"Getting Value for Project column %@",column);
    NSDictionary *columns = [self projectTableColumns];
    return [[columns objectForKey:column] boolValue];
}

#pragma mark Session Table Options
- (NSDictionary *)sessionTableColumns
{
    NSLog(@"Returning the default value for the session columns.");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults dictionaryForKey:CUPreferencesSessionDisplay];
}

- (NSString *)sessionTableColumnNameForTag:(int)tag
{
    NSString *column = nil;
    switch (tag) {
        case CU_PREF_SESDSP_TAG_STARTDATE:
            column = CUPreferencesSessionDisplayStartDate;
            break;
        case CU_PREF_SESDSP_TAG_ENDDATE:
            column = CUPreferencesSessionDisplayEndDate;
            break;
        case CU_PREF_SESDSP_TAG_STARTTIME:
            column = CUPreferencesSessionDisplayStartTime;
            break;
        case CU_PREF_SESDSP_TAG_ENDTIME:
            column = CUPreferencesSessionDisplayEndTime;
            break;
        case CU_PREF_SESDSP_TAG_PAUSETIME:
            column = CUPreferencesSessionDisplayPauseTime;
            break;
        case CU_PREF_SESDSP_TAG_TOTALTIME:
            column = CUPreferencesSessionDisplayTotalTime;
            break;
        case CU_PREF_SESDSP_TAG_CHARGES:
            column = CUPreferencesSessionDisplayCharges;
            break;
        case CU_PREF_SESDSP_TAG_SUMMARY:
            column = CUPreferencesSessionDisplaySummary;
            break;
        case CU_PREF_SESDSP_TAG_NUMBER:
            column = CUPreferencesSessionDisplayNumber;
            break;
        default:
            // do nothing
            break;
    };
    return column;
}

- (void)setSessionTableColumn:(NSString *)column display:(BOOL)yn
{

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *columns = [[defaults dictionaryForKey:CUPreferencesSessionDisplay] mutableCopy];
    if(!columns)
    {
        NSLog(@"We did not get back a dictonary for '%@'",CUPreferencesSessionDisplay);
        return;
    }
        NSLog(@"Setting the display of Session Table Column '%@' to %@", column, (yn == YES)?@"Yes":@"No");
    [columns setObject:[NSNumber numberWithBool:yn] forKey:column];
    [defaults setObject:columns forKey:CUPreferencesSessionDisplay];
}

- (BOOL)displaySessionTableColumn:(NSString *)column
{
    NSLog(@"Getting value for Session Table column %@", column);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *columns = [defaults dictionaryForKey:CUPreferencesSessionDisplay];
    return [[columns objectForKey:column] boolValue];
}

#pragma mark Invoice Options
- (NSString *)invoiceIndexTitle
{
    NSLog(@"Return the default value for the invoice Index Title.");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *invoice = [defaults dictionaryForKey:CUPreferencesInvoice];
    return [invoice objectForKey:CUPreferencesInvoiceIndexTitle];
}

- (NSString *)invoiceIndexHeading
{
    NSLog(@"Return the default value for the invoice index heading.");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *invoice = [defaults dictionaryForKey:CUPreferencesInvoice];
    return [invoice objectForKey:CUPreferencesInvoiceIndexHeading];
}

- (NSString *)invoiceLinkHelp
{
    NSLog(@"Return the default value for the invoice index link help.");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *invoice = [defaults dictionaryForKey:CUPreferencesInvoice];
    return [invoice objectForKey:CUPreferencesInvoiceLinkHelp];
}

- (NSString *)invoiceTitle
{
    NSLog(@"Return the default value for the invoice title.");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *invoice = [defaults dictionaryForKey:CUPreferencesInvoice];
    return [invoice objectForKey:CUPreferencesInvoiceTitle];
}

- (NSString *)invoiceHeading
{
    NSLog(@"Return the default value for the invoice heading.");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *invoice = [defaults dictionaryForKey:CUPreferencesInvoice];
    return [invoice objectForKey:CUPreferencesInvoiceHeading];
}

- (NSFont *)invoiceHeadingFont
{
    NSLog(@"Return the default value for the invoice heading.");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *invoice = [defaults dictionaryForKey:CUPreferencesInvoice];    
    NSData *fontAsData = [invoice objectForKey:CUPreferencesInvoiceHeadingFont];
    return [NSKeyedUnarchiver unarchiveObjectWithData:fontAsData];
}

- (NSFont *)invoiceBodyFont
{
    NSLog(@"Return the default value for the invoice heading.");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *invoice = [defaults dictionaryForKey:CUPreferencesInvoice];    
    NSData *fontAsData = [invoice objectForKey:CUPreferencesInvoiceBodyFont];
    return [NSKeyedUnarchiver unarchiveObjectWithData:fontAsData];
}


#pragma mark Menu Options
- (NSDictionary *)menuTableColumns
{
    NSLog(@"Returning the default value for the menu columns.");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults dictionaryForKey:CUPreferencesMenuDisplay];
}

- (NSString *)menuTableColumnNameForTag:(int)tag
{
    NSString *column = nil;
    switch (tag) {
        case CU_PREF_MENUDSP_TAG_PAUSEBUTTON:
            column = CUPreferencesMenuDisplayPauseButton;
            break;
        case CU_PREF_MENUDSP_TAG_RECRODINGBUTTON:
            column = CUPreferencesMenuDisplayRecrodingButton;
            break;
        case CU_PREF_MENUDSP_TAG_PROJECTLIST:
            column = CUPreferencesMenuDisplayProjectList;
            break;
        case CU_PREF_MENUDSP_TAG_TOTALTIME:
            column = CUPreferencesMenuDisplayTotalTime;
            break;
        case CU_PREF_MENUDSP_TAG_CHARGES:
            column = CUPreferencesMenuDisplayCharges;
        default:
            // do nothing
            break;
    };
    return column;
}
- (void)setMenuTableColumn:(NSString *)column display:(BOOL)yn
{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *columns = [[defaults dictionaryForKey:CUPreferencesMenuDisplay] mutableCopy];
    if(!columns)
    {
        NSLog(@"We did not get back a dictonary for '%@'",CUPreferencesMenuDisplay);
        return;
    }
    NSLog(@"Setting the display of Menu Table Column '%@' to %@", column, (yn == YES)?@"Yes":@"No");
    [columns setObject:[NSNumber numberWithBool:yn] forKey:column];
    [defaults setObject:columns forKey:CUPreferencesMenuDisplay];
}

- (BOOL)displayMenuTableColumn:(NSString *)column
{
    NSLog(@"Getting value for Menu Table column %@", column);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *columns = [defaults dictionaryForKey:CUPreferencesMenuDisplay];
    return [[columns objectForKey:column] boolValue];
}

#pragma mark Actions

- (IBAction)resetPreferences:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"Deleting Preferences.");
    [defaults removeObjectForKey:CUPreferencesAskDeleteProject];
    [defaults removeObjectForKey:CUPreferencesAskDeleteSession];
    [defaults removeObjectForKey:CUPreferencesAutoSaveTime];
    [defaults removeObjectForKey:CUPreferencesMonetaryUnit];
    [defaults removeObjectForKey:CUPreferencesClockSetting];
    [defaults removeObjectForKey:CUPreferencesUpdateTime];
    [defaults removeObjectForKey:CUPreferencesInvoice];
    [defaults removeObjectForKey:CUPreferencesProjectDisplay];
    [defaults removeObjectForKey:CUPreferencesSessionDisplay];
    [defaults removeObjectForKey:CUPreferencesMenuDisplay];
    NSLog(@"Refreshing the display.");
    [self updatePreferences];
}
#pragma mark General Options Actions

- (IBAction)changeAskDeleteProject:(id)sender
{
    int state = [askDeleteProject state];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:state  forKey:CUPreferencesAskDeleteProject];
}

-(IBAction)changeAskDeleteSession:(id)sender
{
    int state = [askDeleteSession state];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:state  forKey:CUPreferencesAskDeleteSession];
}

-(IBAction)changeAutoSaveTime:(id)sender
{
    int state = [autoSaveTime state];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:state forKey:CUPreferencesAutoSaveTime];
}

-(IBAction) changeAutoDeleteSetting:(id)sender
{
    int state = [autoDeleteSettings state];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:state forKey:CUPreferencesAutoDeleteSettings];
}

-(IBAction) changeClock:(id)sender
{
    BOOL state; 
    state = ([sender selectedTag] == CU_PREF_CLOCK_24);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    assert(defaults);
    NSLog(@"Setting clock to %@ hour mode.",state?@"24":@"12");
    [defaults setBool:state forKey:CUPreferencesClockSetting];
    
}

- (IBAction) changeUpdateTime:(id)sender
{
    int selectedTag = [sender  selectedTag];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:selectedTag forKey:CUPreferencesUpdateTime];
}

- (IBAction) changeMonetaryUnit:(id)sender
{
    NSString *value = [aMonetaryUnit stringValue];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:value forKey:CUPreferencesMonetaryUnit];
}

#pragma mark Project Table Options Actions
- (IBAction) changeProjectTableDisplay:(id)sender
{
    id checkBox = [sender selectedCell];
    int tag = [checkBox tag];
    NSString *column = [self projectTableColumnNameForTag:tag];
    if(column){
        NSLog(@"Setting Project Table Column %@ default value.",column);
        [self setProjectTableColumn:column display:[checkBox state]];
    }
}

#pragma mark Session Table Options Actions
- (IBAction) changeSessionTableDisplay:(id)sender
{
    id checkBox = [sender selectedCell];
    int tag = [checkBox tag];
    NSString *column = [self sessionTableColumnNameForTag:tag];
    if(column){
        NSLog(@"Setting Session Table Column %@ default value.",column);
        [self setSessionTableColumn:column display:[checkBox state]];
    }
}

#pragma mark Invoice Options Actions
- (IBAction) changeInvoiceIndexTitle:(id)sender
{
    NSString *value = [indexTitle stringValue];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *columns = [[defaults objectForKey:CUPreferencesInvoice] mutableCopy];
    [columns setObject:value forKey:CUPreferencesInvoiceIndexTitle];
    [defaults setObject:columns forKey:CUPreferencesInvoice];
}

-(IBAction) changeInvoiceIndexHeading:(id)sender
{
    NSString *value = [indexHeading stringValue];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *columns = [[defaults objectForKey:CUPreferencesInvoice] mutableCopy];
    [columns setObject:value forKey:CUPreferencesInvoiceIndexHeading];
    [defaults setObject:columns forKey:CUPreferencesInvoice];
}

- (IBAction) changeInvoiceTitle:(id)sender
{
    NSString *value = [invoiceTitle stringValue];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *columns = [[defaults objectForKey:CUPreferencesInvoice] mutableCopy];
    [columns setObject:value forKey:CUPreferencesInvoiceTitle];
    [defaults setObject:columns forKey:CUPreferencesInvoice];
}

-(IBAction) changeInvoiceLinkHelp:(id)sender
{
    NSString *value = [linkHelp stringValue];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *columns = [[defaults objectForKey:CUPreferencesInvoice] mutableCopy];
    [columns setObject:value forKey:CUPreferencesInvoiceLinkHelp];
    [defaults setObject:columns forKey:CUPreferencesInvoice];
}

-(IBAction) changeInvoiceHeading:(id)sender
{
    NSString *value = [invoiceHeading stringValue];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *columns = [[defaults objectForKey:CUPreferencesInvoice] mutableCopy];
    [columns setObject:value forKey:CUPreferencesInvoiceHeading];
    [defaults setObject:columns forKey:CUPreferencesInvoice];
}

-(IBAction) showFontPanelForHeading:(id)sender
{
    
    NSFont *font = [self invoiceHeadingFont];
    [[NSFontManager sharedFontManager] setSelectedFont:font
                                            isMultiple:NO];
        NSLog(@"Changing the font manager action to changeInvoiceHeadingFont:");
    [[NSFontManager sharedFontManager] setAction:@selector(changeInvoiceHeadingFont:)];
    [[NSFontManager sharedFontManager] orderFrontFontPanel:self];
}
-(IBAction) showFontPanelForBody:(id)sender
{
    
    NSFont *font = [self invoiceBodyFont];
    [[NSFontManager sharedFontManager] setSelectedFont:font
                                            isMultiple:NO];
    NSLog(@"Changing the font manager action to changeInvoiceBodyFont:");
    [[NSFontManager sharedFontManager] setAction:@selector(changeInvoiceBodyFont:)];
    [[NSFontManager sharedFontManager] orderFrontFontPanel:self];
}


-(IBAction) changeInvoiceHeadingFont:(id)sender
{
  /* This action will open up the font panel. */
    NSFontManager *aFontManager = sender;
    NSFont *aFont = [aFontManager convertFont:[self invoiceHeadingFont]];
    NSLog(@"Changed Invoice Heading Font called with font name '%@' and size '%.0f'",[aFont fontName], [aFont pointSize]);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *columns = [[defaults objectForKey:CUPreferencesInvoice] mutableCopy];
    NSData *headingFontAsData = [NSKeyedArchiver archivedDataWithRootObject:aFont];
    [columns setObject:headingFontAsData forKey:CUPreferencesInvoiceHeadingFont];
    [defaults setObject:columns forKey:CUPreferencesInvoice];
    [self updatePreferences];

}

-(IBAction) changeInvoiceBodyFont:(id)sender
{
    /* This action will open up the font panel. */
    NSFontManager *aFontManager = sender;
    NSFont *aFont = [aFontManager convertFont:[self invoiceHeadingFont]];
    NSLog(@"Changed Invoice Body Font called with font name '%@' and size '%.0f'",[aFont fontName], [aFont pointSize]);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *columns = [[defaults objectForKey:CUPreferencesInvoice] mutableCopy];
    NSData *bodyFontAsData = [NSKeyedArchiver archivedDataWithRootObject:aFont];
    [columns setObject:bodyFontAsData forKey:CUPreferencesInvoiceBodyFont];
    [defaults setObject:columns forKey:CUPreferencesInvoice];
    [self updatePreferences];

}

#pragma mark Menu Options Actions
- (IBAction) changeMenuTableDisplay:(id)sender
{
    id checkBox = [sender selectedCell];
    int tag = [checkBox tag];
    NSString *column = [self menuTableColumnNameForTag:tag];
    if(column){
        NSLog(@"Setting Menu Table Column %@ default value.",column);
        [self setMenuTableColumn:column display:[checkBox state]];
    }
}
@end
