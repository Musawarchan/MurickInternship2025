# E-Learning Platform

A modern, cross-platform e-learning application built with Flutter that provides a comprehensive learning experience for both students and instructors.

## 📱 Features

### 🔐 Authentication System
- **User Registration & Login**: Secure authentication with email and password
- **Role-Based Access**: Support for both Student and Instructor roles
- **Persistent Sessions**: Automatic login state management using SharedPreferences
- **Form Validation**: Comprehensive input validation for all forms

### 🎨 Modern UI/UX
- **Material Design 3**: Latest Material Design guidelines implementation
- **Dark/Light Theme**: System-aware theme switching with manual override
- **Responsive Design**: Optimized for various screen sizes
- **Smooth Animations**: Custom page transitions and loading states

### 📚 Course Management
- **Course Catalog**: Browse and discover available courses
- **Featured Courses**: Highlighted courses on the home screen
- **Course Cards**: Beautiful course presentation with thumbnails
- **Course Details**: Detailed course information and descriptions

### 👤 User Profile
- **Profile Management**: Edit personal information (name, email)
- **Role Display**: Clear indication of user role (Student/Instructor)
- **Avatar System**: Personalized user avatars with initials
- **Settings Integration**: Theme preferences and logout functionality

### 🏠 Home Dashboard
- **Hero Banner**: Engaging welcome section with call-to-action
- **Quick Actions**: Join Now and Become Instructor buttons
- **Featured Content**: Curated course recommendations
- **Navigation**: Intuitive bottom navigation with three main sections

## 🏗️ Architecture

### State Management
- **Provider Pattern**: Clean separation of concerns using Provider package
- **Multiple Providers**: Dedicated providers for authentication, courses, and profile management
- **Reactive UI**: Real-time UI updates based on state changes

### Project Structure
```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── user.dart            # User model with role enum
│   └── course.dart          # Course model
├── providers/               # State management
│   ├── auth_provider.dart   # Authentication state
│   ├── course_provider.dart # Course data management
│   └── profile_provider.dart # Profile management
├── screens/                 # UI screens
│   ├── auth/               # Authentication screens
│   │   ├── login_screen.dart
│   │   └── signup_screen.dart
│   └── home/               # Main app screens
│       ├── home_screen.dart
│       └── tabs/           # Tab-based navigation
│           ├── home_tab.dart
│           ├── courses_tab.dart
│           └── profile_tab.dart
├── services/               # Business logic
│   └── auth_service.dart   # Authentication service
├── theme/                  # App theming
│   └── app_theme.dart      # Light and dark themes
├── utils/                  # Utility functions
│   └── validation_utils.dart # Form validation
└── widgets/                # Reusable components
    ├── auth_button.dart    # Custom button component
    ├── custom_form_field.dart # Form field component
    └── role_dropdown.dart  # Role selection dropdown
```

## 🛠️ Technology Stack

### Core Dependencies
- **Flutter SDK**: ^3.6.0
- **Provider**: ^6.1.2 - State management
- **HTTP**: ^1.2.2 - Network requests
- **SharedPreferences**: ^2.3.2 - Local data persistence

### Development Tools
- **Flutter Lints**: ^5.0.0 - Code quality and style enforcement
- **Material Icons**: ^1.0.8 - Icon library

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.6.0 or higher)
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- iOS Simulator / Android Emulator (for testing)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd e_learning_platform
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run
   ```

### Platform Support
- ✅ Android
- ✅ iOS


## 📱 Screenshots

### Authentication Flow
- **Login Screen**: Clean login interface with role selection
- **Signup Screen**: Comprehensive registration form with validation
- **Error Handling**: User-friendly error messages and loading states

### Main Application
- **Home Tab**: Featured courses and quick actions
- **Courses Tab**: Complete course catalog with search functionality
- **Profile Tab**: User profile management and settings

## 🔧 Configuration

### Theme Customization
The app supports both light and dark themes with system preference detection. Themes can be customized in `lib/theme/app_theme.dart`.

### Mock Data
Currently, the app uses mock data for courses and authentication. This can be easily replaced with real API calls in the respective provider classes.

## 🧪 Testing

Run the test suite:
```bash
flutter test
```

## 📦 Building for Production

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```



## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👨‍💻 Author

**Musawar Hussain**
- GitHub: [@musawarhussain](https://github.com/musawarhussain)
