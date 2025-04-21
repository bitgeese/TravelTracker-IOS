# iOS Development Learning Plan: Travel Time Tracker App

This document outlines our learning journey to build the Travel Time Tracker iOS application using SwiftUI. We'll follow iOS development best practices and the specific technical requirements of this project.

## Core Principles & Technologies

Throughout these sessions, we will adhere to the following:

*   **Language:** Swift (latest stable version)
*   **UI Framework:** SwiftUI
*   **Architecture:** MVVM (Model-View-ViewModel)
    *   **Views:** SwiftUI `View` structs.
    *   **ViewModels:** `ObservableObject` classes holding state and logic.
    *   **Models:** Realm `Object` subclasses for persistence, `Codable` structs for API interaction.
*   **Concurrency:** `async/await` for asynchronous operations.
*   **Networking:** Alamofire, managed within a central `APIService`.
*   **Persistence:** Realm Swift SDK, integrated with SwiftUI using `@ObservedResults`, `@ObservedRealmObject`, etc.
*   **Authentication:** Sign in with Apple, Keychain for secure token storage.
*   **Dependency Management:** Swift Package Manager (SPM).
*   **Best Practices:** Follow Apple's Human Interface Guidelines (HIG) and general SwiftUI best practices (small views, appropriate state management wrappers like `@State`, `@StateObject`, `@ObservedObject`, `@EnvironmentObject`).

## Learning Sessions

Here's a breakdown of our planned sessions. We'll tackle one major feature or concept per session, building the app incrementally.

**Session 1: Project Setup & Core Structure** ✅
*   ✅ Create a new Xcode project using the App template (SwiftUI interface, Swift language).
*   ✅ Add dependencies using Swift Package Manager: Alamofire, RealmSwift.
*   ✅ Set up basic project folder structure (e.g., `Views`, `ViewModels`, `Models`, `Services`, `Utils`).
*   ✅ Briefly discuss the MVVM pattern in the context of our project.

**Session 2: Authentication UI** ✅
*   ✅ Goal: Build the user interface for login and registration.
*   ✅ Tasks:
    *   ✅ Create `LoginView.swift` with text fields, buttons, and Sign in with Apple button placeholder.
    *   ✅ Create `RegistrationView.swift` with necessary fields.
    *   ✅ Use `@State` for managing form input.
    *   ✅ Implement basic navigation between `LoginView` and `RegistrationView`.

**Session 3: Authentication Logic & Keychain**
*   Goal: Set up the foundations for handling authentication logic and secure storage.
*   Tasks:
    *   Create `KeychainService.swift` utility for saving/loading tokens.
    *   Create `AuthViewModel.swift` (ObservableObject) to manage authentication state and logic.
    *   Begin implementing "Sign in with Apple" functionality (requesting credentials).
    *   Create `APIService.swift` foundation (class structure, Alamofire session setup).

**Session 4: Networking - API Service & Auth Calls**
*   Goal: Connect authentication UI to the backend API.
*   Tasks:
    *   Define `Codable` structs for authentication request/response models.
    *   Implement login, registration, and token refresh functions in `APIService` using Alamofire and `async/await`.
    *   Connect `AuthViewModel` methods to call `APIService` functions.
    *   Handle API responses (success/error) and update the ViewModel state.
    *   Integrate `KeychainService` to store/retrieve tokens upon successful authentication.

**Session 5: Realm Setup & Data Models**
*   Goal: Define local data models and configure the Realm database.
*   Tasks:
    *   Define Realm `Object` subclasses: `User`, `Country`, `TravelSegment`.
    *   Configure Realm on app launch (e.g., in the App struct).
    *   Implement basic Realm write transactions (e.g., saving user info after login).
    *   Introduce Realm Studio for inspecting the database (optional).

**Session 6: Main UI - Travel List & Dashboard Shell**
*   Goal: Create the main application interface and display initial data.
*   Tasks:
    *   Set up a `TabView` or similar navigation structure for the main app sections.
    *   Create `TravelListView.swift`.
    *   Use `@ObservedResults` to fetch and display `TravelSegment` objects from Realm in a `List`.
    *   Create `DashboardView.swift` shell (UI placeholders for summary info).
    *   Create `SettingsView.swift` shell with a Logout button.

