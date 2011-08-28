//
//  taggerNameViewController.m
//  Taggr
//
//  Created by Alexander List on 8/23/11.
//  Copyright 2011 ExoMachina. All rights reserved.
//

#import "taggerNameViewController.h"
#import "TTPickerTextField.h"
#import "tag.h"
#import "AppDelegate_Shared.h"

@implementation taggerNameViewController
@synthesize tagDataSource;

-(id) init{
	if (self = [super init]){
		
		tagTTDataSource *			dataSource					=	[[tagTTDataSource alloc] init];
		[self setDataSource:dataSource];
		SRELS(dataSource);

	}
	
	return self;
}

#pragma mark viewController
-(void)viewDidLoad{
	[super viewDidLoad];
	
	_bubbleTextField =		[[TTPickerTextField alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
	_bubbleTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    _bubbleTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _bubbleTextField.rightViewMode = UITextFieldViewModeAlways;
	[_bubbleTextField setDataSource:[self dataSource]];
	[_bubbleTextField setDelegate:self];
	[_bubbleTextField setReturnKeyType:UIReturnKeyDone];
	
    _bubbleTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_bubbleTextField sizeToFit];
	
	[self setAutoresizesForKeyboard:TRUE];
	[self setVariableHeightRows:TRUE];
	[[self tableView] setTableHeaderView:_bubbleTextField];
	
	[self setTitle:@"Taggr"];
	
	[self setTabBarItem:[[[UITabBarItem alloc] initWithTitle:@"name" image:nil tag:taggerTabIndexName] autorelease]];
	
//	[[self navigationItem] setRightBarButtonItem:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addTagButtonPressed)]autorelease]];
	
}

-(void)	addTagButtonPressed{
	[self addNewTag];
}

-(void) addNewTag{
	NSString * trimmedTagString	=	[[_bubbleTextField text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

	if (StringHasText(trimmedTagString)){
		NSArray * tagNames		=	[_bubbleTextField cells];
		NSSet * matchingTags	=  [[self tagDataSource] tagsMatchingNames:[NSSet setWithArray:tagNames]];
		
		tag* newTag				=	[NSEntityDescription insertNewObjectForEntityForName:@"tag" inManagedObjectContext:[[self tagDataSource] objectContext]];
		[newTag setExplicitTags:matchingTags];
		[newTag setTagName:trimmedTagString];
		
	}
}


-(tagTTDataSource*)tagDataSource{
	return (tagTTDataSource*)[self dataSource];
}


#pragma mark delegation
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
	
	NSString * trimmedTagString	=	[[_bubbleTextField text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	if (StringHasText(trimmedTagString) == NO){
		[_bubbleTextField resignFirstResponder];
		return FALSE;
	}
	
	tag * matchTag = [[self tagDataSource] tagMatchingTagName:trimmedTagString];
	if (matchTag){
		[_bubbleTextField addCellWithObject:[matchTag tagName]];
		[_bubbleTextField setText:@""];
	}else{
		[self addNewTag];
		[_bubbleTextField addCellWithObject:trimmedTagString];
		[_bubbleTextField setText:@""];
	}
	
	return FALSE;

}

#pragma mark NSObject

-(void) dealloc{
	[[[self dataSource] delegates] removeObject:self];
	
	SRELS(_bubbleTextField);
	
	[super dealloc];
}


@end
