//
//  CUPreferences.m
//  Khronos
//
//  Created by Gautam Dey on 7/5/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "CUPreferences.h"

// These are the General Preferences.
NSString *const CUPreferencesAskDeleteProject    = @"Delete Project";
NSString *const CUPreferencesAskDeleteSession    = @"Delete Session" ;
NSString *const CUPreferencesAutoSaveTime        = @"Auto Save Time";
NSString *const CUPreferencesAutoDeleteSettings  = @"Delete Settings";
NSString *const CUPreferencesMonetaryUnit        = @"Monetary Unit";
NSString *const CUPreferencesClockSetting        = @"24 Hour Clock";
NSString *const CUPreferencesUpdateTime          = @"Update time";
NSString *const CUPreferencesFirstLaunch         = @"First Launch";
NSString *const CUPreferencesTimeSettingsChangedNotification = @"CUTimeSettingsChangedNotification";
NSString *const CUPreferencesClockSettingNotification        = @"CUClockChangedNotification";
NSString *const CUPreferencesUpdateTimeNotification          = @"CUUpdateTimeNotification";
NSString *const CUPreferencesMonetaryUnitChangedNotification = @"CUPreferencesMonetaryUnitChangedNotification";


/*** General Table info ***/
NSString *const CUPreferencesTableNotification       = @"CUPreferencesTableNotification";
NSString *const CUPreferencesTableUserInfoTableName  = @"CUPreferencesTableUserInfoTableName";
NSString *const CUPreferencesTableUserInfoColumnName = @"CUPreferencesTableUserInfoColumnName";
/*** Which columns in the Project table should be shown. ***/
// CUPreferencesProjectDisplay is a dictonary to hold the options for the Project Table.
NSString *const CUPreferencesProjectDisplay           = @"Project Display";
NSString *const CUPreferencesProjectDisplayNumber     = @"Number";
NSString *const CUPreferencesProjectDisplayName       = @"Name";
NSString *const CUPreferencesProjectDisplayClient     = @"Client";
NSString *const CUPreferencesProjectDisplayRate       = @"Rate";
NSString *const CUPreferencesProjectDisplayTime       = @"Time";
NSString *const CUPreferencesProjectDisplayCharges    = @"Charges";

/*** Which columns in the Session Table should be shown. ***/
// CUPreferencesSessionDisplay is a dictonary to hold the options for the Session Table.
NSString *const CUPreferencesSessionDisplay             = @"Sessions Display";
NSString *const CUPreferencesSessionDisplayStartDate    = @"Start Date";
NSString *const CUPreferencesSessionDisplayEndDate      = @"End Date";
NSString *const CUPreferencesSessionDisplayStartTime    = @"Start Time";
NSString *const CUPreferencesSessionDisplayEndTime      = @"End Time";
NSString *const CUPreferencesSessionDisplayPauseTime    = @"Pause Time";
NSString *const CUPreferencesSessionDisplayTotalTime    = @"Total Time";
NSString *const CUPreferencesSessionDisplayCharges      = @"Charges";
NSString *const CUPreferencesSessionDisplaySummary      = @"Summary";
NSString *const CUPreferencesSessionDisplayNumber       = @"Number";

