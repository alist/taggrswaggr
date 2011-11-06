//
//  taggrCellPickerTextField.h
//  Taggr
//
//  Created by Alexander List on 8/29/11.
//  Copyright 2011 ExoMachina. All rights reserved.
//

#import "TTPickerTextField.h"
#import "tag.h"
#import "TITokenFieldView.h"
#import "tagTTDataSource.h"

@class taggrCellPickerTextField;

@protocol taggrCellPickerTextFieldDelegate <NSObject>
@optional
-(void) 	taggrCellPickerTextFieldDidSelectCellWithObject:(id)cellObject withPicker:(taggrCellPickerTextField*)picker;
-(void)		taggrCellPickerTextFieldDidTapSelectedCellWithObject:(id)cellObject withPicker:(taggrCellPickerTextField*)picker;


-(void)		taggrCellPickerModifiedCells:(taggrCellPickerTextField*)picker;
-(void)		taggrCellPickerDidResize:(taggrCellPickerTextField *)picker;
@end


@interface taggrCellPickerTextField : TITokenFieldView <taggrCellPickerTextFieldDelegate, TITokenFieldViewDelegate, TTModelDelegate>{
	id<taggrCellPickerTextFieldDelegate>	_taggrCellPickerDelegate;
	
	tagTTDataSource	*						_dataSource;
}

@property (nonatomic, assign) id<taggrCellPickerTextFieldDelegate>	taggrCellPickerDelegate;
@property (nonatomic, retain) TTTableViewDataSource	*				dataSource;


-(void) openTagWithString:(NSString*)tagName;

- (void)addCellsWithObjects:(NSArray*)objects;
- (void)addCellWithObject:(id)object;

-(void) addNewTag;
@end
