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
#import "UIViewControllerAdditions.h"

@implementation tagViewController

#pragma mark action handlers
-(void) contactTagButtonPressed:(UIButton*) sender{
	if ([[_explicitTagsField cells] containsObject:@"Contact"]){
		[self.navigationController pushViewController:[[viewContactWithTagViewController alloc] initWithContactTag:_repTag] animated:TRUE];	
	}else{
		[self presentModalViewController:[[[editContactWithTagViewController alloc] initWithContactTag:_repTag tagContactDelegate:self] autorelease] animated:TRUE];		
	}
}

-(void) deleteButtonPressed:(UIButton*) sender{
	[[_repTag managedObjectContext] deleteObject:_repTag];
	[[self navigationController] popViewControllerAnimated:TRUE];
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
	
	[self refreshPickerTags];
	
	[super viewDidLoad];
}


-(void) refreshPickerTags{
	[_explicitTagsField removeAllCells];
	
	NSMutableArray *	explicitTagNames	=	[NSMutableArray array];
	for (tag * explicit in _repTag.explicitTags){
		[explicitTagNames addObject:[explicit tagName]];
		if ([[explicit tagName] isEqualToString:@"Contact"]){
			[_contactButton setTitle:@"View Contact" forState:UIControlStateNormal];
		}
	}
	
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
		
	_noteTextField			=	[[UITextView alloc] initWithFrame:CGRectMake(0, 0, 320, 72)];
	[_noteTextField setDataDetectorTypes:UIDataDetectorTypeAll];
	[_noteTextField setFont:[UIFont fontWithName:@"Marker Felt" size:16]];
	[_noteTextField setEditable:FALSE];
	[_noteTextField addGestureRecognizer:[[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(noteFieldTapped:)] autorelease]];

	NSString *	noteText	=	[_repTag extendedNote];
	if (StringHasText(noteText)){
		[_noteTextField setText:noteText];
	}else{
		[_noteTextField setText:@"note"];
		[_noteTextField setTextColor:[UIColor lightGrayColor]];
	}
	
	//controls
	_contactButton		=	[[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
	[_contactButton setTitle:@"Make Contact Tag" forState:UIControlStateNormal];
	[_contactButton sizeToFit];
	[_contactButton addTarget:self action:@selector(contactTagButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	TTTableControlItem	*		contactButtonItem	=	[TTTableControlItem itemWithCaption:nil control:_contactButton];
	

	UIButton * deleteButton		= nil;
	
	if ([[_repTag explicitTags] count] == 0 && [[_repTag timesOpened] intValue]>0){
		deleteButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[deleteButton setTitle:@"Delete Abandoned Tag" forState:UIControlStateNormal];
		[deleteButton sizeToFit];
		[deleteButton addTarget:self action:@selector(deleteButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	}
	
	TTSectionedDataSource	*	sectionedDataSource	=	[TTSectionedDataSource dataSourceWithObjects:@"",_explicitTagsField,@"More",contactButtonItem,_noteTextField,deleteButton,nil];

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

#pragma mark TTMessageControllerDelegate
- (void)composeController:(TTMessageController*)controller didSendFields:(NSArray*)fields{
	NSString * bodyText = 	[[controller body] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	if (StringHasText(bodyText)){
		[_repTag setExtendedNote:bodyText];
		[_noteTextField setText:bodyText];
		[_noteTextField setTextColor:[UIColor blackColor]];
	}
	[[self navigationController] popViewControllerAnimated:TRUE];
}
- (void)composeControllerWillCancel:(TTMessageController*)controller{
	[[self navigationController] popViewControllerAnimated:TRUE];
}


#pragma mark TTTextView

-	(void)noteFieldTapped:(UITapGestureRecognizer*)sender{
	  if ([sender state] ==UIGestureRecognizerStateRecognized){
		  TTMessageController	* messageController	=	[[TTMessageController alloc] initWithRecipients:nil];
		  [messageController setDelegate:self];
		  [messageController	setFields:nil];
		  [messageController setTitle:[NSString stringWithFormat:@"note %@..",[[_repTag tagName] substringToIndex:MIN(10, [[_repTag tagName] length])]]];;
		  [messageController setBody:[_repTag extendedNote]];
		  [[self navigationController] pushViewController:messageController animated:TRUE];
		  SRELS(messageController);
	  }
  }


@end