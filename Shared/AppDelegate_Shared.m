//
//  AppDelegate_Shared.m
//  Taggr
//
//  Created by Alexander List on 3/27/11.
//  Copyright 2011 ExoMachina. All rights reserved.
//

#import "AppDelegate_Shared.h"
#import "tagTTDataSource.h"
#import "taggrNameViewController.h"
#import "taggrDateViewController.h"
#import "taggrTabBarController.h"
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
	
	TTNavigator* navigator		= [TTNavigator navigator];
	[navigator setPersistenceMode:TTNavigatorPersistenceModeAll];
	navigator.window			= window;
	TTURLMap* map				= navigator.URLMap;
	
	[map	from:@"tt://name/" toViewController:[taggrNameViewController class] selector:@selector(init)];
	[map	from:@"tt://date/" toViewController:[taggrDateViewController class] selector:@selector(init)];
	[map	from:@"tt://tag/(initWithTagName:)" toViewController:[tagViewController class] selector:@selector(initWithTagName:)];
	[map 	from:@"tt://tabbar/" toViewController:[taggrTabBarController class] selector:@selector(init)];
	
	
	[self.window makeKeyAndVisible];
	if (! [navigator restoreViewControllers]) {
		[navigator openURLAction:[TTURLAction actionWithURLPath:@"tt://tabbar/"]];
	}
	
	[[exoLocationManager sharedLocationManager] setLocationUsageReason:@"Taggr automatically associates tags with your current location; you can easily remove this data."];
	[[exoLocationManager sharedLocationManager] setLocationAccuracy:exoLocationManagerAccuracyScopeCloseBy];
	[[exoLocationManager sharedLocationManager] startLocationService];
	
    
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

- (void)applicationWillResignActive:(UIApplication *)application {
    [self saveContext];
	[[exoLocationManager sharedLocationManager] stopLocaitonService];
}

-(void) applicationDidBecomeActive:(UIApplication *)application{
	[[exoLocationManager sharedLocationManager] startLocationService];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {

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
    
	
	NSFileManager	* fileManager		= [[[NSFileManager alloc] init] autorelease];
	
	
    NSURL *storeURL			= [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Taggr.sqlite"];
	NSString * storePath	=	[storeURL path];
	if ([fileManager fileExistsAtPath:storePath] == NO){
		NSString	* oldDBPath		=	[[NSBundle mainBundle] pathForResource:@"OldTaggr" ofType:@"sqlite"];
		if ([fileManager fileExistsAtPath:oldDBPath] == YES){
			[fileManager copyItemAtPath:oldDBPath toPath:storePath error:nil];
		}

	}
	
		
	NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:[storeURL path] error:NULL];
	BOOL needsSetEncrypted = [[fileAttributes valueForKey:NSFileProtectionKey] isEqualToString:NSFileProtectionComplete]? FALSE : TRUE;
	
    NSError *error = nil;
    persistentStoreCoordinator_ = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
	
	NSDictionary *storeOptions = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];

	
	_needsPrePopulate = FALSE;
	if ([fileManager fileExistsAtPath:[storeURL path]] == NO)
		_needsPrePopulate = TRUE;
		
    persistentStoreCoordinator_ = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator_ addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:storeOptions error:&error]) {
		[[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
        /*
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
	
	if (needsSetEncrypted){
		NSError *encryptionError = nil;
		NSDictionary *encryptAttributes = [NSDictionary dictionaryWithObject:NSFileProtectionComplete forKey:NSFileProtectionKey];
		if(![fileManager setAttributes:encryptAttributes ofItemAtPath:[storeURL path] error: &encryptionError]) {
			NSLog(@"Unresolved error with store encryption %@, %@", encryptionError, [encryptionError userInfo]);
			abort();
			
		}
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

