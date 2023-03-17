#import "RNJitsiMeetViewManager.h"
#import "RNJitsiMeetView.h"
#import "RNJitsiMeetEventEmitter.h"
#import <JitsiMeetSDK/JitsiMeetUserInfo.h>

@implementation RNJitsiMeetViewManager{
    RNJitsiMeetView *jitsiMeetView;
    RNJitsiMeetEventEmitter *eventEmitter;
}

RCT_EXPORT_MODULE(RNJitsiMeetView)

+ (BOOL)requiresMainQueueSetup {
    return YES;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _isPip = NO;
        _eventSentFlags = [NSMutableDictionary dictionary];
    }
    return self;
}

- (UIView *)view
{
    jitsiMeetView = [[RNJitsiMeetView alloc] init];
    NSLog(@"UI initialized");
    jitsiMeetView.delegate = self;
    return jitsiMeetView;
}

- (void)setBridge:(RCTBridge *)bridge {
    [super setBridge:bridge];
    NSLog(@"Bridge initialized");
    eventEmitter = [bridge moduleForName:@"RNJitsiMeetEventEmitter"];
}

- (void)setMeetOptions:(NSDictionary *)meetOptions forBuilder:(JitsiMeetConferenceOptionsBuilder *)builder withServerConf:(NSDictionary *)serverConf andUserInfo:(JitsiMeetUserInfo *)_userInfo {
    builder.serverURL = [NSURL URLWithString:serverConf[@"urlString"] ?: @""];
    builder.room = serverConf[@"room"] ?: @"";
    builder.userInfo = _userInfo;
    builder.token = meetOptions[@"token"] ?: @"";
    builder.subject = meetOptions[@"subject"] ?: @"";
    builder.videoMuted = meetOptions[@"videoMuted"] ? [meetOptions[@"videoMuted"] boolValue] : false;
    builder.audioOnly = meetOptions[@"audioOnly"] ? [meetOptions[@"audioOnly"] boolValue] : false;
    builder.audioMuted = meetOptions[@"audioMuted"] ? [meetOptions[@"audioMuted"] boolValue] : false;
}

- (void)setMeetFeatureFlags:(NSDictionary *)meetFeatureFlags forBuilder:(JitsiMeetConferenceOptionsBuilder *)builder {
    NSDictionary *flagMapping = @{
        @"iosScreenSharingEnabled": @"ios.screensharing.enabled",
        @"addPeopleEnabled": @"add-people.enabled",
        @"calendarEnabled": @"calendar.enabled",
        @"callIntegrationEnabled": @"call-integration.enabled",
        @"chatEnabled": @"chat.enabled",
        @"closeCaptionsEnabled": @"close-captions.enabled",
        @"conferenceTimerEnabled": @"conference-timer.enabled",
        @"embedMeetingEnabled": @"embed-meeting.enabled",
        @"filmstripEnabled": @"filmstrip.enabled",
        @"hangupEnabled": @"hangup.enabled",
        @"helpEnabled": @"help.enabled",
        @"inviteEnabled": @"invite.enabled",
        @"iosRecordingEnabled": @"ios.recording.enabled",
        @"kickOutEnabled": @"kick-out.enabled",
        @"liveStreamingEnabled": @"live-streaming.enabled",
        @"lobbyModeEnabled": @"lobby-mode.enabled",
        @"meetingNameEnabled": @"meeting-name.enabled",
        @"meetingPasswordEnabled": @"meeting-password.enabled",
        @"notificationsEnabled": @"notifications.enabled",
        @"overflowMenuEnabled": @"overflow-menu.enabled",
        @"pipEnabled": @"pip.enabled",
        @"raiseHandEnabled": @"raise-hand.enabled",
        @"recordingEnabled": @"recording.enabled",
        @"reactionsEnabled": @"reactions.enabled",
        @"remoteVideoMenuEnabled": @"remote-video-menu.enabled",
        @"resolution": @"resolution",
        @"serverURLChangeEnabled": @"server-url-change.enabled",
        @"tileViewEnabled": @"tile-view.enabled",
        @"toolboxAlwaysVisible": @"toolbox.alwaysVisible",
        @"toolboxEnabled": @"toolbox.enabled",
        @"videoShareEnabled": @"video-share.enabled",
        @"welcomePageEnabled": @"welcomepage.enabled",
        @"prejoinPageEnabled": @"prejoinpage.enabled"
    };
    [meetFeatureFlags enumerateKeysAndObjectsUsingBlock:^(NSString *key, id value, BOOL *stop) {
        NSString *flag = flagMapping[key];
        if (flag) {
            if ([flag isEqualToString:@"resolution"]) {
                [builder setFeatureFlag:flag withValue:value];
            } else {
                [builder setFeatureFlag:flag withBoolean:[value boolValue]];
            }
        }
    }];
}

