//
//  AppDelegate_Shared.m
//  Taggr
//
//  Created by Alexander List on 3/27/11.
//  Copyright 2011 ExoMachina. All rights reserved.
//

#import "AppDelegate_Shared.h"
#import "tagTTDataSource.h"
#import "taggerNameViewController.h"
#import "tagViewController.h"
#import "exoLocationManager.h"

@implementation AppDelegate_Shared

@synthesize window;

+(AppDelegate_Shared*)sharedDelegate{
	
	return (AppDelegate_Shared*)[[UIApplication sharedApplication] delegate];
}
#pragma mark -
#pragma mark Application lifecycle
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
	[TTStyleSheet setGlobalStyleSheet:[[[TTDefaultStyleSheet alloc]autorelease] init]];
	
	//	UINavigationController *	_favesNavigationController		=		[[UINavigationController alloc] initWithRootViewController:[[[UITableViewController alloc] init] autorelease]];
	//	[_favesNavigationController setTabBarItem:[[[UITabBarItem alloc] initWithTitle:@"faves" image:nil tag:taggerTabIndexFaves] autorelease]];
	//	
	//	
	//	UINavigationController *	_nearbyNavigationController		=		[[UINavigationController alloc] initWithRootViewController:[[[UITableViewController alloc] init] autorelease]];
	//	[_nearbyNavigationController setTabBarItem:[[[UITabBarItem alloc] initWithTitle:@"nearby" image:nil tag:taggerTabIndexNearby] autorelease]];
	//
	//
	//	UINavigationController *	_dateNavigationController		=		[[UINavigationController alloc] initWithRootViewController:[[[UITableViewController alloc] init] autorelease]];
	//	[_dateNavigationController setTabBarItem:[[[UITabBarItem alloc] initWithTitle:@"date" image:nil tag:taggerTabIndexDate] autorelease]];
	//
	
	TTNavigator* navigator		= [TTNavigator navigator];
	navigator.window			= window;
	TTURLMap* map				= navigator.URLMap;
	
		
	UINavigationController *	nameNavigationController		=	[[UINavigationController alloc] init];
	
	[map	from:@"tt://name/" toViewController:[taggerNameViewController class] selector:@selector(init)];
	[map	from:@"tt://tag/(initWithTagName:)" toViewController:[tagViewController class] selector:@selector(initWithTagName:)];
	
	
	_mainTabBar =		[[UITabBarController alloc] init];
	[_mainTabBar setViewControllers:[NSArray arrayWithObjects:nameNavigationController,nil] animated:TRUE];
	
	
	[self.window addSubview:_mainTabBar.view];
	
	SRELS(nameNavigationController);
	
	[navigator openURLAction:[TTURLAction actionWithURLPath:@"tt://name/"]];
	
	
	[[exoLocationManager sharedLocationManager] setLocationUsageReason:@"Taggr automatically associates tags with your current location; you can easily remove this data."];
	[[exoLocationManager sharedLocationManager] setLocationAccuracy:exoLocationManagerAccuracyScopeCloseBy];
	[[exoLocationManager sharedLocationManager] startLocationService];
	
    [self.window makeKeyAndVisible];
    
    return YES;
}

/**
 Save changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
    [self saveContext];
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    [self saveContext];
}


- (void)saveContext {
    
    NSError *error = nil;
	NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}    
    


#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext {
    
    if (managedObjectContext_ != nil) {
        return managedObjectContext_;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext_ = [[NSManagedObjectContext alloc] init];
        [managedObjectContext_ setPersistentStoreCoordinator:coordinator];
		
		if (_needsPrePopulate){
			NSManagedObject* newTag				=	[NSEntityDescription insertNewObjectForEntityForName:@"tag" inManagedObjectContext:[self managedObjectContext]];
			[newTag setValue:@"Taggr App" forKey:@"tagName"];
			[managedObjectContext_ save:nil];
		}
    }
    return managedObjectContext_;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel {
    
    if (managedObjectModel_ != nil) {
        return managedObjectModel_;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Taggr" withExtension:@"momd"];
    managedObjectModel_ = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return managedObjectModel_;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (persistentStoreCoordinator_ != nil) {
        return persistentStoreCoordinator_;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Taggr.sqlite"];
	
	
	_needsPrePopulate = FALSE;
	if ([[[[NSFileManager alloc] init] autorelease] fileExistsAtPath:[storeURL path]] == NO)
		_needsPrePopulate = TRUE;
		
    NSError *error = nil;
    persistentStoreCoordinator_ = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator_ addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return persistentStoreCoordinator_;
}


#pragma mark -
#pragma mark Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
	SRELS(_mainTabBar);
    
    [managedObjectContext_ release];
    [managedObjectModel_ release];
    [persistentStoreCoordinator_ release];
    
    [window release];
    [super dealloc];
}


@end

