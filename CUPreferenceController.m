//
//  CUPreferenceController.m
//  Khronos
//
//  Created by Gautam Dey on 6/29/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "CUPreferenceController.h"
#import <assert.h>
#import "CUPreferences.h"



#define CU_PREF_CLOCK_12 12
#define CU_PREF_CLOCK_24 24


#define CU_PREF_UPTIME_SEC   0
#define CU_PREF_UPTIME_MIN1  1
#define CU_PREF_UPTIME_MIN15 15
#define CU_PREF_UPTIME_MIN30 30
#define CU_PREF_UPTIME_MIN60 60

/*** Which columns in the Project table should be shown. ***/
// CUPreferencesProjectDisplay is a dictonary to hold the options for the Project Table.

#define CU_PREF_PRJDSP_TAG_NUMBER     0
#define CU_PREF_PRJDSP_TAG_NAME       1
#define CU_PREF_PRJDSP_TAG_CLIENT     2
#define CU_PREF_PRJDSP_TAG_RATE       3
#define CU_PREF_PRJDSP_TAG_TIME       4
#define CU_PREF_PRJDSP_TAG_CHARGES    5
#define CU_PREF_PRJDSP_MAX_TAG_NUMBER 5

/*** Which columns in the Session Table should be shown. ***/
// CUPreferencesSessionDisplay is a dictonary to hold the options for the Session Table.
#define CU_PREF_SESDSP_TAG_STARTDATE  0 
#define CU_PREF_SESDSP_TAG_ENDDATE    1
#define CU_PREF_SESDSP_TAG_STARTTIME  2
#define CU_PREF_SESDSP_TAG_ENDTIME    3
#define CU_PREF_SESDSP_TAG_PAUSETIME  4
#define CU_PREF_SESDSP_TAG_TOTALTIME  5
#define CU_PREF_SESDSP_TAG_CHARGES    6
#define CU_PREF_SESDSP_TAG_SUMMARY    7
#define CU_PREF_SESDSP_TAG_NUMBER     8
#define CU_PREF_SESDSP_MAX_TAG_NUMBER 8

/*** Options for the menu bar ***/
// CUPreferencesMenuDisplay dictonary to hold the options for the menu bar.

#define CU_PREF_MENUDSP_TAG_PAUSEBUTTON     0
#define CU_PREF_MENUDSP_TAG_RECRODINGBUTTON 1
#define CU_PREF_MENUDSP_TAG_PROJECTLIST     2
#define CU_PREF_MENUDSP_TAG_TOTALTIME       3
#define CU_PREF_MENUDSP_TAG_CHARGES         4
#define CU_PREF_MENUDSP_MAX_TAG_NUMBER      4



@implementation CUPreferenceController

- (id)init
{
    if(![super initWithWindowNibName:@"Preferences"])
        return nil;
    preferences = [[CUPreferences init] alloc];
    return self;
}

- (void) dealloc
{
    [preferences release];
    [super dealloc];
}
- (void) updatePreferences
{
    NSDictionary *columns;
    int i;
    NSLog(@"Preferences NIB has loaded.");
    
    // Set the clock to the default.
    
    if([preferences is24HourClock]) {
        NSLog(@"Setting clock to 24 hour mode.");
        BOOL success = [clockSettings selectCellWithTag:CU_PREF_CLOCK_24];
        if( !success) NSLog(@"Failed to select cell with tag %d",CU_PREF_CLOCK_24);
    } else {
        NSLog(@"Setting clock to 12 hour mode.");
        BOOL success = [clockSettings selectCellWithTag:CU_PREF_CLOCK_12];
        if( !success ) NSLog(@"Failed to select cell with tag %d",CU_PREF_CLOCK_12);
    }
    
    NSLog(@"Setting update to every %d minutes.",[preferences updateTimeEvery]);
    [updateTime selectCellWithTag:[preferences updateTimeEvery]];
    NSLog(@"Setting monetaryUnit to %@",[preferences monetaryUnit]);
    [aMonetaryUnit setStringValue:[preferences monetaryUnit]];
    
    // Project Table Settings
    NSLog(@"Setting checkboxes for Project table.");
    columns = [preferences columnsForTable:CUPreferencesProjectDisplay];
    for(i=0; i <= CU_PREF_PRJDSP_MAX_TAG_NUMBER; i++){
        id cell = [projectTableColumns cellWithTag:i];
        [cell setState:[[columns objectForKey:[self projectTableColumnNameForTag:i]] boolValue]];
    }
    // Session Table Settings.
    NSLog(@"Setting checkboxes for Sesison Table.");
    columns = [preferences columnsForTable:CUPreferencesSessionDisplay];
    for(i=0; i <= CU_PREF_SESDSP_MAX_TAG_NUMBER; i++){
        id cell = [sessionTableColumns cellWithTag:i];
        [cell setState:[[columns objectForKey:[self sessionTableColumnNameForTag:i]] boolValue]];
    }
    // Menu Table Settings.
    NSLog(@"Setting checkboxes for Menu Table.");
    columns = [preferences columnsForTable:CUPreferencesMenuDisplay];
    for(i=0; i <= CU_PREF_MENUDSP_MAX_TAG_NUMBER; i++){
        id cell = [menuTableColumns cellWithTag:i];
        [cell setState:[[columns objectForKey:[self menuTableColumnNameForTag:i]] boolValue]];
    }
    
    // Invoice Settings
    NSLog(@"Seeting the text for Invoice");
    [indexTitle setStringValue:[preferences invoiceIndexTitle]];
    [indexHeading setStringValue:[preferences invoiceIndexHeading]];
    [linkHelp setStringValue:[preferences invoiceLinkHelp]];
    [invoiceTitle setStringValue:[preferences invoiceTitle]];
    [invoiceHeading setStringValue:[preferences invoiceHeading]];
    [bodyFont setObjectValue:[preferences invoiceBodyFont]];
    [headingFont setObjectValue:[preferences invoiceHeadingFont]];
    
}
- (void) windowDidLoad
{
    [self updatePreferences];
    
}