/*** Options for the menu bar ***/
// CUPreferencesMenuDisplay dictonary to hold the options for the menu bar.
NSString *const CUPreferencesMenuDisplay                = @"Menubar Display";
NSString *const CUPreferencesMenuDisplayPauseButton     = @"Pause Button";
NSString *const CUPreferencesMenuDisplayRecrodingButton = @"Recording Button";
NSString *const CUPreferencesMenuDisplayProjectList     = @"Projects List";
NSString *const CUPreferencesMenuDisplayTotalTime       = @"Total Time";
NSString *const CUPreferencesMenuDisplayCharges         = @"Charges";

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
NSString *const CUPreferencesInvoiceIndexTitleChangedNotification   = @"CUPreferencesInvoiceIndexTitleChangedNotification";
NSString *const CUPreferencesInvoiceIndexHeadingChangedNotification = @"CUPreferencesInvoiceIndexHeadingChangedNotification";
NSString *const CUPreferencesInvoiceLinkHelpChangedNotification     = @"CUPreferencesInvoiceLinkHelpChangedNotification";
NSString *const CUPreferencesInvoiceTitleChangedNotification        = @"CUPreferencesInvoiceTitleChangedNotification";
NSString *const CUPreferencesInvoiceHeadingChangedNotification      = @"CUPreferencesInvoiceHeadingChangedNotification";
NSString *const CUPreferencesInvoiceHeadingFontChangedNotification  = @"CUPreferencesInvoiceHeadingFontChangedNotification";
NSString *const CUPreferencesInvoiceBodyFontChangedNotification     = @"CUPreferencesInvoiceBodyFontChangedNotification";

@implementation CUPreferences


+ (void) resetPreferences 
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
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
    NSLog(@"Sending out notifications.");
    NSLog(@"Sending notification %@",CUPreferencesClockSettingNotification);
    [nc postNotificationName:CUPreferencesClockSettingNotification object:self];
    [nc postNotificationName:CUPreferencesUpdateTimeNotification object:self];
    [nc postNotificationName:CUPreferencesTimeSettingsChangedNotification object:self];

}

