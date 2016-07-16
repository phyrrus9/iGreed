//
//  ViewController.m
//  greed
//
//  Created by Ethan Laur on 12/9/13.
//  Copyright (c) 2013 Ethan Laur. All rights reserved.
//

#import "ViewController.h"
#import <Twitter/TWTweetComposeViewController.h>
#import <Accounts/Accounts.h>
#import <sys/utsname.h>
#import <GameKit/GameKit.h>
#import <GameKit/GKScore.h>
#include "score.c"

@interface ViewController ()

@end

@implementation ViewController

/////////////INIT SHIT//////////////hey, that rhymed
- (NSString*)machineName
{
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib
	UIPanGestureRecognizer *recognizer =
	[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handler:)];
	[recognizer setMinimumNumberOfTouches:1];
    [recognizer setMaximumNumberOfTouches:1];
	[self.view addGestureRecognizer:recognizer];
	printf("Device: %s\n", [[self machineName] UTF8String]);
	NSString *device = [self machineName];
	bool buttons = true;
	if ([device isEqualToString: @"iPhone3,1"] ||[device isEqualToString: @"iPhone3,2"]) buttons = false;
	if ([device isEqualToString: @"iPhone3,3"] ||[device isEqualToString: @"iPhone4,1"]) buttons = false;
	if (buttons == false)
	{
		_nwb.hidden = YES;
		_nb.hidden = YES;
		_neb.hidden = YES;
		_wb.hidden = YES;
		_eb.hidden = YES;
		_seb.hidden = YES;
		_sb.hidden = YES;
		_swb.hidden = YES;
	}
	[self restore];
	[self populate];
	[self displaymap];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)north:(id)sender     { [self move: 'w']; }
- (IBAction)south:(id)sender     { [self move: 's']; }
- (IBAction)east:(id)sender      { [self move: 'd']; }
- (IBAction)west:(id)sender      { [self move: 'a']; }
- (IBAction)southeast:(id)sender { [self move: 'm']; }
- (IBAction)northeast:(id)sender { [self move: 'u']; }
- (IBAction)northwest:(id)sender { [self move: 'y']; }
- (IBAction)southwest:(id)sender { [self move: 'z']; }

/////////////////score//////////
- (int)getscore
{
	double score = (double)removed / (double)(19 * 10);
	score *= 100;
	return ceil(score) + ((difficulty - 5) * 4) - (level / 4);
}

- (void) reportScore: (int64_t) score forLeaderboardID: (NSString*) category
{
    GKScore *scoreReporter = [[GKScore alloc] initWithCategory:category];
    scoreReporter.value = score;
    scoreReporter.context = 0;

    [scoreReporter reportScoreWithCompletionHandler:^(NSError *error) {
		// Do something interesting here.
    }];
}

//////////////FILESYSTEM//////////
- (void)restore
{
	NSString *strPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	strPath = [strPath stringByAppendingPathComponent:@"pref.txt"];
	NSString *state = [NSString stringWithContentsOfFile:strPath encoding:NSUTF8StringEncoding error:nil];
	NSString *strPath2 = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	strPath2 = [strPath2 stringByAppendingPathComponent:@"level.txt"];
	NSString *state2 = [NSString stringWithContentsOfFile:strPath2 encoding:NSUTF8StringEncoding error:nil];
	
	NSString *strPath3 = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	strPath3 = [strPath3 stringByAppendingPathComponent:@"lives.txt"];
	NSString *state3 = [NSString stringWithContentsOfFile:strPath3 encoding:NSUTF8StringEncoding error:nil];
	if (state != nil) sscanf(state.UTF8String, "%d", &difficulty);
	if (state2 != nil) sscanf(state2.UTF8String, "%d", &level);
	if (state3 != nil) sscanf(state3.UTF8String, "%d", &lives);
}

