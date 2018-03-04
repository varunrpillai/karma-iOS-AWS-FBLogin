//
//  AddKarmaViewController.h
//  Karma
//
//  Controller that handles the view that allows the addition of
//  Karma item and the model that resprents the karma.
//
//  Created by Varun Ramachandran on 1/20/18.
//  Copyright © 2018 Varun Ramachandran. All rights reserved.
//

#import <UIKit/UIKit.h>
@class KarmaItem;

@interface AddKarmaViewController : UIViewController

/*!
 @brief Karma item created by the view controller.
 */
@property (readonly,nullable,strong,nonatomic) KarmaItem *karma;

@end
