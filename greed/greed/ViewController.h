//
//  ViewController.h
//  greed
//
//  Created by Ethan Laur on 12/9/13.
//  Copyright (c) 2013 Ethan Laur. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *display;
@property (weak, nonatomic) IBOutlet UILabel *score;
@property (weak, nonatomic) IBOutlet UILabel *remainingmoves;
@property (weak, nonatomic) IBOutlet UIButton *nwb;
@property (weak, nonatomic) IBOutlet UIButton *nb;
@property (weak, nonatomic) IBOutlet UIButton *neb;
@property (weak, nonatomic) IBOutlet UIButton *wb;
@property (weak, nonatomic) IBOutlet UIButton *eb;
@property (weak, nonatomic) IBOutlet UIButton *swb;
@property (weak, nonatomic) IBOutlet UIButton *sb;
@property (weak, nonatomic) IBOutlet UIButton *seb;
- (IBAction)north:(id)sender;
- (IBAction)south:(id)sender;
- (IBAction)east:(id)sender;
- (IBAction)west:(id)sender;
- (IBAction)southeast:(id)sender;
- (IBAction)northeast:(id)sender;
- (IBAction)northwest:(id)sender;
- (IBAction)southwest:(id)sender;
- (IBAction)newgame:(id)sender;
- (IBAction)infobar:(id)sender;
- (IBAction)options:(id)sender;
- (void)save;
- (void)restore;
- (void)setbuttons: (BOOL) val;

@end

char map[19][20] = {0};
int px, py;
int score;
int moves;
int removed;
int difficulty = 5;
int level = 20;
int lives = 1;
bool disablegest = false;

//increment every time a score of 100 is reached
//+20 = level 1
//+15 = level 2
//+10 = level 3
//+05 = level 4
//+00 = level 5
//-05 = level 6
//-10 = level 7
//-15 = level 8
//-20 = level 9