-(void)save
{
	NSString *state = [[NSString alloc] initWithFormat:@"%d", difficulty];
	NSString *strPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	strPath = [strPath stringByAppendingPathComponent:@"pref.txt"];
	printf("Path: %s\n", [strPath UTF8String]);
	[state writeToFile:strPath atomically:NO encoding:NSStringEncodingConversionAllowLossy error:nil];
	
	NSString *state2 = [[NSString alloc] initWithFormat:@"%d", level];
	NSString *strPath2 = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	strPath2 = [strPath2 stringByAppendingPathComponent:@"level.txt"];
	printf("Level: %s\n", [strPath2 UTF8String]);
	[state2 writeToFile:strPath2 atomically:NO encoding:NSStringEncodingConversionAllowLossy error:nil];
	
	NSString *state3 = [[NSString alloc] initWithFormat:@"%d", lives];
	NSString *strPath3 = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	strPath3 = [strPath3 stringByAppendingPathComponent:@"lives.txt"];
	printf("Lives: %s\n", [strPath2 UTF8String]);
	[state3 writeToFile:strPath3 atomically:NO encoding:NSStringEncodingConversionAllowLossy error:nil];
	[self restore];
}

//////////////UI SHIT////////////


- (void)setbuttons: (BOOL) val
{
	[_nwb setEnabled:val];
	[_nb setEnabled:val];
	[_neb setEnabled:val];
	[_swb setEnabled:val];
	[_sb setEnabled:val];
	[_seb setEnabled:val];
	[_eb setEnabled:val];
	[_wb setEnabled:val];
}

- (void)helpbar
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Information"
													message:
						  @"You should see a screen of numbers, find the *\n"
						  "You can move that * by swiping in that direction, you CAN go diagonal\n"
						  "You can never move to or across a blank space\n"
						  "When you move, the first digit that way will be how far you move in that direction\n"
						  "When you run out of options, the game ends.\n"
						  "You can change the difficulty if you like, it is still the same game"
											delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
}

- (char *)getDifficulty
{
	switch (difficulty)
	{
		case 3:
			return "Easy";
			break;
		case 5:
			return "Normal";
			break;
		case 7:
			return "Hard";
			break;
		case 9:
			return "Insane";
			break;
	}
	return "?";
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(alertView.tag == 1)
	{
		NSString * title = [alertView buttonTitleAtIndex:buttonIndex];
		char buf[250] = {0};
		sprintf(buf, "@phyrrus9, I just got a score of %d playing Greed on iOS in %s mode and level %d using %d moves! What about you?", [self getscore], [self getDifficulty], [self getlevel], moves);
		if ([title isEqualToString: @"OK"])
		{
			ACAccountStore *accountStore = [[ACAccountStore alloc] init];
			ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
			
			[accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError* error)
			 {
				 ACAccount *account = [[ACAccount alloc] initWithAccountType:accountType];
				 NSLog(@"%@, %@", account.username, account.description);
			 }];
			if([TWTweetComposeViewController canSendTweet])
			{
				TWTweetComposeViewController *controller = [[TWTweetComposeViewController alloc] init];
				[controller setInitialText:[[NSString alloc] initWithUTF8String:buf]];
				controller.completionHandler = ^(TWTweetComposeViewControllerResult result)
				{
					[self dismissViewControllerAnimated:YES completion:nil];
					//used to be a switch (result) here (WTweetComposeViewControllerResultCancelled/Done)
				};
				[self presentViewController:controller animated:YES completion:nil];
			}
		}
		if ([title isEqualToString: @"Save me"])
		{
			lives--;
			if (px != 0)
			{
				map[py][px - 1] = '1';
				if (py != 0) map[py - 1][px - 1] = '1';
			}
			if (py != 0) map[py - 1][px] = '1';
			if (py < 18)
			{
				map[py + 1][px] = '1';
				if (px < 19) map[py + 1][px + 1] = '1';
			}
			if (px < 19) map[py][px + 1] = '1';
			if (px != 0 && py < 18 && py > 0) map[py + 1][px - 1] = '1';
			if (px < 19 && px > 0 && py != 0) map[py - 1][px + 1] = '1';
			[self save];
			[self displaymap];
		}
	}
	if (alertView.tag == 2) //confirm new game
	{
		NSString * title = [alertView buttonTitleAtIndex:buttonIndex];
		if ([title isEqualToString: @"Yes"])
		{
			disablegest = false;
			[self setbuttons:YES];
			[self populate];
			[self displaymap];
		}
	}
	if (alertView.tag == 3) //set difficulty
	{
		NSString * title = [alertView buttonTitleAtIndex:buttonIndex];
		if ([title isEqualToString: @"3"])
		{
			difficulty = 3;
			[self populate];
			[self displaymap];
		}
		if ([title isEqualToString: @"5"])
		{
			difficulty = 5;
			[self populate];
			[self displaymap];
		}
		if ([title isEqualToString: @"7"])
		{
			difficulty = 7;
			[self populate];
			[self displaymap];
		}
		if ([title isEqualToString: @"9"])
		{
			difficulty = 9;
			[self populate];
			[self displaymap];
		}
		if (![title isEqualToString: @"Nevermind"])
		{
			[self save];
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Difficulty set"
														message:@"You are starting a new game now"
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
			[alert show];
		}
	}
	if (alertView.tag == 4) //confirm new game
	{
		NSString * title = [alertView buttonTitleAtIndex:buttonIndex];
		if ([title isEqualToString: @"Help"]) [self helpbar];
	}
	if (alertView.tag == 5)
	{
		NSString * title = [alertView buttonTitleAtIndex:buttonIndex];
		if ([title isEqualToString: @"Difficulty"]) [self swdifficulty];
		else if ([title isEqualToString: @"Stats"])
		{
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Information"
															message:
								  [[NSString alloc] initWithFormat:
								   @"Level: %d\n"
								    "Difficulty: %s\n"
									"Lives: %d\n", [self getlevel], [self getDifficulty], lives]
														   delegate:nil
												  cancelButtonTitle:@"OK"
												  otherButtonTitles:nil];
			[alert show];
		}
		else if ([title isEqualToString: @"Reset"])
		{
			level = 20;
			difficulty = 5;
			lives = 1;
			[self save];
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Information"
															message:@"Reset game"
														   delegate:nil
												  cancelButtonTitle:@"OK"
												  otherButtonTitles:nil];
			[alert show];
		}
		else if ([title isEqualToString: @"Help"]) [self helpbar];
	}
}

