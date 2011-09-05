//
//  viewContactWithTagViewController.h
//  Taggr
//
//  Created by Alexander List on 9/3/11.
//  Copyright 2011 ExoMachina. All rights reserved.
//
#import "tag.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <CoreFoundation/CoreFoundation.h>

#import <UIKit/UIKit.h>

@interface viewContactWithTagViewController : ABPersonViewController <ABPersonViewControllerDelegate>{
	tag *	_repTag;
	
	ABAddressBookRef	_addressBook;
}
-(id) initWithContactTag: (tag*) contactTag;

-(ABRecordRef)personRecordWithTagName:(NSString*) tagName;

@end

