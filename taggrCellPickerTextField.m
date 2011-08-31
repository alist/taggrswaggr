//
//  taggrCellPickerTextField.m
//  Taggr
//
//  Created by Alexander List on 8/29/11.
//  Copyright 2011 ExoMachina. All rights reserved.
//

#import "taggrCellPickerTextField.h"
#import "Three20UI/TTPickerViewCell.h"
#import "Three20.h"
#import "tagTTDataSource.h"
#import "AppDelegate_Shared.h"

@implementation taggrCellPickerTextField
@synthesize taggerCellPickerDelegate = _taggerCellPickerDelegate;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
		[self setTaggerCellPickerDelegate:self];
		[self setDelegate:self];
		[self setClearButtonMode:UITextFieldViewModeWhileEditing];
		self.autocorrectionType = UITextAutocorrectionTypeNo;
		self.autocapitalizationType = UITextAutocapitalizationTypeNone;
		self.rightViewMode = UITextFieldViewModeAlways;
		[self setReturnKeyType:UIReturnKeyDone];
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		[self sizeToFit];
    }
    
    return self;
}

- (id)init{
	return (self = [self initWithFrame:CGRectZero])?self:nil;
}

-(void) dealloc{
	
	_taggerCellPickerDelegate		= nil;

	[super dealloc];
}

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
	if (_dataSource) {
		UITouch* touch = [touches anyObject];
		if (touch.view == self) {
			self.selectedCell = nil;
			
		} else {
			if ([touch.view isKindOfClass:[TTPickerViewCell class]]) {
				if (self.selectedCell == touch.view){
					[self taggrCellPickerTextFieldDidTapSelectedCellWithObject:self.selectedCell.object withPicker:self];
				}else{
					self.selectedCell = (TTPickerViewCell*)touch.view;
					[self taggrCellPickerTextFieldDidSelectCellWithObject:self.selectedCell.object withPicker:self];
				}
				[self becomeFirstResponder];
			}
		}
	}
	
	[super touchesBegan:touches withEvent:event];
	
}

- (void)addCellsWithObjects:(NSArray*)objects{
	for (id object in objects){
		[self addCellWithObject:object];
	}
}


#pragma mark taggrCellPickerTextFieldDelegate
-(void) taggrCellPickerTextFieldDidSelectCellWithObject:(id)cellObject withPicker:(taggrCellPickerTextField*)picker{
	if ([_taggerCellPickerDelegate respondsToSelector:@selector(taggrCellPickerTextFieldDidSelectCellWithObject:withPicker:)]){
		[_taggerCellPickerDelegate taggrCellPickerTextFieldDidSelectCellWithObject:cellObject withPicker:self];
	}
}
-(void) taggrCellPickerTextFieldDidTapSelectedCellWithObject:(id)cellObject withPicker:(taggrCellPickerTextField*)picker{
	if ([_taggerCellPickerDelegate respondsToSelector:@selector(taggrCellPickerTextFieldDidTapSelectedCellWithObject:withPicker:)]){
		[_taggerCellPickerDelegate taggrCellPickerTextFieldDidTapSelectedCellWithObject:cellObject withPicker:self];
	}else
	if (StringHasText(cellObject)){
		[self openTagWithString:cellObject];
	}
}


-(void) openTagWithString:(NSString*)tagName{
	NSString * trimmedTagString	=	[tagName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

	if (StringHasText(trimmedTagString) == NO){
		return;
	}
	
	tag * tagForObject	=	[tagTTDataSource tagMatchingTagName:trimmedTagString];
	if (StringHasText([tagForObject tagName])){
		[[TTNavigator navigator] openURLAction:[[TTURLAction actionWithURLPath:[NSString stringWithFormat:@"tt://tag/%@",[[tagForObject tagName] UTF8EscapedString]]] applyAnimated:YES]];
	}
}

#pragma mark text field
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
	
	NSString * trimmedTagString	=	[[self text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	if (StringHasText(trimmedTagString) == NO){
		[self resignFirstResponder];
		return FALSE;
	}
	
	tag * matchTag = [tagTTDataSource tagMatchingTagName:trimmedTagString];
	if ([[self cells] containsObject:[matchTag tagName]])
		return FALSE;
	
	if (matchTag){
		[self addCellWithObject:[matchTag tagName]];
		[self setText:@" "];
	}else{
		[self addNewTag];
		[self addCellWithObject:trimmedTagString];
		[self setText:@" "];
	}
	
	if ([_taggerCellPickerDelegate respondsToSelector:@selector(taggrCellPickerModifiedCells:)]) {
		[_taggerCellPickerDelegate taggrCellPickerModifiedCells:self];
	}

	
	return FALSE;
	
}

-(void) textFieldDidEndEditing:(UITextField *)textField{
	if ([_taggerCellPickerDelegate respondsToSelector:@selector(taggrCellPickerModifiedCells:)]) {
		[_taggerCellPickerDelegate taggrCellPickerModifiedCells:self];
	}
}

-(void) textFieldDidResize:(TTPickerTextField*)field{
	if ([_taggerCellPickerDelegate respondsToSelector:@selector(taggrCellPickerDidResize:)]) {
		[_taggerCellPickerDelegate taggrCellPickerDidResize:self];
	}
}

-(BOOL) textFieldShouldClear:(UITextField *)textField{
	[self removeAllCells];
	[self setText:@""];
	return TRUE;
}


-(void) addNewTag{
	NSString * trimmedTagString	=	[[self text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	if (StringHasText(trimmedTagString)){
		NSArray * tagNames		=	[self cells];
		NSSet * matchingTags	=  [tagTTDataSource tagsMatchingNames:[NSSet setWithArray:tagNames]];
		
		tag* newTag				=	[NSEntityDescription insertNewObjectForEntityForName:@"tag" inManagedObjectContext:[[AppDelegate_Shared sharedDelegate] managedObjectContext]];
		[newTag setExplicitTags:matchingTags];
		[newTag setTagName:trimmedTagString];
		[self openTagWithString:trimmedTagString];
		
	}
}




@end
