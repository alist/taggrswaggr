//
//  tagViewController.h
//  Taggr
//
//  Created by Alexander List on 8/25/11.
//  Copyright 2011 ExoMachina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Three20.h"
#import "tag.h"
#import "taggrCellPickerTextField.h"

@interface tagViewController : TTTableViewController <taggrCellPickerTextFieldDelegate>{
	tag *	_repTag;
	
	taggrCellPickerTextField * _explicitTagsField;
	taggrCellPickerTextField * _implicitTagsField;
}

-(id) initWithTagName:(NSString*)tagName;


-(TTSectionedDataSource*)	tagDisplayDataSource;
@end
