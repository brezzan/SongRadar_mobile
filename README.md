# Songradar Mobile Application

1-) Dowload Android Studio ( flutter sdk: '>=2.19.6 <3.0.0' ) 

2-) Create a flutter application and open the application folder in Android studio  

3-) In terminal:

```sh
   git clone https://github.com/brezzan/SongRadar_mobile
```

4-) Create a virtual mobile device from the SDK Manager ( Android version 9.0 Pie and above)

5-)Open a terminal and run the code to get the dependencies from pubspec.yaml file 

```sh
- flutter pub get
```

6-)Create the virtual environment for api to run. Check the backend side 

  https://github.com/ilhaniskurt/songradar-backend

7-) Activate the virtual device and run the App

# Features

In this app, you can 
- Login/ Sign Up with Tokens for security (Extra - Authentication)

- See album / song / performer info

- Add songs and albums via manual user input (MVP - Data Collection 1)

- Add songs and albums via file selection (MVP - Data Collection 2)
  can read and add json/text files that has the following structure :


-1-) albums full of songs 
```json
  [{"title": "" ,
  "year": 0 ,
  "genre": "",
  "performers": 0 ,
  "songs": [
  {
    "title": "" ,
    "year": 0 ,
    "genre": "",
    "performers": 0 
  }]}
  ]
```

2-) songless albums 
```json
[ {
  "title": "" ,
  "year": 0 ,
  "genre": "",
  "performers": 0 
  }]
```
-3-) albumless songs
```json  
  [{
  "title": "" ,
  "year": 0 ,
  "genre": "",
  "performers": 0 ,
  }]
```

-4-) songs to already existing albums
```json
  [{
  "title": "" ,
  "year": 0 ,
  "genre": "",
  "performers": 0 ,
  "album":"" 
  }]
```
- Add songs and albums via data reading from another local database (MVP - Data Collection 3)

- Delete album and all songs within that album (MVP - Data Collection 5)
