#import "tableGenerator.h"

@implementation tableGenerator
+ (NSTableColumn *)createJobNumberColumn:(NSString *)headerText
{
	NSTableColumn *jobNumberColumn = [[NSTableColumn alloc] initWithIdentifier:@"jobNumber"];
	[[jobNumberColumn headerCell] setStringValue:headerText];
	[[jobNumberColumn headerCell] setAlignment:NSCenterTextAlignment];
	[[jobNumberColumn dataCell] setDrawsBackground:NO];
	[[jobNumberColumn dataCell] setAlignment:NSCenterTextAlignment];
	[jobNumberColumn setWidth:20];
	[jobNumberColumn setMinWidth:15];
	[jobNumberColumn setMaxWidth:60];
	[jobNumberColumn setEditable:NO];
	
	return jobNumberColumn;
}

+ (NSTableColumn *)createJobActiveColumn:(NSString *)headerText
{
	NSTableColumn *jobActiveColumn = [[NSTableColumn alloc] initWithIdentifier:@"jobActive"];
	[[jobActiveColumn headerCell] setStringValue:headerText];
	[[jobActiveColumn headerCell] setAlignment:NSCenterTextAlignment];
	NSImageCell *imageCell = [[NSImageCell alloc] init];
	[jobActiveColumn setDataCell:imageCell];
	[jobActiveColumn setWidth:18];
	[jobActiveColumn setMinWidth:18];
	[jobActiveColumn setMaxWidth:18];
	[jobActiveColumn setEditable:NO];
	
	return jobActiveColumn;
}

+ (NSTableColumn *)createJobNameColumn:(NSString *)headerText
{
	NSTableColumn *jobNameColumn = [[NSTableColumn alloc] initWithIdentifier:@"jobName"];
	[[jobNameColumn headerCell] setStringValue:headerText];
	[[jobNameColumn headerCell] setAlignment:NSLeftTextAlignment];
	[[jobNameColumn dataCell] setDrawsBackground:NO];
	[[jobNameColumn dataCell] setAlignment:NSLeftTextAlignment];
	[jobNameColumn setWidth:130];
	[jobNameColumn setMinWidth:60];
	[jobNameColumn setEditable:NO];
	
	return jobNameColumn;
}

+ (NSTableColumn *)createJobClientColumn:(NSString *)headerText
{
	NSTableColumn *jobClientColumn = [[NSTableColumn alloc] initWithIdentifier:@"clientName"];
	[[jobClientColumn headerCell] setStringValue:headerText];
	[[jobClientColumn headerCell] setAlignment:NSLeftTextAlignment];
	[[jobClientColumn dataCell] setDrawsBackground:NO];
	[[jobClientColumn dataCell] setAlignment:NSLeftTextAlignment];
	[jobClientColumn setWidth:140];
	[jobClientColumn setMinWidth:60];
	[jobClientColumn setEditable:NO];
	
	return jobClientColumn;
}

+ (NSTableColumn *)createJobHourlyRateColumn:(NSString *)headerText
{
	NSTableColumn *hourlyRateColumn = [[NSTableColumn alloc] initWithIdentifier:@"hourlyRate"];
	[[hourlyRateColumn headerCell] setStringValue:headerText];
	[[hourlyRateColumn headerCell] setAlignment:NSLeftTextAlignment];
	[[hourlyRateColumn dataCell] setDrawsBackground:NO];
	[[hourlyRateColumn dataCell] setAlignment:NSLeftTextAlignment];
	[hourlyRateColumn setWidth:70];
	[hourlyRateColumn setMinWidth:50];
	[hourlyRateColumn setEditable:NO];
	
	return hourlyRateColumn;
}

+ (NSTableColumn *)createJobTimeLoggedColumn:(NSString *)headerText
{
	NSTableColumn *jobTimeColumn = [[NSTableColumn alloc] initWithIdentifier:@"jobTimeLogged"];
	[[jobTimeColumn headerCell] setStringValue:headerText];
	[[jobTimeColumn headerCell] setAlignment:NSLeftTextAlignment];
	[[jobTimeColumn dataCell] setDrawsBackground:NO];
	[[jobTimeColumn dataCell] setAlignment:NSLeftTextAlignment];
	[jobTimeColumn setWidth:60];
	[jobTimeColumn setMinWidth:60];
	[jobTimeColumn setEditable:NO];
	
	return jobTimeColumn;
}

