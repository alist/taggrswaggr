//
//  editContactWithTagViewController.m
//  Taggr
//
//  Created by Alexander List on 8/31/11.
//  Copyright 2011 ExoMachina. All rights reserved.
//

#import "editContactWithTagViewController.h"
#import "tagTTDataSource.h"

@implementation editContactWithTagViewController
@synthesize tagContactDelegate = _tagContactDelegate;
@synthesize representedTag = _representedTag;

#pragma mark delegation
#pragma mark ABNewPersonViewControllerDelegate
- (void)newPersonViewController:(ABNewPersonViewController *)newPersonView didCompleteWithNewPerson:(ABRecordRef)person{
	
	if (person == NULL){
		[_tagContactDelegate editContactWithTagViewControllerCanceledWithUneditedTag:_representedTag];
	}else{
		
		
		NSMutableSet *		tagsToAdd	= [NSMutableSet set];

		tag * contactTagRef	=	[tagTTDataSource tagMatchingTagName:@"Contact"];
		if (contactTagRef == nil){
			contactTagRef	=	[NSEntityDescription insertNewObjectForEntityForName:@"tag" inManagedObjectContext:[_representedTag managedObjectContext]];
			[contactTagRef setTagName:@"Contact"];
		}
		[tagsToAdd addObject:contactTagRef];
		
		ABAddressBookRef	addressBook = ABAddressBookCreate(); 
		
		//this is actually just annoying
//		ABMultiValueRef phoneNumbers	=	ABRecordCopyValue(person, kABPersonPhoneProperty);
//		CFIndex phoneCount	=	ABMultiValueGetCount(phoneNumbers);
//		for (int i = 0; i < phoneCount; i++){
//			CFStringRef phone = ABMultiValueCopyValueAtIndex(phoneNumbers, i);
//			NSString* phoneString = [NSString stringWithString:(NSString*)phone];
//            CFRelease(phone);
//
//			NSString * newTagNameString	=	[NSString stringWithFormat:@"Tel: %@",phoneString];
//			
//			tag * newTag			=	[NSEntityDescription insertNewObjectForEntityForName:@"tag" inManagedObjectContext:[_representedTag managedObjectContext]];
//			[newTag setTagName:newTagNameString];
//			
//			[tagsToAdd addObject:newTag];
//		}
//		CFRelease(phoneNumbers);

		
		CFRelease(addressBook);
		
		[_representedTag setExplicitTags:[[_representedTag explicitTags] setByAddingObjectsFromSet:tagsToAdd]];

		
		[_tagContactDelegate editContactWithTagViewControllerConcludedWithEditedTag:_representedTag];
	}
}

-(id) initWithContactTag: (tag*) contactTag	tagContactDelegate: (id<editContactWithTagViewControllerDelegate>) delegate{
	if (self = [super init]){
		_representedTag		=	[contactTag retain];
		[self setTagContactDelegate:delegate];
	}
	return self;
}

#pragma mark defaults
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		self.modalPresentationStyle	=	UIModalPresentationFullScreen;
		self.modalTransitionStyle	=	UIModalTransitionStyleCoverVertical;
    }
    return self;
}

-(void) dealloc{
	SRELS(_representedTag);
	_tagContactDelegate	=	nil;
	
	[super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

- (void)viewDidLoad
{
	ABNewPersonViewController *newPersonViewController = [[ABNewPersonViewController alloc] init];
	
	ABRecordRef newContact = ABPersonCreate();
	CFErrorRef anError = NULL;
	
	
	
//	NSString* firstName = (NSString*)ABRecordCopyValue(newContact, kABPersonFirstNameProperty);
//	NSString* lastname = (NSString*)ABRecordCopyValue(newContact, kABPersonLastNameProperty);
	
	NSArray * nameComponents	=	[_representedTag.tagName componentsSeparatedByString:@" "];
	if ([nameComponents count] > 0){
		ABRecordSetValue(newContact, kABPersonFirstNameProperty, [nameComponents objectAtIndex:0], &anError);		
	}
	if ([nameComponents count] > 1){
		NSString *lastName = [[nameComponents subarrayWithRange:NSMakeRange(1, [nameComponents count]-1)] componentsJoinedByString:@" "];
		if (StringHasText(lastName))
			ABRecordSetValue(newContact, kABPersonLastNameProperty, lastName, &anError);		
	}
	
//	ABMultiValueRef email = ABMultiValueCreateMutable(kABMultiStringPropertyType);
//	bool didAdd = ABMultiValueAddValueAndLabel(email, @"John-Appleseed@mac.com", kABOtherLabel, NULL);
	
	[newPersonViewController setDisplayedPerson:newContact];
	
	CFRelease(newContact);

	[newPersonViewController setNewPersonViewDelegate:self];
	
	[self pushViewController:newPersonViewController animated:FALSE];
	SRELS(newPersonViewController);
	
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
