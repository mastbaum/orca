//--------------------------------------------------------
// ORGT521Model
// Created by Mark  A. Howe on Fri Jul 22 2005
// Code partially generated by the OrcaCodeWizard. Written by Mark A. Howe.
// Copyright (c) 2005 CENPA, University of Washington. All rights reserved.
//-----------------------------------------------------------
//This program was prepared for the Regents of the University of 
//Washington at the Center for Experimental Nuclear Physics and 
//Astrophysics (CENPA) sponsored in part by the United States 
//Department of Energy (DOE) under Grant #DE-FG02-97ER41020. 
//The University has certain rights in the program pursuant to 
//the contract and the program should not be copied or distributed 
//outside your organization.  The DOE and the University of 
//Washington reserve all rights in the program. Neither the authors,
//University of Washington, or U.S. Government make any warranty, 
//express or implied, or assume any liability or responsibility 
//for the use of this software.
//-------------------------------------------------------------

#pragma mark ***Imported Files

#import "ORGT521Model.h"
#import "ORSerialPortAdditions.h"
#import "ORDataTypeAssigner.h"
#import "ORDataPacket.h"
#import "ORTimeRate.h"
#import "ORAlarm.h"

#pragma mark ***External Strings
NSString* ORGT521ModelLocationChanged = @"ORGT521ModelLocationChanged";
NSString* ORGT521ModelCountAlarmLimitChanged = @"ORGT521ModelCountAlarmLimitChanged";
NSString* ORGT521ModelMaxCountsChanged = @"ORGT521ModelMaxCountsChanged";
NSString* ORGT521ModelCycleNumberChanged	= @"ORGT521ModelCycleNumberChanged";
NSString* ORGT521ModelCycleWillEndChanged	= @"ORGT521ModelCycleWillEndChanged";
NSString* ORGT521ModelCycleStartedChanged	= @"ORGT521ModelCycleStartedChanged";
NSString* ORGT521ModelRunningChanged		= @"ORGT521ModelRunningChanged";
NSString* ORGT521ModelCycleDurationChanged = @"ORGT521ModelCycleDurationChanged";
NSString* ORGT521ModelCountingModeChanged	= @"ORGT521ModelCountingModeChanged";
NSString* ORGT521ModelCount2Changed		= @"ORGT521ModelCount2Changed";
NSString* ORGT521ModelCount1Changed		= @"ORGT521ModelCount1Changed";
NSString* ORGT521ModelSize2Changed			= @"ORGT521ModelSize2Changed";
NSString* ORGT521ModelSize1Changed			= @"ORGT521ModelSize1Changed";
NSString* ORGT521ModelMeasurementDateChanged = @"ORGT521ModelMeasurementDateChanged";
NSString* ORGT521ModelMissedCountChanged	= @"ORGT521ModelMissedCountChanged";

NSString* ORGT521Lock = @"ORGT521Lock";

@interface ORGT521Model (private)
- (void) timeout;
- (void) processOneCommandFromQueue;
- (void) process_response:(NSString*)theResponse;
- (void) goToNextCommand;
- (void) startTimeOut;
- (void) checkCycle;
- (void) processStatus:(NSString*)aString;
- (void) clearDelay;
- (void) startDataArrivalTimeout;
- (void) cancelDataArrivalTimeout;
- (void) doCycleKick;
- (void) postCouchDBRecord;
@end

@implementation ORGT521Model

#define kGT521CmdTimeout  10

- (id) init
{
	self = [super init];
	[self setMaxCounts:1000];
	[self setCountAlarmLimit:800];
	return self;
}

- (void) dealloc
{
    [cycleWillEnd release];
    [cycleStarted release];
    [measurementDate release];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [buffer release];
	[missingCyclesAlarm release];
	[missingCyclesAlarm clearAlarm];
	
	int i;
	for(i=0;i<2;i++){
		[timeRates[i] release];
	}	
	[super dealloc];
}

- (void) sleep
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	[super sleep];
}

- (void) wakeUp
{
	[super wakeUp];
}

- (void) setUpImage
{
	[self setImage:[NSImage imageNamed:@"GT521.tif"]];
}

- (void) makeMainController
{
	[self linkToController:@"ORGT521Controller"];
}

- (void) dataReceived:(NSNotification*)note
{
    if([[note userInfo] objectForKey:@"serialPort"] == serialPort){
		
        
        NSString* theString = [[[[NSString alloc] initWithData:[[note userInfo] objectForKey:@"data"] 
												      encoding:NSASCIIStringEncoding] autorelease] uppercaseString];
		
		[self process_response:theString];
	}
}

#pragma mark ***Accessors

