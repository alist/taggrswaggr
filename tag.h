//
//  tag.h
//  Taggr
//
//  Created by Alexander List on 3/27/11.
//  Copyright 2011 ExoMachina. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface tag : NSManagedObject {

}

@property (nonatomic, retain) NSDate * dateCreated;
@property (nonatomic, retain) NSString * extendedNote;
@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * meterDistance;
@property (nonatomic, retain) NSString * tagName;
@property (nonatomic, retain) NSSet* explicitTags;
@property (nonatomic, retain) NSSet* implicitTags;
@property (nonatomic, retain) NSSet* faveGroupsIn;

@end