//
//  AppDelegate_iPhone.h
//  Taggr
//
//  Created by Alexander List on 3/27/11.
//  Copyright 2011 ExoMachina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate_Shared.h"

typedef enum taggerTabIndex{
	taggerTabIndexName,
	taggerTabIndexDate,
	taggerTabIndexNearby,
	taggerTabIndexFaves
}taggerTabIndex;

@interface AppDelegate_iPhone : AppDelegate_Shared {
	
		
	UITabBarController *		_mainTabBar;
}


@end