- (int) location
{
    return location;
}

- (void) setLocation:(int)aLocation
{
    [[[self undoManager] prepareWithInvocationTarget:self] setLocation:location];
    
    location = aLocation;

    [[NSNotificationCenter defaultCenter] postNotificationName:ORGT521ModelLocationChanged object:self];
}
- (int) missedCycleCount
{
    return missedCycleCount;
}

- (void) setMissedCycleCount:(int)aValue
{
    missedCycleCount = aValue;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORGT521ModelMissedCountChanged object:self];
    
	if((missedCycleCount >= 3) && (countingMode == kGT521Counting)){
		if(!missingCyclesAlarm){
			NSString* s = [NSString stringWithFormat:@"GT521 (Unit %lu) Missing Cycles",[self uniqueIdNumber]];
			missingCyclesAlarm = [[ORAlarm alloc] initWithName:s severity:kHardwareAlarm];
			[missingCyclesAlarm setSticky:YES];
            [missingCyclesAlarm setHelpString:@"The particle counter is not reporting counts at the end of its cycle. ORCA tried to kick start it at least three times.\n\nThis alarm will not go away until the problem is cleared. Acknowledging the alarm will silence it."];
			[missingCyclesAlarm postAlarm];
		}
	}
	else {
		[missingCyclesAlarm clearAlarm];
		[missingCyclesAlarm release];
		missingCyclesAlarm = nil;
	}
    
}
- (BOOL) dataForChannelValid:(int)aChannel
{
    return dataValid && [serialPort isOpen];
}

- (float) countAlarmLimit
{
    return countAlarmLimit;
}

- (void) setCountAlarmLimit:(float)aCountAlarmLimit
{
    [[[self undoManager] prepareWithInvocationTarget:self] setCountAlarmLimit:countAlarmLimit];
    countAlarmLimit = aCountAlarmLimit;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORGT521ModelCountAlarmLimitChanged object:self];
}

- (float) maxCounts
{
    return maxCounts;
}

- (void) setMaxCounts:(float)aMaxCounts
{
    [[[self undoManager] prepareWithInvocationTarget:self] setMaxCounts:maxCounts];
    
    maxCounts = aMaxCounts;

    [[NSNotificationCenter defaultCenter] postNotificationName:ORGT521ModelMaxCountsChanged object:self];
}

- (ORTimeRate*)timeRate:(int)index
{
	return timeRates[index];
}

- (int) cycleNumber
{
    return cycleNumber;
}

- (void) setCycleNumber:(int)aCycleNumber
{
    cycleNumber = aCycleNumber;

    [[NSNotificationCenter defaultCenter] postNotificationName:ORGT521ModelCycleNumberChanged object:self];
}

- (NSDate*) cycleWillEnd
{
    return cycleWillEnd;
}

- (void) setCycleWillEnd:(NSCalendarDate*)aCycleWillEnd
{
    [aCycleWillEnd retain];
    [cycleWillEnd release];
    cycleWillEnd = aCycleWillEnd;

    [[NSNotificationCenter defaultCenter] postNotificationName:ORGT521ModelCycleWillEndChanged object:self];
}

- (NSDate*) cycleStarted
{
    return cycleStarted;
}

- (void) setCycleStarted:(NSDate*)aCycleStarted
{
    [aCycleStarted retain];
    [cycleStarted release];
    cycleStarted = aCycleStarted;

    [[NSNotificationCenter defaultCenter] postNotificationName:ORGT521ModelCycleStartedChanged object:self];
}

- (BOOL) running
{
    return running;
}

- (void) setRunning:(BOOL)aRunning
{
    running = aRunning;

    [[NSNotificationCenter defaultCenter] postNotificationName:ORGT521ModelRunningChanged object:self];
}

- (int) cycleDuration
{
    return cycleDuration;
}

- (void) setCycleDuration:(int)aCycleDuration
{
	if(aCycleDuration == 0) aCycleDuration = 1;
    [[[self undoManager] prepareWithInvocationTarget:self] setCycleDuration:cycleDuration];
    
    cycleDuration = aCycleDuration;

    [[NSNotificationCenter defaultCenter] postNotificationName:ORGT521ModelCycleDurationChanged object:self];
}

- (int) countingMode
{
    return countingMode;
}

- (void) setCountingMode:(int)aCountingMode
{
    countingMode = aCountingMode;

    [[NSNotificationCenter defaultCenter] postNotificationName:ORGT521ModelCountingModeChanged object:self];
}

- (NSString*) countingModeString
{
	switch ([self countingMode]) {
		case kGT521Counting: return @"Counting";
		case kGT521Holding:  return @"Holding";
		case kGT521Stopped:  return @"Stopped";
		default: return @"--";
	}
}

