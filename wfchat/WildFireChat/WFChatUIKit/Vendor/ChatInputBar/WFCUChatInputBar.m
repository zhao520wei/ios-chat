//
//  ChatInputBar.m
//  WFChat UIKit
//
//  Created by WF Chat on 2017/10/28.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import <CoreText/CoreText.h>
#import "WFCUChatInputBar.h"

#import "WFCUFaceBoard.h"
#import "WFCUVoiceRecordView.h"
#import "WFCUPluginBoardView.h"
#import "WFCUUtilities.h"
#import "WFCULocationViewController.h"
#import "WFCULocationPoint.h"
#import "WFCUSelectFileViewController.h"
#import "KZVideoViewController.h"
#import "UIView+Toast.h"
#import <WFChatClient/WFCChatClient.h>
#import "WFCUContactListViewController.h"
#import "MBProgressHUD.h"
#import "UIColor+YH.h"
#if WFCU_SUPPORT_VOIP
#import <WFAVEngineKit/WFAVEngineKit.h>
#endif
#import "DNImagePickerController.h"
#import "DNAsset.h"
#import <Photos/Photos.h>


#define CHAT_INPUT_BAR_PADDING 8
#define CHAT_INPUT_BAR_ICON_SIZE (CHAT_INPUT_BAR_HEIGHT - CHAT_INPUT_BAR_PADDING - CHAT_INPUT_BAR_PADDING)

@implementation WFCUMetionInfo
- (instancetype)initWithType:(int)type target:(NSString *)target range:(NSRange)range {
    self = [super init];
    if (self) {
        self.mentionType = type;
        self.target = target;
        self.range = range;
    }
    return self;
}
@end

//@implementation TextInfo
//
//@end
@interface WFCUChatInputBar () <UITextViewDelegate, WFCUFaceBoardDelegate, UIImagePickerControllerDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate, WFCUPluginBoardViewDelegate, UIImagePickerControllerDelegate, LocationViewControllerDelegate, UIActionSheetDelegate, KZVideoViewControllerDelegate, DNImagePickerControllerDelegate>

@property (nonatomic, assign)BOOL textInput;
@property (nonatomic, assign)BOOL voiceInput;
@property (nonatomic, assign)BOOL emojInput;
@property (nonatomic, assign)BOOL pluginInput;

@property (nonatomic, strong)UIButton *voiceSwitchBtn;
@property (nonatomic, strong)UIButton *emojSwitchBtn;
@property (nonatomic, strong)UIButton *pluginSwitchBtn;

@property (nonatomic, strong)UITextView *textInputView;
@property (nonatomic, strong)UIView *inputCoverView;

@property (nonatomic, strong)UIButton *voiceInputBtn;

@property (nonatomic, strong)UIView *emojInputView;
@property (nonatomic, strong)UIView *pluginInputView;

@property(nonatomic, weak)id<WFCUChatInputBarDelegate> delegate;

@property (nonatomic, strong)WFCUVoiceRecordView *recordView;

@property(nonatomic) AVAudioRecorder *recorder;
@property(nonatomic) NSTimer *recordingTimer;
@property(nonatomic) NSTimer *updateMeterTimer;
@property(nonatomic, assign) int seconds;
@property(nonatomic) BOOL recordCanceled;

@property(nonatomic, weak)UIView *parentView;

@property (nonatomic, strong)NSMutableArray<WFCUMetionInfo *> *mentionInfos;
@property (nonatomic, strong)WFCCConversation *conversation;

@property (nonatomic, assign)double lastTypingTime;

@property (nonatomic, strong)UIColor *textInputViewTintColor;

@property (nonatomic, assign)CGRect backupFrame;
@end

@implementation WFCUChatInputBar
- (instancetype)initWithSuperView:(UIView *)parentView conversation:(WFCCConversation *)conversation delegate:(id<WFCUChatInputBarDelegate>)delegate {
    self = [super initWithFrame:CGRectMake(0, parentView.bounds.size.height - CHAT_INPUT_BAR_HEIGHT, parentView.bounds.size.width, CHAT_INPUT_BAR_HEIGHT)];
    if (self) {
        [parentView addSubview:self];
        [self initSubViews];
        self.delegate = delegate;
        self.parentView = parentView;
        self.mentionInfos = [[NSMutableArray alloc] init];
        self.conversation = conversation;
        self.lastTypingTime = 0;
        self.backupFrame = CGRectZero;
    }
    return self;
}

