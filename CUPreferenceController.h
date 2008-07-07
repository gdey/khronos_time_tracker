//
//  CUPreferenceController.h
//  Khronos
//
//  Created by Gautam Dey on 6/29/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Preferences;

@interface CUPreferenceController : NSWindowController {

    Preferences *preferences;
    
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
    // Session Table Settings
    IBOutlet NSMatrix *menuTableColumns;
    
    // Invoice Settings
    // Text information
    IBOutlet NSTextField *indexTitle;
    IBOutlet NSTextField *indexHeading;
    IBOutlet NSTextField *linkHelp;
    IBOutlet NSTextField *invoiceTitle;
    IBOutlet NSTextField *invoiceHeading;
    // Fonts
    IBOutlet NSTextField *bodyFont;
    IBOutlet NSTextField *headingFont;
}

- (IBAction) resetPreferences:(id)sender;
// General Options

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
- (NSString *)projectTableColumnNameForTag:(int)tag;

#pragma mark Project Table Options Actions
- (IBAction) changeProjectTableDisplay:(id)sender;

#pragma mark Session Table Options
- (NSString *)sessionTableColumnNameForTag:(int)tag;
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

#pragma mark Invoice Options Actions
- (IBAction) changeInvoiceIndexTitle:(id)sender;
- (IBAction) changeInvoiceIndexHeading:(id)sender;
- (IBAction) changeInvoiceLinkHelp:(id)sender;
- (IBAction) changeInvoiceTitle:(id)sender;
- (IBAction) changeInvoiceHeading:(id)sender;
- (IBAction) changeInvoiceHeadingFont:(id)sender;
- (IBAction) changeInvoiceBodyFont:(id)sender;
- (IBAction) showFontPanelForHeading:(id)sender;
- (IBAction) showFontPanelForBody:(id)sender;

#pragma mark Menu Options
- (NSString *)menuTableColumnNameForTag:(int)tag;

#pragma mark Menu Options Actions
- (IBAction) changeMenuTableDisplay:(id)sender;

@end
