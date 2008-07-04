//
//  CUPreferenceController.h
//  Khronos
//
//  Created by Gautam Dey on 6/29/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


extern NSString *const CUPreferencesAskDeleteJob;
extern NSString *const CUPreferencesAskDeleteSession;
extern NSString *const CUPreferencesAutoSaveTime;
extern NSString *const CUPreferencesAutoDeleteSettings;
extern NSString *const CUPreferencesClockSetting;
extern NSString *const CUPreferencesUpdateTime;
extern NSString *const CUPreferencesMonetaryUnit;

/*** Which columns in the Project table should be shown. ***/
extern NSString *const CUPreferencesProjectDisplay;
extern NSString *const CUPreferencesProjectDisplayNumber;
extern NSString *const CUPreferencesProjectDisplayName;
extern NSString *const CUPreferencesProjectDisplayClient;
extern NSString *const CUPreferencesProjectDisplayRate;
extern NSString *const CUPreferencesProjectDisplayTime;
extern NSString *const CUPreferencesProjectDisplayCharges;

/*** Which columns in the Seesion Table should be shown. ***/
extern NSString *const CUPreferencesSessionDisplay;
extern NSString *const CUPreferencesSessionDisplayStartDate;
extern NSString *const CUPreferencesSessionDisplayEndDate;
extern NSString *const CUPreferencesSessionDisplayStartTime;
extern NSString *const CUPreferencesSessionDisplayEndTime;
extern NSString *const CUPreferencesSessionDisplayPauseTime;
extern NSString *const CUPreferencesSessionDisplayTotalTime;
extern NSString *const CUPreferencesSessionDisplayCharges;
extern NSString *const CUPreferencesSessionDisplaySummary;
extern NSString *const CUPreferencesSessionDisplayNumber;

/*** Options for the menu bar ***/
extern NSString *const CUPreferencesMenuDisplay;
extern NSString *const CUPreferencesMenuDisplayPauseButton;
extern NSString *const CUPreferencesMenuDisplayRecrodingButton;
extern NSString *const CUPreferencesMenuDisplayProjectList;
extern NSString *const CUPreferencesMenuDisplayTotalTime;
extern NSString *const CUPreferencesMenuDisplayCharges;

/*** Options for Invoice ***/
extern NSString *const CUPreferencesInvoice;
extern NSString *const CUPreferencesInvoiceIndexTitle;
extern NSString *const CUPreferencesInvoiceIndexHeading;
extern NSString *const CUPreferencesInvoiceLinkHelp;
extern NSString *const CUPreferencesInvoiceTitle;
extern NSString *const CUPreferencesInvoiceHeading;
extern NSString *const CUPreferencesInvoiceBodyFont;
extern NSString *const CUPreferencesInvoiceHeadingFont;




@interface CUPreferenceController : NSWindowController {

    IBOutlet NSButton *askDeleteProject;
    IBOutlet NSButton *askDeleteSession;
    IBOutlet NSButton *autoSaveTime;
    IBOutlet NSButton *autoDeleteSettings;
    IBOutlet NSTextField *aMonetaryUnit;
    IBOutlet NSMatrix *clockSettings;
    IBOutlet NSMatrix *updateTime;
    
    // Project Table Settings
    IBOutlet NSMatrix *projectTableColumns;
    
    // Session Table Settings
    IBOutlet NSMatrix *sessionTableColumns;
}

- (IBAction) resetPreferences:(id)sender;
// General Options
#pragma mark General Options
- (BOOL) askDeleteProject;
- (BOOL) askDeleteSession;
- (BOOL) autoSaveTime;
- (BOOL) autoDeleteSettings;
- (BOOL) is24HourClock;
-(int) updateTimeEvery;
- (NSString *)monetaryUnit;


#pragma mark General Options Actions
- (IBAction) changeAskDeleteProject:(id)sender;
- (IBAction) changeAskDeleteSession:(id)sender;
- (IBAction) changeAutoSaveTime:(id)sender;
- (IBAction) changeAutoDeleteSetting:(id)sender;
- (IBAction) changeClock:(id)sender;
- (IBAction) changeUpdateTime:(id)sender;
- (IBAction) changeMonetaryUnit:(id)sender;


// Options for the tables;
#pragma mark Project Table Options
- (NSDictionary *)projectTableColumns;
- (NSString *)projectTableColumnNameForTag:(int)tag;
- (void)setProjectTableColumn:(NSString *)column display:(BOOL)yn;
- (BOOL)displayProjectTableColumn:(NSString *)column;

#pragma mark Project Table Options Actions
- (IBAction) changeProjectTableDisplay:(id)sender;

#pragma mark Session Table Options
- (NSDictionary *)sessionTableColumns;
- (NSString *)sessionTableColumnNameForTag:(int)tag;
- (void)setSessionTableColumn:(NSString *)column display:(BOOL)yn;
- (BOOL)displayProjectTableColumn:(NSString *)column;

#pragma mark Session Table Actions
- (IBAction) changeSessionTableDisplay:(id)sender;

// Options for Invoice
#pragma mark Invoice Options
- (NSString *)invoiceIndexTitle;
- (NSString *)invoiceIndexHeading;
- (NSString *)invoiceLinkHelp;
- (NSString *)invoiceTitle;
- (NSString *)invoiceHeading;
- (NSFont *)invoiceHeadingFont;
- (NSFont *)invoiceBodyFont;
/* Just For now.
#pragma mark Invoice Options Actions
- (IBAction) changeInvoiceIndexTitle:(id)sender;
- (IBAction) changeInvoiceIndexHeading:(id)sender;
- (IBAction) changeInvoiceLinkHelp:(id)sender;
- (IBAction) changeInvoiceTitle:(id)sender;
- (IBAction) changeInvoiceHeading:(id)sender;
- (IBAction) changeInvoiceHeadingFont:(id)sender;
- (IBAction) changeInvoiceBodyFont:(id)sender;
*/
@end