+ (void) initializeDefaults
{
#pragma mark Setting Default Values.
    // Create a Dictionary
    NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
    
    // Register the default values for Clock, which is 24 hour clock.
    [defaultValues setObject:[NSNumber numberWithBool:YES] forKey:CUPreferencesClockSetting];
    // Register the default value for Update time, which is 0 minutes
    [defaultValues setObject:[NSNumber numberWithInt:0] forKey:CUPreferencesUpdateTime];
    // Register the default value for Montery Unit.
    [defaultValues setObject:@"$" forKey:CUPreferencesMonetaryUnit];
    
    
    NSLog(@"Registering Project Table Defaults.");
    // Register the default value for the Poject Table.
    NSArray *keys = [NSArray arrayWithObjects: 
                     CUPreferencesProjectDisplayNumber,
                     CUPreferencesProjectDisplayName,
                     CUPreferencesProjectDisplayClient,
                     CUPreferencesProjectDisplayRate,
                     CUPreferencesProjectDisplayTime,
                     CUPreferencesProjectDisplayCharges,
                     nil];
    NSArray *values = [NSArray arrayWithObjects:
                       [NSNumber  numberWithBool: YES], // Number
                       [NSNumber  numberWithBool: YES], // Name
                       [NSNumber  numberWithBool: YES], // Client Name
                       [NSNumber  numberWithBool: NO] , // Rate
                       [NSNumber  numberWithBool: YES], // Time
                       [NSNumber  numberWithBool: YES], // Charges
                       nil];
    
    NSDictionary *projectTableValues = [NSDictionary dictionaryWithObjects:values 
                                                                   forKeys:keys];
    [defaultValues setObject:projectTableValues forKey:CUPreferencesProjectDisplay];
    
    NSLog(@"Registering Session Table Defaults.");
    // Register the default value for the Poject Table.
    keys = [NSArray arrayWithObjects: 
            CUPreferencesSessionDisplayStartDate,
            CUPreferencesSessionDisplayEndDate,
            CUPreferencesSessionDisplayStartTime,
            CUPreferencesSessionDisplayEndTime,
            CUPreferencesSessionDisplayPauseTime,
            CUPreferencesSessionDisplayTotalTime,
            CUPreferencesSessionDisplayCharges,
            CUPreferencesSessionDisplaySummary,
            CUPreferencesSessionDisplayNumber,
            nil];
    values = [NSArray arrayWithObjects:
              [NSNumber  numberWithBool: YES],  // Start Date
              [NSNumber  numberWithBool: YES],  // End Date
              [NSNumber  numberWithBool: YES],  // Start Time
              [NSNumber  numberWithBool: YES],  // End Time
              [NSNumber  numberWithBool: NO ],  // Pause Time
              [NSNumber  numberWithBool: YES],  // Total Time
              [NSNumber  numberWithBool: YES],  // Charges
              [NSNumber  numberWithBool: YES],  // Summary
              [NSNumber  numberWithBool: YES],  // Number
              nil];
    NSDictionary *sessionTableValues = [NSDictionary dictionaryWithObjects:values 
                                                                   forKeys:keys];
    [defaultValues setObject:sessionTableValues forKey:CUPreferencesSessionDisplay];
    
    
    NSLog(@"Registering Invoice Defaults");
    NSData *headingFontAsData = [NSKeyedArchiver archivedDataWithRootObject:[NSFont fontWithName:@"Helvetica" size:18]];
    NSData *bodyFontAsData = [NSKeyedArchiver archivedDataWithRootObject:[NSFont fontWithName:@"Helvetica" size:10]];
    keys = [NSArray arrayWithObjects:
            CUPreferencesInvoiceIndexTitle,
            CUPreferencesInvoiceIndexHeading,
            CUPreferencesInvoiceTitle,
            CUPreferencesInvoiceLinkHelp,
            CUPreferencesInvoiceHeading,
            CUPreferencesInvoiceHeadingFont,
            CUPreferencesInvoiceBodyFont,
            nil];
    values = [NSArray arrayWithObjects:
              @"Khronos Invoice List",                // Index Title
              @"Invoices",                            // Index Heading
              @"Khronos Invoice",                     // Title
              @"Click the job to view the invoice.",  // Link Help
              @"Invoice",                             // Heading
              headingFontAsData,                      // Heading Font
              bodyFontAsData,                         // Body Font
              nil];
    NSDictionary *invoiceValues = [NSDictionary dictionaryWithObjects:values
                                                              forKeys:keys];
    [defaultValues setObject:invoiceValues forKey:CUPreferencesInvoice];
    
    NSLog(@"Registering Menu Table Defaults.");
    // Register the default value for the Poject Table.
    keys = [NSArray arrayWithObjects: 
            CUPreferencesMenuDisplayPauseButton,
            CUPreferencesMenuDisplayRecrodingButton,
            CUPreferencesMenuDisplayProjectList,
            CUPreferencesMenuDisplayTotalTime,
            CUPreferencesMenuDisplayCharges,
            nil];
    values = [NSArray arrayWithObjects:
              [NSNumber  numberWithBool: YES],  // Pause Button
              [NSNumber  numberWithBool: YES],  // Recording Button
              [NSNumber  numberWithBool: YES],  // Project List
              [NSNumber  numberWithBool: YES],  // Total Time
              [NSNumber  numberWithBool: YES],  // Charges
              nil];
    NSDictionary *menuTableValues = [NSDictionary dictionaryWithObjects:values 
                                                                forKeys:keys];
    [defaultValues setObject:menuTableValues forKey:CUPreferencesMenuDisplay];
    // Register the dictionary of defaults.
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
    
    NSLog(@"Registered defaults: %@", defaultValues ); 
}

#pragma mark Table Options
// These are the setting for Project Table, Session Table and Menu.
- (NSDictionary *)columnsForTable:(NSString *)tableName
{
    return [[NSUserDefaults standardUserDefaults] dictionaryForKey:tableName];
}
- (void) setTable:(NSString *)tableName column:(NSString *)column display:(BOOL)yn
{
    NSNotificationCenter *nc;
    nc = [NSNotificationCenter defaultCenter];
    NSMutableDictionary *newTable = [[self columnsForTable:tableName] mutableCopy];
    [newTable setObject:[NSNumber numberWithBool:yn] forKey:column];
    NSLog(@"Setting table '%@' to value %@",tableName, newTable);
    [[NSUserDefaults standardUserDefaults] setObject:newTable forKey:tableName];
    [nc postNotificationName:CUPreferencesTableNotification 
                      object:self 
                    userInfo:[NSDictionary 
                              dictionaryWithObjects: [NSArray arrayWithObjects: tableName, column, nil]
                              forKeys: [NSArray arrayWithObjects: CUPreferencesTableUserInfoTableName, CUPreferencesTableUserInfoColumnName, nil]]];
}
- (BOOL) displayForTable:(NSString *)tableName column:(NSString *)column
{
    return [[[self columnsForTable:tableName] objectForKey:column] boolValue];
}

