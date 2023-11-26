//
//  TextToSpeechTools.m
//  My_Study
//
//  Created by hzw on 2023/11/25.
//  Copyright © 2023 HZW. All rights reserved.
//

#import "TextToSpeechTools.h"

@implementation TextToSpeechTools

- (instancetype)init {
   self = [super init];
   if (self) {
       self.synthesizer = [[AVSpeechSynthesizer alloc] init];
   }
   return self;
}

- (void)convertTextToSpeech:(NSString *)text {
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:text];

    utterance.rate = 0.5;
    utterance.pitchMultiplier = 1;
    // 设置音量,[0-1] 默认 = 1
    utterance.volume = 1;
    // 读一段前的停顿时间
    utterance.preUtteranceDelay = 0.1;
    // 读完一段后的停顿时间
    utterance.postUtteranceDelay = 1;
    utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CN"];

    self.synthesizer = [[AVSpeechSynthesizer alloc] init];
    [self.synthesizer speakUtterance:utterance];
}

@end
