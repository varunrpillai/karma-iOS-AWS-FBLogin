//
//  GardenProvider.m
//  Karma
//
// Handles the garden information.
//
//  Created by Varun Ramachandran on 1/20/18.
//  Copyright © 2018 Varun Ramachandran. All rights reserved.
//

#import "GardenProvider.h"


@implementation GardenProvider

// Seven is the max number of Karmas allowed. But user is allowed to have less than 7 karmas
// in the list. This method calculates the progress based on number of Karmas added and
// number of Karmas completed. Based on the progress, a garden image(name) is chosen. 
-(NSString*) getGardenImageNameForKarmas:(int) karmaCount completed:(int)completedKarmas
{
	NSString *gardenImage = @"garden1";
	if (karmaCount < completedKarmas) {
		return gardenImage;
	}
	float progress = (float) completedKarmas/karmaCount;
	
	//Max seven karmas are allowed
	float onebyseventh = (float) 1/7;
	
	if (progress <= onebyseventh) {
		gardenImage = @"garden1";
	} else if (progress <= onebyseventh * 2) {
		gardenImage = @"garden2";
	} else  if (progress <= onebyseventh * 3) {
		gardenImage = @"garden3";
	} else  if (progress <= onebyseventh * 4) {
		gardenImage = @"garden4";
	} else  if (progress <= onebyseventh * 5) {
		gardenImage = @"garden5";
	} else  if (progress <= onebyseventh * 6) {
		gardenImage = @"garden6";
	} else  if (progress <= 1) {
		gardenImage = @"gardenCompleted";
	}
	
	return gardenImage;
}

@end
