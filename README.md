# Android Starter

A clean, modular Android project template to kickstart your next Android application. This starter template comes with a multi-module architecture and an easy setup script to customize it for your project.

## 🏗️ Architecture

This project follows a clean, modular architecture with the following modules:

- **`app`** - Main application module containing UI and application-specific code
- **`core`** - Core utilities, extensions, and shared functionality
- **`domain`** - Business logic and use cases
- **`data`** - Data sources, repositories, and data management

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/achmadss/android-starter.git
cd android-starter
```

### 2. Run the Setup Script

Make the setup script executable and run it:

```bash
chmod +x setup.sh
./setup.sh
```

The setup script will prompt you for:

- **Project Name**: The display name of your project (e.g., "My Awesome App")
- **Package Name**: The main package name for your app module (e.g., "com.company.myapp")
- **Minimum SDK**: The minimum Android SDK version (default: 26)

#### Example Setup

```bash
Project Name: (Android Starter) My Awesome App
Package Name (for app module): (com.example.androidstarter) com.company.myapp
Minimum SDK Version: (26) 24
```

This will configure your project with:
- App module package: `com.company.myapp`
- Core module package: `com.company.core`
- Domain module package: `com.company.domain`
- Data module package: `com.company.data`

### 3. Open in Android Studio

Open the project in Android Studio, sync gradle and you're good to go.

## 📁 Project Structure

After setup, your project structure will look like this:

```
android-starter/
├── app/                          # Main application module
│   ├── src/main/java/your/package/name/
│   └── build.gradle
├── core/                         # Core utilities module
│   ├── src/main/java/your/package/core/
│   └── build.gradle
├── domain/                       # Business logic module
│   ├── src/main/java/your/package/domain/
│   └── build.gradle
├── data/                         # Data layer module
│   ├── src/main/java/your/package/data/
│   └── build.gradle
├── build.gradle
├── settings.gradle
└── setup.sh
```

## 🎯 Features

- **Multi-module architecture** for better separation of concerns
- **Automated setup script** for easy project customization
- **Clean package structure** with proper module namespacing
- **Cross-platform compatibility** (macOS and Linux)
- **Input validation** for package names and SDK versions

## 🤝 Contributing

Feel free to submit issues and pull requests to improve this starter template!

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.