- (void)initSubViews {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    self.backgroundColor = [UIColor colorWithHexString:@"0xf7f7f7"];
    CGRect parentRect = self.bounds;
    self.voiceSwitchBtn = [[UIButton alloc] initWithFrame:CGRectMake(CHAT_INPUT_BAR_PADDING, CHAT_INPUT_BAR_PADDING, CHAT_INPUT_BAR_ICON_SIZE, CHAT_INPUT_BAR_ICON_SIZE)];
    [self.voiceSwitchBtn setImage:[UIImage imageNamed:@"chat_input_bar_voice"] forState:UIControlStateNormal];
    [self.voiceSwitchBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.voiceSwitchBtn addTarget:self action:@selector(onSwitchBtn:) forControlEvents:UIControlEventTouchDown];
    [self addSubview:self.voiceSwitchBtn];
    
    self.pluginSwitchBtn = [[UIButton alloc] initWithFrame:CGRectMake(parentRect.size.width - CHAT_INPUT_BAR_HEIGHT + CHAT_INPUT_BAR_PADDING, CHAT_INPUT_BAR_PADDING, CHAT_INPUT_BAR_ICON_SIZE, CHAT_INPUT_BAR_ICON_SIZE)];
    [self.pluginSwitchBtn setImage:[UIImage imageNamed:@"chat_input_bar_plugin"] forState:UIControlStateNormal];
    [self.pluginSwitchBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.pluginSwitchBtn addTarget:self action:@selector(onSwitchBtn:) forControlEvents:UIControlEventTouchDown];
    [self addSubview:self.pluginSwitchBtn];
    
    self.emojSwitchBtn = [[UIButton alloc] initWithFrame:CGRectMake(parentRect.size.width - CHAT_INPUT_BAR_HEIGHT - CHAT_INPUT_BAR_ICON_SIZE, CHAT_INPUT_BAR_PADDING, CHAT_INPUT_BAR_ICON_SIZE, CHAT_INPUT_BAR_ICON_SIZE)];
    [self.emojSwitchBtn setImage:[UIImage imageNamed:@"chat_input_bar_emoj"] forState:UIControlStateNormal];
    [self.emojSwitchBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.emojSwitchBtn addTarget:self action:@selector(onSwitchBtn:) forControlEvents:UIControlEventTouchDown];
    [self addSubview:self.emojSwitchBtn];
    
    self.textInputView = [[UITextView alloc] initWithFrame:CGRectMake(CHAT_INPUT_BAR_HEIGHT, CHAT_INPUT_BAR_PADDING, parentRect.size.width - CHAT_INPUT_BAR_HEIGHT - CHAT_INPUT_BAR_HEIGHT - CHAT_INPUT_BAR_HEIGHT + CHAT_INPUT_BAR_PADDING, CHAT_INPUT_BAR_ICON_SIZE)];
    self.textInputView.delegate = self;
    self.textInputView.layoutManager.allowsNonContiguousLayout = NO;
    [self.textInputView setExclusiveTouch:YES];
    [self.textInputView setTextColor:[UIColor blackColor]];
    [self.textInputView setFont:[UIFont systemFontOfSize:16]];
    [self.textInputView setReturnKeyType:UIReturnKeySend];
    self.textInputView.backgroundColor = [UIColor whiteColor];
    self.textInputView.enablesReturnKeyAutomatically = YES;
    self.textInputView.userInteractionEnabled = YES;
    [self addSubview:self.textInputView];
    
    self.inputCoverView = [[UIView alloc] initWithFrame:self.textInputView.bounds];
    self.inputCoverView.backgroundColor = [UIColor clearColor];
    [self.textInputView addSubview:self.inputCoverView];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapInputView:)];
        tap.numberOfTapsRequired = 1;
        [self.inputCoverView addGestureRecognizer:tap];
    
    
    self.voiceInputBtn = [[UIButton alloc] initWithFrame:CGRectMake(CHAT_INPUT_BAR_HEIGHT, CHAT_INPUT_BAR_PADDING, parentRect.size.width - CHAT_INPUT_BAR_HEIGHT - CHAT_INPUT_BAR_HEIGHT - CHAT_INPUT_BAR_HEIGHT + CHAT_INPUT_BAR_PADDING, CHAT_INPUT_BAR_ICON_SIZE)];
    [self.voiceInputBtn setTitle:WFCString(@"HoldToTalk") forState:UIControlStateNormal];
    [self.voiceInputBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.voiceInputBtn.layer.cornerRadius = 4;
    self.voiceInputBtn.layer.masksToBounds = YES;
    self.voiceInputBtn.layer.borderWidth = 0.5f;
    self.voiceInputBtn.layer.borderColor = HEXCOLOR(0xdbdbdd).CGColor;
    [self addSubview:self.voiceInputBtn];
    
    self.layer.borderWidth = 0.5f;
    self.layer.borderColor = HEXCOLOR(0xdbdbdd).CGColor;
    
    self.inputBarStatus = ChatInputBarDefaultStatus;
    
    
    [self.voiceInputBtn addTarget:self action:@selector(onTouchDown:) forControlEvents:UIControlEventTouchDown];
    [self.voiceInputBtn addTarget:self action:@selector(onTouchDragExit:) forControlEvents:UIControlEventTouchDragExit];
    [self.voiceInputBtn addTarget:self action:@selector(onTouchDragEnter:) forControlEvents:UIControlEventTouchDragEnter];
    [self.voiceInputBtn addTarget:self action:@selector(onTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.voiceInputBtn addTarget:self action:@selector(onTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
    [self.voiceInputBtn addTarget:self action:@selector(onTouchUpOutside:) forControlEvents:UIControlEventTouchCancel];

    self.voiceInputBtn.hidden = YES;
    self.textInputView.returnKeyType = UIReturnKeySend;
    self.textInputView.delegate = self;
}

- (void)onTapInputView:(id)sender {
    NSLog(@"on tap input view");
    self.inputBarStatus = ChatInputBarKeyboardStatus;
}

- (void)onTouchDown:(id)sender {
    if ([self canRecord]) {
        _recordView = [[WFCUVoiceRecordView alloc] initWithFrame:CGRectMake(self.parentView.bounds.size.width/2 - 70, self.parentView.bounds.size.height/2 - 100, 140, 150)];
//        _recordView.center = self.parentView.center;
        [self.parentView addSubview:_recordView];
        [self.parentView bringSubviewToFront:_recordView];
        
        [self recordStart];
    }
}

- (void)willAppear {
    if (self.backupFrame.size.height) {
        [self.delegate willChangeFrame:self.backupFrame withDuration:0.5 keyboardShowing:NO];
    }
}

- (void)recordStart {
    if (self.recorder.recording) {
        return;
    }
    
    //[self stopPlayer];
    
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        if (granted) {
            AVAudioSession *session = [AVAudioSession sharedInstance];
            [session setCategory:AVAudioSessionCategoryRecord error:nil];
            BOOL r = [session setActive:YES error:nil];
            if (!r) {
                NSLog(@"activate audio session fail");
                return;
            }
            NSLog(@"start record...");
            
            NSArray *pathComponents = [NSArray arrayWithObjects:
                                       [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                                       @"voice.wav",
                                       nil];
            NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
            
            // Define the recorder setting
            NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
            
            [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
            [recordSetting setValue:[NSNumber numberWithFloat:8000] forKey:AVSampleRateKey];
            [recordSetting setValue:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
            
            self.recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSetting error:NULL];
            self.recorder.delegate = self;
            self.recorder.meteringEnabled = YES;
            if (![self.recorder prepareToRecord]) {
                NSLog(@"prepare record fail");
                return;
            }
            if (![self.recorder record]) {
                NSLog(@"start record fail");
                return;
            }
            
            
            self.recordCanceled = NO;
            self.seconds = 0;
            self.recordingTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
            
            self.updateMeterTimer = [NSTimer scheduledTimerWithTimeInterval:0.05
                                                                     target:self
                                                                   selector:@selector(updateMeter:)
                                                                   userInfo:nil
                                                                    repeats:YES];
        } else {
            [[[UIAlertView alloc] initWithTitle:@"警告" message:@"无法录音,请到设置-隐私-麦克风,允许程序访问" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] show];
        }
    }];
}

- (void)recordCancel {
    NSLog(@"touch cancel");
    
    if (self.recorder.recording) {
        NSLog(@"cancel record...");
        self.recordCanceled = YES;
        [self stopRecord];
    }
}

- (void)onTouchDragExit:(id)sender {
    [self.recordView recordButtonDragOutside];
    NSLog(@"----  onTouchDragExit");
}

- (void)onTouchDragEnter:(id)sender {
    [self.recordView recordButtonDragInside];
    NSLog(@"----  onTouchDragEnter");
}

- (void)onTouchUpInside:(id)sender {
    [self.recordView removeFromSuperview];
    [self recordEnd];
    
    NSLog(@"----  onTouchUpInside");
}

- (void)onTouchUpOutside:(id)sender {
    [self.recordView removeFromSuperview];
    [self recordCancel];
}

- (BOOL)canRecord {
    __block BOOL bCanRecord = YES;
    
    if ([[AVAudioSession sharedInstance]
         respondsToSelector:@selector(requestRecordPermission:)]) {
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            bCanRecord = granted;
            dispatch_async(dispatch_get_main_queue(), ^{
                bCanRecord = granted;
                if (granted) {
                    bCanRecord = YES;
                } else {
                    
                }
            });
        }];
    }
    
    return bCanRecord;
}

- (void)timerFired:(NSTimer*)timer {
    self.seconds = self.seconds + 1;
    int minute = self.seconds/60;
    int s = self.seconds%60;
    NSString *str = [NSString stringWithFormat:@"%02d:%02d", minute, s];
    NSLog(@"timer:%@", str);
    int countdown = 60 - self.seconds;
    if (countdown <= 10) {
        [self.recordView setCountdown:countdown];
    }
    if (countdown <= 0) {
        [self.recordView removeFromSuperview];
        [self recordEnd];
    } else {
        [self notifyTyping:1];
    }
}
// 监听说话音量的大小来调节音量的动画
- (void)updateMeter:(NSTimer*)timer {
    double voiceMeter = 0;
    if ([self.recorder isRecording]) {
        [self.recorder updateMeters];
        //获取音量的平均值  [recorder averagePowerForChannel:0];
        //音量的最大值  [recorder peakPowerForChannel:0];
        double lowPassResults = pow(10, (0.05 * [self.recorder peakPowerForChannel:0]));
        voiceMeter = lowPassResults;
    }
    [self.recordView setVoiceImage:voiceMeter];
}

-(void)recordEnd {
    if (self.recorder.recording) {
        NSLog(@"stop record...");
        self.recordCanceled = NO;
        [self stopRecord];
    }
}

-(void)stopRecord {
    [self.recorder stop];
    [self.recordingTimer invalidate];
    self.recordingTimer = nil;
    [self.updateMeterTimer invalidate];
    self.updateMeterTimer = nil;
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    BOOL r = [audioSession setActive:NO error:nil];
    if (!r) {
        NSLog(@"deactivate audio session fail");
    }
}

- (void)resetInputBarStatue {
    if (self.inputBarStatus != ChatInputBarRecordStatus && self.inputBarStatus != ChatInputBarMuteStatus) {
        self.inputBarStatus = ChatInputBarDefaultStatus;
    }
}

- (void)onSwitchBtn:(id)sender {
    if (sender == self.voiceSwitchBtn) {
        if (self.voiceInput && self.inputBarStatus != ChatInputBarDefaultStatus) {
            self.inputBarStatus = ChatInputBarKeyboardStatus;
        } else {
            self.inputBarStatus = ChatInputBarRecordStatus;
        }
    } else if(sender == self.emojSwitchBtn) {
        if (self.emojInput && self.inputBarStatus != ChatInputBarDefaultStatus) {
            self.inputBarStatus = ChatInputBarKeyboardStatus;
        } else {
            self.inputBarStatus = ChatInputBarEmojiStatus;
        }
    } else if (sender == self.pluginSwitchBtn) {
        if (self.pluginInput && self.inputBarStatus != ChatInputBarDefaultStatus) {
            self.inputBarStatus = ChatInputBarKeyboardStatus;
        } else {
            self.inputBarStatus = ChatInputBarPluginStatus;
        }
    }
}

- (void)setInputBarStatus:(ChatInputBarStatus)inputBarStatus {
    if (inputBarStatus == _inputBarStatus) {
        return;
    }
    if (_inputBarStatus == ChatInputBarMuteStatus) {
        [self.textInputView setUserInteractionEnabled:YES];
        [self.voiceInputBtn setEnabled:YES];
        [self.voiceSwitchBtn setEnabled:YES];
        [self.emojSwitchBtn setEnabled:YES];
        [self.pluginSwitchBtn setEnabled:YES];
    }
    
    _inputBarStatus = inputBarStatus;
    switch (inputBarStatus) {
        case ChatInputBarKeyboardStatus:
            self.voiceInput = NO;
            self.emojInput = NO;
            self.pluginInput = NO;
            self.textInput = YES;
            break;
        case ChatInputBarPluginStatus:
            self.voiceInput = NO;
            self.emojInput = NO;
            self.pluginInput = YES;
            self.textInput = NO;
            break;
        case ChatInputBarEmojiStatus:
            self.voiceInput = NO;
            self.emojInput = YES;
            self.pluginInput = NO;
            self.textInput = NO;
            break;
        case ChatInputBarRecordStatus:
            self.voiceInput = YES;
            self.emojInput = NO;
            self.pluginInput = NO;
            self.textInput = NO;
            break;
        case ChatInputBarPublicStatus:
            self.voiceInput = NO;
            self.emojInput = NO;
            self.pluginInput = NO;
            self.textInput = NO;
            break;
        case ChatInputBarDefaultStatus:
            self.voiceInput = NO;
            self.emojInput = NO;
            self.pluginInput = NO;
            self.textInput = YES;
            [self.textInputView resignFirstResponder];
            break;
        case ChatInputBarMuteStatus:
            self.voiceInput = NO;
            self.emojInput = NO;
            self.pluginInput = NO;
            self.textInput = YES;
            [self.textInputView setUserInteractionEnabled:NO];
            [self.voiceInputBtn setEnabled:NO];
            [self.voiceSwitchBtn setEnabled:NO];
            [self.emojSwitchBtn setEnabled:NO];
            [self.pluginSwitchBtn setEnabled:NO];
            break;
        default:
            break;
    }
    if (inputBarStatus != ChatInputBarKeyboardStatus) {
        if (self.textInputView.tintColor != [UIColor clearColor]) {
            self.textInputViewTintColor = self.textInputView.tintColor;
        }
        self.textInputView.tintColor = [UIColor clearColor];
        self.inputCoverView.hidden = NO;
    } else {
        self.textInputView.tintColor = self.textInputViewTintColor;
        self.inputCoverView.hidden = YES;
    }
}

- (void)setVoiceInput:(BOOL)voiceInput {
    _voiceInput = voiceInput;
    if (voiceInput) {
        [self.textInputView setHidden:YES];
        [self.voiceInputBtn setHidden:NO];
        if (self.textInputView.isFirstResponder) {
            [self.textInputView resignFirstResponder];
        }
        [self.voiceSwitchBtn setImage:[UIImage imageNamed:@"chat_input_bar_keyboard"] forState:UIControlStateNormal];
    } else {
        [self.textInputView setHidden:NO];
        [self.voiceInputBtn setHidden:YES];
        [self.voiceSwitchBtn setImage:[UIImage imageNamed:@"chat_input_bar_voice"] forState:UIControlStateNormal];
    }
}

- (void)setEmojInput:(BOOL)emojInput {
    _emojInput = emojInput;
    if (emojInput) {
        [self.textInputView setHidden:NO];
        [self.voiceInputBtn setHidden:YES];
        self.textInputView.inputView = self.emojInputView;
        if (!self.textInputView.isFirstResponder) {
            [self.textInputView becomeFirstResponder];
        }
        [self.textInputView reloadInputViews];
        [self.emojSwitchBtn setImage:[UIImage imageNamed:@"chat_input_bar_keyboard"] forState:UIControlStateNormal];
    } else {
        [self.emojSwitchBtn setImage:[UIImage imageNamed:@"chat_input_bar_emoj"] forState:UIControlStateNormal];
    }
}

- (void)setPluginInput:(BOOL)pluginInput {
    _pluginInput = pluginInput;
    if (pluginInput) {
        [self.textInputView setHidden:NO];
        [self.voiceInputBtn setHidden:YES];
        self.textInputView.inputView = self.pluginInputView;
        if (!self.textInputView.isFirstResponder) {
            [self.textInputView becomeFirstResponder];
        }
        [self.textInputView reloadInputViews];
    }
}

- (void)setTextInput:(BOOL)textInput {
    _textInput = textInput;
    if (textInput) {
        [self.textInputView setHidden:NO];
        [self.voiceInputBtn setHidden:YES];
        self.textInputView.inputView = nil;
        if (!self.textInputView.isFirstResponder && _inputBarStatus == ChatInputBarKeyboardStatus) {
            [self.textInputView becomeFirstResponder];
        }
        if (_inputBarStatus == ChatInputBarKeyboardStatus) {
            [self.textInputView reloadInputViews];
        }
    }
    
}

- (void)notifyTyping:(WFCCTypingType)type {
    double now = [[NSDate date] timeIntervalSince1970];
    if (self.lastTypingTime + TYPING_INTERVAL < now) {
        if ([self.delegate respondsToSelector:@selector(onTyping:)]) {
            [self.delegate onTyping:type];
        }
        self.lastTypingTime = now;
    }
}
- (void)setDraft:(NSString *)draft {
    NSError *__error = nil;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:[draft dataUsingEncoding:NSUTF8StringEncoding]
                                                               options:kNilOptions
                                                                 error:&__error];
    
    BOOL hasMentionInfo = NO;
    NSString *text = nil;
    NSMutableArray<WFCUMetionInfo *> *mentionInfos = [[NSMutableArray alloc] init];
    if (!__error) {
        if (dictionary[@"text"] != nil && [dictionary[@"mentions"] isKindOfClass:[NSArray class]]) {
            hasMentionInfo = YES;
            text = dictionary[@"text"];
            NSArray *mentions = dictionary[@"mentions"];
            [mentions enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSDictionary *dic = (NSDictionary *)obj;
                WFCUMetionInfo *mentionInfo = [[WFCUMetionInfo alloc] init];
                mentionInfo.target = dic[@"target"];
                mentionInfo.mentionType = [dic[@"type"] intValue];
                mentionInfo.range = NSMakeRange([dic[@"loc"] integerValue], [dic[@"len"] integerValue]);
                [mentionInfos addObject:mentionInfo];
            }];
        }
    }
    
    if (hasMentionInfo) {
        draft = text;
    }
    //防止弹出@选项
    if ([draft isEqualToString:@"@"]) {
        draft = @"@ ";
    }
    
    [self textView:self.textInputView shouldChangeTextInRange:NSMakeRange(0, 0) replacementText:draft];
    self.textInputView.text = draft;
    self.mentionInfos = mentionInfos;
}

