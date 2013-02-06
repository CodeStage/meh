// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ImageInfo.m instead.

#import "_ImageInfo.h"

const struct ImageInfoAttributes ImageInfoAttributes = {
	.fetchingInProgress = @"fetchingInProgress",
	.pageNumber = @"pageNumber",
	.title = @"title",
	.url = @"url",
};

const struct ImageInfoRelationships ImageInfoRelationships = {
	.imageData = @"imageData",
	.predecessor = @"predecessor",
	.successor = @"successor",
};

const struct ImageInfoFetchedProperties ImageInfoFetchedProperties = {
};

@implementation ImageInfoID
@end

@implementation _ImageInfo

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"ImageInfo" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"ImageInfo";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"ImageInfo" inManagedObjectContext:moc_];
}

- (ImageInfoID*)objectID {
	return (ImageInfoID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"fetchingInProgressValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"fetchingInProgress"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"pageNumberValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"pageNumber"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic fetchingInProgress;



- (BOOL)fetchingInProgressValue {
	NSNumber *result = [self fetchingInProgress];
	return [result boolValue];
}

- (void)setFetchingInProgressValue:(BOOL)value_ {
	[self setFetchingInProgress:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveFetchingInProgressValue {
	NSNumber *result = [self primitiveFetchingInProgress];
	return [result boolValue];
}

- (void)setPrimitiveFetchingInProgressValue:(BOOL)value_ {
	[self setPrimitiveFetchingInProgress:[NSNumber numberWithBool:value_]];
}





@dynamic pageNumber;



- (int32_t)pageNumberValue {
	NSNumber *result = [self pageNumber];
	return [result intValue];
}

- (void)setPageNumberValue:(int32_t)value_ {
	[self setPageNumber:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitivePageNumberValue {
	NSNumber *result = [self primitivePageNumber];
	return [result intValue];
}

- (void)setPrimitivePageNumberValue:(int32_t)value_ {
	[self setPrimitivePageNumber:[NSNumber numberWithInt:value_]];
}





@dynamic title;






@dynamic url;






@dynamic imageData;

	

@dynamic predecessor;

	

@dynamic successor;

	






@end
