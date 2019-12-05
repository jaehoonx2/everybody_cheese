# EVERYBODY CHEESE

<img src="https://github.com/jaehoonx2/everybody_cheese/blob/master/assets/logo_text.png?raw=true" width="400"/>

Final project of the Mobile App Development lecture for the second semester of 2019 at Handong Global Univ.

## Getting Started

### 1. Firebase section
1. A Firebase project is needed so that you should add one in [here](https://firebase.google.com).
2. Then, add the Android and iOS apps to the project you created.
3. Download google-services.json(for Android) and GoogleService-Info.plist(for iOS).
4. Locate them in appropriate locations.

[How to add Firebase](https://codelabs.developers.google.com/codelabs/flutter-firebase/#0)

### 2. Google Maps API section
1. This project uses the Google Maps API. Please get an API key [here](https://cloud.google.com/maps-platform/).
2. To specify your key on the project, follow the 'Getting Started' section in [here](https://pub.dev/packages/google_maps_flutter#getting-started). 
3. Add your key also in ```./lib/key.dart```.
```
// Google Maps API key
const kGoogleApiKey = "YOUR KEY HERE";
```

### 3. iOS integrartion for google_sign_in
Add the CFBundleURLTypes attributes below into the ```./ios/Runner/Info.plist```.
Please follow [this](https://pub.dev/packages/google_sign_in#ios-integration).
