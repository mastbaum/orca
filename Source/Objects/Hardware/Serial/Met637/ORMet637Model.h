//--------------------------------------------------------
// ORMet637Model
// Created by Mark  A. Howe on Mon Jan 23, 2012
// Code partially generated by the OrcaCodeWizard. Written by Mark A. Howe.
// Copyright (c) 2012 University of North Carolina. All rights reserved.
//-----------------------------------------------------------
//This program was prepared for the Regents of the University of 
//North Carolina sponsored in part by the United States 
//Department of Energy (DOE) under Grant #DE-FG02-97ER41020. 
//The University has certain rights in the program pursuant to 
//the contract and the program should not be copied or distributed 
//outside your organization.  The DOE and the University of 
//Washington reserve all rights in the program. Neither the authors,
//University of North Carolina, or U.S. Government make any warranty, 
//express or implied, or assume any liability or responsibility 
//for the use of this software.
//-------------------------------------------------------------

#pragma mark ***Imported Files
#import "ORAdcProcessing.h"

@class ORSerialPort;
@class ORTimeRate;

#define kMet637CmdTimeout  1
#define kMet637ProbeTime   5

#define kMet637Manual  0
#define kMet637Auto    1

@interface ORMet637Model : OrcaObject <ORAdcProcessing>
{
    @private
        NSString*       portName;
        BOOL            portWasOpen;
        ORSerialPort*   serialPort;
        unsigned long	dataId;
		NSString*		lastRequest;
		unsigned long	timeMeasured;
        NSMutableString* buffer;
		unsigned int    currentRequest;
		unsigned int    waitTime;
		unsigned int    expectedCount;
		NSString*		measurementDate;
		ORTimeRate*		timeRates[8];
		int				count[6];
		float			maxCounts[8];
		float			countAlarmLimit[8];
		int				countingMode;
		int				cycleDuration;
		BOOL			running;
		NSDate*			cycleStarted;
		NSDate*			cycleWillEnd;
		int				cycleNumber;
		BOOL			recordComingIn;
		BOOL			statusComingIn;
		BOOL			wasRunning;
		int				actualDuration;
		float			temperature;
		float			humidity;
		int				location;
		int				statusBits;
		int				countUnits;
		int				tempUnits;
		BOOL			probing;
		int				holdTime;
		BOOL			isLog;
		BOOL			timedOut;
		BOOL			dumpInProgress;
		int				dumpCount;
}

#pragma mark ***Initialization
- (id)   init;
- (void) dealloc;
- (void) registerNotificationObservers;
- (void) dataReceived:(NSNotification*)note;

#pragma mark ***Accessors
- (int) dumpCount;
- (void) setDumpCount:(int)aDumpCount;
- (BOOL) dumpInProgress;
- (void) setDumpInProgress:(BOOL)aDumpInProgress;
- (BOOL) timedOut;
- (void) setTimedOut:(BOOL)aTimedOut;
- (BOOL) isLog;
- (void) setIsLog:(BOOL)aIsLog;
- (int) holdTime;
- (void) setHoldTime:(int)aHoldTime;
- (int) tempUnits;
- (void) setTempUnits:(int)aTempUnits;
- (int) countUnits;
- (void) setCountUnits:(int)aCountUnits;
- (int) statusBits;
- (void) setStatusBits:(int)aStatusBits;
- (int) location;
- (void) setLocation:(int)aLocation;
- (float) humidity;
- (void) setHumidity:(float)aHumidity;
- (float) temperature;
- (void) setTemperature:(float)aTemperature;
- (int) actualDuration;
- (void) setActualDuration:(int)aActualDuration;
- (ORTimeRate*)timeRate:(int)index;
- (int) cycleNumber;
- (void) setCycleNumber:(int)aCycleNumber;
- (NSDate*) cycleWillEnd;
- (void) setCycleWillEnd:(NSDate*)aCycleWillEnd;
- (NSDate*) cycleStarted;
- (void) setCycleStarted:(NSDate*)aCycleStarted;
- (BOOL) running;
- (void) setRunning:(BOOL)aRunning;
- (int) cycleDuration;
- (void) setCycleDuration:(int)aCycleDuration;
- (int) countingMode;
- (void) setCountingMode:(int)aCountingMode;
- (void) setCount:(int)index value:(int)aValue;
- (int) count:(int)index;
- (NSString*) measurementDate;
- (void) setMeasurementDate:(NSString*)aMeasurementDate;
- (ORSerialPort*) serialPort;
- (void) setSerialPort:(ORSerialPort*)aSerialPort;
- (BOOL) portWasOpen;
- (void) setPortWasOpen:(BOOL)aPortWasOpen;
- (NSString*) portName;
- (void) setPortName:(NSString*)aPortName;
- (void) openPort:(BOOL)state;
- (unsigned long) timeMeasured;
- (NSString*) countingModeString;
- (float) countAlarmLimit:(int)index;
- (void) setIndex:(int)index countAlarmLimit:(float)aCountAlarmLimit;
- (float) maxCounts:(int)index;
- (void) setIndex:(int)index maxCounts:(float)aMaxCounts;