#pragma mark Project Table Options
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

#pragma mark Session Table Options
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


#pragma mark Menu Options
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
#pragma mark Actions

- (IBAction)resetPreferences:(id)sender 
{
    [CUPreferences resetPreferences];
    NSLog(@"Refreshing the display.");
    [self updatePreferences];
}
#pragma mark General Options Actions

- (IBAction)changeAskDeleteProject:(id)sender
{
    [preferences setAskDeleteProject:[askDeleteProject state]];
}

-(IBAction)changeAskDeleteSession:(id)sender
{
    [preferences setAskDeleteSession:[askDeleteSession state]];
}

-(IBAction)changeAutoSaveTime:(id)sender
{
    [preferences setAutoSaveTime:[autoSaveTime state]];
}

-(IBAction) changeAutoDeleteSetting:(id)sender
{
    [preferences setAutoDeleteSettings:[autoDeleteSettings state]];
}

-(IBAction) changeClock:(id)sender
{
    [preferences setIs24HourClock:([sender selectedTag] == CU_PREF_CLOCK_24)];
}

- (IBAction) changeUpdateTime:(id)sender
{
    [preferences setUpdateTimeEvery:[sender selectedTag]];
}

- (IBAction) changeMonetaryUnit:(id)sender
{
    [preferences setMonetaryUnit:[aMonetaryUnit stringValue]];
}

#pragma mark Project Table Options Actions
- (IBAction) changeProjectTableDisplay:(id)sender
{
    id checkBox = [sender selectedCell];
    int tag = [checkBox tag];
    NSString *column = [self projectTableColumnNameForTag:tag];
    if(column){
        NSLog(@"Setting Project Table Column %@ default value.",column);
        [preferences setTable:CUPreferencesProjectDisplay column:column display:[checkBox state]];
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
        [preferences setTable:CUPreferencesSessionDisplay column:column display:[checkBox state]];
    }
}

#pragma mark Menu Options Actions
- (IBAction) changeMenuTableDisplay:(id)sender
{
    id checkBox = [sender selectedCell];
    int tag = [checkBox tag];
    NSString *column = [self menuTableColumnNameForTag:tag];
    if(column){
        NSLog(@"Setting Menu Table Column %@ default value.",column);
        [preferences setTable:CUPreferencesMenuDisplay column:column display:[checkBox state]];
    }
}
#pragma mark Invoice Options Actions
- (IBAction) changeInvoiceIndexTitle:(id)sender
{
    [preferences setInvoiceIndexTitle:[indexTitle stringValue]];
}

-(IBAction) changeInvoiceIndexHeading:(id)sender
{
    [preferences setInvoiceIndexHeading:[indexHeading stringValue]];
}

- (IBAction) changeInvoiceTitle:(id)sender
{
    [preferences setInvoiceTitle:[invoiceTitle stringValue]];
}

-(IBAction) changeInvoiceLinkHelp:(id)sender
{
    [preferences setInvoiceLinkHelp:[linkHelp stringValue]];
}

-(IBAction) changeInvoiceHeading:(id)sender
{
    [preferences setInvoiceHeading:[invoiceHeading stringValue]];
}

-(IBAction) showFontPanelForHeading:(id)sender
{
    
    NSFont *font = [preferences invoiceHeadingFont];
    [[NSFontManager sharedFontManager] setSelectedFont:font
                                            isMultiple:NO];
        NSLog(@"Changing the font manager action to changeInvoiceHeadingFont:");
    [[NSFontManager sharedFontManager] setAction:@selector(changeInvoiceHeadingFont:)];
    [[NSFontManager sharedFontManager] orderFrontFontPanel:self];
}
-(IBAction) showFontPanelForBody:(id)sender
{
    
    NSFont *font = [preferences invoiceBodyFont];
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
    NSFont *aFont = [aFontManager convertFont:[preferences invoiceHeadingFont]];
    NSLog(@"Changed Invoice Heading Font called with font name '%@' and size '%.0f'",[aFont fontName], [aFont pointSize]);
    [preferences setInvoiceHeadingFont:aFont];
    [headingFont setObjectValue:[preferences invoiceHeadingFont]];
}

-(IBAction) changeInvoiceBodyFont:(id)sender
{
    /* This action will open up the font panel. */
    NSFontManager *aFontManager = sender;
    NSFont *aFont = [aFontManager convertFont:[preferences invoiceBodyFont]];
    NSLog(@"Changed Invoice Body Font called with font name '%@' and size '%.0f'",[aFont fontName], [aFont pointSize]);
    [preferences setInvoiceBodyFont:aFont];
    [bodyFont setObjectValue:[preferences invoiceBodyFont]];
}


@end
