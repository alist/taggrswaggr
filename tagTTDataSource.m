//
//  tagTTDataSource.m
//  Taggr
//
//  Created by Alexander List on 8/23/11.
//  Copyright 2011 ExoMachina. All rights reserved.
//

#import "tagTTDataSource.h"
#import "tag.h"
#import "AppDelegate_Shared.h"
#import "NSArrayAdditions.h"
#import "NSDateAdditions.h"
#import "TTModel.h"

#import "taggrNameViewController.h";

@implementation tagTTDataSource
@synthesize fetchController, objectContext;
@synthesize explicitlyReferencedTags = _explicitlyReferencedTags;
@synthesize tagSortType = _tagSortType;

#pragma mark public 

+(tag*) tagMatchingTagName:(NSString*)tagName{
	NSManagedObjectContext * objectContext = [[AppDelegate_Shared sharedDelegate] managedObjectContext];

	NSFetchRequest * request	= [[NSFetchRequest alloc] init];
	[request setEntity:[NSEntityDescription entityForName:@"tag" inManagedObjectContext:objectContext]];
	[request setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"tagName" ascending:FALSE]]];
	NSPredicate * namePredicate	= [NSPredicate predicateWithFormat:@"tagName ==[cd] %@",tagName];
	[request setPredicate:namePredicate];
	
	NSFetchedResultsController* fetchTagNameController 			= [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:objectContext sectionNameKeyPath:nil cacheName:nil];
	SRELS(request);
	
	NSError *fetchError = nil;
	[fetchTagNameController performFetch:&fetchError];
	
	NSArray * results			=	[fetchTagNameController fetchedObjects];
	SRELS(fetchTagNameController);
	
	if (ArrayHasItems(results))
		return [results objectAtIndex:0];
	
	if ([results count] > 1){
		EXOLog(@"Fetched items for percise tag == %i", [results count]);
	}
	
	return nil;
}

+(NSSet*)	tagsMatchingNames:(NSSet*)tagNames{
	NSManagedObjectContext * objectContext = [[AppDelegate_Shared sharedDelegate] managedObjectContext];
	NSFetchRequest * request	= [[NSFetchRequest alloc] init];
	[request setEntity:[NSEntityDescription entityForName:@"tag" inManagedObjectContext:objectContext]];
	[request setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"tagName" ascending:FALSE]]];
	NSPredicate * namePredicate	= [NSPredicate predicateWithFormat:@"tagName IN[cd] %@",tagNames];
	[request setPredicate:namePredicate];
	
	NSFetchedResultsController* fetchTagNameController 			= [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:objectContext sectionNameKeyPath:nil cacheName:nil];
	SRELS(request);
	
	NSError *fetchError = nil;
	[fetchTagNameController performFetch:&fetchError];
	
	NSArray * results			=	[fetchTagNameController fetchedObjects];
	SRELS(fetchTagNameController);
	
	if (ArrayHasItems(results))
		return [NSSet setWithArray:results];
	
	if ([results count] > 1){
		EXOLog(@"Fetched items for percise tag == %i", [results count]);
	}
	
	return nil;
}

-(NSManagedObjectContext*) objectContext{
	return _objectContext;
}

-(NSFetchedResultsController*)fetchController{
	if (_fetchController == nil){
		
		NSFetchRequest * request	= [[NSFetchRequest alloc] init];
		[request setEntity:[NSEntityDescription entityForName:@"tag" inManagedObjectContext:_objectContext]];

		NSMutableArray *	propertiesToFetch	=	[NSMutableArray arrayWithObjects:@"tagName", nil];
		NSString *			sectionNameKey		=	nil;
		
		if (_tagSortType ==	taggrSortTypeDate){
			[propertiesToFetch addObject:@"tagDate"];
			[propertiesToFetch addObject:@"tagDay"];
			sectionNameKey	=	@"tagDay";
			
			[request setSortDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"tagDay" ascending:FALSE],[NSSortDescriptor sortDescriptorWithKey:@"tagDate" ascending:TRUE],nil]];
		}else if (_tagSortType == taggrSortTypeRelevance){
			[request setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"tagName" ascending:TRUE]]];
		}
		
		[request setPropertiesToFetch:propertiesToFetch];
		
		_fetchController 			= [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:_objectContext sectionNameKeyPath:sectionNameKey cacheName:nil];
		[_fetchController setDelegate:self];
		SRELS(request);
		
		NSError *fetchError = nil;
		[_fetchController performFetch:&fetchError];
	}
	return _fetchController;
}

-(void) setExplicitlyReferencedTags:(NSSet *)explicitlyReferencedTags{
	if ([explicitlyReferencedTags isEqualToSet:_explicitlyReferencedTags])
		return;
	
	SRELS(_explicitlyReferencedTags);
	_explicitlyReferencedTags	=	[explicitlyReferencedTags retain];
}