- (void)joinConferenceWithOptions:(NSDictionary *)serverConf meetOptions:(NSDictionary *)meetOptions  userInfo:(NSDictionary *)userInfo meetFeatureFlags:(NSDictionary *)meetFeatureFlags audioOnly:(BOOL)audioOnly {
    JitsiMeetUserInfo *_userInfo = [self createUserInfo:userInfo];
    JitsiMeetConferenceOptions *options = [JitsiMeetConferenceOptions fromBuilder:^(JitsiMeetConferenceOptionsBuilder *builder) {
        [self setMeetOptions:meetOptions forBuilder:builder withServerConf:serverConf andUserInfo:_userInfo];
        [self setMeetFeatureFlags:meetFeatureFlags forBuilder:builder];
        builder.audioOnly = audioOnly;
    }];
    [jitsiMeetView join:options];
}

- (void)sendEventOnce:(NSString *)eventName body:(NSDictionary *)body {
    if ([self.eventSentFlags[eventName] boolValue]) {
        self.eventSentFlags[eventName] = @(NO);
        return;
    }
    
    self.eventSentFlags[eventName] = @(YES);
    [eventEmitter sendEventWithName:eventName body:(!body ? @{@"isPip": @(_isPip=!_isPip)} : body)];
}

- (JitsiMeetUserInfo *)createUserInfo:(NSDictionary *)userInfo {
    JitsiMeetUserInfo * _userInfo = [[JitsiMeetUserInfo alloc] init];
    
    _userInfo.displayName = userInfo[@"displayName"] ?: @"";
    _userInfo.email = userInfo[@"email"] ?: @"";
    
    NSString *avatar = userInfo[@"avatar"];
    if (avatar) {
        NSURL *url = [NSURL URLWithString:[avatar stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
        _userInfo.avatar = url;
    }
    
    return _userInfo;
}

RCT_EXPORT_METHOD(call:(NSDictionary *)serverConf userInfo:(NSDictionary *)userInfo  meetOptions:(NSDictionary *)meetOptions meetFeatureFlags:(NSDictionary *)meetFeatureFlags) {
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self joinConferenceWithOptions:serverConf meetOptions:meetOptions userInfo:userInfo meetFeatureFlags:meetFeatureFlags audioOnly:NO];
    });
}

RCT_EXPORT_METHOD(audioCall:(NSDictionary *)serverConf userInfo:(NSDictionary *)userInfo){
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self joinConferenceWithOptions:serverConf meetOptions:nil userInfo:userInfo meetFeatureFlags:nil audioOnly:YES];
    });
}

RCT_EXPORT_METHOD(endCall)
{
    dispatch_sync(dispatch_get_main_queue(), ^{
        [jitsiMeetView leave];
    });
}

#pragma mark JitsiMeetViewDelegate
-(void)conferenceJoined:(NSDictionary *)data {
    [self sendEventOnce:@"onConferenceJoined" body:data];
}

-(void)conferenceTerminated:(NSDictionary *)data {
    [self sendEventOnce:@"onConferenceTerminated" body:data];
}

-(void)conferenceWillJoin:(NSDictionary *)data {
    [self sendEventOnce:@"onConferenceWillJoin" body:data];
}

-(void)enterPictureInPicture:(NSDictionary *)data {
   
    [self sendEventOnce:@"onEnterPictureInPicture" body:nil];
}

@end

