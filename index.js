import {
  NativeModules,
  requireNativeComponent,
  NativeEventEmitter,
} from "react-native";

const {
  RNJitsiMeetView: JitsiMeetModule,
  RNJitsiMeetEventEmitter: JitsiMeetEventEmitter,
} = NativeModules;

const JitsiMeetView = requireNativeComponent("RNJitsiMeetView");
const jitsiEventEmitter = new NativeEventEmitter(JitsiMeetEventEmitter);

const jitsiCall = (
  url,
  userInfo = {},
  meetOptions = {},
  meetFeatureFlags = {}
) => {
  JitsiMeetModule.call(url, userInfo, meetOptions, meetFeatureFlags);
};

const jitsiAudioCall = (url, userInfo = {}) => {
  JitsiMeetModule.audioCall(url, userInfo);
};

const jitsiEndCall = () => {
  JitsiMeetModule.endCall();
};

export {
  JitsiMeetView,
  jitsiEventEmitter,
  jitsiCall,
  jitsiAudioCall,
  jitsiEndCall,
};