+ (NSTableColumn *)createJobChargesColumn:(NSString *)headerText
{
	NSTableColumn *jobChargesColumn = [[NSTableColumn alloc] initWithIdentifier:@"jobCharges"];
	[[jobChargesColumn headerCell] setStringValue:headerText];
	[[jobChargesColumn headerCell] setAlignment:NSLeftTextAlignment];
	[[jobChargesColumn dataCell] setDrawsBackground:NO];
	[[jobChargesColumn dataCell] setAlignment:NSLeftTextAlignment];
	[jobChargesColumn setWidth:60];
	[jobChargesColumn setMinWidth:60];
	[jobChargesColumn setEditable:NO];
	
	return jobChargesColumn;
}

+ (NSTableColumn *)createSessionNumberColumn:(NSString *)headerText
{
	NSTableColumn *sessionNumberColumn = [[NSTableColumn alloc] initWithIdentifier:@"sessionNumber"];
	[[sessionNumberColumn headerCell] setStringValue:headerText];
	[[sessionNumberColumn headerCell] setAlignment:NSCenterTextAlignment];
	[[sessionNumberColumn dataCell] setDrawsBackground:NO];
	[[sessionNumberColumn dataCell] setAlignment:NSCenterTextAlignment];
	[sessionNumberColumn setWidth:20];
	[sessionNumberColumn setMinWidth:15];
	[sessionNumberColumn setMaxWidth:60];
	[sessionNumberColumn setEditable:NO];
	
	return sessionNumberColumn;

}

+ (NSTableColumn *)createSessionActiveColumn:(NSString *)headerText
{
	NSTableColumn *sessionActiveColumn = [[NSTableColumn alloc] initWithIdentifier:@"sessionActive"];
	[[sessionActiveColumn headerCell] setStringValue:headerText];
	[[sessionActiveColumn headerCell] setAlignment:NSCenterTextAlignment];
	NSImageCell *imageCell = [[NSImageCell alloc] init];
	[sessionActiveColumn setDataCell:imageCell];
	[sessionActiveColumn setWidth:18];
	[sessionActiveColumn setMinWidth:18];
	[sessionActiveColumn setMaxWidth:18];
	[sessionActiveColumn setEditable:NO];
	
	return sessionActiveColumn;
}

+ (NSTableColumn *)createSessionSDateColumn:(NSString *)headerText
{
	NSTableColumn *sessionStartDateColumn = [[NSTableColumn alloc] initWithIdentifier:@"startDate"];
	[[sessionStartDateColumn headerCell] setStringValue:headerText];
	[[sessionStartDateColumn headerCell] setAlignment:NSLeftTextAlignment];
	[[sessionStartDateColumn dataCell] setDrawsBackground:NO];
	[[sessionStartDateColumn dataCell] setAlignment:NSLeftTextAlignment];
	[sessionStartDateColumn setWidth:70];
	[sessionStartDateColumn setMinWidth:60];
	[sessionStartDateColumn setEditable:NO];
	
	return sessionStartDateColumn;
}

+ (NSTableColumn *)createSessionSTimeColumn:(NSString *)headerText
{
	NSTableColumn *sessionStartTimeColumn = [[NSTableColumn alloc] initWithIdentifier:@"startTime"];
	[[sessionStartTimeColumn headerCell] setStringValue:headerText];
	[[sessionStartTimeColumn headerCell] setAlignment:NSLeftTextAlignment];
	[[sessionStartTimeColumn dataCell] setDrawsBackground:NO];
	[[sessionStartTimeColumn dataCell] setAlignment:NSLeftTextAlignment];
	[sessionStartTimeColumn setWidth:75];
	[sessionStartTimeColumn setMinWidth:60];
	[sessionStartTimeColumn setEditable:NO];
	
	return sessionStartTimeColumn;
}

+ (NSTableColumn *)createSessionEDateColumn:(NSString *)headerText
{
	NSTableColumn *sessionEndDateColumn = [[NSTableColumn alloc] initWithIdentifier:@"endDate"];
	[[sessionEndDateColumn headerCell] setStringValue:headerText];
	[[sessionEndDateColumn headerCell] setAlignment:NSLeftTextAlignment];
	[[sessionEndDateColumn dataCell] setDrawsBackground:NO];
	[[sessionEndDateColumn dataCell] setAlignment:NSLeftTextAlignment];
	[sessionEndDateColumn setWidth:70];
	[sessionEndDateColumn setMinWidth:60];
	[sessionEndDateColumn setEditable:NO];
	
	return sessionEndDateColumn;
}