- (IBAction)newgame:(id)sender {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Are you sure?"
													message:@"Are you sure you wish to start a new game?"
												   delegate:self
										  cancelButtonTitle:@"No"
										  otherButtonTitles:@"Yes", nil];
	[alert setTag:2];
	[alert show];
}

- (void)swdifficulty
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Change Difficulty"
													message:@"3: Easy\n5: Normal\n7: Hard\n9: Insane"
												   delegate:self
										  cancelButtonTitle:@"Nevermind"
										  otherButtonTitles:@"3", @"5", @"7", @"9", nil];
	[alert setTag:3];
	[alert show];
}


- (IBAction)infobar:(id)sender
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Information"
													message:
						  @"A remake of GNU Greed by ESR\n"
						   "Written by Ethan Laur (@phyrrus9)\n"
						   //"Help from Jerrick Davis (@ph0enix_dev)\n"
						   "Resources from Jonathan Schober\n"
						   "Thanks for buying!"
												   delegate:self
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:@"Help", nil];
	alert.tag = 4;
	[alert show];
}

- (IBAction)options:(id)sender
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Options"
													message:@"Please select an option"
												   delegate:self
										  cancelButtonTitle:@"Nevermind"
										  otherButtonTitles:@"Difficulty",
						  									@"Stats",
						  									@"Help",
						  									@"Reset", nil];
	alert.tag = 5;
	[alert show];
}


- (void)populate
{
	int i, x;
	char hard = 0;
	srand(time(0));
	for (i = 0; i < 19; i++)
	{
		for (x = 0; x < 20; x++)
		{
			map[i][x] = rand() % difficulty + 49;
		}
	}
	if (level < 0) hard = 1;
	for (i = 0; i < abs(level); i++)
	{
		if (hard)
		{
			map[rand() % 19][rand() % 20] = rand() % 4 + (49 + 5);
		}
		else
		{
			map[rand() % 19][rand() % 20] = rand() % 3 + 49;
		}
	}
	px = rand() % 20;
	py = rand() % 19;
	map[py][px] = '*';
	score = 0;
	removed = 0;
	moves = 0;
}


