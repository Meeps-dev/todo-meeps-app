📝 TodoMeeps — Smart Todo App (Flutter + Firebase)

A clean, modern, and scalable task-management mobile app built with Flutter, Riverpod, Firebase (Auth, Firestore, Storage), and Hive for offline persistence.
Designed with production-level architecture, clean MVVM patterns, and rock-solid state management.

🚀 Features

✔️ Firebase Authentication (Email/Password)

✔️ Personal Todo Lists (Synced in real-time via Firestore)

✔️ Add, Update, Delete Todos

✔️ Profile Management (Name + Profile Picture Upload)

✔️ Upload profile images to Firebase Storage

✔️ Offline caching with Hive

✔️ Riverpod for state management

✔️ Clean MVVM Architecture

✔️ Responsive UI

✔️ Error-handled API / Firebase operations

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

🛠️ Tech Stack
Layer	Technology
Framework	Flutter (Dart)
State Management	Riverpod
Authentication	Firebase Auth
Database	Cloud Firestore
File Storage	Firebase Storage
Local Storage	Hive
UI	Material Design 3


🔧 Installation & Setup


1️⃣ Clone the repository
git clone https://github.com/<your-username>/<repo-name>.git
cd <repo-name>

2️⃣ Install dependencies
flutter pub get

3️⃣ Configure Firebase

Enable:

Authentication → Email/Password

Firestore Database

Firebase Storage

Then run:

flutterfire configure


Place these files:

android/app/google-services.json
ios/Runner/GoogleService-Info.plist

4️⃣ Initialize Hive
await Hive.initFlutter();
await Hive.openBox('userBox');

5️⃣ Run the app
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

Sensitive files to keep private:

firebase_options.dart

google-services.json

GoogleService-Info.plist

Add them to .gitignore if necessary.

🤝 Contributing
git checkout -b feature/new-feature
git commit -m "Add new feature"
git push origin feature/new-feature


Open a Pull Request after pushing.

📄 License

Licensed under the MIT License — free to use, fork, and modify.

⭐ Support

If this project helped you, consider starring ⭐ the repo!