- (NSString *)draft {
    if (self.mentionInfos.count) {
        NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
        [dataDict setObject:self.textInputView.text forKey:@"text"];
        NSMutableArray *mentions = [[NSMutableArray alloc] init];
        [self.mentionInfos enumerateObjectsUsingBlock:^(WFCUMetionInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setObject:obj.target forKey:@"target"];
            [dic setObject:@(obj.mentionType) forKey:@"type"];
            [dic setObject:@(obj.range.location) forKey:@"loc"];
            [dic setObject:@(obj.range.length) forKey:@"len"];
            [mentions addObject:dic];
        }];
        [dataDict setObject:mentions forKey:@"mentions"];
        
        NSData *data = [NSJSONSerialization dataWithJSONObject:dataDict
                                                                options:kNilOptions
                                                                  error:nil];
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    } else {
        return self.textInputView.text;
    }
}

- (void)appendText:(NSString *)text {
    [self textView:self.textInputView shouldChangeTextInRange:NSMakeRange(self.textInputView.text.length, 0) replacementText:text];
    self.textInputView.text = [self.textInputView.text stringByAppendingString:text];
}

- (UIView *)emojInputView {
    if (!_emojInputView) {
        _emojInputView = [[WFCUFaceBoard alloc] init];
        ((WFCUFaceBoard*)_emojInputView).delegate = self;
    }
    return _emojInputView;
}

