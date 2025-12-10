📝 TodoMeeps — Smart Todo App (Flutter + Firebase)

A clean, modern, and scalable Todo management mobile application built using Flutter, Riverpod, Firebase (Auth, Firestore, Storage) and Hive for offline persistence.
Designed with production-level architecture and best practices.

🚀 Features

✔️ User Authentication (Firebase Email/Password)

✔️ Personalized Todo Lists (Synced to Firestore)

✔️ Add, Update, and Delete Todos

✔️ Profile Management (Name + Profile Picture Upload)

✔️ Upload Profile Image to Firebase Storage

✔️ Local Caching with Hive

✔️ State Management using Riverpod

✔️ Responsive UI

✔️ Clean MVVM Architecture

✔️ Error-handled API Integration

🧱 Project Architecture
lib/
├── models/              # Data models (Todo, User)
├── viewmodels/          # Notifiers & business logic
├── providers/           # Riverpod providers
├── services/            # Firebase, API, Storage logic
├── views/               # UI screens
│   ├── auth/            # Login & Signup
│   ├── home/            # Todo list page
│   ├── profile/         # Profile page
│   └── ...
├── core/
│   ├── network/         # API services
│   └── utils/           # Helpers & constants
└── main.dart            # App entry point


This follows a clean MVVM pattern, ensuring maintainability and scalability.

🛠️ Tech Stack
Layer	Technology
Framework	Flutter (Dart)
State Management	Riverpod
Authentication	Firebase Auth
Database	Cloud Firestore
File Storage	Firebase Storage
Local Storage	Hive
UI Framework	Material Design 3
📸 Screenshots

Add images later if you want:

assets/screens/home.png
assets/screens/profile.png
assets/screens/login.png

🔧 Installation & Setup
1️⃣ Clone the Repository
git clone https://github.com/<your-username>/<repo-name>.git
cd <repo-name>

2️⃣ Install Dependencies
flutter pub get

3️⃣ Setup Firebase

Create a Firebase project, then enable:

Authentication → Email/Password

Firestore Database

Firebase Storage

Add Firebase to your Flutter project:

flutterfire configure


Place these files correctly:

android/app/google-services.json
ios/Runner/GoogleService-Info.plist

4️⃣ Initialize Hive
await Hive.initFlutter();
await Hive.openBox('userBox');

5️⃣ Run the App
flutter run

📁 Firestore Structure
users/
  <userId>/
    name: string
    email: string
    profileImage: string (URL)
    token: string

todos/
  <userId>/
      <todoId>/
          title: string
          description: string
          createdAt: timestamp

🔐 Environment Notes

Keep these files private:

firebase_options.dart
GoogleService-Info.plist
google-services.json


Add them to .gitignore if needed.

🤝 Contributing

Fork this repo

Create your feature branch

Commit your changes

Push your branch

Open a Pull Request

Example:

git checkout -b feature/new-feature
git commit -m "Added new feature"
git push origin feature/new-feature

📄 License

This project is licensed under the MIT License — free to use and modify.

⭐ Support

If this project helped you, please ⭐ star the repo.
It motivates further development and enhancements ❤️