- (void)displaymap
{
	char buf[10000] = {0};
	int i, x;
	for (i = 0; i < 19; i++)
	{
		for (x = 0; x < 20; x++)
		{
			sprintf(buf + strlen(buf), "%c ", map[i][x]);
		}
		sprintf(buf + strlen(buf), "\n");
	}
	_display.text = [[NSString alloc] initWithUTF8String:buf];
	sprintf(buf, "%d", [self getscore]);
	_score.text = [[NSString alloc] initWithUTF8String:buf];
	sprintf(buf, "%d", [self checkgame]);
	_remainingmoves.text = [[NSString alloc] initWithUTF8String:buf];
	if ([self checkgame] == 0)
	{
		[self endgame];
	}
}

- (int)checkgame
{
	char c;
	int jump = 0;
	int goodcount = 0;
	if (px > 0)
	{
		c = map[py][px - 1];
		if (c == ' ') {}
		else
		{
			jump = c - '0';
			goodcount += [self checkpath:'a' withDistance:jump];
		}
	}
	if (py > 0)
	{
		c = map[py - 1][px];
	 	if (c == ' ') {}
	 	else
	 	{
	 		jump = c - '0';
	 		goodcount += [self checkpath:'w' withDistance:jump];
	 	}
	}
	if (px < 18)
	{
		c = map[py][px + 1];
	 	if (c == ' ') {}
	 	else
	 	{
	 		jump = c - '0';
	 		goodcount += [self checkpath:'d' withDistance:jump];
	 	}
	}
	if (py < 19)
	{
		c = map[py + 1][px];
	 	if (c == ' ') {}
	 	else
	 	{
	 		jump = c - '0';
	 		goodcount += [self checkpath:'s' withDistance:jump];
	 	}
	}
	if (px > 0 && py > 0)
	{
		c = map[py - 1][px - 1];
	 	if (c == ' ') {}
	 	else
	 	{
	 		jump = c - '0';
	 		goodcount += [self checkpath:'y' withDistance:jump];
	 	}
	}
	if (px > 0 && py < 19)
	{
		c = map[py + 1][px - 1];
	 	if (c == ' ') {}
	 	else
	 	{
	 		jump = c - '0';
	 		goodcount += [self checkpath:'z' withDistance:jump];
	 	}
	}
	if (px < 18 && py > 0)
	{
		c = map[py - 1][px + 1];
	 	if (c == ' ') {}
	 	else
	 	{
	 		jump = c - '0';
	 		goodcount += [self checkpath:'u' withDistance:jump];
	 	}
	}
	if (px < 18 && py > 19)
	{
		c = map[py + 1][px + 1];
	 	if (c == ' ') {}
	 	else
	 	{
	 		jump = c - '0';
	 		goodcount += [self checkpath:'m' withDistance:jump];
	 	}
	}
	return goodcount;
}

- (char)checkpath: (char)place withDistance:(int)distance
{
	int i;
	int x = px, y = py;
	for (i = 0; i < distance; i++)
	{
		switch (place)
		{
			case 'w':
				y--;
				break;
			case 's':
				y++;
				break;
			case 'a':
				x--;
				break;
			case 'd':
				x++;
				break;
			case 'z':
				{ x--; y++; }
				break;
			case 'm':
				{ x++; y++; }
				break;
			case 'y':
				{ x--; y--; }
				break;
			case 'u':
				{ x++; y--; }
				break;
		}
		if (y < 0 || x < 0)
			return 0;
		if (y > 18 || x > 19)
			return 0;
		if (map[y][x] == ' ')
			return 0;
	}
	return 1;
}