#pragma mark General Options

- (BOOL) askDeleteProject
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:CUPreferencesAskDeleteProject];
}

- (void) setAskDeleteProject:(BOOL)yn
{
    [[NSUserDefaults standardUserDefaults] setBool:yn forKey:CUPreferencesAskDeleteProject];
}

- (BOOL) askDeleteSession
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:CUPreferencesAskDeleteSession];
}

- (void) setAskDeleteSession:(BOOL)yn
{

    [[NSUserDefaults standardUserDefaults] setBool:yn forKey:CUPreferencesAskDeleteSession];
}

- (BOOL) autoSaveTime
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:CUPreferencesAutoSaveTime];
}

- (void) setAutoSaveTime:(BOOL)yn
{
    [[NSUserDefaults standardUserDefaults] setBool:yn forKey:CUPreferencesAutoSaveTime];
}

- (BOOL) autoDeleteSettings
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:CUPreferencesAutoDeleteSettings];    
}
- (void) setAutoDeleteSettings:(BOOL)yn
{
    [[NSUserDefaults standardUserDefaults] setBool:yn forKey:CUPreferencesAutoDeleteSettings];
}
- (BOOL) is24HourClock
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:CUPreferencesClockSetting];
}
- (void) setIs24HourClock:(BOOL)yn
{
    [[NSUserDefaults standardUserDefaults] setBool:yn forKey:CUPreferencesClockSetting];
    
    // Notification
    NSNotificationCenter *nc;
    nc = [NSNotificationCenter defaultCenter];
    NSLog(@"Sending notification %@",CUPreferencesClockSettingNotification);
    [nc postNotificationName:CUPreferencesClockSettingNotification object:self];
    [nc postNotificationName:CUPreferencesTimeSettingsChangedNotification object:self];
    
}
- (int) updateTimeEvery
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:CUPreferencesUpdateTime] intValue];
}
- (void) setUpdateTimeEvery:(int)minutes
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:minutes] forKey:CUPreferencesUpdateTime];    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    NSLog(@"Sending notification %@",CUPreferencesUpdateTimeNotification);
    [nc postNotificationName:CUPreferencesUpdateTimeNotification object:self];
    [nc postNotificationName:CUPreferencesTimeSettingsChangedNotification object:self];
}
- (NSString *)monetaryUnit
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:CUPreferencesMonetaryUnit];
}
- (void) setMonetaryUnit:(NSString *)unit
{
    [[NSUserDefaults standardUserDefaults] setObject:unit  forKey:CUPreferencesMonetaryUnit];    
    [[NSNotificationCenter defaultCenter] postNotificationName:CUPreferencesMonetaryUnitChangedNotification object:self];
}

- (BOOL) firstLaunch
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    BOOL state = [defaults boolForKey:CUPreferencesFirstLaunch];
    if(state) 
        [defaults setBool:NO forKey:CUPreferencesFirstLaunch];
    return state;
}
#pragma mark Invoce Options
- (NSDictionary *)invoiceTable
{
    return [[NSUserDefaults standardUserDefaults] dictionaryForKey:CUPreferencesInvoice];
}

- (id)invoiceValuesForColumn:(NSString *)column
{
    return [[self invoiceTable] objectForKey:column];
}