+ (NSTableColumn *)createSessionETimeColumn:(NSString *)headerText
{
	NSTableColumn *sessionEndTimeColumn = [[NSTableColumn alloc] initWithIdentifier:@"endTime"];
	[[sessionEndTimeColumn headerCell] setStringValue:headerText];
	[[sessionEndTimeColumn headerCell] setAlignment:NSLeftTextAlignment];
	[[sessionEndTimeColumn dataCell] setDrawsBackground:NO];
	[[sessionEndTimeColumn dataCell] setAlignment:NSLeftTextAlignment];
	[sessionEndTimeColumn setWidth:75];
	[sessionEndTimeColumn setMinWidth:60];
	[sessionEndTimeColumn setEditable:NO];
	
	return sessionEndTimeColumn;
}

+ (NSTableColumn *)createSessionPauseTimeColumn:(NSString *)headerText
{
	NSTableColumn *sessionTotalTimeColumn = [[NSTableColumn alloc] initWithIdentifier:@"pauseTime"];
	[[sessionTotalTimeColumn headerCell] setStringValue:headerText];
	[[sessionTotalTimeColumn headerCell] setAlignment:NSLeftTextAlignment];
	[[sessionTotalTimeColumn dataCell] setDrawsBackground:NO];
	[[sessionTotalTimeColumn dataCell] setAlignment:NSLeftTextAlignment];
	[sessionTotalTimeColumn setWidth:60];
	[sessionTotalTimeColumn setMinWidth:60];
	[sessionTotalTimeColumn setEditable:NO];
	
	return sessionTotalTimeColumn;
}

+ (NSTableColumn *)createSessionTotalTimeColumn:(NSString *)headerText
{
	NSTableColumn *sessionTotalTimeColumn = [[NSTableColumn alloc] initWithIdentifier:@"totalTime"];
	[[sessionTotalTimeColumn headerCell] setStringValue:headerText];
	[[sessionTotalTimeColumn headerCell] setAlignment:NSLeftTextAlignment];
	[[sessionTotalTimeColumn dataCell] setDrawsBackground:NO];
	[[sessionTotalTimeColumn dataCell] setAlignment:NSLeftTextAlignment];
	[sessionTotalTimeColumn setWidth:60];
	[sessionTotalTimeColumn setMinWidth:60];
	[sessionTotalTimeColumn setEditable:NO];
	
	return sessionTotalTimeColumn;
}

+ (NSTableColumn *)createSessionChargesColumn:(NSString *)headerText
{
	NSTableColumn *sessionChargesColumn = [[NSTableColumn alloc] initWithIdentifier:@"sessionCharges"];
	[[sessionChargesColumn headerCell] setStringValue:headerText];
	[[sessionChargesColumn headerCell] setAlignment:NSLeftTextAlignment];
	[[sessionChargesColumn dataCell] setDrawsBackground:NO];
	[[sessionChargesColumn dataCell] setAlignment:NSLeftTextAlignment];
	[sessionChargesColumn setWidth:60];
	[sessionChargesColumn setMinWidth:60];
	[sessionChargesColumn setEditable:NO];
	
	return sessionChargesColumn;
}

+ (NSTableColumn *)createSessionSummaryColumn:(NSString *)headerText
{
	NSTableColumn *sessionSummaryColumn = [[NSTableColumn alloc] initWithIdentifier:@"sessionSummary"];
	[[sessionSummaryColumn headerCell] setStringValue:headerText];
	[[sessionSummaryColumn headerCell] setAlignment:NSLeftTextAlignment];
	[[sessionSummaryColumn dataCell] setDrawsBackground:NO];
	[[sessionSummaryColumn dataCell] setAlignment:NSLeftTextAlignment];
	[sessionSummaryColumn setWidth:300];
	[sessionSummaryColumn setMinWidth:15];
	[sessionSummaryColumn setEditable:YES];
	
	return sessionSummaryColumn;
}
@end