//
//  editTagDateViewController.m
//  Taggr
//
//  Created by Alexander List on 9/13/11.
//  Copyright 2011 ExoMachina. All rights reserved.
//

#import "editTagDateViewController.h"
#import "Three20+Additions.h"

@implementation editTagDateViewController
@synthesize representedTag = _repTag, delegate = _delegate;
- (id)initWithTag:(tag*)repTag {
    self = [self initWithStyle:UITableViewStyleGrouped];
    if (self) {
        _repTag		= [repTag retain];
		_tempDate	= [_repTag tagDate];
    }
    return self;
}

-(id) initWithStyle:(UITableViewStyle)style{
	self = [super initWithStyle:style];
    if (self) {
		_dateFormatter =	    [[NSDateFormatter alloc] init];
		_dateFormatter.dateFormat = @"EEE, LLL d, YYYY 'at' h:mm a";
		
		[self setVariableHeightRows:TRUE];

	}
    return self;
}

-(void)dealloc{
	SRELS(_dateFormatter);
	SRELS(_repTag);
	SRELS(_datePicker);
	
	[super dealloc];
}

-(void) viewDidLoad{
	[super viewDidLoad];
	
	[self setTitle:[NSString stringWithFormat:@"date for %@..",[[_repTag tagName] substringToIndex:MIN(10, [[_repTag tagName] length])]]];
	
	[self setDataSource:[self dateDisplayDataSource]];
	[self displayDatePicker];
}


-(UIDatePicker*)datePicker{
	if (_datePicker == nil){
		_datePicker		=	[[UIDatePicker alloc] init];
		[_datePicker	setDatePickerMode:UIDatePickerModeDateAndTime];
		[_datePicker addTarget:self action:@selector(pickerValueChangedWithSender:) forControlEvents:UIControlEventValueChanged];
		[_datePicker setDate:_tempDate];
	}
	
	return _datePicker;
}

-(TTTableViewDataSource	*)dateDisplayDataSource{
	TTTableSubtextItem	*	dateItem			=	[TTTableSubtextItem itemWithText:[_dateFormatter stringFromDate:_tempDate] caption:nil];
	
	TTTableSubtextItem	*		IsEventItem		=	[TTTableSubtextItem itemWithText:@"Set as 'Event'" delegate:self selector:@selector(meetingButtonPressed:)];
	if ([_repTag isReferencedToTagNamed:@"Event"]){
		[IsEventItem setText:@"Taggd as Event"];
		[IsEventItem setDelegate:nil];
	}else 	if (_chosenFlags & editTagDateTagFlagIsEvent){
		[IsEventItem setText:@"Will Save as Event"];
	}

	
	TTTableSubtextItem	*		isToDoItem			=	[TTTableSubtextItem itemWithText:@"Set as 'ToDo'" delegate:self selector:@selector(toDoButtonPressed:)];
	if ([_repTag isReferencedToTagNamed:@"ToDo"]){
		[isToDoItem setText:@"Taggd as ToDo"];
		[isToDoItem setDelegate:nil];
	}else 	if (_chosenFlags & editTagDateTagFlagIsTodo){
		[isToDoItem setText:@"Will Save as ToDo"];
	}

	return	[TTSectionedDataSource dataSourceWithObjects:@"",dateItem,@"",isToDoItem,IsEventItem,nil];
}

-(void)displayDatePicker{
	if (self.datePicker.superview == nil)
    {
        [self.view addSubview: self.datePicker];
        
        CGRect screenRect	= CGRectMake(0, 0,320, 460);
        CGSize pickerSize	= [self.datePicker sizeThatFits:CGSizeZero];

		CGSize tabBarSize	=	self.navigationController.tabBarController.tabBar.size;
		
        CGRect pickerRect = CGRectMake(0.0,
                                       screenRect.origin.y + screenRect.size.height - pickerSize.height - tabBarSize.height - 40,
                                       pickerSize.width,
                                       pickerSize.height);

		self.datePicker.frame = pickerRect;
        		
		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveDateButtonPressedWithSender:)] autorelease];
    }
}

-(void) pickerValueChangedWithSender: (UIDatePicker*) picker{
	_tempDate	=	[picker date];
	[self setDataSource:[self dateDisplayDataSource]];
	[[self tableView] reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

-(void)	saveDateButtonPressedWithSender: (id) sender{
	
	if ([[_repTag tagDate] isEqualToDate:_tempDate] == NO){
		_chosenFlags	= _chosenFlags | editTagDateTagFlagDateChanged;
		[_repTag setTagDate:_tempDate];
	}
	[_delegate editTagDateViewControllerDidUpdateTag:_repTag withFlags:_chosenFlags withController:self];
	[self.navigationController popViewControllerAnimated:TRUE];
}

-(void) toDoButtonPressed: (id) sender{
	_chosenFlags =	_chosenFlags ^ editTagDateTagFlagIsTodo;
	
	[self setDataSource:[self dateDisplayDataSource]];
	[[self tableView] reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationFade];

}

-(void) meetingButtonPressed: (id) sender{
	_chosenFlags =	_chosenFlags ^ editTagDateTagFlagIsEvent;
	
	[self setDataSource:[self dateDisplayDataSource]];
	[[self tableView] reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:1]] withRowAnimation:UITableViewRowAnimationFade];
}										  
@end