- (UIView *)pluginInputView {
    if (!_pluginInputView) {
#if WFCU_SUPPORT_VOIP
        BOOL hasVoip = self.conversation.type == Single_Type || (self.conversation.type == Group_Type && [WFAVEngineKit sharedEngineKit].supportMultiCall);
#else
        BOOL hasVoip = NO;
#endif
        _pluginInputView = [[WFCUPluginBoardView alloc] initWithDelegate:self withVoip:hasVoip];
    }
    return _pluginInputView;
}

- (void)keyboardWillShow:(NSNotification *)notification {
    if (![self.textInputView isFirstResponder]) {
        return;
    }
    NSDictionary *userInfo = [notification userInfo];
    NSValue *value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [value CGRectValue];
    int height = keyboardRect.size.height - kTabbarSafeBottomMargin;
    
    CGFloat duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect frame = CGRectMake(0, self.superview.bounds.size.height - self.bounds.size.height - height, self.superview.bounds.size.width, self.bounds.size.height);
    [self.delegate willChangeFrame:frame withDuration:duration keyboardShowing:YES];
    self.backupFrame = frame;
    [UIView animateWithDuration:duration animations:^{
        self.frame = frame;
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    
    CGFloat duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect frame = CGRectMake(0, self.superview.bounds.size.height - self.bounds.size.height, self.superview.bounds.size.width, self.bounds.size.height);
    [self.delegate willChangeFrame:frame withDuration:duration keyboardShowing:NO];
    self.backupFrame = frame;
    [UIView animateWithDuration:duration animations:^{
        self.frame = frame;
    }];
}

-(void)keyboardDidHide:(NSNotification *)notification{
    if ((self.emojInput || self.pluginInput || self.textInput) && self.inputBarStatus != ChatInputBarDefaultStatus) {
        [self.textInputView becomeFirstResponder];
    }
}

- (BOOL)appendMention:(NSString *)userId name:(NSString *)userName {
    if (self.conversation.type == Group_Type) {
        NSString *mentionText = [NSString stringWithFormat:@"@%@ ", userName];
        BOOL needDelay = NO;
        if(self.inputBarStatus == ChatInputBarDefaultStatus || self.inputBarStatus == ChatInputBarPluginStatus || self.inputBarStatus == ChatInputBarRecordStatus) {
            self.inputBarStatus = ChatInputBarKeyboardStatus;
            needDelay = YES;
        }
        if (needDelay) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self didMentionType:1 user:userId range:NSMakeRange(self.textInputView.selectedRange.location, mentionText.length) text:mentionText];
            });
        } else {
            [self didMentionType:1 user:userId range:NSMakeRange(self.textInputView.selectedRange.location, mentionText.length) text:mentionText];
        }
        
        return YES;
    } else {
        return NO;
    }
}

