// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ImageInfo.h instead.

#import <CoreData/CoreData.h>


extern const struct ImageInfoAttributes {
	__unsafe_unretained NSString *fetchingInProgress;
	__unsafe_unretained NSString *pageNumber;
	__unsafe_unretained NSString *title;
	__unsafe_unretained NSString *url;
} ImageInfoAttributes;

extern const struct ImageInfoRelationships {
	__unsafe_unretained NSString *imageData;
	__unsafe_unretained NSString *predecessor;
	__unsafe_unretained NSString *successor;
} ImageInfoRelationships;

extern const struct ImageInfoFetchedProperties {
} ImageInfoFetchedProperties;

@class ImageData;
@class ImageInfo;
@class ImageInfo;






@interface ImageInfoID : NSManagedObjectID {}
@end

@interface _ImageInfo : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (ImageInfoID*)objectID;





@property (nonatomic, strong) NSNumber* fetchingInProgress;



@property BOOL fetchingInProgressValue;
- (BOOL)fetchingInProgressValue;
- (void)setFetchingInProgressValue:(BOOL)value_;

//- (BOOL)validateFetchingInProgress:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* pageNumber;



@property int32_t pageNumberValue;
- (int32_t)pageNumberValue;
- (void)setPageNumberValue:(int32_t)value_;

//- (BOOL)validatePageNumber:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* title;



//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* url;



//- (BOOL)validateUrl:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) ImageData *imageData;

//- (BOOL)validateImageData:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) ImageInfo *predecessor;

//- (BOOL)validatePredecessor:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) ImageInfo *successor;

//- (BOOL)validateSuccessor:(id*)value_ error:(NSError**)error_;





@end

@interface _ImageInfo (CoreDataGeneratedAccessors)

@end

@interface _ImageInfo (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveFetchingInProgress;
- (void)setPrimitiveFetchingInProgress:(NSNumber*)value;

- (BOOL)primitiveFetchingInProgressValue;
- (void)setPrimitiveFetchingInProgressValue:(BOOL)value_;




- (NSNumber*)primitivePageNumber;
- (void)setPrimitivePageNumber:(NSNumber*)value;

- (int32_t)primitivePageNumberValue;
- (void)setPrimitivePageNumberValue:(int32_t)value_;




- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;




- (NSString*)primitiveUrl;
- (void)setPrimitiveUrl:(NSString*)value;





- (ImageData*)primitiveImageData;
- (void)setPrimitiveImageData:(ImageData*)value;



- (ImageInfo*)primitivePredecessor;
- (void)setPrimitivePredecessor:(ImageInfo*)value;



- (ImageInfo*)primitiveSuccessor;
- (void)setPrimitiveSuccessor:(ImageInfo*)value;


@end
