//
//  AppDelegate_Shared.h
//  Taggr
//
//  Created by Alexander List on 3/27/11.
//  Copyright 2011 ExoMachina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>


//nsuser defaults for faves

typedef enum taggerTabIndex{
	taggerTabIndexName,
	taggerTabIndexDate,
	taggerTabIndexNearby,
	taggerTabIndexFaves
}taggerTabIndex;


@interface AppDelegate_Shared : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
	
	UITabBarController *		_mainTabBar;
    
	BOOL						_needsPrePopulate;
	
@private
    NSManagedObjectContext *managedObjectContext_;
    NSManagedObjectModel *managedObjectModel_;
    NSPersistentStoreCoordinator *persistentStoreCoordinator_;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory;
- (void)saveContext;

+(AppDelegate_Shared*)sharedDelegate;

@end

