//
//  faveGroup.h
//  Taggr
//
//  Created by Alexander List on 3/27/11.
//  Copyright 2011 ExoMachina. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface faveGroup : NSManagedObject {

}
@property (nonatomic, retain) NSSet* includedTags;
@end
