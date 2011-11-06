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
#import "TTNavigator.h"
#import "AppDelegate_Shared.h"

@class taggrNameViewController;

@implementation taggrCellPickerTextField
@synthesize taggrCellPickerDelegate = _taggrCellPickerDelegate, dataSource = _dataSource;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
		[self setTaggrCellPickerDelegate:self];
		[self setDelegate:self];
		[self.tokenField setClearButtonMode:UITextFieldViewModeWhileEditing];
		self.tokenField.autocorrectionType = UITextAutocorrectionTypeYes;
		self.tokenField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
		self.tokenField.rightViewMode = UITextFieldViewModeAlways;
		[self.tokenField setReturnKeyType:UIReturnKeyDone];
		
		tagTTDataSource *			dataSource					=	[[tagTTDataSource alloc] init];
		[[dataSource delegates] addObject:self];
		[self setDataSource:dataSource];
		SRELS(dataSource);

		
//		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//		[self sizeToFit];
//		[self setSearchesAutomatically:TRUE];
    }
    
    return self;
}

- (id)init{
	return (self = [self initWithFrame:CGRectZero])?self:nil;
}

-(void) dealloc{
	
	_taggrCellPickerDelegate		= nil;
	SRELS(_dataSource);

	[super dealloc];
}

//- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
//	if (_dataSource) {
//		UITouch* touch = [touches anyObject];
//		if (touch.view == self) {
//			self.selectedCell = nil;
//			
//		} else {
//			if ([touch.view isKindOfClass:[TTPickerViewCell class]]) {
//				if (self.selectedCell == touch.view){
//					[self taggrCellPickerTextFieldDidTapSelectedCellWithObject:self.selectedCell.object withPicker:self];
//				}else{
//					self.selectedCell = (TTPickerViewCell*)touch.view;
//					[self taggrCellPickerTextFieldDidSelectCellWithObject:self.selectedCell.object withPicker:self];
//				}
//				[self becomeFirstResponder];
//			}
//		}
//	}
//	
//	[super touchesBegan:touches withEvent:event];
//	
//}

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
		[self.tokenField addToken:cellString];
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

#pragma mark - TTModelDelegate
-(void)modelDidChange:(TTModel*)model{
	[self setSourceArray:[_dataSource namesOfAllCurrentTags]];
}

#pragma mark - TITokenFieldViewDelegate
- (BOOL)tokenFieldShouldReturn:(TITokenField *)tokenField{
	return TRUE;
}

- (void)tokenField:(TITokenField *)tokenField didChangeToFrame:(CGRect)frame{
	
}
- (void)tokenFieldTextDidChange:(TITokenField *)tokenField{
	[_dataSource search:[self.tokenField text]];
}
- (void)tokenField:(TITokenField *)tokenField didFinishSearch:(NSArray *)matches{
	
}

- (UITableViewCell *)tokenField:(TITokenField *)tokenField resultsTableView:(UITableView *)tableView cellForObject:(id)object{
	return [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tag"] autorelease];
}
- (CGFloat)tokenField:(TITokenField *)tokenField resultsTableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return 40;
}


#pragma mark UITableView
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
	id object = [_dataSource tableView:tableView objectForRowAtIndexPath:indexPath];
	TTOpenURL([object accessoryURL]);
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
//	id object = [_dataSource tableView:tableView objectForRowAtIndexPath:indexPath];
	[super tableView:tableView didSelectRowAtIndexPath:indexPath];
}

#pragma mark text field
//- (CGRect)rectForSearchResults:(BOOL)withKeyboard {
//	CGRect searchRect = [super rectForSearchResults:withKeyboard];
//	
//	return CGRectUnion(searchRect, CGRectApplyAffineTransform(searchRect, CGAffineTransformMakeTranslation(0, 40)));
//}



//- (BOOL)textFieldShouldReturn:(UITextField *)textField{
//	
//	if ([self selectedCell] != nil){
//		[self setSelectedCell:nil];
//		return FALSE;
//	}
//	
//	NSString * trimmedTagString	=	[[self text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//	if (StringHasText(trimmedTagString) == NO){
//		[self resignFirstResponder];
//		return FALSE;
//	}
//	
//	tag * matchTag = [tagTTDataSource tagMatchingTagName:trimmedTagString];
//	if ([[self cells] containsObject:[matchTag tagName]])
//		return FALSE;
//	
//	if (matchTag){
//		[self addCellWithObject:[matchTag tagName]];
//		[self setText:@" "];
//	}else{
//		[self addNewTag];
//		[self addCellWithObject:trimmedTagString];
//		[self setText:@" "];
//	}
//	
//	if ([_taggrCellPickerDelegate respondsToSelector:@selector(taggrCellPickerModifiedCells:)]) {
//		[_taggrCellPickerDelegate taggrCellPickerModifiedCells:self];
//	}
//
//	
//	return FALSE;
//	
//}
-(void)textFieldDidBeginEditing:(UITextField *)textField{
}

-(void) textFieldDidEndEditing:(UITextField *)textField{
}

-(void) textFieldDidResize:(TTPickerTextField*)field{
	if ([_taggrCellPickerDelegate respondsToSelector:@selector(taggrCellPickerDidResize:)]) {
		[_taggrCellPickerDelegate taggrCellPickerDidResize:self];
	}
}

-(BOOL) textFieldShouldClear:(UITextField *)textField{
	[self.tokenField.tokensArray removeAllObjects];
	[self.tokenField setText:@""];
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
	NSString * trimmedTagString	=	[[self.tokenField text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	if (StringHasText(trimmedTagString)){		
		tag* newTag				=	[NSEntityDescription insertNewObjectForEntityForName:@"tag" inManagedObjectContext:[[AppDelegate_Shared sharedDelegate] managedObjectContext]];
		
		
		UIViewController * superViewController=  [[self superview] viewController];
		if ([superViewController isKindOfClass:[taggrNameViewController class]]){
			//	this functionality would allow setting of tags based on pre-existing tag-search entries, but it provides an unconsistant experience
			NSArray * tagNames		=	[self cells];
			NSSet * matchingTags	=  [tagTTDataSource tagsMatchingNames:[NSSet setWithArray:tagNames]];
			[newTag setExplicitTags:matchingTags];
		}
		
		[newTag setTagName:trimmedTagString];
		[self openTagWithString:trimmedTagString];
		
	}
}




@end