- (void)paste:(id)sender {
    [self.textInputView paste:sender];
}

#pragma mark - AVAudioRecorderDelegate
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    NSLog(@"record finish:%d", flag);
    if (!flag) {
        return;
    }
    if (self.recordCanceled) {
        return;
    }
    if (self.seconds < 1) {
        NSLog(@"record time too short");
        [[[UIAlertView alloc] initWithTitle:@"警告" message:@"录音时间太短了" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] show];
        
        return;
    }
    [self.delegate recordDidEnd:[recorder.url path] duration:self.seconds error:nil];
    [[NSFileManager defaultManager] removeItemAtURL:recorder.url error:nil];
}

#pragma mark - FaceBoardDelegate
- (void)didTouchEmoj:(NSString *)emojString {
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc]initWithString:emojString];
    UIFont *font = [UIFont fontWithName:@"Heiti SC-Bold" size:16];
    [attStr addAttribute:(__bridge NSString*)kCTFontAttributeName value:(id)CFBridgingRelease(CTFontCreateWithName((CFStringRef)font.fontName,
                                                                                                                   16,
                                                                                                                   NULL)) range:NSMakeRange(0, emojString.length)];
    
    NSInteger cursorPosition;
    if (self.textInputView.selectedTextRange) {
        cursorPosition = self.textInputView.selectedRange.location ;
    } else {
        cursorPosition = 0;
    }
    //获取光标位置
    if(cursorPosition> self.textInputView.textStorage.length)
        cursorPosition = self.textInputView.textStorage.length;
    [self.textInputView.textStorage
     insertAttributedString:attStr  atIndex:cursorPosition];
    
    NSRange range;
    range.location = self.textInputView.selectedRange.location + emojString.length;
    range.length = 1;
    
    self.textInputView.selectedRange = range;
}

- (void)didTouchBackEmoj {
    [self.textInputView deleteBackward];
}

- (void)didTouchSendEmoj {
    [self sendAndCleanTextView];
}

- (void)sendAndCleanTextView {
    [self.delegate didTouchSend:self.textInputView.text withMentionInfos:self.mentionInfos];
    self.textInputView.text = nil;
    [self.mentionInfos removeAllObjects];
    [self changeTextViewHeight:32 needUpdateText:NO updateRange:NSMakeRange(0, 0)];
}


