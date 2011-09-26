//
//  tagTTDataSource.h
//  Taggr
//
//  Created by Alexander List on 8/23/11.
//  Copyright 2011 ExoMachina. All rights reserved.
//
#import "Three20/Three20.h"
#import "tag.h"

//nsuser defaults for faves
typedef enum taggrSortType{
	taggrSortTypeName,
	taggrSortTypeRelevance,
	taggrSortTypeDate,
	taggrSortTypeNearby,
	taggrSortTypeFaves
}taggrSortType;



@interface tagTTDataSource : TTTableViewDataSource <NSFetchedResultsControllerDelegate, TTModel>{
	NSManagedObjectContext *		_objectContext;
	
	NSFetchedResultsController	*	_fetchController;
	
	NSSet						*	_explicitlyReferencedTags;
	
	NSMutableArray*					_delegates;

	NSIndexPath					*	_indexPathOfTodaySection;
	
	taggrSortType					_tagSortType;
}
@property (nonatomic, readonly) NSFetchedResultsController	*	fetchController;
@property (nonatomic, readonly) NSManagedObjectContext *		objectContext;
@property (nonatomic, assign)	taggrSortType					tagSortType;

//setting this property causes a new predicate generation without "search text"
@property (nonatomic, retain)	NSSet	*						explicitlyReferencedTags;

-(id) initWithTagSortType: (taggrSortType)sortType;

-(NSPredicate*)	predicateForTagsMatchingString:(NSString*) searchString	withExplicitTagConnections:(NSSet*)	referencedTags;
- (void)searchWithExplicitlyReferencedTags: (NSSet*) referencedTags searchText:(NSString*) searchText;
- (void)search:	(NSString*)text;

+(tag*)		tagMatchingTagName:(NSString*)tagName;

+(NSSet*)	tagsMatchingNames:(NSSet*)tagNames;

-(NSIndexPath*)	initialScrollPath;



//TTModel

/**
 * Notifies delegates that the model started to load.
 */
- (void)didStartLoad;

/**
 * Notifies delegates that the model finished loading
 */
- (void)didFinishLoad;

/**
 * Notifies delegates that the model failed to load.
 */
- (void)didFailLoadWithError:(NSError*)error;

/**
 * Notifies delegates that the model canceled its load.
 */
- (void)didCancelLoad;

/**
 * Notifies delegates that the model has begun making multiple updates.
 */
- (void)beginUpdates;

/**
 * Notifies delegates that the model has completed its updates.
 */
- (void)endUpdates;

/**
 * Notifies delegates that an object was updated.
 */
- (void)didUpdateObject:(id)object atIndexPath:(NSIndexPath*)indexPath;

/**
 * Notifies delegates that an object was inserted.
 */
- (void)didInsertObject:(id)object atIndexPath:(NSIndexPath*)indexPath;

/**
 * Notifies delegates that an object was deleted.
 */
- (void)didDeleteObject:(id)object atIndexPath:(NSIndexPath*)indexPath;

/**
 * Notifies delegates that the model changed in some fundamental way.
 */
- (void)didChange;

@end
