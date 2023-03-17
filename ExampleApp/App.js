import React, {useEffect, useState} from 'react';
import {
  JitsiMeetView,
  jitsiEventEmitter,
  jitsiCall,
} from 'react-native-jitsi-meet';

const App = () => {
  const [isLoading, setIsLoading] = useState(false);

  useEffect(() => {
    setTimeout(() => {
      const serverConf = {
        serverUrl: 'https://meet.jit.si',
        room: 'https://meet.jit.si/deneme',
      };
      const userInfo = {
        displayName: 'User',
        email: 'user@example.com',
        avatar: 'https:/gravatar.com/avatar/abc123',
      };
      const meetOptions = {
        audioMuted: true,
        audioOnly: true,
        videoMuted: true,
        // subject: 'your subject',
        // token: 'your token',
      };
      const meetFeatureFlags = {
        iosScreenSharingEnabled: false,
        addPeopleEnabled: true,
        calendarEnabled: false,
        callIntegrationEnabled: true,
        chatEnabled: true,
        closeCaptionsEnabled: false,
        inviteEnabled: true,
        iosRecordingEnabled: false,
        liveStreamingEnabled: true,
        meetingNameEnabled: true,
        toolboxEnabled: true,
        toolboxAlwaysVisible: false,
        raiseHandEnabled: true,
        reactionsEnabled: false,
        kickOutEnabled: true,
        conferenceTimerEnabled: false,
        videoShareEnabled: true,
        meetingPasswordEnabled: true,
        pipEnabled: false,
        tileViewEnabled: false,
        welcomePageEnabled: false,
        prejoinPageEnabled: false,
        overflowMenuEnabled: true,
        remoteVideoMenuEnabled: false,
        recordingEnabled: true,
        lobbyModeEnabled: true,
        resolution: '1080',
      };
      jitsiCall(serverConf, userInfo, meetOptions, meetFeatureFlags);
      setIsLoading(true);
    }, 1000);
  }, []);

  useEffect(() => {
    const subscriptions = [];
    subscriptions.push(
      jitsiEventEmitter.addListener('onConferenceJoined', (data) => {
        console.log('onConferenceJoined:', data);
      }),
    );
    subscriptions.push(
      jitsiEventEmitter.addListener('onConferenceTerminated', (data) => {
        console.log('onConferenceTerminated:', data);
      }),
    );
    subscriptions.push(
      jitsiEventEmitter.addListener('onConferenceWillJoin', (data) => {
        console.log('onConferenceWillJoin:', data);
      }),
    );
    subscriptions.push(
      jitsiEventEmitter.addListener('onEnterPictureInPicture', (data) => {
        console.log('onEnterPictureInPicture:', data);
      }),
    );

    return () => {
      subscriptions.forEach((sub) => sub.remove());
    };
  }, []);

  return (
    isLoading && (
      <JitsiMeetView
        style={{
          flex: 1,
          height: '100%',
          width: '100%',
          backgroundColor: 'transparent',
        }}
      />
    )
  );
};

export default App;
