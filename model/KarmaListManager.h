//
//  KarmaListHandler.h
//  Karma
//
// The model is a singleton that stores and handles list of Karmas.
// It saves data locally or in cloud.
// It also retrieves data from cloud on installation.
//
//  Created by Varun Ramachandran on 3/2/18.
//  Copyright © 2018 Varun Ramachandran. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KarmaItem;

@interface KarmaListManager : NSObject

/*!
 @brief Returns the instance of the KarmaListManager (singleton).
 */
+ (id _Nonnull )sharedManager:(nullable void (^)(NSArray * __nonnull))completion;

/*!
 @brief Set a unique identifier that identifies the user across any device.

 @discussion When setting Id, the KarmaListManager able to use the id to store and retrieve the
 Karmas in cloud. To disable sync, set id as nil.
 */
- (void) setIdentifier:(NSString* __nullable) id completion:(nullable void (^)(NSArray * __nonnull))completion;

/*!
 @brief Returns the KarmaItems.
 */
- (NSMutableArray*_Nonnull) getKarmaItems;

/*!
 @brief Replace the KarmaItems if the caller wants to modify it.
 */
- (void) replaceKarma:(NSMutableArray*_Nonnull) karmaItems;


@end
