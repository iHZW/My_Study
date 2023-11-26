//
//  TextToSpeech.m
//  My_Study
//
//  Created by hzw on 2023/11/25.
//  Copyright © 2023 HZW. All rights reserved.
//

#import "TextToSpeech.h"
#import "TextToSpeechTools.h"
#import <Speech/Speech.h>

@interface TextToSpeech () <SFSpeechRecognizerDelegate>

@property(nonatomic, strong) UITextView *textView;

@property(nonatomic, strong) UIButton *toSpeechBtn;

@property(nonatomic, strong) UIButton *startBtn;
@property(nonatomic, strong) UIButton *stopBtn;

@property(nonatomic, strong) TextToSpeechTools *textToSpeechTools;

@property(nonatomic, strong) SFSpeechRecognizer *speechRecognizer;
@property(nonatomic, strong) SFSpeechAudioBufferRecognitionRequest *recognitionRequest;
@property(nonatomic, strong) SFSpeechRecognitionTask *recognitionTask;
@property(nonatomic, strong) AVAudioEngine *audioEngine;

@end

@implementation TextToSpeech

- (void)loadUIData {
    [super loadUIData];

    [self _setUpData];

    [self loadSubViews];
}

#pragma mark - 初始化语音识别器
- (void)_setUpData {
    // 初始化语音识别器
    self.speechRecognizer = [[SFSpeechRecognizer alloc] initWithLocale:[NSLocale localeWithLocaleIdentifier:@"zh_CN"]];
    self.audioEngine = [[AVAudioEngine alloc] init];

    // 请求语音识别权限
    [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
        if (status == SFSpeechRecognizerAuthorizationStatusAuthorized) {
            NSLog(@"Speech recognition authorized");
        } else {
            NSLog(@"Speech recognition authorization denied");
        }
    }];
}

#pragma mark - 加载子视图
- (void)loadSubViews {
    [self.view addSubview:self.textView];
    [self.view addSubview:self.toSpeechBtn];
    [self.view addSubview:self.startBtn];
    [self.view addSubview:self.stopBtn];

    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(30);
        make.right.offset(-30);
        make.top.offset(100);
        make.height.offset(300);
    }];

    [self.toSpeechBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.textView.mas_bottom).offset(50);
        make.centerX.equalTo(self.view);
        make.height.mas_equalTo(40);
        //        make.size.mas_equalTo(CGSizeMake(100, 40));
    }];

    [self.startBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.toSpeechBtn.mas_bottom).offset(50);
        make.centerX.equalTo(self.view);
        make.height.mas_equalTo(40);
        //        make.size.mas_equalTo(CGSizeMake(100, 40));
    }];

    [self.stopBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.startBtn.mas_bottom).offset(50);
        make.centerX.equalTo(self.view);
        make.height.mas_equalTo(40);
        //        make.size.mas_equalTo(CGSizeMake(100, 40));
    }];
}

#pragma mark - 处理点击事件
- (void)_handleTextToSpeech {
    if (!ValidString(self.textView.text)) {
        return;
    }

    // 要转换成语音的文本
    NSString *textToConvert = self.textView.text;

    // 调用转换文本到语音的方法
    [self.textToSpeechTools convertTextToSpeech:textToConvert];
}

- (void)startRecording {
    // 创建语音识别请求
    self.recognitionRequest = [[SFSpeechAudioBufferRecognitionRequest alloc] init];

    // 获取音频输入设备
    AVAudioInputNode *inputNode = self.audioEngine.inputNode;

    // 启动音频引擎
    [self.audioEngine prepare];
    NSError *error = nil;
    [self.audioEngine startAndReturnError:&error];

    if (error) {
        NSLog(@"Error starting audio engine: %@", error.localizedDescription);
        return;
    }

    // 将语音识别请求与音频输入节点关联
    self.recognitionRequest.shouldReportPartialResults = YES;
    self.recognitionTask = [self.speechRecognizer recognitionTaskWithRequest:self.recognitionRequest resultHandler:^(SFSpeechRecognitionResult *_Nullable result, NSError *_Nullable error) {
        if (result) {
            NSString *transcription = result.bestTranscription.formattedString;
            self.textView.text = transcription;
        }

        if (error || result.isFinal) {
            [self.audioEngine stop];
            [inputNode removeTapOnBus:0];
            self.recognitionRequest = nil;
            self.recognitionTask = nil;
        }
    }];

    // 将语音输入节点的音频数据传递给语音识别请求
    AVAudioFormat *recordingFormat = [inputNode outputFormatForBus:0];
    [inputNode installTapOnBus:0 bufferSize:1024 format:recordingFormat block:^(AVAudioPCMBuffer *buffer, AVAudioTime *when) {
        [self.recognitionRequest appendAudioPCMBuffer:buffer];
    }];
}

- (void)stopRecording {
    // 停止语音识别请求
    [self.audioEngine stop];
    [self.recognitionRequest endAudio];
    [self.recognitionTask cancel];
}

#pragma mark -  Lazy loading
- (UITextView *)textView {
    if (!_textView) {
        _textView = [[UITextView alloc] initWithFrame:CGRectZero];
        _textView.textColor = UIColor.purpleColor;
        _textView.font = PASFont(30);
    }
    return _textView;
}

- (UIButton *)toSpeechBtn {
    if (!_toSpeechBtn) {
        @weakify(self)
            _toSpeechBtn = [UIButton buttonWithFrame:CGRectZero title:@"文本转语音" font:PASFont(25) titleColor:UIColorFromRGB(0xE2233E) block:^{
                @strongify(self)
                    [self _handleTextToSpeech];
            }];
        [_toSpeechBtn setCornerRadius:6.0 borderWidth:1.0 borderColor:UIColor.systemPinkColor];
    }
    return _toSpeechBtn;
}

- (TextToSpeechTools *)textToSpeechTools {
    if (!_textToSpeechTools) {
        _textToSpeechTools = [TextToSpeechTools new];
    }
    return _textToSpeechTools;
}

- (UIButton *)startBtn {
    if (!_startBtn) {
        @weakify(self)
            _startBtn = [UIButton buttonWithFrame:CGRectZero title:@"开始" font:PASFont(25) titleColor:UIColorFromRGB(0xE2233E) block:^{
                @strongify(self)
                    [self startRecording];
            }];
        [_startBtn setCornerRadius:6.0 borderWidth:1.0 borderColor:UIColor.systemPinkColor];
    }
    return _startBtn;
}

- (UIButton *)stopBtn {
    if (!_stopBtn) {
        @weakify(self)
            _stopBtn = [UIButton buttonWithFrame:CGRectZero title:@"暂停" font:PASFont(25) titleColor:UIColorFromRGB(0xE2233E) block:^{
                @strongify(self)
                    [self stopRecording];
            }];
        [_stopBtn setCornerRadius:6.0 borderWidth:1.0 borderColor:UIColor.systemPinkColor];
    }
    return _stopBtn;
}

@end