- (void)move: (char)place
{
	char read = 0;
	int jump = 0;
	int i;
	switch (place)
	{
		case 'w':
			if (py <= 0)
				return;
			read = map[py - 1][px];
			break;
		case 's':
			if (py >= 19)
				return;
			read = map[py + 1][px];
			break;
		case 'a':
			if (px <= 0)
				return;
			read = map[py][px - 1];
			break;
		case 'd':
			if (px > 18)
				return;
			read = map[py][px + 1];
			break;
		case 'z':
			if (px <= 0 || py >= 19)
				return;
			read = map[py + 1][px - 1];
			break;
		case 'm':
			if (px >= 18 || py >= 19)
				return;
			read = map[py + 1][px + 1];
			break;
		case 'y':
			if (px <= 0 || py <= 0)
				return;
			read = map[py - 1][px - 1];
			break;
		case 'u':
			if (px >= 18 || py <= 0)
				return;
			read = map[py - 1][px + 1];
			break;
	}
	jump = read - '0';
	if (place == 'z' && [self checkpath:'z' withDistance:jump])
	{
		map[py][px] = ' ';
		for (i = 0; i < jump; i++)
		{
			score += (int)(map[py + 1][px - 1] + '0');
			map[py + 1][px - 1] = ' ';
			py++;
			px--;
			removed++;
		}
	}
	else if (place == 'm' && [self checkpath:'m' withDistance:jump])
	{
		map[py][px] = ' ';
		for (i = 0; i < jump; i++)
		{
			score += (int)(map[py + 1][px + 1] + '0');
			map[py + 1][px + 1] = ' ';
			py++;
			px++;
			removed++;
		}
	}
	else if (place == 'y' && [self checkpath:'y' withDistance:jump])
	{
		map[py][px] = ' ';
		for (i = 0; i < jump; i++)
		{
			score += (int)(map[py - 1][px - 1] + '0');
			map[py - 1][px - 1] = ' ';
			py--;
			px--;
			removed++;
		}
	}
	else if (place == 'u' && [self checkpath:'u' withDistance:jump])
	{
		map[py][px] = ' ';
		for (i = 0; i < jump; i++)
		{
			score += (int)(map[py - 1][px + 1] + '0');
			map[py - 1][px + 1] = ' ';
			py--;
			px++;
			removed++;
		}
	}
	else if (place == 'w' && [self checkpath:place withDistance:jump])
	{
		map[py][px] = ' ';
		for (i = 0; i < jump; i++)
		{
			score += (int)(map[py - 1][px] + '0');
			map[py - 1][px] = ' ';
			py--;
			removed++;
		}
	}
	else if (place == 's' && [self checkpath:place withDistance:jump])
	{
		map[py][px] = ' ';
		for (i = 0; i < jump; i++)
		{
			score += (int)(map[py + 1][px] + '0');
			map[py + 1][px] = ' ';
			py++;
			removed++;
		}
	}
	else if (place == 'a' && [self checkpath:place withDistance:jump])
	{
		map[py][px] = ' ';
		for (i = 0; i < jump; i++)
		{
			score += (int)(map[py][px - 1] + '0');
			map[py][px - 1] = ' ';
			px--;
			removed++;
		}
	}
	else if (place == 'd' && [self checkpath:place withDistance:jump])
	{
		map[py][px] = ' ';
		for (i = 0; i < jump; i++)
		{
			score += (int)(map[py][px + 1] + '0' && [self checkpath:place withDistance:jump]);
			map[py][px + 1] = ' ';
			px++;
			removed++;
		}
	}
	else{}
	if (moves > (200 / ([self getlevel] + 2)))
	{
		//19x20
		int yl, xl;
		for (yl = 0; yl < 19; yl++)
		{
			for (xl = 0; xl < 20; xl++)
			{
				if (map[yl][xl] != ' ' && map[yl][xl] < '9' && map[yl][xl] > '0')
				{
					if (moves % 3 == 0)
						map[yl][xl]++;
				}
			}
		}
	}
	moves++;
	map[py][px] = '*';
	[self displaymap];
}

/////////////////GESTURE SHIT////////////

