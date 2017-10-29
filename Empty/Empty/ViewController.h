//
//  ViewController.h
//  Empty
//
//  Created by Alex Sid on 20.03.16.
//  Copyright (c) 2016 AlvaStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "SpeechToTextModule.h"

@interface ViewController : UIViewController <AVSpeechSynthesizerDelegate, SpeechToTextModuleDelegate>

@property(nonatomic, strong) SpeechToTextModule *speechToTextModule;

@end

