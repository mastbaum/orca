//--------------------------------------------------------
// ORPacFPModel
// Created by Mark  A. Howe on Mon Jun 16, 2014
// Code partially generated by the OrcaCodeWizard. Written by Mark A. Howe.
// Copyright (c) 2014, University of North Carolina. All rights reserved.
//-----------------------------------------------------------
//This program was prepared for the Regents of the University of
//North Carolina sponsored in part by the United States
//Department of Energy (DOE) under Grant #DE-FG02-97ER41020.
//The University has certain rights in the program pursuant to
//the contract and the program should not be copied or distributed
//outside your organization.  The DOE and the University of
//North Carolina reserve all rights in the program. Neither the authors,
//University of North Carolina, or U.S. Government make any warranty,
//express or implied, or assume any liability or responsibility
//for the use of this software.
//-------------------------------------------------------------

#pragma mark •••Imported Files
#import "ORAdcProcessing.h"
#import "ORBitProcessing.h"

@class ORTimeRate;
@class ORSafeQueue;
@class NetSocket;

@interface ORPacFPModel : OrcaObject <ORAdcProcessing,ORBitProcessing>
{
    @private
        //ip protocol
        NSString*           ipAddress;
        BOOL                isConnected;
        NetSocket*          socket;
        BOOL                wasConnected;
  
        unsigned long		dataId;
		NSString*			lastRequest;
		ORSafeQueue*		cmdQueue;
		NSMutableString*    buffer;
    
        unsigned short		adc[8];
		unsigned long		timeMeasured[8];
		ORTimeRate*			timeRates[8];
        int					gain[148];
        int					gainReadBack[148];
		BOOL				pollRunning;
		NSTimeInterval		pollingState;
		BOOL				logToFile;
		NSString*			logFile;
		NSMutableArray*		logBuffer;
		unsigned long		readCount;
		int					gainDisplayType;
		NSString*			lastGainFile;
        BOOL                readOnce;
        NSMutableArray*     processLimits;    
        int                 gainIndex;
        unsigned short      lcm;
        unsigned short      lcmTimeMeasured;
        NSDate*             lastGainRead;
        int                 workingOnGain;
        BOOL                setGainsResult;
}

#pragma mark •••Initialization
- (void) dealloc;

#pragma mark •••Accessors
- (BOOL) setGainsResult;
- (void) setSetGainsResult:(BOOL)aSetGainsResult;
- (int) workingOnGain;
- (void) setWorkingOnGain:(int)aWorkingOnGain;
- (NetSocket*) socket;
- (void) setSocket:(NetSocket*)aSocket;
- (NSString*) ipAddress;
- (void) setIpAddress:(NSString*)aIpAddress;
- (BOOL) isConnected;
- (void) setIsConnected:(BOOL)aFlag;
- (void) writeCmdString:(NSString*)aCommand;
- (void) parseString:(NSString*)theString;
- (void) connect;

- (NSString*) title;

- (NSDate*) lastGainRead;
- (void) setLastGainRead:(NSDate*)aLastGainRead;
- (unsigned short) lcmTimeMeasured;
- (unsigned short) lcm;
- (void) setLcm:(unsigned short)aLc;
- (NSString*) lastGainFile;
- (void) setLastGainFile:(NSString*)aLastGainFile;
- (int) gainDisplayType;
- (void) setGainDisplayType:(int)aGainDisplayType;
- (ORTimeRate*)timeRate:(int)index;
- (void) setPollingState:(NSTimeInterval)aState;
- (NSTimeInterval) pollingState;
- (int)  gain:(int)index;
- (void) setGain:(int)index withValue:(int)aValue;
- (int)  gainReadBack:(int)index;
- (void) setGainReadBack:(int)index withValue:(int)aValue;
- (NSString*) lastRequest;
- (void) setLastRequest:(NSString*)aRequest;
- (unsigned short) adc:(int)index;
- (unsigned long) timeMeasured:(int)index;
- (void) setAdc:(int)index value:(unsigned short)aValue;
- (float) lcmVoltage;
- (float) adcVoltage:(int)index;
- (float) convertedLcm;
- (float) convertedAdc:(int)index;
- (NSString*) logFile;
- (void) setLogFile:(NSString*)aLogFile;
- (BOOL) logToFile;
- (void) setLogToFile:(BOOL)aLogToFile;
- (int) queCount;
- (void) setProcessLimitDefaults;
- (void) flushQueue;

#pragma mark •••Data Records
- (void) appendDataDescription:(ORDataPacket*)aDataPacket userInfo:(id)userInfo;
- (NSDictionary*) dataRecordDescription;
- (unsigned long) dataId;
- (void) setDataId: (unsigned long) DataId;
- (void) setDataIds:(id)assigner;
- (void) syncDataIdsWith:(id)anotherPacFP;
- (void) writeLogBufferToFile;

#pragma mark •••Commands
- (void) getGains;
- (void) setGains;
- (void) getTemperatures;
- (void) getCurrent;
- (void) writeShipCmd;
- (void) readAdcs;

- (id)   initWithCoder:(NSCoder*)decoder;
- (void) encodeWithCoder:(NSCoder*)encoder;
- (void) readGainFile:(NSString*) aPath;
- (void) saveGainFile:(NSString*) aPath;
- (NSMutableArray*) processLimits;
- (NSString*)processName:(int)aChan;
- (NSString*)adcName:(int)aChan;

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
@end

@interface NSObject (ORHistModel)
- (void) removeFrom:(NSMutableArray*)anArray;
@end

extern NSString* ORPacFPModelSetGainsResultChanged;
extern NSString* ORPacFPModelWorkingOnGainChanged;
extern NSString* ORPacFPModelLastGainReadChanged;
extern NSString* ORPacFPModelLcmChanged;
extern NSString* ORPacFPModelProcessLimitsChanged;
extern NSString* ORPacFPModelGainDisplayTypeChanged;
extern NSString* ORPacFPLock;
extern NSString* ORPacFPModelAdcChanged;
extern NSString* ORPacFPModelGainsChanged;
extern NSString* ORPacFPModelGainReadBacksChanged;
extern NSString* ORPacFPModelPollingStateChanged;
extern NSString* ORPacFPModelLogToFileChanged;
extern NSString* ORPacFPModelLogFileChanged;
extern NSString* ORPacFPModelQueCountChanged;
extern NSString* ORPacFPModelGainsReadBackChanged;
extern NSString* ORPacFPModelIsConnectedChanged;
extern NSString* ORPacFPModelIpAddressChanged;

