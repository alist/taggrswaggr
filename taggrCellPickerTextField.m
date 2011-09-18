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
@synthesize taggrCellPickerDelegate = _taggrCellPickerDelegate;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
		[self setTaggrCellPickerDelegate:self];
		[self setDelegate:self];
		[self setClearButtonMode:UITextFieldViewModeWhileEditing];
		self.autocorrectionType = UITextAutocorrectionTypeYes;
		self.autocapitalizationType = UITextAutocapitalizationTypeSentences;
		self.rightViewMode = UITextFieldViewModeAlways;
		[self setReturnKeyType:UIReturnKeyDone];
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		[self sizeToFit];
		[self setSearchesAutomatically:TRUE];
    }
    
    return self;
}

- (id)init{
	return (self = [self initWithFrame:CGRectZero])?self:nil;
}

-(void) dealloc{
	
	_taggrCellPickerDelegate		= nil;

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


-(void)	addCellWithObject:(id)object{
	NSString	* cellString	= nil;
	
	if ([object isKindOfClass:[TTTableTextItem class]])
		cellString = [object text];
	
	if ([object isKindOfClass:[NSString class]])
		cellString = object;
	
	if (StringHasText(cellString)){
		[super addCellWithObject:cellString];
	}
}

#pragma mark taggrCellPickerTextFieldDelegate
-(void) taggrCellPickerTextFieldDidSelectCellWithObject:(id)cellObject withPicker:(taggrCellPickerTextField*)picker{
	if ([_taggrCellPickerDelegate respondsToSelector:@selector(taggrCellPickerTextFieldDidSelectCellWithObject:withPicker:)]){
		[_taggrCellPickerDelegate taggrCellPickerTextFieldDidSelectCellWithObject:cellObject withPicker:self];
	}
}
-(void) taggrCellPickerTextFieldDidTapSelectedCellWithObject:(id)cellObject withPicker:(taggrCellPickerTextField*)picker{
	if ([_taggrCellPickerDelegate respondsToSelector:@selector(taggrCellPickerTextFieldDidTapSelectedCellWithObject:withPicker:)]){
		[_taggrCellPickerDelegate taggrCellPickerTextFieldDidTapSelectedCellWithObject:cellObject withPicker:self];
	}else
	if (cellObject){
		NSString	* cellString	= ([cellObject isKindOfClass:[TTTableTextItem class]])?[cellObject text]:cellObject;
		[self openTagWithString:cellString];
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
	
	if ([self selectedCell] != nil){
		[self setSelectedCell:nil];
		return FALSE;
	}
	
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
	
	if ([_taggrCellPickerDelegate respondsToSelector:@selector(taggrCellPickerModifiedCells:)]) {
		[_taggrCellPickerDelegate taggrCellPickerModifiedCells:self];
	}

	
	return FALSE;
	
}
-(void)textFieldDidBeginEditing:(UITextField *)textField{
	[self showSearchResults:TRUE];
}

-(void) textFieldDidEndEditing:(UITextField *)textField{
	[self showSearchResults:NO];
}

-(void) textFieldDidResize:(TTPickerTextField*)field{
	if ([_taggrCellPickerDelegate respondsToSelector:@selector(taggrCellPickerDidResize:)]) {
		[_taggrCellPickerDelegate taggrCellPickerDidResize:self];
	}
}

-(BOOL) textFieldShouldClear:(UITextField *)textField{
	[self removeAllCells];
	[self setText:@""];
	if ([_taggrCellPickerDelegate respondsToSelector:@selector(taggrCellPickerModifiedCells:)]) {
		[_taggrCellPickerDelegate taggrCellPickerModifiedCells:self];
	}
	return TRUE;
}

-(void) textEditorDidChange:(TTTextEditor *)textEditor{
	[[self dataSource] search:[textEditor text]];
}

-(void) textField:(TTPickerTextField *)textField didRemoveCellAtIndex:(NSInteger)cellIndex{
	if ([_taggrCellPickerDelegate respondsToSelector:@selector(taggrCellPickerModifiedCells:)]) {
		[_taggrCellPickerDelegate taggrCellPickerModifiedCells:self];
	}
}

- (void)textField:(TTPickerTextField*)textField didAddCellAtIndex:(NSInteger)cellIndex {
	if ([_taggrCellPickerDelegate respondsToSelector:@selector(taggrCellPickerModifiedCells:)]) {
		[_taggrCellPickerDelegate taggrCellPickerModifiedCells:self];
	}
}

-(void) addNewTag{
	NSString * trimmedTagString	=	[[self text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	if (StringHasText(trimmedTagString)){		
		tag* newTag				=	[NSEntityDescription insertNewObjectForEntityForName:@"tag" inManagedObjectContext:[[AppDelegate_Shared sharedDelegate] managedObjectContext]];
//this functionality would allow setting of tags based on pre-existing tag-search entries, but it provides an unconsistant experience
//		NSArray * tagNames		=	[self cells];
//		NSSet * matchingTags	=  [tagTTDataSource tagsMatchingNames:[NSSet setWithArray:tagNames]];
//		[newTag setExplicitTags:matchingTags];
		[newTag setTagName:trimmedTagString];
		[self openTagWithString:trimmedTagString];
		
	}
}




@end
