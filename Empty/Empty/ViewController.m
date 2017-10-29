//
//  ViewController.m
//  Empty
//
//  Created by Alex Sid on 20.03.16.
//  Copyright (c) 2016 AlvaStudio. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () {
    BOOL isSpeaking;
    UITextView *answerTextView;
}

@end

@implementation ViewController

-(id)init {
    self = [super init];
    if (self) {
        self.speechToTextModule = [[SpeechToTextModule alloc] init];
        [self.speechToTextModule setDelegate:self];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, 100)];
    title.font = [UIFont fontWithName:@"Arial" size:40];
    title.textAlignment = NSTextAlignmentCenter;
    title.text = @"Speech Recognition";
    [self.view addSubview:title];
    
    UILabel *footer = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 30, self.view.bounds.size.width, 30)];
    footer.font = [UIFont fontWithName:@"Arial" size:20];
    footer.textAlignment = NSTextAlignmentCenter;
    footer.text = @"http://adlibtech.ru";
    [self.view addSubview:footer];
    
    UIButton *btnSpeak = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSpeak.frame = CGRectMake((self.view.bounds.size.width - 200)/2, 200, 200, 60);
    btnSpeak.layer.cornerRadius = 20;
    btnSpeak.layer.borderColor = [UIColor blackColor].CGColor;
    btnSpeak.layer.borderWidth = 1;
    [btnSpeak setTitle:@"Speak" forState:UIControlStateNormal];
    [btnSpeak.titleLabel setFont:[UIFont fontWithName:@"Arial" size:24]];
    [btnSpeak setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnSpeak setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [btnSpeak addTarget:self action:@selector(actionSpeak:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnSpeak];
    
    answerTextView = [[UITextView alloc] initWithFrame:CGRectMake(10,
                                                                  btnSpeak.frame.origin.y + btnSpeak.bounds.size.height + 20,
                                                                  self.view.bounds.size.width - 20,
                                                                  self.view.bounds.size.height - (btnSpeak.frame.origin.y + btnSpeak.bounds.size.height + 20) - 60
                                                                  )];
    answerTextView.font = [UIFont fontWithName:@"Arial" size:14];
    answerTextView.textColor = [UIColor blackColor];
    answerTextView.text = @"Here is the answer...";
    answerTextView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:answerTextView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)actionSpeak:(id)sender {
    if (isSpeaking) {
        return;
    }
    
    [self clearAnswer];
    
    [self.speechToTextModule beginRecording];
    isSpeaking = YES;
}

-(void)showAnswer:(NSString*)answerString {
    answerTextView.text = answerString;
}

-(void)clearAnswer {
    answerTextView.text = @"";
}

-(void)workWithAnswer:(NSData*)data {
    if (NSClassFromString(@"NSJSONSerialization")) {
        
        // FIX JSON ERROR
        NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        responseString = [responseString stringByReplacingOccurrencesOfString:@"{\"result\":[]}" withString:@""];
        
        NSError *error = nil;
        /*
         NSJSONReadingMutableContainers = (1UL << 0),
         NSJSONReadingMutableLeaves = (1UL << 1),
         NSJSONReadingAllowFragments = (1UL << 2)
         */
        /*
         {
         alternative =         (
         {
         confidence = "0.97148877";
         transcript = computer;
         },
         {
         transcript = cumputer;
         },
         {
         transcript = computers;
         },
         {
         transcript = "grumpy Utica";
         },
         {
         transcript = "come to Utah";
         }
         );
         final = 1;
         }
         */
        id object = [NSJSONSerialization JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding]
                                                    options:NSJSONReadingMutableContainers
                                                      error:&error];
        
        if (error) {
            NSLog(@"Error...%@", error);
        }
        
        if ([object isKindOfClass:[NSDictionary class]]) {
            NSDictionary *results = object;
            NSArray *resultDict = [results objectForKey:@"result"];
            NSDictionary *alternativeDict = [resultDict objectAtIndex:0];
            NSArray *alternative = [alternativeDict objectForKey:@"alternative"];
            NSDictionary *answerDict = [alternative objectAtIndex:0];
            NSString *answerTranscript = [answerDict objectForKey:@"transcript"];
            
            [self showAnswer:answerTranscript];
        } else {
            [self showAnswer:@"Error answer"];
        }
    } else {
        [self showAnswer:@"Error answer"];
    }
    
}

#pragma mark - SpeechToTextModule Delegate -
- (BOOL)didReceiveVoiceResponse:(NSData *)data
{
    isSpeaking = NO;
    [self clearAnswer];
    
    if (data != nil) {
        NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"Response %@", responseString);
        [self workWithAnswer:data];
    }
    
    return YES;
}

-(void)requestFailedWithError:(NSError *)error {
    isSpeaking = NO;
    [self clearAnswer];
}

@end
