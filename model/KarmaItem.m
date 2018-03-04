//
//  KarmaItem.m
//  Model that represent a single karma item and
//  handles its persistance.
//
//  Created by Varun Ramachandran on 1/20/18.
//  Copyright © 2018 Varun Ramachandran. All rights reserved.
//

#import "KarmaItem.h"

@implementation KarmaItem

- (id)initWithCoder:(NSCoder *)decoder {
	self = [super init];
	if (!self) {
		return nil;
	}
	
	self.itemName = [decoder decodeObjectForKey:@"itemName"];
	self.completed = [decoder decodeBoolForKey:@"completed"];
	self.completedDate = [decoder decodeObjectForKey:@"completedDate"];
	return self;
}


- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:self.itemName forKey:@"itemName"];
	[encoder encodeBool:self.completed forKey:@"completed"];
	[encoder encodeObject:self.completedDate forKey:@"completedDate"];
}


@end
