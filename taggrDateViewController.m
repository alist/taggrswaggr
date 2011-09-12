//
//  taggrDateViewController.m
//  Taggr
//
//  Created by Alexander List on 9/9/11.
//  Copyright 2011 ExoMachina. All rights reserved.
//

#import "taggrDateViewController.h"

@implementation taggrDateViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(void) viewDidLoad{
	[super viewDidLoad];
	

	[self setTitle:@"Date"];
}

-(taggrSortType)	tagSortType{
	return taggrSortTypeDate;
}

@end
