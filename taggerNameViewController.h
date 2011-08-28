//
//  taggerNameViewController.h
//  Taggr
//
//  Created by Alexander List on 8/23/11.
//  Copyright 2011 ExoMachina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "Three20/Three20.h"
#import "tagTTDataSource.h"

@interface taggerNameViewController : TTTableViewController <TTTextEditorDelegate, UITextFieldDelegate>{
	TTPickerTextField * _bubbleTextField;
}

@property (nonatomic, readonly) tagTTDataSource *tagDataSource;

-(void) addNewTag;

@end
