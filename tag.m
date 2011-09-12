//
//  tag.m
//  Taggr
//
//  Created by Alexander List on 3/27/11.
//  Copyright 2011 ExoMachina. All rights reserved.
//

#define AWAKEFROMUPGRADE 1

#import "tag.h"
#import "exoLocationManager.h"

@implementation tag

@dynamic tagDate, tagDay;
@dynamic extendedNote;
@dynamic image;
@dynamic latitude;
@dynamic longitude;
@dynamic meterDistance;
@dynamic tagName;
@dynamic explicitTags;
@dynamic lastOpenedDate;
@dynamic timesOpened;


#if AWAKEFROMUPGRADE == 1
#warning this is extremely intensive  
-(void) awakeFromFetch{
	if ([self tagDay] == nil){
		[self setTagDate:[self tagDate]];
	}
}
#endif

-(void) awakeFromInsert{
	[super awakeFromInsert];
	[self setTagDate:[NSDate date]];
	[self setLastOpenedDate:[NSDate date]];
	
	CLLocation * location	=	[[exoLocationManager sharedLocationManager] lastLocation];
	if (location != nil){
		[self setTagLocation:location];
	}
}

-(void) setTagDate:(NSDate *)tagDate{	
	[super setPrimitiveValue:tagDate forKey:@"tagDate"];
	[self setValue:[tagDate dateAtMidnight] forKey:@"tagDay"];
}

-(CLLocation*)tagLocation{
	CLLocation* coordinate = [[[CLLocation alloc] initWithLatitude:[[self latitude]doubleValue] longitude:[[self longitude]doubleValue]] autorelease];
	return coordinate;
}

-(void)setTagLocation:(CLLocation*)coordinate{
	if (coordinate == nil)
		return;
	
	NSNumber *longitude = [NSNumber numberWithDouble:[coordinate coordinate].longitude];
	NSNumber *latitude = [NSNumber numberWithDouble:[coordinate coordinate].latitude];
	
	[self setLatitude:latitude];
	[self setLongitude:longitude];
	
}

@end