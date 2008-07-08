/* Controller */

#import <Cocoa/Cocoa.h>
#import "tableGenerator.h"
#import "cuDateTime.h"
#import "dataHandler.h"

@class CUPreferenceController;
@class CUPreferences;

@interface Controller : NSObject
{

	BOOL firstLaunch;
	int windowHeight;
	int windowWidth;
	int windowX;
	int windowY;

	NSMutableArray *jobData;

	IBOutlet NSMenu *menuJobList;
	NSStatusItem *jobPullDownMenu;
	NSStatusItem *menuStartStopButton;
	NSStatusItem *menuPauseButton;
	NSStatusItem *menuTimeDisplay;
	NSStatusItem *menuChargeDisplay;
	
	NSSortDescriptor *lastJobSorter;
	NSSortDescriptor *lastSessionSorter;
	BOOL lastJobSortAscending;
	BOOL lastSessionSortAscending;
	
	NSPrintInfo *printInfo;
	
	NSImage *tableActive;
	NSImage *tableInactive;
	NSImage *tablePaused;
	NSImage *pauseYes;
	NSImage *pauseNo;
	NSImage *startStopGray;
	NSImage *startStopGreen;
	NSImage *startStopRed;
	NSImage *menuStartStopGray;
	NSImage *menuStartStopGreen;
	NSImage *menuStartStopRed;
	NSImage *menuPauseYes;
	NSImage *menuPauseNo;
	NSImage *menuPauseNull;
	NSImage *menuJobListIcon;
	NSImage *menuJobListAltIcon;
	
	NSTimer *updateTimer;

	//PrefsVariables
	int saveTimer;
	int autoDeleteTime;
	
	//MainWindow
	IBOutlet id mainWindow;
	IBOutlet id jobTable;
	IBOutlet id pauseButton;
	IBOutlet id startStopButton;
    IBOutlet id startStopField;
	IBOutlet id editJobButton;
	IBOutlet id deleteJobButton;
	
	//Drawer
	IBOutlet id sessionTable;
	IBOutlet id addSessionButton;
	IBOutlet id editSessionButton;
	IBOutlet id deleteSessionButton;
	
	//AddJobPanel
	IBOutlet id addJobClient;
    IBOutlet id addJobHourlyRate;
    IBOutlet id addJobJobName;
    IBOutlet id addJobPanel;
	
	//EditJobPanel
	IBOutlet id editJobClient;
    IBOutlet id editJobHourlyRate;
    IBOutlet id editJobJobName;
    IBOutlet id editJobPanel;
	
	//AddSessionPanel
	IBOutlet id addSessionEndDate;
    IBOutlet id addSessionEndTime;
    IBOutlet id addSessionPanel;
    IBOutlet id addSessionStartDate;
    IBOutlet id addSessionStartTime;
	
	//EditSessionPanel
	IBOutlet id editSessionEndDate;
    IBOutlet id editSessionEndTime;
    IBOutlet id editSessionPanel;
    IBOutlet id editSessionStartDate;
    IBOutlet id editSessionStartTime;
	
	
	//Text Storage
	IBOutlet id textArr;
    IBOutlet id textBah;
    IBOutlet id textCharges;
    IBOutlet id textClientName;
    IBOutlet id textDataMustBe;
    IBOutlet id textDeleteJobLong;
    IBOutlet id textDeleteJobShort;
    IBOutlet id textDeleteSessionLong;
    IBOutlet id textDeleteSessionShort;
    IBOutlet id textEndLater;
	IBOutlet id textExportTo;
	IBOutlet id textHourSuffix;
    IBOutlet id textJobActive;
    IBOutlet id textJobName;
    IBOutlet id textJobNumber;
    IBOutlet id textMenuDisable;
    IBOutlet id textNewVersion;
    IBOutlet id textNoJobData;
    IBOutlet id textPauses;
    IBOutlet id textProblemConnect;
    IBOutlet id textRate;
    IBOutlet id textRejoice;
    IBOutlet id textSelectFile;
    IBOutlet id textSelectJob;
    IBOutlet id textSessionActive;
    IBOutlet id textSessionCharges;
    IBOutlet id textSessionDate;
    IBOutlet id textSessionEnd;
    IBOutlet id textSessionEndDate;
    IBOutlet id textSessionNumber;
    IBOutlet id textSessionStart;
    IBOutlet id textSessionSummary;
    IBOutlet id textSessionTime;
	IBOutlet id textStartRecording;
	IBOutlet id textStopRecording;
    IBOutlet id textTimeLogged;
	IBOutlet id textTotalDue;
    IBOutlet id textUpToDate;
    IBOutlet id textYeargh;
	
