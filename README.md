#Vehicle Breakdown Assistance App

Overview:

    The Vehicle Breakdown Assistance App is designed to provide users with quick and reliable support in case of a vehicle breakdown. The app allows users to save important contacts, such as tow services, mechanics, and emergency contacts, directly within the application. Users can also manage and update these contacts, including profile photos, for easier identification.

Features:

    Contact Management: Save, update, and delete contact information, including names, phone numbers, and profile photos.

    Profile Photo Support: Users can attach a profile photo to each contact. If no photo is provided, a default placeholder image will be displayed.

    Real-time Updates: Contacts are stored in Firestore, and any changes are reflected in real-time within the app.

    Contact Import: Import contacts from your device’s contact list directly into the app for easy access during emergencies.

    User Authentication: Secure access to the app using Firebase Authentication, with each user having a personal contact list.

    Long-Press to Delete: Easily delete contacts by long-pressing on them in the list view.

    Smooth Navigation: Intuitive UI for navigating between saving contacts and viewing the contact list.

Technologies Used:

    Flutter: Cross-platform mobile application development.

    Firebase: Backend services including Firestore for real-time database and Firebase Authentication.

    Contacts Service: To import contacts from the device.

    Permission Handler: To manage and request necessary permissions for accessing contacts.

Installation:

    Prerequisites:

        Flutter SDK
        Firebase project set up with Firestore and Firebase Authentication
        A physical or virtual device to run the application


    Steps:

    Clone the repository:

        git clone https://github.com/yourusername/vehicle-breakdown-app.git
        cd vehicle-breakdown-app


    Install dependencies:

        flutter pub get

    Set up Firebase:

        Create a new Firebase project in the Firebase console.

        Add an Android/iOS app to your Firebase project and download the google-services.json or GoogleService-Info.plist file.

        Place the google-services.json file in the android/app directory (for Android) or the GoogleService-Info.plist file in the ios/Runner directory (for iOS).
        
        Enable Firestore and Firebase Authentication in the Firebase console.

    Run the application:

        flutter run


Usage:

    Login/Signup: Upon launching the app, the user will be prompted to log in or sign up using their email.

    Loading Contacts: The user can load contacts from their device's contact list by clicking the "Load Contacts" button.

    Saving Contacts: After selecting the desired contacts, the user can save them to Firestore using the "Save Selected Contacts" button.

    Viewing Contacts: All saved contacts will be displayed in a list view. Each contact will show their profile photo, name, and phone numbers.

    Deleting Contacts: Long-press on any contact to bring up a delete confirmation dialog. Confirming will delete the contact from Firestore.
