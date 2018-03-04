//
//  KarmaItem.h
//  Model that represent a single karma item and
//  handles its persistance.
//
//  Created by Varun Ramachandran on 1/20/18.
//  Copyright © 2018 Varun Ramachandran. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KarmaItem : NSObject <NSCoding>

/*!
 * @brief Represents the name of the karma.
 */
@property (readwrite,nullable,strong,nonatomic) NSString *itemName;

/*!
 * @brief Represents the state of the Karma whether it is completed today or not.
 */
@property (readwrite,assign,nonatomic) BOOL completed;

/*!
 * @brief Represents the date on which it was last completed.
 */
@property (readwrite,nullable,strong,nonatomic) NSDate *completedDate;

@end
