---

# **Flutter CBT App** 🎓📱  

A **Computer-Based Testing (CBT) application** built with **Flutter** and **Supabase** as the backend. This app allows **teachers** to create and manage tests, while **students** can take tests and receive scores instantly. The project follows the **MVVM architecture** with **GetX** for state management.

---

## **🚀 Features**  
✅ **User Authentication** – Secure login & registration using Supabase Auth  
✅ **Role-based Access** – Different dashboards for teachers & students  
✅ **Test Management** – Teachers can create tests with multiple-choice questions  
✅ **Scheduling System** – Set test start and end times  
✅ **Student Test Attempts** – Students can start, complete, and submit answers  
✅ **Auto Grading** – Tests are automatically graded based on correct answers  

---

## **🛠️ Tech Stack**  
- **Flutter** – Frontend framework  
- **Supabase (PostgreSQL)** – Backend database & authentication  
- **GetX** – State management  
- **Dart** – Programming language  
- **PostgreSQL** – Database used via Supabase  

---

## **📌 Prerequisites**  
Before setting up the project, ensure you have:  
1. **Flutter SDK** installed – [Download Here](https://flutter.dev/docs/get-started/install)  
    - **Tested Version**: Flutter 3.29.0-1.0.pre.24 (Channel: master) 
2. **Supabase Account** – [Sign Up Here](https://supabase.com/)  
3. **Git** installed – [Download Here](https://git-scm.com/)  
4. **Code Editor (VS Code/Android Studio)**  

---

## **📥 Installation & Setup**  

### **1️⃣ Clone the Repository**  
```sh
git clone https://github.com/deswinar/Flutter-Computer-Based-Test.git
cd Flutter-Computer-Based-Test
```

### **2️⃣ Install Dependencies**  
```sh
flutter pub get
```

### **3️⃣ Set Up Supabase**  
1. **Create a new project on Supabase**  
2. **Go to the SQL Editor** in Supabase and run the following:  
   ```sh
   \i init_tables.sql
   ```
   _(This will create all necessary tables in your Supabase database)_  

3. **Get your Supabase URL & Anon Key**:  
   - Go to **Supabase Dashboard** → **Project Settings** → **API**  
   - Copy **SUPABASE_URL** & **SUPABASE_ANON_KEY**  

4. **Create a `.env` file** in the project root:  
   ```sh
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=your-anon-key
   ```

### **4️⃣ Run the App**  
For Android:  
```sh
flutter run
```
For iOS (requires macOS):  
```sh
flutter run --no-sound-null-safety
```

---

## **🎯 Project Structure**  
```
/Flutter-Computer-Based-Test
  ├── app/
  │   ├── data/             # Repositories & API handlers
  │   ├── modules/          # MVVM structured feature modules
  │   │   ├── auth/         # Authentication module
  │   │   ├── teacher/      # Teacher module
  │   │   ├── student/      # Student module
  │   ├── middleware/       # Middleware for route guards
  │   ├── routes/           # App routes using GetX
  ├── assets/               # Images & icons
  │   ├── .env.example      # Example environment variables
  ├── init_tables.sql       # SQL schema
  ├── pubspec.yaml          # Flutter dependencies
  ├── README.md             # Project documentation
```

## **👍 Best Practices Followed**  
✅ **MVVM Structure** for better code maintainability   
✅ **GetX** for routing, state management, and dependency injection     
✅ **Supabase Auth & Database Integration**     
✅ **Environment Variables (.env)** for security

---

## **🔖 API Endpoints Used**  
✅ **Authentication**: Supabase Auth (Login, Register, Logout)  
✅ **Database Operations**: CRUD for Tests & Users

---

## **📌 Troubleshooting**  
💡 **Issue: "Supabase keys are missing"**  
👉 Ensure you have **correct** `SUPABASE_URL` and `SUPABASE_ANON_KEY` in the `.env` file.  

💡 **Issue: "App not running on iOS"**  
👉 Run `cd ios && pod install`, then retry `flutter run`.  

---

## **📜 License**  
This project is for submitting **Final Project** of the **Sanbercode Flutter Bootcamp**.  

---

## **💡 Future Development**  
🔹 Add **Classroom Management** (Students enroll in teacher’s class)  
🔹 Implement **Real-time Leaderboard** for student rankings  
🔹 Improve **UI/UX for a better experience**  

---

🚀 **Happy Coding!** 💙