- (void)didSelectedSticker:(NSString *)stickerPath {
    if ([self.delegate respondsToSelector:@selector(didSelectSticker:)]) {
        [self.delegate didSelectSticker:stickerPath];
    }
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]){ //判断输入的字是否是回车，即按下return
        [self sendAndCleanTextView];
        return NO;
    }
    
    BOOL needUpdateText = NO;
    if(self.conversation.type == Group_Type) {
        if ([text isEqualToString:@"@"]) {
            
            WFCUContactListViewController *pvc = [[WFCUContactListViewController alloc] init];
            pvc.selectContact = YES;
            pvc.multiSelect = NO;
            NSMutableArray *disabledUser = [[NSMutableArray alloc] init];
            [disabledUser addObject:[WFCCNetworkService sharedInstance].userId];
            pvc.disableUsers = disabledUser;
            NSMutableArray *candidateUser = [[NSMutableArray alloc] init];
            NSArray<WFCCGroupMember *> *members = [[WFCCIMService sharedWFCIMService] getGroupMembers:self.conversation.target forceUpdate:NO];
            for (WFCCGroupMember *member in members) {
                [candidateUser addObject:member.memberId];
            }
            pvc.candidateUsers = candidateUser;
            pvc.withoutCheckBox = YES;
            
            
            __weak typeof(self)ws = self;
            WFCCGroupInfo *groupInfo = [[WFCCIMService sharedWFCIMService] getGroupInfo:self.conversation.target refresh:NO];
            WFCCGroupMember *member = [[WFCCIMService sharedWFCIMService] getGroupMember:self.conversation.target memberId:[WFCCNetworkService sharedInstance].userId];
            if ([groupInfo.owner isEqualToString:[WFCCNetworkService sharedInstance].userId] || member.type == Member_Type_Manager) {
                pvc.showMentionAll = YES;
                pvc.mentionAll = ^{
                    NSString *text = WFCString(@"@All");
                    [ws didMentionType:2 user:nil range:NSMakeRange(range.location, text.length) text:text];
                };
            }
            
            
            pvc.selectResult = ^(NSArray<NSString *> *contacts) {
                if (contacts.count == 1) {
                    WFCCUserInfo *userInfo = [[WFCCIMService sharedWFCIMService] getUserInfo:[contacts objectAtIndex:0] inGroup:self.conversation.target refresh:NO];
                    NSString *name = userInfo.displayName;
                    if (userInfo.groupAlias.length) {
                        name = userInfo.groupAlias;
                    }
                    
                    NSString *text = [NSString stringWithFormat:@"@%@ ", name];
                    [ws didMentionType:1 user:[contacts objectAtIndex:0] range:NSMakeRange(range.location, text.length) text:text];
                } else {
                    [ws didCancelMentionAtRange:range];
                }
            };
            
            pvc.cancelSelect = ^(void) {
                [ws didCancelMentionAtRange:range];
            };
            
            pvc.disableUsersSelected = YES;
            
            UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:pvc];
            [[self.delegate requireNavi] presentViewController:navi animated:YES completion:nil];
            return NO;
        }
        
        if (text.length == 0) {
            WFCUMetionInfo *deletedMention;
            for (WFCUMetionInfo *mentionInfo in self.mentionInfos) {
                if ((mentionInfo.range.location >= range.location && mentionInfo.range.location < range.location + range.length) ||
                    (range.location >= mentionInfo.range.location && range.location < mentionInfo.range.location + mentionInfo.range.length)) {
                    deletedMention = mentionInfo;
                }
            }
            
            if (deletedMention) {
                range = deletedMention.range;
                [self.mentionInfos removeObject:deletedMention];
                needUpdateText = YES;
            }
        } else {
            for (WFCUMetionInfo *mentionInfo in self.mentionInfos) {
                if (range.location <= mentionInfo.range.location) {
                    mentionInfo.range = NSMakeRange(mentionInfo.range.location - range.length + text.length, mentionInfo.range.length);
                }
            }
        }
        
    }
    
  NSString *oldStr = textView.text;
  NSString *newStr = [oldStr stringByReplacingCharactersInRange:range withString:text];
  CGFloat textAreaWidth = textView.frame.size.width - 2 * textView.textContainer.lineFragmentPadding;
  CGSize size = [WFCUUtilities getTextDrawingSize:newStr font:[UIFont systemFontOfSize:16] constrainedSize:CGSizeMake(textAreaWidth, 1000)];
  
    [self changeTextViewHeight:size.height needUpdateText:needUpdateText updateRange:range];
  
    return YES;
}
- (void)changeTextViewHeight:(CGFloat)height needUpdateText:(BOOL)needUpdateText updateRange:(NSRange)range {
    CGRect tvFrame = self.textInputView.frame;
    CGRect baseFrame = self.frame;
    CGRect voiceFrame = self.voiceSwitchBtn.frame;
    CGRect emojFrame = self.emojSwitchBtn.frame;
    CGRect extendFrame = self.pluginSwitchBtn.frame;
    
    CGFloat diff = 0;
    if (height <= 32.f) {
        tvFrame.size.height = 32.f;
        diff = (48.f - baseFrame.size.height);
        baseFrame.size.height = 48.f;
    } else if (height > 32.f && height < 50.f) {
        tvFrame.size.height = 50.f;
        diff = (66.f - baseFrame.size.height);
        baseFrame.size.height = 66.f;
    } else {
        tvFrame.size.height = 65.f;
        diff = (81.f - baseFrame.size.height);
        baseFrame.size.height = 81.f;
    }
    
    baseFrame.origin.y -= diff;
    voiceFrame.origin.y += diff;
    emojFrame.origin.y += diff;
    extendFrame.origin.y += diff;
    
    
    float duration = 0.5f;
    [self.delegate willChangeFrame:baseFrame withDuration:duration keyboardShowing:YES];
    self.backupFrame = baseFrame;
    __weak typeof(self)ws = self;
    [UIView animateWithDuration:duration animations:^{
        ws.textInputView.frame = tvFrame;
        ws.inputCoverView.frame = ws.textInputView.bounds;
        self.frame = baseFrame;
        self.voiceSwitchBtn.frame = voiceFrame;
        self.emojSwitchBtn.frame = emojFrame;
        self.pluginSwitchBtn.frame = extendFrame;
        if(needUpdateText) {
            [ws.textInputView.textStorage replaceCharactersInRange:range withString:@" "];
        }
    }];
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
    if (self.textInputView == textView && self.conversation.type == Group_Type) {
        NSRange range = textView.selectedRange;
        for (WFCUMetionInfo *mention in self.mentionInfos) {
            if (range.location > mention.range.location && range.location < mention.range.location + mention.range.length) {
                if (range.length == 0) {
                    if(range.location == mention.range.location + mention.range.length - 1) {
                        range.location = mention.range.location;
                    } else {
                        range = NSMakeRange(mention.range.location + mention.range.length, 0);
                    }
                } else {
                    long length = range.length - (mention.range.location + mention.range.length) + range.location;
                    if (length < 0) {
                        length = 0;
                    }
                    range = NSMakeRange(mention.range.location + mention.range.length, length);
                }
                
                textView.selectedRange = range;
                break;
            }
        }
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    if (textView.text.length > 0) {
        [self notifyTyping:0];
    }
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if (self.inputBarStatus == ChatInputBarDefaultStatus) {
        self.inputBarStatus = ChatInputBarKeyboardStatus;
    }
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    return YES;
}
#pragma mark - PluginBoardViewDelegate  聊天对话框的下方选择button action

- (void)onItemClicked:(NSUInteger)itemTag {
    UINavigationController *navi = [self.delegate requireNavi];
  
    self.inputBarStatus = ChatInputBarDefaultStatus;
    if (itemTag == 1) {
#if 0
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
#if TARGET_IPHONE_SIMULATOR
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
#else
        if (itemTag == 1) {
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        } else if(itemTag == 2){
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        }
#endif
        picker.videoExportPreset = AVAssetExportPresetPassthrough;
        picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:picker.sourceType];
        [navi presentViewController:picker animated:YES completion:nil];
        [self checkAndAlertCameraAccessRight];
#else
        DNImagePickerController *imagePicker = [[DNImagePickerController alloc] init];
        imagePicker.imagePickerDelegate = self;
        imagePicker.modalPresentationStyle = UIModalPresentationFullScreen;
        [navi presentViewController:imagePicker animated:YES completion:nil];
#endif
    } else if(itemTag == 2) {
#if TARGET_IPHONE_SIMULATOR
        [self makeToast:@"模拟器不支持相机" duration:1 position:CSToastPositionCenter];
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [navi presentViewController:picker animated:YES completion:nil];
        [self checkAndAlertCameraAccessRight];
#else
        KZVideoViewController *videoVC = [[KZVideoViewController alloc] init];
        videoVC.delegate = self;
        [videoVC startAnimationWithType:KZVideoViewShowTypeSingle selectExist:NO];
        double now = [[NSDate date] timeIntervalSince1970];
        [self notifyTyping:2];
#endif
    } else if(itemTag == 3){
        WFCULocationViewController *vc = [[WFCULocationViewController alloc] initWithDelegate:self];
        
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        [navi presentViewController:nav animated:YES completion:nil];
        [self notifyTyping:3];
        return;
    } else if(itemTag == 4) {
#if WFCU_SUPPORT_VOIP
        UIActionSheet *actionSheet =
        [[UIActionSheet alloc] initWithTitle:nil
                                    delegate:self
                           cancelButtonTitle:WFCString(@"Cancel")
                      destructiveButtonTitle:@"视频"
                           otherButtonTitles:@"音频", nil];
        [actionSheet showInView:self.parentView];
#endif
    } else if(itemTag == 5) {
        WFCUSelectFileViewController *sfvc = [[WFCUSelectFileViewController alloc] init];
        UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:sfvc];
        __weak typeof(self) ws = self;
        sfvc.selectResult = ^(NSArray *selectFiles) {
            [ws.delegate didSelectFiles:selectFiles];
        };
        [[self.delegate requireNavi] presentViewController:navi animated:YES completion:nil];
        [self notifyTyping:4];
    } else if (itemTag == 6) {
        // 发送请假单
        if ([self.delegate respondsToSelector:@selector(sentLeaveMessage)]) {
            [self.delegate sentLeaveMessage];
        }
    } else if (itemTag == 7) {
        if ([self.delegate respondsToSelector:@selector(sendUniversalCustomMessage)]) {
            [self.delegate sendUniversalCustomMessage];
        }
    }
    
    
}
- (void)checkAndAlertCameraAccessRight {
    AVAuthorizationStatus authStatus =
    [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusDenied ||
        authStatus == AVAuthorizationStatusRestricted) {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"拍照权限"
                                  message:@"需要拍照权限，请在设置里打开"
                                  delegate:nil
                                  cancelButtonTitle:@"确认"
                                  otherButtonTitles:nil, nil];
        [alertView show];
    }
}

