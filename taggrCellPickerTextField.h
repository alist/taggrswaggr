//
//  taggrCellPickerTextField.h
//  Taggr
//
//  Created by Alexander List on 8/29/11.
//  Copyright 2011 ExoMachina. All rights reserved.
//

#import "TTPickerTextField.h"
@class taggrCellPickerTextField;

@protocol taggrCellPickerTextFieldDelegate <NSObject>
@optional
-(void) 	taggrCellPickerTextFieldDidSelectCellWithObject:(id)cellObject withPicker:(taggrCellPickerTextField*)picker;
-(void)		taggrCellPickerTextFieldDidTapSelectedCellWithObject:(id)cellObject withPicker:(taggrCellPickerTextField*)picker;


-(void)		taggrCellPickerModifiedCells:(taggrCellPickerTextField*)picker;
-(void)		taggrCellPickerDidResize:(taggrCellPickerTextField *)picker;
@end


@interface taggrCellPickerTextField : TTPickerTextField <taggrCellPickerTextFieldDelegate, TTTextEditorDelegate, UITextFieldDelegate>{
	id<taggrCellPickerTextFieldDelegate> _taggerCellPickerDelegate;
}

@property (nonatomic, assign) id<taggrCellPickerTextFieldDelegate> taggerCellPickerDelegate;

- (void)addCellsWithObjects:(NSArray*)objects;

-(void) addNewTag;
@end
