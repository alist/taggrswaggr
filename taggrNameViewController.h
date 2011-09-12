//
//  taggrNameViewController.h
//  Taggr
//
//  Created by Alexander List on 8/23/11.
//  Copyright 2011 ExoMachina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "Three20/Three20.h"
#import "tagTTDataSource.h"
#import "taggrCellPickerTextField.h"


@interface taggrNameViewController : TTTableViewController <TTTextEditorDelegate, UITextFieldDelegate, taggrCellPickerTextFieldDelegate>{
	taggrCellPickerTextField * _bubbleTextField;
}

@property (nonatomic, readonly) tagTTDataSource *tagDataSource;

-(void) addNewTag;
-(taggrSortType)	tagSortType;

@end
