# QuizChamp: Flutter Quiz Application

This repository contains the production-ready, clean architecture boilerplate for the **QuizChamp** mobile application, built using Flutter, BLoC for state management, and GetIt for dependency injection.

The current codebase provides the complete architectural foundation, data models, repository interfaces, use cases, and core BLoC logic for Authentication and Quiz functionality.

---

## 🚀 Project Status: Architectural Foundation Complete

The following core components have been implemented and are ready for UI and native service integration:

| Layer | Components Implemented | Status |
| :--- | :--- | :--- |
| **Architecture** | Layered Architecture (Data, Domain, Presentation), GetIt DI | **Complete** |
| **Core** | `Failure` handling, `UseCase` base class | **Complete** |
| **Domain** | `UserEntity`, `QuestionEntity`, Repository Interfaces | **Complete** |
| **Data** | `UserModel`, `QuestionModel`, Repository Implementations | **Complete** |
| **Data Sources** | `AuthRemoteDataSource` (Google Sign-In), `QuizRemoteDataSource` (OpenTDB) | **Complete** |
| **BLoC** | `AuthBloc` (Sign In/Out), `QuizBloc` (Fetch/Answer Questions) | **Complete** |
| **UI** | Placeholder Pages (`SplashPage`, `SignInPage`, `HomePage`, `QuizPage`) | **Boilerplate Ready** |

---

## 🛠️ Next Steps: Native Service Integration & UI Development

To make this a fully functional mobile application, you must complete the following steps, which require configuration outside of the codebase:

1.  **Firebase Project Setup:** Configure the Firebase project and integrate the platform-specific files (`google-services.json` for Android, `GoogleService-Info.plist` for iOS).
2.  **Google Sign-In Configuration:** Complete the native setup for Google Sign-In on both platforms.
3.  **AdMob & IAP Setup:** Configure the native platforms for Google Mobile Ads and In-App Purchases.
4.  **UI Implementation:** Replace the placeholder pages with the polished, Lottie-animated UI.

### 1. Detailed Firebase Setup Guide

The application is designed to use Firebase for Authentication, Cloud Firestore (Leaderboards/User Data), Cloud Messaging (Push Notifications), and Analytics.

**Action Required:** Follow the steps below in the Firebase Console:

| Step | Firebase Console Action | Configuration Details |
| :--- | :--- | :--- |
| **1. Project Creation** | Create a new Firebase Project. | **Project Name:** QuizChamp |
| **2. App Registration** | Register both **Android** and **iOS** apps. | **Android Package Name:** `com.quizchamp.app` (or your chosen ID) |
| | | **iOS Bundle ID:** `com.quizchamp.app` (or your chosen ID) |
| **3. Config Files** | Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS). | **Placement:** `android/app/` and `ios/Runner/` respectively. |
| **4. Authentication** | Enable **Google** as a Sign-in provider. | **Web SDK Configuration:** Required for Google Sign-In to work on Flutter. |
| **5. Firestore** | Create a **Cloud Firestore** database. | **Start in Production Mode** (or Test Mode if preferred). |
| **6. Cloud Messaging** | Enable **Cloud Messaging** (FCM) for push notifications. | **iOS:** Requires APNs Authentication Key setup. |
| **7. Analytics** | Ensure **Google Analytics** is enabled. | Used for tracking events like `quiz_started`, `purchase_made`, etc. |

### 2. Google Sign-In Native Configuration

The `google_sign_in` package requires specific native setup beyond just the Firebase config files.

*   **Android:** Ensure your `android/app/build.gradle` includes the necessary dependencies and that your SHA-1 key is registered in the Firebase console for the Android app.
*   **iOS:** Add the `REVERSED_CLIENT_ID` to your `ios/Runner/Info.plist` file and configure the URL Scheme as per the `google_sign_in` documentation.

### 3. AdMob and In-App Purchase (IAP) Setup

These features require linking your app to external developer accounts.

| Feature | Required Accounts/Setup | Next Steps in Code |
| :--- | :--- | :--- |
| **AdMob** | Google AdMob Account, App registered in AdMob. | Implement `google_mobile_ads` logic in the UI to show banners, interstitials, and rewarded ads. |
| **In-App Purchase** | Apple Developer Account, Google Play Console Account. | Define products (Hearts, Subscription) in both stores. Implement `in_app_purchase` logic to handle purchase flow and receipt validation. |

### 4. Running the Project

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/SHuzaifaAli/QuizChamp.git
    cd QuizChamp
    ```
2.  **Get dependencies:**
    ```bash
    flutter pub get
    ```
3.  **Run the app:**
    ```bash
    flutter run
    ```

---

## 📚 Technical Architecture Overview

The project adheres to the principles of **Clean Architecture** and **BLoC** (Business Logic Component) pattern:

*   **Presentation Layer:** Contains the UI (`pages`, `widgets`) and the state management (`blocs`). It depends only on the Domain layer.
*   **Domain Layer:** The core business logic. Contains `entities`, `usecases`, and Repository interfaces. It is independent of all other layers.
*   **Data Layer:** Contains the `models`, `repositories` (implementations of Domain interfaces), and `datasources` (remote/local). It depends on the Domain layer.

This structure ensures testability, maintainability, and separation of concerns.

---

*Generated by Manus AI*