- (int) count2
{
    return count2;
}

- (void) setCount2:(int)aCount2
{
	//normalize to counts/ft^3
	//flow for this model is .1 ft^3/min
    count2 = aCount2*10/(float)cycleDuration;;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORGT521ModelCount2Changed object:self];
	if(timeRates[1] == nil) timeRates[1] = [[ORTimeRate alloc] init];
	[timeRates[1] addDataToTimeAverage:count2];
}

- (int) count1
{
    return count1;
}

- (void) setCount1:(int)aCount1
{
	//normalize to counts/ft^3
	//flow for this model is .1 ft^3/min
    count1 = aCount1*10/(float)cycleDuration;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORGT521ModelCount1Changed object:self];
	if(timeRates[0] == nil) timeRates[0] = [[ORTimeRate alloc] init];
	[timeRates[0] addDataToTimeAverage:count1];
}

- (float) size2
{
    return size2;
}

- (void) setSize2:(float)aSize2
{
    size2 = aSize2;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORGT521ModelSize2Changed object:self];
}

- (float) size1
{
    return size1;
}

- (void) setSize1:(float)aSize1
{
    size1 = aSize1;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORGT521ModelSize1Changed object:self];
}

- (NSString*) measurementDate
{
	if(!measurementDate)return @"";
    else return measurementDate;
}

- (void) setMeasurementDate:(NSString*)aMeasurementDate
{
    [measurementDate autorelease];
    measurementDate = [aMeasurementDate copy];    

    [[NSNotificationCenter defaultCenter] postNotificationName:ORGT521ModelMeasurementDateChanged object:self];
}

- (unsigned long) timeMeasured
{
	return timeMeasured;
}

- (NSString*) lastRequest
{
	return lastRequest;
}

- (void) setLastRequest:(NSString*)aRequest
{
	[lastRequest autorelease];
	lastRequest = [aRequest copy];    
}


- (void) setUpPort
{
	[serialPort setSpeed:9600];
	[serialPort setParityNone];
	[serialPort setStopBits2:NO];
	[serialPort setDataBits:8];
}

- (void) firstActionAfterOpeningPort
{
	if(wasRunning)[self startCycle];
}

#pragma mark ***Archival
- (id) initWithCoder:(NSCoder*)decoder
{
	self = [super initWithCoder:decoder];
	[[self undoManager] disableUndoRegistration];
	[self setLocation:[decoder decodeIntForKey:@"location"]];
	wasRunning = [decoder decodeBoolForKey:@"wasRunning"];
	[self setCycleDuration:		[decoder decodeIntForKey:@"cycleDuration"]];
	[self setCountAlarmLimit:	[decoder decodeFloatForKey:@"countAlarmLimit"]];
	[self setMaxCounts:			[decoder decodeFloatForKey:@"maxCounts"]];
    if(location<=0)location = 1;
    
	[[self undoManager] enableUndoRegistration];
    
	int i; 
	for(i=0;i<2;i++){
		timeRates[i] = [[ORTimeRate alloc] init];
	}
	
	
	return self;
}
- (void) encodeWithCoder:(NSCoder*)encoder
{
    [super encodeWithCoder:encoder];
    [encoder encodeInt:     location        forKey:@"location"];
    [encoder encodeFloat:	countAlarmLimit forKey:@"countAlarmLimit"];
    [encoder encodeFloat:	maxCounts		forKey:@"maxCounts"];
    [encoder encodeInt:		cycleDuration	forKey:@"cycleDuration"];
    [encoder encodeBool:	wasRunning		forKey:	@"wasRunning"];
}

#pragma mark *** Commands
- (void) addCmdToQueue:(NSString*)aCmd
{
   if([serialPort isOpen]){
       if(![aCmd hasSuffix:@"\r\n"]) aCmd = [aCmd stringByAppendingFormat:@"\r\n"];
	   [self enqueueCmd:aCmd];
	   [self enqueueCmd:@"++Delay"];
		if(!lastRequest){
			[self processOneCommandFromQueue];
		}
	}
}

- (void) startCounting				{ [self addCmdToQueue:@"S"]; }
- (void) stopCounting				{ [self addCmdToQueue:@"E"]; }
- (void) clearBuffer				{ [self addCmdToQueue:@"BY"]; }
- (void) getFirmwareVersion			{ [self addCmdToQueue:@"Q"]; }
- (void) getLastRecord				{ [self addCmdToQueue:@"L"]; }
- (void) selectUnit                 { [self addCmdToQueue:[NSString stringWithFormat:@"U%d",location]]; }

