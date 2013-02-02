// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ImageData.m instead.

#import "_ImageData.h"

const struct ImageDataAttributes ImageDataAttributes = {
	.data = @"data",
};

const struct ImageDataRelationships ImageDataRelationships = {
	.imageInfo = @"imageInfo",
};

const struct ImageDataFetchedProperties ImageDataFetchedProperties = {
};

@implementation ImageDataID
@end

@implementation _ImageData

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"ImageData" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"ImageData";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"ImageData" inManagedObjectContext:moc_];
}

- (ImageDataID*)objectID {
	return (ImageDataID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic data;






@dynamic imageInfo;

	






@end
