 # chatbot_app

A new Flutter project.

## Features
* The app enables users to communicate through text messages, fostering interaction and easy information exchange.
* This feature condenses lengthy text into concise and understandable summaries, saving users time and aiding quick comprehension.
* The app boasts an intuitive interface that facilitates seamless navigation and efficient utilization of its features.

## Screenshots


| Home                                         | Chat                                         | History                                      |
|----------------------------------------------|----------------------------------------------|----------------------------------------------|
| ![image](https://github.com/vodatvan01/flutter_chat/assets/87610505/5bd19ba9-ffe5-466f-b5ac-53833af1378b)|![image](https://github.com/vodatvan01/flutter_chat/assets/87610505/014ea1b0-e2d5-4f71-ad3b-db8eeb56a654)|![image](https://github.com/vodatvan01/flutter_chat/assets/87610505/fb8aa845-b135-440d-9770-4e410e03c77d)|
| Chat                                         | Summarize                                    | Summarize                                    |
| ![image](https://github.com/vodatvan01/flutter_chat/assets/87610505/df763968-7ad0-47fd-b1b5-ecb770d431d1)|![image](https://github.com/vodatvan01/flutter_chat/assets/87610505/3b18e73c-9fd3-481d-bf7b-f89a939f3e4d)|![image](https://github.com/vodatvan01/flutter_chat/assets/87610505/e4733ab2-f76e-4e4d-b2fc-bf7fb2e04d72)|



## Installation
### Step 1: Download the Source Code from GitHub
1. Access the GitHub repository containing the Flutter application source code you want to download.
2. Click on the "Code" (or "Clone") button and copy the repository URL.
    `
###  Step 2: Install Dependencies and Run the Application
1. Open Terminal or Command Prompt on your computer.
2. Navigate to the directory where you want to store the source code using the cd path_to_directory command.
3. Clone the repository using the following command (replace URL_repository with the URL you copied):
```bash
git clone https://github.com/vodatvan01/flutter_chat.git

````
4. Install the Flutter dependencies by running:
```bash
flutter pub get

````
***************************************
## Installing Firebase CLI
Firebase Command Line Interface (CLI) is a powerful tool for managing your Firebase projects through the command line. Below is a guide on how to install the Firebase CLI on your computer.

#### Step 1: Install Node.js and npm

Firebase CLI is built on the Node.js platform and uses npm (Node Package Manager) to manage software packages. If you haven't installed Node.js and npm, you can follow these steps:

1. Visit the official Node.js website at [https://nodejs.org/](https://nodejs.org/).
2. Download and install the appropriate version of Node.js for your operating system.
3. Once the installation is complete, open a terminal window or command prompt and run the following commands to check the installed version of Node.js and npm:

   ```bash
   node -v
   npm -v
   ```

#### Step 2: Install Firebase CLI
After you have installed Node.js and npm, you can proceed to install the Firebase CLI with the following steps:
1. Open a terminal window or command prompt on your computer.
2. Run the following command to install Firebase CLI:
   ```bash
   npm install -g firebase-tools
   ```
   This command will globally install Firebase CLI on your system, allowing you to use the `firebase` command from anywhere on your computer.
3. Wait for the installation process to complete.
#### Step 3: Verify the Installation
To verify if Firebase CLI has been successfully installed, you can run the following command:
```bash
firebase --version
```
If you see the current version of Firebase CLI, it indicates that the installation was successful.

   ***************************************
### Log in and test the Firebase CLI
1. Log into Firebase using your Google account by running the following command:
```bash
firebase login
```
This command connects your local machine to Firebase and grants you access to your Firebase projects.
2. Install the FlutterFire CLI by running the following command from any directory:
```bash
dart pub global activate flutterfire_cli
```
3. Config your app to use flutter:
```bash
flutterfire configure
```
   ***************************************


## Creating a Project and Connecting to Firebase:
   1. Log in to the [Firebase Console](https://console.firebase.google.com/).
   2. Create a new project or select an existing project.
## Adding Data to Firestore:
   1. In the Firebase Console, select "Build" from the left sidebar and then choose "Firestore Database."
   2. Click on the "Create database" button.
   3. Select "Start in production mode."
   4. Choose a region that is close to your location.
   5. Once the database is created, you can add data to Firestore by clicking on the "Start collection" button and adding documents to each collection you create.

## Below is a guide on how to change Firestore rules in the Firebase Console:

1. **Select Rules**:
   - In the top menu, choose the "Rules" tab.

2. **Edit Rules**:
   - On the Rules page, you will see a text editor where you can edit your rules.

3. **Enter New Rules**:
   - Replace the current rules with the rules you want to apply. For example, to apply the rules you provided:

   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /{document=**} {
         allow read, write: if false;
       }
     }
   }
   ```

4. **Save Rules**:
   - After making changes to the rules, make sure to click the "Save" button to save and deploy the new rules.
      ***************************************
## Create the following value variables in Cloud Firestore for use in the app.

![image](https://github.com/vodatvan01/flutter_chat/assets/87610505/a371417b-c6b0-4568-a035-25cd91afff02)
![image](https://github.com/vodatvan01/flutter_chat/assets/87610505/c0e35513-cd7e-4989-bd4b-4bf0f014ad87)
![image](https://github.com/vodatvan01/flutter_chat/assets/87610505/2f32c156-364f-44c9-b8c8-487f558f748a)

***************************************
## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
