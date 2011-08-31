//
//  taggrNameViewController.m
//  Taggr
//
//  Created by Alexander List on 8/23/11.
//  Copyright 2011 ExoMachina. All rights reserved.
//

#import "taggrNameViewController.h"
#import "tag.h"
#import "AppDelegate_Shared.h"

@implementation taggrNameViewController
@synthesize tagDataSource;

-(id) init{
	if (self = [super init]){
		
		tagTTDataSource *			dataSource					=	[[tagTTDataSource alloc] init];
		[self setDataSource:dataSource];
		SRELS(dataSource);
		
		[self setTabBarItem:[[[UITabBarItem alloc] initWithTitle:@"name" image:nil tag:taggrTabIndexName] autorelease]];
		[self setTitle:@"Taggr"];
	}
	
	return self;
}

#pragma mark viewController
-(void)viewDidLoad{
	[super viewDidLoad];
	
	_bubbleTextField =		[[taggrCellPickerTextField alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
	[_bubbleTextField setTaggrCellPickerDelegate:self];
	[_bubbleTextField setDataSource:self.dataSource];
	
	[self setAutoresizesForKeyboard:TRUE];
	[self setVariableHeightRows:TRUE];
	[[self tableView] setTableHeaderView:_bubbleTextField];
	[[self.tableView tableHeaderView] setHeight:_bubbleTextField.height];
			
//	[[self navigationItem] setRightBarButtonItem:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addTagButtonPressed)]autorelease]];
	
}

-(void)	addTagButtonPressed{
	[self addNewTag];
}

-(void) addNewTag{
	NSString * trimmedTagString	=	[[_bubbleTextField text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

	if (StringHasText(trimmedTagString)){
		NSArray * tagNames		=	[_bubbleTextField cells];
		NSSet * matchingTags	=  [tagTTDataSource tagsMatchingNames:[NSSet setWithArray:tagNames]];
		
		tag* newTag				=	[NSEntityDescription insertNewObjectForEntityForName:@"tag" inManagedObjectContext:[[self tagDataSource] objectContext]];
		[newTag setExplicitTags:matchingTags];
		[newTag setTagName:trimmedTagString];
		
	}
}


-(tagTTDataSource*)tagDataSource{
	return (tagTTDataSource*)[self dataSource];
}


#pragma mark delegation
#pragma mark taggrCellPicker
-(void)		taggrCellPickerModifiedCells:(taggrCellPickerTextField*)picker{
	//SAVE or something
	if ([picker isFirstResponder]){
		 [[self tagDataSource] searchWithExplicitlyReferencedTags:[NSSet setWithArray:[picker cells]] searchText:nil];
	}else{
		[[self tagDataSource] setExplicitlyReferencedTags:[NSSet setWithArray:[picker cells]]];
	}
}
-(void)		taggrCellPickerDidResize:(taggrCellPickerTextField *)picker{
	if (picker == _bubbleTextField)
		[self.tableView setTableHeaderView:picker];

}

#pragma mark NSObject

-(void) dealloc{
	[[[self dataSource] delegates] removeObject:self];
	
	SRELS(_bubbleTextField);
	
	[super dealloc];
}


@end
