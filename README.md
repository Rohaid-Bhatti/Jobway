# Flutter Job Portal

Flutter Job Portal is a cross-platform mobile application built with Flutter and Firebase. It serves as a platform for both job seekers and job providers to connect. Job seekers can search for jobs, apply, and manage their applications. Job providers can post jobs, manage applicants, and track job postings.

## Features

### For Job Seekers

- **Authentication**: Users can sign up and log in securely.
- **Job Search**: Search for jobs based on title, location, or keywords.
- **Job Details**: View detailed job descriptions.
- **Apply for Jobs**: Submit job applications through the app.
- **Application Status**: Check the status of submitted applications.

### For Job Providers

- **Authentication**: Providers can sign up and log in securely.
- **Post Jobs**: Create new job listings with details such as title, description, location, salary, and job type.
- **Manage Jobs**: Edit or delete posted jobs.
- **Manage Applicants**: Review and manage job applications received.
- **Dashboard**: Track metrics such as the number of jobs posted and total applicants.

## Screens

### Job Seeker Module

- **Home Screen**: Displays a list of available jobs. Includes search functionality and filtering options.
- **Job Details Screen**: Shows detailed information about a selected job, including description, location, salary, and application button.
- **Application Screen**: Allows job seekers to submit applications for jobs they are interested in. Displays application status.

### Job Provider Module

- **Dashboard Screen**: Overview of job postings and total applicants. Includes options to post new jobs and view applicant details.
- **Post Job Screen**: Form for creating new job listings, including fields for job title, description, location, salary, and job type.
- **Applicant Details Screen**: Displays detailed information about applicants for a specific job posting. Includes applicant contact information and status.

## Getting Started

### Prerequisites

- Flutter SDK
- Firebase Account
- Dart

### Installation

1. Clone the repository:
   ```sh
   https://github.com/Rohaid-Bhatti/Jobway.git
   cd flutter_job_portal
   
# Install dependencies:

flutter pub get

# Set up Firebase:

* Create a new Firebase project in the Firebase Console.
* Add an Android and/or iOS app to your Firebase project.
* Follow the instructions to download and place the google-services.json (for Android) and/or GoogleService-Info.plist (for iOS) files in the appropriate directories.
* Enable Firestore in your Firebase project.

# Update Firebase configuration in your Flutter project:

* For Android, update the android/app/build.gradle file with your Firebase project info.
* For iOS, update the ios/Runner/Info.plist file with your Firebase project info.

# Running the App

flutter run

# Contributing

Contributions are welcome! If you find any bugs or want to contribute to this project, feel free to open an issue or create a pull request.

# License

This project is licensed under the [License Name] License - see the LICENSE.md file for details.

# Acknowledgments

Flutter
Firebase
Provider