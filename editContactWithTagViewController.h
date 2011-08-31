//
//  editContactWithTagViewController.h
//  Taggr
//
//  Created by Alexander List on 8/31/11.
//  Copyright 2011 ExoMachina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "tag.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <CoreFoundation/CoreFoundation.h>

@class editContactWithTagViewController;
@protocol editContactWithTagViewControllerDelegate <NSObject>
-(void) editContactWithTagViewControllerConcludedWithEditedTag:(tag*)editedTag;
-(void) editContactWithTagViewControllerCanceledWithUneditedTag:(tag*)editedTag;

@end

@interface editContactWithTagViewController : UINavigationController <ABNewPersonViewControllerDelegate>{
	
	tag	*	_representedTag;
	
	id<editContactWithTagViewControllerDelegate>	_tagContactDelegate;
}
@property (nonatomic, assign)	id<editContactWithTagViewControllerDelegate> tagContactDelegate;
@property (nonatomic, readonly)	tag	*	representedTag;


-(id) initWithContactTag: (tag*) contactTag	tagContactDelegate: (id<editContactWithTagViewControllerDelegate>) delegate;

@end