#pragma mark - UIImagePickerControllerDelegate<NSObject>
//- (void)imagePickerController:(UIImagePickerController *)picker
//        didFinishPickingImage:(UIImage *)image
//                  editingInfo:(NSDictionary *)editingInfo {
//    [picker dismissViewControllerAnimated:YES completion:nil];
//    [self.delegate imageDidCapture:image];
//}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey, id> *)info {
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if([mediaType isEqualToString:@"public.movie"]) {
        NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
        NSString *url = [videoURL absoluteString];
        url = [url stringByReplacingOccurrencesOfString:@"file:///private" withString:@""];
        //获取视频的thumbnail
        AVURLAsset *asset1 = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
        AVAssetImageGenerator *generate1 = [[AVAssetImageGenerator alloc] initWithAsset:asset1];
        generate1.appliesPreferredTrackTransform = YES;
        NSError *err = NULL;
        CMTime time = CMTimeMake(1, 2);
        CGImageRef oneRef = [generate1 copyCGImageAtTime:time actualTime:NULL error:&err];
        UIImage *thumbnail = [[UIImage alloc] initWithCGImage:oneRef];
        thumbnail = [WFCCUtilities generateThumbnail:thumbnail withWidth:120 withHeight:120];
        
        AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:videoURL options:nil];
        NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
        
        NSString *CompressionVideoPaht = [WFCCUtilities getDocumentPathWithComponent:@"/VIDEO"];
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:@"AVAssetExportPresetMediumQuality"];
        
        NSDateFormatter *formater = [[NSDateFormatter alloc] init];// 用时间, 给文件重新命名, 防止视频存储覆盖,
        
        [formater setDateFormat:@"yyyy-MM-dd-HH:mm:ss"];
        
        NSFileManager *manager = [NSFileManager defaultManager];
        
        BOOL isExists = [manager fileExistsAtPath:CompressionVideoPaht];
        if (!isExists) {
             [manager createDirectoryAtPath:CompressionVideoPaht withIntermediateDirectories:YES attributes:nil error:nil];
         }
//        
        NSString *resultPath = [CompressionVideoPaht stringByAppendingPathComponent:[NSString stringWithFormat:@"outputJFVideo-%@.mov", [formater stringFromDate:[NSDate date]]]];
        
        NSLog(@"resultPath = %@",resultPath);
        
        exportSession.outputURL = [NSURL fileURLWithPath:resultPath];
        
        exportSession.outputFileType = AVFileTypeMPEG4;
        
        exportSession.shouldOptimizeForNetworkUse = YES;
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:picker.view animated:YES];
        hud.label.text = @"处理中...";
        [hud showAnimated:YES];
        
        __weak typeof(self)ws = self;
        [exportSession exportAsynchronouslyWithCompletionHandler:^(void)
         {
             if (exportSession.status == AVAssetExportSessionStatusCompleted) {
                 NSData *data = [NSData dataWithContentsOfFile:resultPath];
                 float memorySize = (float)data.length / 1024 / 1024;
                 NSLog(@"视频压缩后大小 %f", memorySize);
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [hud hideAnimated:YES];
                     [picker dismissViewControllerAnimated:YES completion:nil];
                     [ws.delegate videoDidCapture:resultPath thumbnail:thumbnail duration:10];
                 });
             } else {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [hud hideAnimated:YES];
                     [picker dismissViewControllerAnimated:YES completion:nil];
                 });
                 NSLog(@"压缩失败");
             }
             
         }];
        

    } else if ([mediaType isEqualToString:@"public.image"]) {
        [picker dismissViewControllerAnimated:YES completion:nil];
        UIImage* image = [info objectForKey:UIImagePickerControllerEditedImage];
        if (!image)
            image = [info objectForKey:UIImagePickerControllerOriginalImage];
        [self.delegate imageDidCapture:image];
    }
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - LocationViewControllerDelegate <NSObject>

- (void)onSendLocation:(WFCULocationPoint *)locationPoint {
    [self.delegate locationDidSelect:locationPoint.coordinate locationName:locationPoint.title mapScreenShot:locationPoint.thumbnail];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
#if WFCU_SUPPORT_VOIP
        [self.delegate didTouchVideoBtn:NO];
#endif
    } else if(buttonIndex == 1) {
#if WFCU_SUPPORT_VOIP
        [self.delegate didTouchVideoBtn:YES];
#endif
    }
}

#pragma mark - KZVideoViewControllerDelegate
- (void)videoViewController:(KZVideoViewController *)videoController didCaptureImage:(UIImage *)image {
    [self.delegate imageDidCapture:image];
}
- (void)videoViewController:(KZVideoViewController *)videoController didRecordVideo:(KZVideoModel *)videoModel {
    [self.delegate videoDidCapture:videoModel.videoAbsolutePath thumbnail:[UIImage imageWithContentsOfFile:videoModel.thumAbsolutePath] duration:10];
}

- (void)videoViewControllerDidCancel:(KZVideoViewController *)videoController {

}

#pragma mark - WFCUMentionUserDelegate
- (void)didMentionType:(int)type user:(NSString *)userId range:(NSRange)range text:(NSString *)text {
    [self textView:self.textInputView shouldChangeTextInRange:NSMakeRange(range.location, 0) replacementText:text];
    
    [self.mentionInfos addObject:[[WFCUMetionInfo alloc] initWithType:type target:userId range:NSMakeRange(range.location, range.length)]];
    
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc]initWithString:text];
    UIFont *font = [UIFont fontWithName:@"Heiti SC-Bold" size:16];
    [attStr addAttribute:(__bridge NSString*)kCTFontAttributeName value:(id)CFBridgingRelease(CTFontCreateWithName((CFStringRef)font.fontName,
                                                                                                                   16,
                                                                                                                   NULL)) range:NSMakeRange(0, text.length)];
    
    [self.textInputView.textStorage
     insertAttributedString:attStr  atIndex:range.location];
    range.location += range.length;
    range.length = 0;
    self.textInputView.selectedRange = range;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self.textInputView.isFirstResponder) {
            [self.textInputView becomeFirstResponder];
        }
    });
}

- (void)didCancelMentionAtRange:(NSRange)range {
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc]initWithString:@"@"];
    UIFont *font = [UIFont fontWithName:@"Heiti SC-Bold" size:16];
    [attStr addAttribute:(__bridge NSString*)kCTFontAttributeName value:(id)CFBridgingRelease(CTFontCreateWithName((CFStringRef)font.fontName,
                                                                                                                   16,
                                                                                                                   NULL)) range:NSMakeRange(0, 1)];
    

    [self.textInputView.textStorage
     insertAttributedString:attStr  atIndex:range.location];
    range.location += 1;
    range.length = 0;
    
    self.textInputView.selectedRange = range;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self.textInputView.isFirstResponder) {
            [self.textInputView becomeFirstResponder];
        }
    });
}
#pragma mark - DNImagePickerControllerDelegate
- (void)dnImagePickerController:(DNImagePickerController *)imagePicker
                     sendImages:(NSArray *)images
                    isFullImage:(BOOL)isFullImage {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.parentView animated:YES];
    hud.label.text = @"处理中...";
    [hud showAnimated:YES];
    [self recursiveHandle:images isFullImage:isFullImage];
}

