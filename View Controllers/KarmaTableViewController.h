//
//  KarmaTableViewController.h
//  Karma
//
//  Controller that handles the view that manages a list of Karmas.
//
//  Created by Varun Ramachandran on 1/20/18.
//  Copyright © 2018 Varun Ramachandran. All rights reserved.
//

@class KarmaListManager;

#import <UIKit/UIKit.h>

@interface KarmaTableViewController : UITableViewController

/*!
  @brief Method called by child VCs that are pushed on top of this VC to unwind to this VC.
 */
- (IBAction)unwindToKarmaList:(UIStoryboardSegue *)segue;

@end
