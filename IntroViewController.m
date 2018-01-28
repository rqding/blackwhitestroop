//
//  IntroViewController.m
//  Black and White
//
//  Created by cj on 16/6/30.
//  Copyright © 2016年 Carleton University Math Lab. All rights reserved.
//

#import "IntroViewController.h"

@interface IntroViewController ()

@end

@implementation IntroViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _StartPractice.hidden = YES;
    
    // Get the dirctory
    NSArray *dirPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = dirPath[0];
    
    //setup path for property file
    NSString *propertypath = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent:@"configure.plist"]];
    NSMutableDictionary *configDict = [NSMutableDictionary dictionaryWithContentsOfFile:propertypath];
    //read value base on key name
    NSString *testIntro = [configDict objectForKey:@"Main_Instruction"];
    
    _mainIntroText.text = testIntro;
    
    [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(showStartButton) userInfo:nil repeats:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void) showUIAlerWithMessage:(NSString*)message andTitle:(NSString*)title{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}


-(void)showStartButton {
    
    _StartPractice.hidden = NO;
    
}

@end