#pragma mark ***Polling and Cycles
- (void) startCycle
{
    [self startCycle:NO];
}
- (void) startCycle:(BOOL)force
{
	if((![self running] || force) && [serialPort isOpen]){
		[self setRunning:YES];
		[self setCycleNumber:1];
		NSDate* now = [NSDate date];
		[self setCycleStarted:now];
        NSDate* endTime = [now dateByAddingTimeInterval:[self cycleDuration]*60];
		[self setCycleWillEnd:endTime]; 
		[self clearBuffer];
		[self startCounting];
		[self checkCycle];
        [self startDataArrivalTimeout];
		NSLog(@"GT521(%d) Starting particle counter\n",[self uniqueIdNumber]);
	}
}

- (void) stopCycle
{
	if([self running] && [serialPort isOpen]){
		[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(checkCycle) object:nil];
		[self setRunning:NO];
		[self setCycleNumber:0];
		[self stopCounting];
		[self getLastRecord];
        [self cancelDataArrivalTimeout];
		NSLog(@"GT521(%d) Stopping particle counter\n",[self uniqueIdNumber]);
	}
}

#pragma mark •••Bit Processing Protocol
- (void) processIsStarting
{
	if(!running){
		if(!sentStartOnce){
			sentStartOnce = YES;
			sentStopOnce = NO;
            wasRunning = NO;
			
			[self startCycle:YES];
		}
	}
    else wasRunning = YES;

}

- (void) processIsStopping
{
	if(!wasRunning){
		if(!sentStopOnce){
			sentStopOnce = YES;
			sentStartOnce = NO;
			[self stopCycle];
		}
	}
}

//note that everything called by these routines MUST be threadsafe
- (void) startProcessCycle
{    
	@try { 
	}
	@catch(NSException* localException) { 
		//catch this here to prevent it from falling thru, but nothing to do.
	}
}

- (void) endProcessCycle
{
}

- (NSString*) identifier
{
	NSString* s;
 	@synchronized(self){
		s= [NSString stringWithFormat:@"GT521,%lu",[self uniqueIdNumber]];
	}
	return s;
}

- (NSString*) processingTitle
{
	NSString* s;
 	@synchronized(self){
		s= [self identifier];
	}
	return s;
}

- (double) convertedValue:(int)aChan
{
	double theValue;
	@synchronized(self){
		if(aChan==0) theValue = [self count1];
		else		 theValue = [self count2];
	}
	return theValue;
}

- (double) maxValueForChan:(int)aChan
{
	double theValue;
	@synchronized(self){
		theValue = (double)[self maxCounts]; 
	}
	return theValue;
}

- (double) minValueForChan:(int)aChan
{
	return 0;
}

- (void) getAlarmRangeLow:(double*)theLowLimit high:(double*)theHighLimit channel:(int)channel
{
	@synchronized(self){
		*theLowLimit = -.001;
		*theHighLimit =  [self countAlarmLimit]; 
	}		
}

- (BOOL) processValue:(int)channel
{
	BOOL r;
	@synchronized(self){
		r = YES;    //temp -- figure out what the process bool for this object should be.
	}
	return r;
}

- (void) setProcessOutput:(int)channel value:(int)value
{
    //nothing to do. not used in adcs. really shouldn't be in the protocol
}

@end

@implementation ORGT521Model (private)

- (void) postCouchDBRecord
{
    NSDictionary* values = [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSArray arrayWithObjects:
                             [NSNumber numberWithInt:count1],
                             [NSNumber numberWithInt:count2],
                              nil], @"counts",
                            [NSNumber numberWithInt:    cycleDuration],    @"pollTime",
                            nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ORCouchDBAddObjectRecord" object:self userInfo:values];
}

- (void) checkCycle
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(checkCycle) object:nil];
	if(running){
		NSDate* now = [NSDate date];
		if([cycleWillEnd timeIntervalSinceDate:now] >= 0){
			[[NSNotificationCenter defaultCenter] postNotificationName:ORGT521ModelCycleWillEndChanged object:self];
			//[self getMode];
			[self performSelector:@selector(checkCycle) withObject:nil afterDelay:2];
		}
		else {
			//time to end this cycle
			[self stopCounting];
			[self getLastRecord];

			NSDate* endTime = [now dateByAddingTimeInterval:[self cycleDuration]*60];
			
			[self setCycleStarted:now];
			[self setCycleWillEnd:endTime]; 
			[self startCounting];
			int theCount = [self cycleNumber];
			[self setCycleNumber:theCount+1];
			[self performSelector:@selector(checkCycle) withObject:nil afterDelay:1];
		}
	}
}
- (void) startDataArrivalTimeout
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(doCycleKick) object:nil];
    [self performSelector:@selector(doCycleKick)  withObject:nil afterDelay:((cycleDuration*60)+120)];
}

