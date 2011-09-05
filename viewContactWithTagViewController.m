//
//  viewContactWithTagViewController.m
//  Taggr
//
//  Created by Alexander List on 9/3/11.
//  Copyright 2011 ExoMachina. All rights reserved.
//

#import "viewContactWithTagViewController.h"

@implementation viewContactWithTagViewController


-(id) initWithContactTag: (tag*) contactTag{
	if (self = [super init]){
		_repTag		=	[contactTag retain];
		[self setPersonViewDelegate:self];
		[self setAllowsEditing:TRUE];
	}
	
	return self;
}
- (id)init
{
    self = [self initWithContactTag:nil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(void) dealloc{
	SRELS(_repTag);
	CFRelease(_addressBook);
	_addressBook	= NULL;
	
	[super dealloc];
}
#pragma mark -
#pragma mark view
-(void) viewDidLoad{
	ABPersonViewController	* personViewController	=	self;
	[personViewController setAddressBook:_addressBook];
	[personViewController setDisplayedPerson:[self personRecordWithTagName:[_repTag tagName]]];
	
	[super viewDidLoad];
}

#pragma mark -
#pragma mark address book

- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifierForValue{
	
	return TRUE;
}


-(ABRecordRef)personRecordWithTagName:(NSString*) tagName{
	_addressBook	=  (_addressBook == NULL)? ABAddressBookCreate() : _addressBook;
	
	NSArray* tagABCandidates		=	(NSArray*) ABAddressBookCopyPeopleWithName(_addressBook, (CFStringRef) tagName);
	ABRecordRef	returnPerson		=	NULL;
	if ([tagABCandidates count] > 0){
		returnPerson				=	[[[tagABCandidates objectAtIndex:0] retain] autorelease];
	}
	
	SRELS(tagABCandidates);

	return returnPerson;
}

@end
