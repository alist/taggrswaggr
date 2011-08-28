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
#import "TTModel.h"

@implementation tagTTDataSource
@synthesize fetchController, objectContext;;


#pragma mark public 
-(tag*) tagMatchingTagName:(NSString*)tagName{
	NSFetchRequest * request	= [[NSFetchRequest alloc] init];
	[request setEntity:[NSEntityDescription entityForName:@"tag" inManagedObjectContext:_objectContext]];
	[request setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"tagName" ascending:FALSE]]];
	NSPredicate * namePredicate	= [NSPredicate predicateWithFormat:@"tagName ==[cd] %@",tagName];
	[request setPredicate:namePredicate];
	
	NSFetchedResultsController* fetchTagNameController 			= [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:_objectContext sectionNameKeyPath:nil cacheName:nil];
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

-(NSSet*)	tagsMatchingNames:(NSSet*)tagNames{
	NSFetchRequest * request	= [[NSFetchRequest alloc] init];
	[request setEntity:[NSEntityDescription entityForName:@"tag" inManagedObjectContext:_objectContext]];
	[request setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"tagName" ascending:FALSE]]];
	NSPredicate * namePredicate	= [NSPredicate predicateWithFormat:@"tagName IN[cd] %@",tagNames];
	[request setPredicate:namePredicate];
	
	NSFetchedResultsController* fetchTagNameController 			= [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:_objectContext sectionNameKeyPath:nil cacheName:nil];
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
		[request setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"tagName" ascending:TRUE]]];
		
		_fetchController 			= [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:_objectContext sectionNameKeyPath:nil cacheName:nil];
		[_fetchController setDelegate:self];
		SRELS(request);
		
		NSError *fetchError = nil;
		[_fetchController performFetch:&fetchError];
	}
	return _fetchController;
}

#pragma mark NSObject
-(id) init{
	if (self = [super init]){
		_objectContext = [[[AppDelegate_Shared sharedDelegate] managedObjectContext] retain];
	}
	
	return self;
}

- (void)search:	(NSString*)text{
	//string name
}


-(void) dealloc{
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
		[self didUpdateObject:anObject atIndexPath:newIndexPath];
	}else if (type == NSFetchedResultsChangeDelete){
		[self didDeleteObject:anObject atIndexPath:indexPath];
	}
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type{
	EXOLog(@"Controller section change %i", sectionIndex);
}


#pragma mark -
#pragma mark private

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id  sectionInfo =	[[[self fetchController] sections] objectAtIndex:section];
	int objectCount	=	[sectionInfo numberOfObjects];
    return objectCount;
}

- (id)tableView:(UITableView *)tableView objectForRowAtIndexPath:(NSIndexPath *)indexPath {
	tag * rowTag			= [[self fetchController] objectAtIndexPath:indexPath];
    TTTableTextItem* item	= [TTTableTextItem itemWithText:[rowTag tagName] URL:[NSString stringWithFormat:@"tt://name/%@",@"name"]];
    return item;
}

- (Class)tableView:(UITableView *)tableView cellClassForObject:(id)object {
    return [TTTableTextItemCell class];
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
