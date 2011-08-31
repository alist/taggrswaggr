//
//  taggrTabBarController.m
//  Taggr
//
//  Created by Alexander List on 8/30/11.
//  Copyright 2011 ExoMachina. All rights reserved.
//

#import "taggrTabBarController.h"
#import "Three20.h"
#import "UITabBarControllerAdditions.h"

@implementation taggrTabBarController

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

	[self setTabURLs:[NSArray arrayWithObjects:@"tt://name/", nil]];	
	
	
	if (! [[TTNavigator navigator] restoreViewControllers]) {
		[[TTNavigator navigator] openURLAction:[TTURLAction actionWithURLPath:@"helloworld://tabbar"]];
	}
	
}

@end
