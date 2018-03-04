//
//  GardenProvider.h
//  Karma
//
// Handles the garden information.
//
//  Created by Varun Ramachandran on 1/20/18.
//  Copyright © 2018 Varun Ramachandran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface GardenProvider : NSObject

-(NSString*) getGardenImageNameForKarmas:(int) karmaCount completed:(int)completedKarmas;

@end