- (void)searchWithExplicitlyReferencedTags: (NSSet*) referencedTags searchText:(NSString*) searchText{
//	if ([referencedTags isEqualToSet:_explicitlyReferencedTags] || (_explicitlyReferencedTags == nil && [referencedTags count] == 0))
//		return;
	[self setExplicitlyReferencedTags:referencedTags];
	
	[self search:searchText];
}

-(NSPredicate*)	predicateForTagsMatchingString:(NSString*) searchString	withExplicitTagConnections:(NSSet*)	referencedTags{
	
	NSPredicate * explicitTagsPredicate = nil;
	if ([referencedTags count] >0){
		explicitTagsPredicate			=	[NSPredicate predicateWithFormat:@"(SUBQUERY(explicitTags, $s, $s.tagName IN %@).@count == %i)",referencedTags,[referencedTags count]];

	}
	
	NSArray *searchTerms				= [[searchString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsSeparatedByString:@" "];
							
	NSMutableArray *namePredicatePieces	=[NSMutableArray arrayWithCapacity:[searchTerms count]];
	for (NSString *searchComponent in searchTerms){
		if (StringHasText(searchComponent)){
			NSPredicate *nextPredicate	= [NSPredicate predicateWithFormat:@"tagName CONTAINS[cd] %@",searchComponent];
			[namePredicatePieces addObject:nextPredicate];
		}
	}
	NSPredicate * tagNamePredicate		=	[NSCompoundPredicate andPredicateWithSubpredicates:namePredicatePieces];
	
	return [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:tagNamePredicate,explicitTagsPredicate, nil]];

}

#pragma mark NSObject
-(id) init{
	if (self = [self initWithTagSortType:taggrSortTypeRelevance]) {
		
	}
	return self;
}


-(id) initWithTagSortType: (taggrSortType)sortType{
	if (self = [super init]){
		_tagSortType	= sortType;
		_objectContext	= [[[AppDelegate_Shared sharedDelegate] managedObjectContext] retain];
	}
	
	return self;
}

- (void)search:	(NSString*)text{
	NSPredicate * searchPredicate	=	[self predicateForTagsMatchingString:text withExplicitTagConnections:[self explicitlyReferencedTags]];
	[[[self fetchController] fetchRequest] setPredicate:searchPredicate];
	NSError *fetchError = nil;
	[_fetchController performFetch:&fetchError];
	if (fetchError){
		EXOLog(@"%@", [fetchError description]);
	}
	[self didChange];
}


-(void) dealloc{
	SRELS(_explicitlyReferencedTags);
	SRELS(_objectContext);
	SRELS(_fetchController);
	SRELS(_delegates);
	
	[super dealloc];
}


#pragma mark NSFetchedResultsControllerDelegate
-(void) controllerWillChangeContent:(NSFetchedResultsController *)controller{
	[self beginUpdates];
}

-(void) controllerDidChangeContent:(NSFetchedResultsController *)controller{
	[self endUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath{
	if (type == NSFetchedResultsChangeInsert){		
		[self didInsertObject:anObject atIndexPath:newIndexPath];
    }else if (type == NSFetchedResultsChangeMove){
		[self didDeleteObject:anObject atIndexPath:indexPath];
		[self didInsertObject:anObject atIndexPath:newIndexPath];
	}else if (type == NSFetchedResultsChangeUpdate){
		[self didUpdateObject:anObject atIndexPath:indexPath];
	}else if (type == NSFetchedResultsChangeDelete){
		[self didDeleteObject:anObject atIndexPath:indexPath];
	}
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type{
	if (type == NSFetchedResultsChangeInsert){		
		[_delegates perform:@selector(model:didInsertObject:atIndexPath:) withObject:self withObject:sectionInfo withObject:[NSIndexPath indexPathWithIndex:sectionIndex]];
    }else if (type == NSFetchedResultsChangeMove){
		[_delegates perform:@selector(model:didDeleteObject:atIndexPath:) withObject:self withObject:sectionInfo withObject:[NSIndexPath indexPathWithIndex:sectionIndex]];
		[_delegates perform:@selector(model:didInsertObject:atIndexPath:) withObject:self withObject:sectionInfo withObject:[NSIndexPath indexPathWithIndex:sectionIndex]];
	}else if (type == NSFetchedResultsChangeUpdate){
		[_delegates perform:@selector(model:didUpdateObject:atIndexPath:) withObject:self withObject:sectionInfo withObject:[NSIndexPath indexPathWithIndex:sectionIndex]];
	}else if (type == NSFetchedResultsChangeDelete){
		[_delegates perform:@selector(model:didDeleteObject:atIndexPath:) withObject:self withObject:sectionInfo withObject:[NSIndexPath indexPathWithIndex:sectionIndex]];
	}
}


#pragma mark -
#pragma mark private

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	if (_tagSortType == taggrSortTypeDate){
		NSIndexPath * sectionPath	=	[NSIndexPath indexPathForRow:0 inSection:section];
		tag * firstInSection		=	[[self fetchController] objectAtIndexPath:sectionPath];
		NSDate * sectionDay			=	[firstInSection tagDay];
		if ([sectionDay timeIntervalSinceDate:[NSDate dateWithToday]] == 0){
			
			_indexPathOfTodaySection=	[sectionPath retain];
			return [NSString stringWithFormat:@"Today: %@",[sectionDay formatAsShortString]];
		}
		return [sectionDay formatDate];
	}
	
	return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchController sections] count];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id  sectionInfo =	[[[self fetchController] sections] objectAtIndex:section];
	int objectCount	=	[sectionInfo numberOfObjects];
    return objectCount;
}

