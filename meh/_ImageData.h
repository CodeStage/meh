// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ImageData.h instead.

#import <CoreData/CoreData.h>


extern const struct ImageDataAttributes {
	__unsafe_unretained NSString *data;
} ImageDataAttributes;

extern const struct ImageDataRelationships {
	__unsafe_unretained NSString *info;
} ImageDataRelationships;

extern const struct ImageDataFetchedProperties {
} ImageDataFetchedProperties;

@class ImageInfo;



@interface ImageDataID : NSManagedObjectID {}
@end

@interface _ImageData : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (ImageDataID*)objectID;





@property (nonatomic, strong) NSData* data;



//- (BOOL)validateData:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) ImageInfo *info;

//- (BOOL)validateInfo:(id*)value_ error:(NSError**)error_;





@end

@interface _ImageData (CoreDataGeneratedAccessors)

@end

@interface _ImageData (CoreDataGeneratedPrimitiveAccessors)


- (NSData*)primitiveData;
- (void)setPrimitiveData:(NSData*)value;





- (ImageInfo*)primitiveInfo;
- (void)setPrimitiveInfo:(ImageInfo*)value;


@end
