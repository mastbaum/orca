//
//  ORSIS3302Decoders.m
//  Orca
//
//  Created by Mark A. Howe on Wednesday 9/30/08.
//  Copyright (c) 2008 CENPA. University of Washington. All rights reserved.
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

#import "ORSIS3302Decoders.h"
#import "ORDataPacket.h"
#import "ORDataSet.h"
#import "ORDataTypeAssigner.h"
#import "ORSIS3302Model.h"


@implementation ORSIS3302Decoder
- (id) init

{
    self = [super init];
    getRatesFromDecodeStage = YES;
    return self;
}

- (void) dealloc
{
	[actualSIS3302Cards release];
    [super dealloc];
}

- (unsigned long) decodeData:(void*)someData fromDecoder:(ORDecoder*)aDecoder intoDataSet:(ORDataSet*)aDataSet
{
    unsigned long* ptr = (unsigned long*)someData;
	unsigned long length = ExtractLength(ptr[0]);
	int crate	= ShiftAndExtract(ptr[1],21,0xf);
	int card	= ShiftAndExtract(ptr[1],16,0x1f);
	int channel = ShiftAndExtract(ptr[1],0,0xff);
	
	NSString* crateKey		= [self getCrateKey: crate];
	NSString* cardKey		= [self getCardKey: card];
	NSString* channelKey	= [self getChannelKey: channel];
	
	unsigned long lastWord = ptr[length-1];
	if(lastWord == 0xdeadbeef){
		unsigned long energy = ptr[length - 4]/4; 
		[aDataSet histogram:energy numBins:65*1024 sender:self  withKeys:@"SIS3302", @"Energy", crateKey,cardKey,channelKey,nil];
		
		long waveformLength = ptr[2];
		long energyLength   = ptr[2];
		
		if(waveformLength){
			unsigned char* bPtr = (unsigned char*)&ptr[4 + 2];
			NSData* recordAsData = [NSData dataWithBytes:bPtr length:waveformLength*sizeof(long)];
			[aDataSet loadWaveform:recordAsData 
							offset: 0 //bytes!
						  unitSize: 2 //unit size in bytes!
							sender: self  
						  withKeys: @"SIS3302", @"ADC Trace",crateKey,cardKey,channelKey,nil];
		}

		if(energyLength){
			unsigned char* bPtr = (unsigned char*)&ptr[4 + 2 + waveformLength];
			NSData* recordAsData = [NSData dataWithBytes:bPtr length:energyLength*sizeof(long)];
			[aDataSet loadWaveform:recordAsData 
							offset: 0
						  unitSize: 2 //unit size in bytes!
							sender: self 						 
						  withKeys: @"SIS3302", @"Energy Waveform",crateKey,cardKey,channelKey,nil];	
		}
	
 
			
		//get the actual object
		if(getRatesFromDecodeStage){
			NSString* aKey = [crateKey stringByAppendingString:cardKey];
			if(!actualSIS3302Cards)actualSIS3302Cards = [[NSMutableDictionary alloc] init];
			ORSIS3302Model* obj = [actualSIS3302Cards objectForKey:aKey];
			if(!obj){
				NSArray* listOfCards = [[[NSApp delegate] document] collectObjectsOfClass:NSClassFromString(@"ORSIS3302Model")];
				NSEnumerator* e = [listOfCards objectEnumerator];
				ORSIS3302Model* aCard;
				while(aCard = [e nextObject]){
					if([aCard slot] == card){
						[actualSIS3302Cards setObject:aCard forKey:aKey];
						obj = aCard;
						break;
					}
				}
			}
			getRatesFromDecodeStage = [obj bumpRateFromDecodeStage:channel];
		}
		
		
	}
 
    return length; //must return number of longs
}

- (NSString*) dataRecordDescription:(unsigned long*)ptr
{
	ptr++;
    NSString* title= @"SIS3302 Waveform Record\n\n";
    NSString* crate = [NSString stringWithFormat:@"Crate = %d\n",(*ptr&0x01e00000)>>21];
    NSString* card  = [NSString stringWithFormat:@"Card  = %d\n",(*ptr&0x001f0000)>>16];
	NSString* moduleID = (*ptr&0x1)?@"SIS3301":@"SIS3302";
	ptr++;
	NSString* triggerWord = [NSString stringWithFormat:@"TriggerWord  = 0x08%x\n",*ptr];
	ptr++;
	NSString* Event = [NSString stringWithFormat:@"Event  = 0x%08x\n",(*ptr>>24)&0xff];
	NSString* Time = [NSString stringWithFormat:@"Time Since Last Trigger  = 0x%08x\n",*ptr&0xffffff];

    return [NSString stringWithFormat:@"%@%@%@%@%@%@%@",title,crate,card,moduleID,triggerWord,Event,Time];               
}

@end
