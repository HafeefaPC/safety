# Safe Haven - Emergency Safety App

A comprehensive Flutter mobile application designed to provide emergency safety features and quick access to emergency services.

## Features

### 🚨 Emergency Actions
- **Send Location**: Instantly share your current location with emergency contacts via SMS
- **I'm Safe**: Send a pre-defined "I'm Safe" message to emergency contacts
- **Check-in Timer**: Automatic emergency location sharing if not stopped within set time
- **Loud Siren**: Play a loud alarm sound for attracting attention
- **Shake-to-Alert**: Shake your phone to automatically send emergency location

### 📞 Direct Calling
- **Emergency Helplines**: Quick access to categorized emergency numbers
- **One-tap Calling**: Direct phone calls to any helpline number
- **Offline Access**: All helpline data stored locally

### 📱 Additional Features
- **Fake Call**: Simulate incoming calls for safety purposes
- **Medical Information**: Store and access essential medical details
- **Emergency Contacts**: Manage emergency contact list
- **Offline Functionality**: Works without internet connection

## Technical Architecture

### Project Structure
```
lib/
├── main.dart
├── screens/
│   ├── home_screen.dart
│   ├── fake_call_screen.dart
│   ├── medical_info_screen.dart
│   └── emergency_contacts_screen.dart
├── widgets/
│   ├── helpline_card.dart
│   ├── emergency_action_button.dart
│   └── custom_app_bar.dart
├── models/
│   ├── helpline_model.dart
│   └── medical_info_model.dart
├── services/
│   ├── call_service.dart
│   ├── location_service.dart
│   ├── telephony_service.dart
│   ├── audio_service.dart
│   └── preferences_service.dart
├── data/
│   └── static_helpline_data.dart
└── utils/
    └── constants.dart
```

### Dependencies
- `url_launcher`: Phone calls
- `geolocator`: Location services
- `telephony`: SMS functionality
- `audioplayers`: Audio playback
- `sensors_plus`: Shake detection
- `shared_preferences`: Local storage
- `flutter_local_notifications`: Fake call notifications
- `permission_handler`: Permission management

## Setup Instructions

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd safe_haven
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run
   ```

## Permissions Required

- **Location**: To share current location in emergency
- **SMS**: To send emergency messages
- **Phone**: To make emergency calls
- **Audio**: To play siren sound
- **Notifications**: For fake call feature

## Usage

### Setting Up Emergency Contacts
1. Open the app
2. Navigate to "Emergency Contacts"
3. Add phone numbers that should receive emergency messages
4. Test SMS functionality

### Using Emergency Features
1. **Quick Emergency**: Tap "Send Location" to immediately share your location
2. **Check-in Timer**: Start timer and stop it within the set time to prevent automatic emergency message
3. **Shake Alert**: Shake your phone to trigger emergency location sharing
4. **Siren**: Tap "Play Siren" to attract attention

### Medical Information
1. Navigate to "Medical Info"
2. Enter your blood type, allergies, medications, and other important details
3. This information is stored locally and can be accessed during emergencies

## Safety Features

- **Offline Operation**: All core features work without internet
- **Local Storage**: All data stored securely on device
- **Quick Access**: Emergency features accessible from main screen
- **Reliable**: Uses system-level services for calls and SMS

## Development Notes

- Each file is kept under 100 lines for maintainability
- Clean architecture with separation of concerns
- Reusable widgets for consistent UI
- Service-based architecture for business logic
- Comprehensive error handling

## License

This project is for educational and safety purposes. Please use responsibly.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## Support

For issues or questions, please create an issue in the repository.