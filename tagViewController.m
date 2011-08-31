//
//  tagViewController.m
//  Taggr
//
//  Created by Alexander List on 8/25/11.
//  Copyright 2011 ExoMachina. All rights reserved.
//

#import "tagViewController.h"
#import "tagTTDataSource.h"
#import "taggrCellPickerTextField.h"


@implementation tagViewController

#pragma mark action handlers
-(void) contactTagButtonPressed:(UIButton*) sender{
	[self presentModalViewController:[[[editContactWithTagViewController alloc] initWithContactTag:_repTag tagContactDelegate:self] autorelease] animated:TRUE];
}

#pragma mark viewController
-(id) initWithTagName:(NSString*)tagName{
	if (self = [super init]){
		NSString * unescapedTagName	=	[tagName stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		if (StringHasText(unescapedTagName)){
			tag * tempTag	=	[tagTTDataSource tagMatchingTagName:unescapedTagName];
			if (tempTag != nil){
				_repTag =	[tempTag retain];
			}
		}
	}
	return self;
}

-(void) dealloc{
	SRELS(_explicitTagsField);
	
	[super dealloc];
}

-(void) viewDidLoad{
	self.title = _repTag.tagName;
	
	[self setAutoresizesForKeyboard:TRUE];
	[self setVariableHeightRows:TRUE];
	
	[self setDataSource:[self tagDisplayDataSource]];
	
	[_repTag setLastOpenedDate:[NSDate date]];
	
	int timesOpened	=	[[_repTag timesOpened] intValue];
	if (timesOpened == 0){
		[self setTagEditModeEnabled:TRUE];
	}
	
	[_repTag setTimesOpened:[NSNumber numberWithInt:timesOpened +1]];

	[super viewDidLoad];
}


-(void) refreshPickerTags{
	[_explicitTagsField removeAllCells];
	
	NSMutableArray *	explicitTagNames	=	[NSMutableArray array];
	for (tag * explicit in _repTag.explicitTags)
		[explicitTagNames addObject:[explicit tagName]];
	
	[_explicitTagsField addCellsWithObjects:explicitTagNames];
}
#pragma mark dataSource
-(TTSectionedDataSource*)	tagDisplayDataSource{
	
	if (self.dataSource != nil)
		return self.dataSource;
	
	//manipulations
	if (_explicitTagsField == nil){
		_explicitTagsField	=	[[taggrCellPickerTextField alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
		_explicitTagsField.autocorrectionType = UITextAutocorrectionTypeNo;
		_explicitTagsField.autocapitalizationType = UITextAutocapitalizationTypeNone;
		_explicitTagsField.rightViewMode = UITextFieldViewModeAlways;
		tagTTDataSource *			dataSource					=	[[tagTTDataSource alloc] init];
		[_explicitTagsField setDataSource:dataSource];
		SRELS(dataSource);
		[_explicitTagsField setTaggrCellPickerDelegate:self];
		[_explicitTagsField setReturnKeyType:UIReturnKeyDone];
		_explicitTagsField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		[_explicitTagsField sizeToFit];
	}
	NSMutableArray *	explicitTagNames	=	[NSMutableArray array];
	for (tag * explicit in _repTag.explicitTags)
		[explicitTagNames addObject:[explicit tagName]];
	
	[_explicitTagsField addCellsWithObjects:explicitTagNames];
		
	//controls
	UIButton			*		contactButton		=	[UIButton buttonWithType:UIButtonTypeRoundedRect];
	[contactButton setTitle:@"Make Contact Tag" forState:UIControlStateNormal];
	[contactButton sizeToFit];
	[contactButton addTarget:self action:@selector(contactTagButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	TTTableControlItem	*		contactButtonItem	=	[TTTableControlItem itemWithCaption:nil control:contactButton];
	
	TTSectionedDataSource	*	sectionedDataSource	=	[TTSectionedDataSource dataSourceWithObjects:@"",_explicitTagsField,@"Options",contactButtonItem,nil];

	return sectionedDataSource;
}

-(void) setTagEditModeEnabled:(BOOL)editingTagsEnabled{
	if (editingTagsEnabled){
		[_explicitTagsField becomeFirstResponder];
	}else{
		[_explicitTagsField resignFirstResponder];
	}
}

#pragma mark delegation
#pragma mark editContactWithTagViewControllerDelegate
-(void) editContactWithTagViewControllerConcludedWithEditedTag:(tag*)editedTag{
	//may need to reload datasource for segmented input controller
	[self refreshPickerTags];
	[self dismissModalViewControllerAnimated:TRUE];
}
-(void) editContactWithTagViewControllerCanceledWithUneditedTag:(tag*)editedTag{
	[self dismissModalViewControllerAnimated:TRUE];
}


#pragma mark taggrCellPicker
-(void)		taggrCellPickerModifiedCells:(taggrCellPickerTextField*)picker{
	//SAVE or something
	NSArray * tagNames		=	[picker cells];
	NSSet * updateTags		=  [tagTTDataSource tagsMatchingNames:[NSSet setWithArray:tagNames]];

	if (picker == _explicitTagsField)
		[_repTag setExplicitTags:updateTags];

}
-(void)		taggrCellPickerDidResize:(taggrCellPickerTextField *)picker{
	if (picker == _explicitTagsField){
		BOOL reBecomeFirstResponder = [picker isFirstResponder];
		
		NSIndexPath * reloadPath	=	[[self dataSource] tableView:self.tableView indexPathForObject:picker];
		if (reloadPath != nil){
			[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:reloadPath] withRowAnimation:UITableViewRowAnimationFade];
		}
		if (reBecomeFirstResponder) {
			[picker becomeFirstResponder];
		}
	}
}

@end