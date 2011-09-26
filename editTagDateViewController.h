//
//  editTagDateViewController.h
//  Taggr
//
//  Created by Alexander List on 9/13/11.
//  Copyright 2011 ExoMachina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Three20/Three20.h"
#import "tag.h"


typedef enum {
	editTagDateTagFlagDateChanged	= 1 << 0,
	editTagDateTagFlagIsTodo		= 1 << 1,
	editTagDateTagFlagIsEvent		= 1 << 2
}editTagDateTagFlag;

@class editTagDateViewController;
@protocol editTagDateViewControllerDelegate <NSObject>

-(void)	editTagDateViewControllerDidUpdateTag:(tag*)theTag withFlags:(editTagDateTagFlag)flags withController:(editTagDateViewController*)controler;

@end


@interface editTagDateViewController : TTTableViewController{
	NSDateFormatter	*	_dateFormatter;
	tag *				_repTag;
	UIDatePicker	*	_datePicker;
	
	NSDate			*	_tempDate;
	
	id<editTagDateViewControllerDelegate>	_delegate;
	
	editTagDateTagFlag	_chosenFlags;
	
}

@property (nonatomic, readonly) tag *	representedTag;
@property (nonatomic, assign)	id<editTagDateViewControllerDelegate>	delegate;

-(TTTableViewDataSource	*)dateDisplayDataSource;
-(UIDatePicker*)datePicker;
-(void)displayDatePicker;

- (id)initWithTag:(tag*)repTag ;
@end