-(void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer
{
	printf("Guesture: %d\n", recognizer.direction);
	if (recognizer.direction == UISwipeGestureRecognizerDirectionLeft)
	{
		printf("a\n");
		[self move: 'a'];
	}
	else if (recognizer.direction == UISwipeGestureRecognizerDirectionRight)
	{
		printf("d\n");
		[self move: 'd'];
	}
	else if (recognizer.direction == UISwipeGestureRecognizerDirectionUp)
	{
		printf("w\n");
		[self move: 'w'];
	}
	else if (recognizer.direction == UISwipeGestureRecognizerDirectionDown)
	{
		printf("s\n");
		[self move: 's'];
	}
	else if (recognizer.direction == (UISwipeGestureRecognizerDirectionRight | UISwipeGestureRecognizerDirectionUp))
	{
		printf("y\n");
		[self move: 'd'];
	}
}

- (void)handler:(UIPanGestureRecognizer *)gesture
{
	CGPoint velocity = [gesture velocityInView:self.view];
	int x, y;
	x = velocity.x;
	y = velocity.y;
	int dead = 500;
	if (gesture.state == UIGestureRecognizerStateEnded)
	{
		if (disablegest) return;
		printf("X: %03d Y: %03d\n", x, y);
		if (x > dead && y > dead)
		{
			[self move: 'm'];
		}
		else if (x > dead && y < -dead)
		{
			[self move: 'u'];
		}
		else if (x < -dead && y > dead)
		{
			[self move: 'z'];
		}
		else if (x < -dead && y < -dead)
		{
			[self move: 'y'];
		}
		else if (x > (dead * 2) / 3)
		{
			[self move: 'd'];
		}
		else if (x < -(dead * 2) / 3)
		{
			[self move: 'a'];
		}
		else if (y > (dead * 2) / 3)
		{
			[self move: 's'];
		}
		else if (y < -(dead * 2) / 3)
		{
			[self move: 'w'];
		}
	}
}


////////////////LEVEL SHIT//////////////////////
- (int)getlevel
{
	switch (level)
	{
		case 20:
			return 1;
			break;
		case 15:
			return 2;
			break;
		case 10:
			return 3;
			break;
		case 5:
			return 4;
			break;
		case 0:
			return 5;
			break;
		case -5:
			return 6;
			break;
		case -10:
			return 7;
			break;
		case -15:
			return 8;
			break;
		default:
			return 8;
			break;
	}
	return -1;
}

- (void)levelup
{
	int levelnum = 0;
	switch (level)
	{
		case 20:
			level = 15;
			lives += 1;
			levelnum = 2;
			break;
		case 15:
			level = 10;
			lives += 1;
			levelnum = 3;
			break;
		case 10:
			level = 5;
			lives += 1;
			levelnum = 4;
			break;
		case 5:
			level = 0;
			lives += 1;
			levelnum = 5;
			break;
		case 0:
			level = -5;
			lives += 1;
			levelnum = 6;
			break;
		case -5:
			level = -10;
			lives += 2;
			levelnum = 7;
			break;
		case -10:
			level = -15;
			lives += 3;
			levelnum = 8;
			break;
		case -15:
			level = -20;
			lives += 4;
			levelnum = 9;
			break;
		default:
			lives += 5;
			levelnum = -1;
			break;
	}
	if (levelnum > 0)
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Level up!"
														message:[[NSString alloc]
																 initWithFormat:@"You are now level %d", levelnum]
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
		[alert show];
		[self setbuttons: NO];
	}
	[self save];
}

- (void)endgame
{
	char buf[100];
	sprintf(buf, "Your score was %d, brag about it!", [self getscore]);
	UIAlertView *alert;
	if (lives > 0)
		alert = [[UIAlertView alloc] initWithTitle:@"Game over"
										   message:[[NSString alloc] initWithUTF8String:buf]
										  delegate:self
								 cancelButtonTitle:@"No thanks"
								 otherButtonTitles:@"OK", @"Save me", nil];
	else
		alert = [[UIAlertView alloc] initWithTitle:@"Game over"
										   message:[[NSString alloc] initWithUTF8String:buf]
										  delegate:self
								 cancelButtonTitle:@"No thanks"
								 otherButtonTitles:@"OK", nil];
	[alert setTag:1];
	[alert show];
	//[self reportScore:[self getscore] forLeaderboardID:@"scores"]; /*will implement in next version*/
	[self setbuttons:NO];
	disablegest = true;
	if ([self getscore] >= 100)
	{
		[self levelup];
	}
}

@end