- (void)setInvoiceValueForColumn:(NSString *)column value:(id)value
{

    NSMutableDictionary *table = [[self invoiceTable] mutableCopy];
    [table setObject:value forKey:column];
    [[NSUserDefaults standardUserDefaults] setObject:table forKey:CUPreferencesInvoice];
}
    
- (NSString *)invoiceIndexTitle
{
    return [self invoiceValuesForColumn:CUPreferencesInvoiceIndexTitle];
}
    
- (void) setInvoiceIndexTitle:(NSString *)title
{
    [self setInvoiceValueForColumn:CUPreferencesInvoiceIndexTitle value:title];
    [[NSNotificationCenter defaultCenter] postNotificationName:CUPreferencesInvoiceIndexTitleChangedNotification object:self];
}
    
- (NSString *)invoiceIndexHeading
{
    return [self invoiceValuesForColumn:CUPreferencesInvoiceIndexHeading];
}
- (void) setInvoiceIndexHeading:(NSString *)heading
{
    [self setInvoiceValueForColumn:CUPreferencesInvoiceIndexHeading value:heading];
    [[NSNotificationCenter defaultCenter] postNotificationName:CUPreferencesInvoiceIndexHeadingChangedNotification object:self];
}
- (NSString *)invoiceLinkHelp
{
    return [self invoiceValuesForColumn:CUPreferencesInvoiceLinkHelp];
}
- (void) setInvoiceLinkHelp:(NSString *)linkHelp
{
    [self setInvoiceValueForColumn:CUPreferencesInvoiceLinkHelp value:linkHelp];
    [[NSNotificationCenter defaultCenter] postNotificationName:CUPreferencesInvoiceLinkHelpChangedNotification object:self];
}
- (NSString *)invoiceTitle
{
    return [self invoiceValuesForColumn:CUPreferencesInvoiceTitle];
}
- (void) setInvoiceTitle:(NSString  *)title
{
    [self setInvoiceValueForColumn:CUPreferencesInvoiceTitle value:title];
    [[NSNotificationCenter defaultCenter] postNotificationName:CUPreferencesInvoiceTitleChangedNotification object:self];
}
- (NSString *)invoiceHeading
{
    return [self invoiceValuesForColumn:CUPreferencesInvoiceHeading];
}
- (void)setInvoiceHeading:(NSString *)heading
{
    [self setInvoiceValueForColumn:CUPreferencesInvoiceHeading value:heading];
    [[NSNotificationCenter defaultCenter] postNotificationName:CUPreferencesInvoiceHeadingChangedNotification object:self];
}
- (NSFont *)invoiceHeadingFont
{
    NSData *fontAsData = [self invoiceValuesForColumn:CUPreferencesInvoiceHeadingFont];
    return [NSKeyedUnarchiver unarchiveObjectWithData:fontAsData];
}
- (void)setInvoiceHeadingFont:(NSFont *)aFont
{
    NSData *fontAsData = [NSKeyedArchiver archivedDataWithRootObject:aFont];
    [self setInvoiceValueForColumn:CUPreferencesInvoiceHeadingFont value:fontAsData];
    [[NSNotificationCenter defaultCenter] postNotificationName:CUPreferencesInvoiceHeadingFontChangedNotification object:self];
}
- (NSFont *)invoiceBodyFont
{
    NSData *fontAsData = [self invoiceValuesForColumn:CUPreferencesInvoiceBodyFont];
    return [NSKeyedUnarchiver unarchiveObjectWithData:fontAsData];    
}
- (void)setInvoiceBodyFont:(NSFont *)aFont
{
    NSData *fontAsData = [NSKeyedArchiver archivedDataWithRootObject:aFont];
    [self setInvoiceValueForColumn:CUPreferencesInvoiceBodyFont value:fontAsData];
    [[NSNotificationCenter defaultCenter] postNotificationName:CUPreferencesInvoiceBodyFontChangedNotification object:self];
}

@end
