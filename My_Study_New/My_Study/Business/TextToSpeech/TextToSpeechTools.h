//
//  TextToSpeechTools.h
//  My_Study
//
//  Created by hzw on 2023/11/25.
//  Copyright © 2023 HZW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^ConverComplete)(void);

@interface TextToSpeechTools : NSObject

@property (nonatomic, strong) AVSpeechSynthesizer *synthesizer;

@property (nonatomic, copy) ConverComplete converComplete;

- (void)convertTextToSpeech:(NSString *)text;

@end

NS_ASSUME_NONNULL_END
