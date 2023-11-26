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

@interface TextToSpeechTools : NSObject

@property (nonatomic, strong) AVSpeechSynthesizer *synthesizer;

- (void)convertTextToSpeech:(NSString *)text;

@end

NS_ASSUME_NONNULL_END