- (void) cancelDataArrivalTimeout
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(doCycleKick) object:nil];
}

- (void) doCycleKick
{
    [self setMissedCycleCount:missedCycleCount+1];
    NSLogColor([NSColor redColor],@"%@ data did not arrive at end of cycle (missed %d)\n",[self fullID],missedCycleCount);
	NSLogColor([NSColor redColor],@"Kickstarting %@\n",[self fullID]);		
	[self stopCycle];
	[self startCycle:YES];
}

- (void) timeout
{
	[super timeout];
}

- (void) recoverFromTimeout
{
}

- (void) goToNextCommand
{
	[self setLastRequest:nil];			 //clear the last request
	[self processOneCommandFromQueue];	 //do the next command in the queue
}

- (void) clearDelay
{
	delay = NO;
	[self processOneCommandFromQueue];
}

- (void) processOneCommandFromQueue
{
	if(delay)return;
	
	NSString* aCmd = [self nextCmd];
	if(aCmd){
		if([aCmd isEqualToString:@"++Delay"]){
			delay = YES;
			[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(clearDelay) object:nil];
			[self performSelector:@selector(clearDelay) withObject:nil afterDelay:kGT521DelayTime];
		}
		else {
			[self setLastRequest:aCmd];
			[self startTimeOut];
			[serialPort writeString:[NSString stringWithFormat:@"U%d\r\n",location]];
			[serialPort writeString:aCmd];
		}
	}
	if(!lastRequest){
		[self performSelector:@selector(processOneCommandFromQueue) withObject:nil afterDelay:3];
	}
}

- (void) process_response:(NSString*)theResponse
{
	//NSLog(@"response: %@\n",theResponse);
    BOOL gotResponse = NO;
    if([theResponse hasPrefix:@"unit"]){
        gotResponse = YES;
    }
    else if([theResponse hasPrefix:@"counting"]){
        gotResponse = YES;
    }
	else {
        dataValid = YES;

        [buffer appendString:theResponse];
        [buffer autorelease];
        buffer = [[[buffer componentsSeparatedByString:@"  "]componentsJoinedByString:@" "] mutableCopy] ;

        NSArray* parts = [buffer componentsSeparatedByString:@","];
        if([parts count] >= 10){
            NSString* datePart		= [parts objectAtIndex:0];
            NSString* timePart		= [parts objectAtIndex:1];
            //id is part 2
            NSString* size1Part		= [parts objectAtIndex:3];
            NSString* count1Part	= [parts objectAtIndex:4];
            NSString* size2Part		= [parts objectAtIndex:5];
            NSString* count2Part	= [parts objectAtIndex:6];
            if([datePart length] >= 6 && [timePart length] >= 6){
                [self setMeasurementDate: [NSString stringWithFormat:@"%02d/%02d/%02d %02d:%02d:%02d",
                                           [[datePart substringWithRange:NSMakeRange(0,2)]intValue],
                                           [[datePart substringWithRange:NSMakeRange(2,2)]intValue],
                                           [[datePart substringWithRange:NSMakeRange(4,2)]intValue],
                                           [[timePart substringWithRange:NSMakeRange(0,2)]intValue],
                                           [[timePart substringWithRange:NSMakeRange(2,2)]intValue],
                                           [[timePart substringWithRange:NSMakeRange(4,2)]intValue]
                                           ]];
            }
            
            [self setSize1: [size1Part floatValue]];
            [self setCount1: [count1Part intValue]];
            [self setSize2: [size2Part floatValue]];
            [self setCount2: [count2Part intValue]];
                            
            [self setMissedCycleCount:0];
            [self startDataArrivalTimeout];
            
            [self postCouchDBRecord];
		}
    }
    if(gotResponse){
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(timeout) object:nil];
        [self performSelector:@selector(goToNextCommand) withObject:nil afterDelay:1];
    }
    
}

- (void) processStatus:(NSString*)aString
{
	NSString* s = [aString substringWithRange:NSMakeRange(1,1)];
	if([s isEqualToString:@"C"])	  [self setCountingMode:kGT521Counting];
	else if([s isEqualToString:@"H"]) [self setCountingMode:kGT521Holding];
	else if([s isEqualToString:@"S"]) [self setCountingMode:kGT521Stopped];
}

- (void) startTimeOut
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(timeout) object:nil];
	[self performSelector:@selector(timeout) withObject:nil afterDelay:kGT521CmdTimeout];
}
@end
