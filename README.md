Songradar Mobile Application
Step 1: Download Android Studio (Flutter SDK: '>=2.19.6 <3.0.0').

Step 2: Create a Flutter application and open the application folder in Android Studio.

Step 3: In the terminal, execute the following command:

bash
Copy code
git clone https://github.com/brezzan/SongRadar_mobile
Step 4: Create a virtual mobile device from the SDK Manager (Android version 9.0 Pie and above).

Step 5: Open a terminal and run the code to get the dependencies from the pubspec.yaml file:

bash
Copy code
flutter pub get
Step 6: Create the virtual environment for the API to run. Check the backend side at Songradar Backend.

Step 7: Activate the virtual device and run the app.

Features
In this app, you can:

Login/Sign Up with Tokens for security (Extra - Authentication).

View album/song/performer info.

Add songs and albums via manual user input (MVP - Data Collection 1).

Add songs and albums via file selection (MVP - Data Collection 2).

Can read and add JSON/text files with the following structure:
Albums full of songs:
json
Copy code
[{"title": string,
"year": int,
"genre": string,
"performers": string,
"songs": [
{
"title": string,
"year": int,
"genre": string,
"performers": string
}]]}
Songless albums:
json
Copy code
[{
"title": string,
"year": int,
"genre": string,
"performers": string
}]
Albumless songs:
json
Copy code
[{
"title": string,
"year": int,
"genre": string,
"performers": string
}]
Songs to already existing albums:
json
Copy code
[{
"title": string,
"year": int,
"genre": string,
"performers": string,
"album": string
}]

Add songs and albums via data reading from another local database (MVP - Data Collection 3).

Delete an album and all songs within that album (MVP - Data Collection 5).