- (void)dnImagePickerControllerDidCancel:(DNImagePickerController *)imagePicker {
    [imagePicker dismissViewControllerAnimated:YES completion:nil];
}

- (void)convertAvcompositionToAvasset:(AVComposition *)composition completion:(void (^)(AVAsset *asset))completion {
    // 导出视频
    AVAssetExportSession *exporter = [AVAssetExportSession exportSessionWithAsset:composition presetName:AVAssetExportPresetHighestQuality];
    // 生成一个文件路径
    NSInteger randNumber = arc4random();
    NSString *exportPath = [NSTemporaryDirectory() stringByAppendingString:[NSString stringWithFormat:@"%ldvideo.mov", randNumber]];
    NSURL *exportURL = [NSURL fileURLWithPath:exportPath];
    // 导出
    if (exporter) {
        exporter.outputURL = exportURL;  // 设置路径
        exporter.outputFileType = AVFileTypeQuickTimeMovie;
        exporter.shouldOptimizeForNetworkUse = YES;
        [exporter exportAsynchronouslyWithCompletionHandler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                if (AVAssetExportSessionStatusCompleted == exporter.status) {   // 导出完成
                    NSURL *URL = exporter.outputURL;
                    AVAsset *avAsset = [AVAsset assetWithURL:URL];
                     if (completion) {
                        completion(avAsset);
                    }
                } else {
                    if (completion) {
                        completion(nil);
                    }
                }
            });
        }];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(nil);
            }
        });
    }
}
- (void)handleVideo:(NSURL *)url photos:(NSMutableArray<DNAsset *> *)photos isFullImage:(BOOL)isFullImage {
    AVURLAsset *asset1 = [[AVURLAsset alloc] initWithURL:url options:nil];
    AVAssetImageGenerator *generate1 = [[AVAssetImageGenerator alloc] initWithAsset:asset1];
    generate1.appliesPreferredTrackTransform = YES;
    NSError *err = NULL;
    CMTime time = CMTimeMake(1, 2);
    CGImageRef oneRef = [generate1 copyCGImageAtTime:time actualTime:NULL error:&err];
    UIImage *thumbnail = [[UIImage alloc] initWithCGImage:oneRef];
    thumbnail = [WFCCUtilities generateThumbnail:thumbnail withWidth:120 withHeight:120];

    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:url options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];

    NSString *CompressionVideoPaht = [WFCCUtilities getDocumentPathWithComponent:@"/VIDEO"];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:@"AVAssetExportPresetMediumQuality"];

    NSDateFormatter *formater = [[NSDateFormatter alloc] init];// 用时间, 给文件重新命名, 防止视频存储覆盖,

    [formater setDateFormat:@"yyyy-MM-dd-HH:mm:ss"];

    NSFileManager *manager = [NSFileManager defaultManager];

    BOOL isExists = [manager fileExistsAtPath:CompressionVideoPaht];
    if (!isExists) {
         [manager createDirectoryAtPath:CompressionVideoPaht withIntermediateDirectories:YES attributes:nil error:nil];
     }
//
    NSString *resultPath = [CompressionVideoPaht stringByAppendingPathComponent:[NSString stringWithFormat:@"outputJFVideo-%@.mov", [formater stringFromDate:[NSDate date]]]];

    NSLog(@"resultPath = %@",resultPath);

    exportSession.outputURL = [NSURL fileURLWithPath:resultPath];

    exportSession.outputFileType = AVFileTypeMPEG4;

    exportSession.shouldOptimizeForNetworkUse = YES;

    __weak typeof(self)ws = self;
    [exportSession exportAsynchronouslyWithCompletionHandler:^(void)
     {
         if (exportSession.status == AVAssetExportSessionStatusCompleted) {
             NSData *data = [NSData dataWithContentsOfFile:resultPath];
             float memorySize = (float)data.length / 1024 / 1024;
             NSLog(@"视频压缩后大小 %f", memorySize);
             dispatch_async(dispatch_get_main_queue(), ^{
                 [ws.delegate videoDidCapture:resultPath thumbnail:thumbnail duration:10];
             });
             [ws recursiveHandle:photos isFullImage:isFullImage];
         } else {
             dispatch_async(dispatch_get_main_queue(), ^{
             });
             NSLog(@"压缩失败");
         }

     }];
}
- (void)recursiveHandle:(NSMutableArray<DNAsset *> *)photos isFullImage:(BOOL)isFullImage {
    if (photos.count == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.parentView animated:YES];
        });
    }else{
        DNAsset *item = photos[0];
        [photos removeObjectAtIndex:0];
        __weak typeof(self) weakself = self;
        if (item.asset.mediaType == PHAssetMediaTypeVideo) {
            PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
            options.version = PHImageRequestOptionsVersionCurrent;
            options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
            PHAsset *phAsset = item.asset;
            
            PHImageManager *manager = [PHImageManager defaultManager];
            [manager requestAVAssetForVideo:phAsset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {

                if ([asset isKindOfClass:[AVComposition class]]) {
                    [weakself convertAvcompositionToAvasset:(AVComposition *)asset completion:^(AVAsset *asset) {
                        AVURLAsset *urlAsset = (AVURLAsset *)asset;
                        [weakself handleVideo:urlAsset.URL photos:photos isFullImage:isFullImage];
                    }];
                } else {
                    AVURLAsset *urlAsset = (AVURLAsset *)asset;
                    [weakself handleVideo:urlAsset.URL photos:photos isFullImage:isFullImage];
                }
                
                
            }];
        } else if(item.asset.mediaType == PHAssetMediaTypeImage) {
            PHImageRequestOptions *imageRequestOption = [[PHImageRequestOptions alloc] init];
            imageRequestOption.networkAccessAllowed = YES;
            PHCachingImageManager *cachingImageManager = [[PHCachingImageManager alloc] init];
            cachingImageManager.allowsCachingHighQualityImages = NO;
            [cachingImageManager
             requestImageDataForAsset:item.asset
             
             options:imageRequestOption
             
             resultHandler:^(NSData *_Nullable imageData, NSString *_Nullable dataUTI,
                                                                   UIImageOrientation orientation, NSDictionary *_Nullable info) {
                   BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
                   if (downloadFinined) {
                       if ([weakself.delegate respondsToSelector:@selector(imageDidCapture:)]) {
                           [weakself.delegate imageDidCapture:[UIImage imageWithData:imageData]];
                       }
                       
                       [weakself recursiveHandle:photos isFullImage:isFullImage];
                   }

                   if ([info objectForKey:PHImageErrorKey]) {
                       [weakself.parentView makeToast:@"下载图片失败"];
                       [weakself recursiveHandle:photos isFullImage:isFullImage];
                   }
                                                       
            }];
        }
        
    }
        
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