#pragma mark ***Polling
- (void) startCycle;
- (void) stopCycle;

#pragma mark ***Commands
- (void) sendAllData;
- (void) sendNewData;
- (void) setDate;
- (void) sendClearData;
- (void) sendStart;
- (void) sendEnd;
- (void) getSampleTime;
- (void) getSampleMode;
- (void) getLocation;
- (void) getHoldTime;
- (void) getUnits;	
- (void) sendCountingTime:(int)aValue;
- (void) sendCountingMode:(BOOL)aValue;
- (void) sendID:(int)aValue;
- (void) sendHoldTime:(int)aValue;
- (void) sendTempUnit:(int)aTempUnit countUnits:(int)aCountUnit;
- (void) probe;

#pragma mark •••Adc Processing Protocol
- (void)processIsStarting;
- (void)processIsStopping;
- (void) startProcessCycle;
- (void) endProcessCycle;
- (BOOL) processValue:(int)channel;
- (void) setProcessOutput:(int)channel value:(int)value;
- (NSString*) processingTitle;
- (void) getAlarmRangeLow:(double*)theLowLimit high:(double*)theHighLimit  channel:(int)channel;
- (double) convertedValue:(int)channel;
- (double) maxValueForChan:(int)channel;

#pragma mark •••Archival
- (id)   initWithCoder:(NSCoder*)decoder;
- (void) encodeWithCoder:(NSCoder*)encoder;

@end

extern NSString* ORMet637ModelDumpCountChanged;
extern NSString* ORMet637ModelDumpInProgressChanged;
extern NSString* ORMet637ModelTimedOutChanged;
extern NSString* ORMet637ModelIsLogChanged;
extern NSString* ORMet637ModelHoldTimeChanged;
extern NSString* ORMet637ModelTempUnitsChanged;
extern NSString* ORMet637ModelCountUnitsChanged;
extern NSString* ORMet637ModelStatusBitsChanged;
extern NSString* ORMet637ModelLocationChanged;
extern NSString* ORMet637ModelHumidityChanged;
extern NSString* ORMet637ModelTemperatureChanged;
extern NSString* ORMet637ModelActualDurationChanged;
extern NSString* ORMet637ModelCountAlarmLimitChanged;
extern NSString* ORMet637ModelMaxCountsChanged;
extern NSString* ORMet637ModelCycleNumberChanged;
extern NSString* ORMet637ModelCycleWillEndChanged;
extern NSString* ORMet637ModelCycleStartedChanged;
extern NSString* ORMet637ModelRunningChanged;
extern NSString* ORMet637ModelCycleDurationChanged;
extern NSString* ORMet637ModelCountingModeChanged;
extern NSString* ORMet637ModelCountChanged;
extern NSString* ORMet637ModelMeasurementDateChanged;
extern NSString* ORMet637ModelPollTimeChanged;
extern NSString* ORMet637ModelSerialPortChanged;
extern NSString* ORMet637Lock;
extern NSString* ORMet637ModelPortNameChanged;
extern NSString* ORMet637ModelPortStateChanged;