	//PrintWindow
	IBOutlet id printWindow;
	IBOutlet id printTable;
	IBOutlet id printJobName;
	IBOutlet id printClientName;
	IBOutlet id printHourlyRate;
	IBOutlet id printTotalTimeLogged;
	IBOutlet id printTotalCharges;
    
    // New Preferences Controller
    CUPreferenceController *preferencesController;
    CUPreferences *preferences;
    
    // Main Bundle
    NSBundle *main;
}
//***Main Methods***
- (void)applicationWillTerminate:(NSNotification *)notification;
- (void)createNewJob:(NSString *)name client:(NSString *)client rate:(double)rate;
- (void)createNewSession:(cuDateTime *)startDateTime endDateTime:(cuDateTime *)endDateTime job:(int)whichJob active:(BOOL)active;
- (void)computeJobTime:(int)job;
// - (void)loadPrefsFromFile;
- (void)updateLoop;
- (void)updateMenuBarData;
- (void)updateMenuBarJobList;
- (void)updateMenuBarButtons;
- (void)jobMenuListSelectionChanged:(id)sender;
- (void)addJobToMenuList:(NSString *)jobName;
- (void)saveLoop;
// - (void)savePrefs;
- (void)buildJobTable;
- (void)buildSessionTable;

- (void)buildPrintTable;
- (void)updatePrintWindowFields;

- (void)buildStatusItem;
- (int)getHighestJobNumber;
- (int)getHighestSessionNumber:(int)whichJob;
- (NSString *)truncateChargeString:(NSString *)originalString;

//***TableView Methods***
- (int)numberOfRowsInTableView:(NSTableView *)tableView;
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)rowIndex;
- (void)tableView:(NSTableView *)tableView mouseDownInHeaderOfTableColumn:(NSTableColumn *)tableColumn;
- (void)tableViewSelectionDidChange:(NSNotification *)notification;
- (void)tableDoubleClick:(NSTableView *)tableView;
- (void)tableView:(NSTableView *)tableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)tableColumn row:(int)rowIndex;
- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(int)row;

//***Buttons***
//Main Window
- (IBAction)startStopRecording:(id)sender;
- (IBAction)pauseUnpause:(id)sender;
- (IBAction)addJobButton:(id)sender;
- (IBAction)deleteJobButton:(id)sender;
- (IBAction)editJobButton:(id)sender;

//Drawer
- (IBAction)addSessionButton:(id)sender;
- (IBAction)deleteSessionButton:(id)sender;
- (IBAction)editSessionButton:(id)sender;
- (void)editJob;

//AddJobPanel
- (IBAction)addJobCancel:(id)sender;
- (IBAction)addJobSave:(id)sender;

//EditJobPanel
- (IBAction)editJobCancel:(id)sender;
- (IBAction)editJobSave:(id)sender;

//AddSessionPanel
- (IBAction)addSessionCancel:(id)sender;
- (IBAction)addSessionSave:(id)sender;

//EditSessionPanel
- (IBAction)editSessionCancel:(id)sender;
- (IBAction)editSessionSave:(id)sender;
- (void)editSession;

//***MenuItems***
- (IBAction)menuPauseAllJobs:(id)sender;
- (IBAction)menuAddData:(id)sender;
- (IBAction)menuBlatantAd:(id)sender;
- (IBAction)menuDisplayHelp:(id)sender;
- (IBAction)menuDonate:(id)sender;
- (IBAction)menuExport:(id)sender;
- (IBAction)menuOpenWindow:(id)sender;
- (IBAction)menuPrintInvoice:(id)sender;
- (IBAction)menuHTML:(id)sender;
- (IBAction)menuHTMLAll:(id)sender;
- (NSString *)generateIndexHTML;
- (NSString *)generateHTMLForJob:(int)jobNumber;
- (IBAction)menuSave:(id)sender;
- (IBAction)menuSendEmail:(id)sender;
- (IBAction)menuVisitWebsite:(id)sender;
- (IBAction)menuCheckForUpdates:(id)sender;
- (IBAction)showPagePanel:(id)sender;

/***** Preferences *****/
- (IBAction)showPreferencesPanel:(id)sender;
- (void) handleClockSettingsChanged:(NSNotification *)note;
- (void) handleTableChanges:(NSNotification *)note;
- (void)handlePreferencesReset:(NSNotification *)note;

@end