**Session 7: Manual Data Entry - UI & ViewModel**
*   Goal: Build the interface for manually adding travel segments.
*   Tasks:
    *   Create `ManualEntryView.swift` with `Form`, `DatePicker`, `TextFields`/`Pickers` for data input.
    *   Create `ManualEntryViewModel.swift` (ObservableObject) to manage the state of the form.
    *   Bind UI elements to ViewModel properties.

**Session 8: Manual Data Entry - Saving to Realm & API**
*   Goal: Implement the logic to save new/edited travel segments locally and sync to the backend.
*   Tasks:
    *   Implement saving logic in `ManualEntryViewModel` to create/update `TravelSegment` objects in Realm.
    *   Add relevant API endpoints (create/update travel segment) to `APIService`.
    *   Call the API service after successfully saving to Realm (or as part of sync logic).

**Session 9: Synchronization Logic**
*   Goal: Implement the core data synchronization mechanism between Realm and the backend.
*   Tasks:
    *   Develop the "Fetch-then-Update" strategy.
    *   Implement logic to find local changes (new/modified Realm objects).
    *   Implement functions in `APIService` to upload local changes.
    *   Implement functions in `APIService` to fetch latest data from the backend.
    *   Write logic to merge fetched data into Realm, respecting `updated_at` timestamps ("Last Write Wins").
    *   Trigger sync on app launch/foreground and network status changes.

**Session 10: CSV Import - File Picker & Upload**
*   Goal: Allow users to select and start uploading a CSV file.
*   Tasks:
    *   Add a button/menu item to trigger the file importer.
    *   Use the `.fileImporter` modifier in a SwiftUI View to present the system file picker.
    *   Handle the selected file URL.
    *   Add the CSV import endpoint to `APIService`.
    *   Implement the file upload logic using Alamofire, sending the file data and receiving the `task_id`.

**Session 11: CSV Import - Status Polling**
*   Goal: Monitor the backend processing status of the uploaded CSV.
*   Tasks:
    *   Add the status polling endpoint to `APIService`.
    *   Implement a polling mechanism (e.g., using `Timer` or `async/await` with delays) in a relevant ViewModel or Service to check the task status using the `task_id`.
    *   Update the UI to reflect the import progress (e.g., "Processing", "Success", "Failure").
    *   Trigger a data refresh/sync upon successful import.

**Session 12: Map View Integration**
*   Goal: Display visited locations on a map.
*   Tasks:
    *   Create `TravelMapView.swift`.
    *   Integrate `MapKit` using `UIViewRepresentable` or the native SwiftUI `Map` view (if targeting iOS 17+ is acceptable, otherwise stick to representable for broader compatibility as per spec).
    *   Fetch `TravelSegment` data (or aggregated country data).
    *   Display annotations or overlays on the map representing visited countries/locations.
    *   (Optional) Customize annotations to show time spent.

**Session 13: Calculations Display**
*   Goal: Fetch and display calculated data (Schengen status).
*   Tasks:
    *   Add the Schengen calculation endpoint to `APIService`.
    *   Create a method in a ViewModel (e.g., `DashboardViewModel`) to fetch the status.
    *   Display the fetched status information in `DashboardView`.
    *   Decide on refresh strategy (manual button, periodic fetch, etc.).

**Session 14: Push Notifications Setup**
*   Goal: Enable the app to receive push notifications from the backend.
*   Tasks:
    *   Configure Push Notifications capability in Xcode project settings.
    *   Use `UserNotifications` framework to request user authorization.
    *   Implement AppDelegate methods (or SwiftUI equivalents) to register for remote notifications and receive the device token.
    *   Add an endpoint to `APIService` to send the device token to the backend.
    *   Implement basic handling for receiving a notification while the app is running or in the background.

**Session 15: Refinements, Testing & Wrap-up**
*   Goal: Polish the app, add tests, and review the project.
*   Tasks:
    *   Review UI/UX for consistency and adherence to HIG.
    *   Add unit tests for ViewModels and Services.
    *   (Optional) Add UI tests for critical flows.
    *   Address any remaining bugs or TODOs.
    *   Final code cleanup and review.

---

We can adjust this plan as we go. Ready to start with **Session 3: Authentication Logic & Keychain**? 