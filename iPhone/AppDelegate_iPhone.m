//
//  AppDelegate_iPhone.m
//  Taggr
//
//  Created by Alexander List on 3/27/11.
//  Copyright 2011 ExoMachina. All rights reserved.
//

#import "AppDelegate_iPhone.h"
#import "Three20/Three20.h"

@implementation AppDelegate_iPhone


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
	[TTStyleSheet setGlobalStyleSheet:[[[TTDefaultStyleSheet alloc]autorelease] init]];
	
	UINavigationController *	_favesNavigationController		=		[[UINavigationController alloc] initWithRootViewController:[[[UITableViewController alloc] init] autorelease]];
	[_favesNavigationController setTabBarItem:[[[UITabBarItem alloc] initWithTitle:@"faves" image:nil tag:taggerTabIndexFaves] autorelease]];
	
	
	UINavigationController *	_nearbyNavigationController		=		[[UINavigationController alloc] initWithRootViewController:[[[UITableViewController alloc] init] autorelease]];
	[_nearbyNavigationController setTabBarItem:[[[UITabBarItem alloc] initWithTitle:@"nearby" image:nil tag:taggerTabIndexNearby] autorelease]];


	UINavigationController *	_dateNavigationController		=		[[UINavigationController alloc] initWithRootViewController:[[[UITableViewController alloc] init] autorelease]];
	[_dateNavigationController setTabBarItem:[[[UITabBarItem alloc] initWithTitle:@"date" image:nil tag:taggerTabIndexDate] autorelease]];

	
	UITableViewController *		_nameViewController				=	[[UITableViewController alloc] init] ;
	UINavigationController *	_nameNavigationController		=	[[UINavigationController alloc] initWithRootViewController:_nameViewController];
	[_nameNavigationController setTabBarItem:[[[UITabBarItem alloc] initWithTitle:@"name" image:nil tag:taggerTabIndexName] autorelease]];
	TTPickerTextField * bubbleTextField =		[[TTPickerTextField alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
	bubbleTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    bubbleTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    bubbleTextField.rightViewMode = UITextFieldViewModeAlways;
//    bubbleTextField.delegate = self;
    bubbleTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [bubbleTextField sizeToFit];
	
	[bubbleTextField addCellWithObject:[NSString stringWithString:@"Initial Typin!"]];
	[[_nameViewController tableView] setTableHeaderView:bubbleTextField];
	

	SRELS(bubbleTextField);
	
	_mainTabBar =		[[UITabBarController alloc] init];
	[_mainTabBar setViewControllers:[NSArray arrayWithObjects:_nameNavigationController,_dateNavigationController,_nearbyNavigationController,_favesNavigationController,nil] animated:TRUE];
	
	[self.window addSubview:_mainTabBar.view];
	
	SRELS(_favesNavigationController);
	SRELS(_nearbyNavigationController);
	SRELS(_dateNavigationController);
	SRELS(_nameNavigationController);
	
	
	
    [self.window makeKeyAndVisible];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.

     Superclass implementation saves changes in the application's managed object context before the application terminates.
     */
	[super applicationDidEnterBackground:application];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of the transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


/**
 Superclass implementation saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
	[super applicationWillTerminate:application];
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
    [super applicationDidReceiveMemoryWarning:application];
}


- (void)dealloc {
	SRELS(_mainTabBar);
	
	[super dealloc];
}


@end