- (id)tableView:(UITableView *)tableView objectForRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([self tableView:tableView numberOfRowsInSection:indexPath.section] <= indexPath.row)
		return nil;
	
	tag * rowTag			= [[self fetchController] objectAtIndexPath:indexPath];
    TTTableTextItem* item	= [TTTableTextItem itemWithText:[rowTag tagName] URL:[NSString stringWithFormat:@"tt://tag/%@",[[rowTag tagName] UTF8EscapedString]]];
	
	UIViewController * superViewController=  [[tableView superview] viewController];
	if ([superViewController isKindOfClass:[taggrNameViewController class]]){
		[item setAccessoryURL:[NSString stringWithFormat:@"tt://tag/%@",[[rowTag tagName] UTF8EscapedString]]];

	}

    return item;
}

- (Class)tableView:(UITableView *)tableView cellClassForObject:(id)object {
    return [TTTableTextItemCell class];
}

-(NSIndexPath*)	initialScrollPath{
	if (_tagSortType == taggrSortTypeDate){
		return _indexPathOfTodaySection;
	}

	return [NSIndexPath indexPathForRow:0 inSection:0];
}

#pragma mark -
#pragma mark TTTableViewDelegate
//- (NSString*)titleForEmpty{
//	return @"No Tags!";
//}
//
//- (NSString*)subtitleForEmpty{
//	return @"Tap above to get started!";
//}

#pragma mark TTModel
- (NSMutableArray*)delegates {
	if (nil == _delegates) {
		_delegates = TTCreateNonRetainingArray();
	}
	return _delegates;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didStartLoad {
	[_delegates perform:@selector(modelDidStartLoad:) withObject:self];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didFinishLoad {
	[_delegates perform:@selector(modelDidFinishLoad:) withObject:self];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didFailLoadWithError:(NSError*)error {
	[_delegates perform:@selector(model:didFailLoadWithError:) withObject:self
			 withObject:error];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didCancelLoad {
	[_delegates perform:@selector(modelDidCancelLoad:) withObject:self];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)beginUpdates {
	[_delegates perform:@selector(modelDidBeginUpdates:) withObject:self];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)endUpdates {
	[_delegates perform:@selector(modelDidEndUpdates:) withObject:self];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didUpdateObject:(id)object atIndexPath:(NSIndexPath*)indexPath {
	[_delegates perform: @selector(model:didUpdateObject:atIndexPath:)
			 withObject: self
			 withObject: object
			 withObject: indexPath];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didInsertObject:(id)object atIndexPath:(NSIndexPath*)indexPath {
	[_delegates perform: @selector(model:didInsertObject:atIndexPath:)
			 withObject: self
			 withObject: object
			 withObject: indexPath];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didDeleteObject:(id)object atIndexPath:(NSIndexPath*)indexPath {
	[_delegates perform: @selector(model:didDeleteObject:atIndexPath:)
			 withObject: self
			 withObject: object
			 withObject: indexPath];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didChange {
	[_delegates perform:@selector(modelDidChange:) withObject:self];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isLoaded {
	return YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isLoading {
	return NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isLoadingMore {
	return NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isOutdated {
	return NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)cancel {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)invalidate:(BOOL)erase {
}


#pragma mark TableViewDataSource
- (NSIndexPath*)tableView:(UITableView*)tableView willUpdateObject:(id)object
			  atIndexPath:(NSIndexPath*)indexPath{
	return indexPath;
}

- (NSIndexPath*)tableView:(UITableView*)tableView willInsertObject:(id)object
			  atIndexPath:(NSIndexPath*)indexPath{
	return indexPath;
}

- (NSIndexPath*)tableView:(UITableView*)tableView willRemoveObject:(id)object
			  atIndexPath:(NSIndexPath*)indexPath{
	return indexPath;
}



@end
