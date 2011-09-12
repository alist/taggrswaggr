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
#import "UIViewControllerAdditions.h"

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
	
	[self setTabURLs:[NSArray arrayWithObjects:@"tt://name/",@"tt://date/", nil]];	

	// this is highly unoptomized; in the future, let's just iterate through each navigation controller and set tab bar items here!
	//see: http://www.jefflinwood.com/2010/11/quick-tip-adding-icons-to-three20-tab-bar/
	for (UIViewController * controller in [self viewControllers]){
		UIViewController * topController = [controller topSubcontroller];
		topController.view;
	}

}

@end
