import 'package:flutter/material.dart';
import 'dart:core';
import 'package:songradar/api.dart';
import 'package:songradar/variables.dart';
import 'package:fl_chart/fl_chart.dart';

class starredSongsPage extends StatefulWidget {
  final int userid;
  final String username;
  const starredSongsPage(
      {required this.userid, required this.username, Key? key})
      : super(key: key);

  @override
  State<starredSongsPage> createState() => _starredSongsPageState();
}

class _starredSongsPageState extends State<starredSongsPage> {
  late String username;
  late int userid;
  List<dynamic> songs = [];


  Map<String,int> most_repeated_year ={};
  Map<String,int> most_repeated_artists ={};

  double avg_danceability = 0 ;
  double avg_energy = 0 ;
  double avg_key = 0 ;
  double avg_loudness = 0 ;
  double avg_mode = 0 ;
  double avg_speechiness = 0 ;
  double avg_acousticness = 0 ;
  double avg_instrumentalness = 0 ;
  double avg_liveness = 0 ;
  double avg_valence = 0 ;
  double avg_tempo = 0 ;
  double avg_duration_ms = 0 ;
  double tot_duration_ms = 0;
  ScrollController _scrollControllerSong = ScrollController();

  int currentPageSong = 1;
  int pageSize = 30;

  Song avg =  Song(
    id:  '',
    name: '',
    album: '',
    album_id: "[]",
    artists: "[]",
    artist_ids:  '',
    track_number: 0,
    disc_number: 0,
    explicit: false,
    danceability:  0.0,
    energy:0.0,
    key:  0,
    loudness:  0,
    mode: 0,
    speechiness: 0,
    acousticness: 0,
    instrumentalness: 0,
    liveness:  0,
    valence: 0,
    tempo:  0,
    duration_ms:  0,
    time_signature:  0,
    year: 0,
    month:0,
    day: 0,
    owner_id: 0,

  );

  void avarages(List<dynamic> songs){

    List<String> artists = [];
    double danceability = 0 ;
    double energy = 0 ;
    double key = 0 ;
    double loudness = 0 ;
    double mode = 0 ;
    double speechiness = 0 ;
    double acousticness = 0 ;
    double instrumentalness = 0 ;
    double liveness = 0 ;
    double valence = 0 ;
    double tempo = 0 ;
    double duration_ms = 0 ;

    Map<String,int> artist_occurences = {};
    Map<String,int>year_occurences = {};


    print('songsis here : $songs');
    for(var song in songs) {  // data gathering
      print('ı am here now');
      print(song);
      List<String> s_artists = song['artists'].replaceAll("'", "").replaceAll(
          "[", "").replaceAll("]", "").split(',');

      for (var art in s_artists) {

          if (artist_occurences.containsKey(art)) {
            artist_occurences[art] = artist_occurences[art]! + 1;
          } else {
            artist_occurences[art] = 1;
          }

      }
        String new_year = song['year'].toString().substring(0, 3) +'0s';

        if (year_occurences.containsKey(new_year )) {
          year_occurences[new_year] = year_occurences[new_year]! + 1;
        } else {
          year_occurences[new_year] = 1;
        }


      danceability += song['danceability'];
      energy += song['energy'];
      key += song['key'];
      loudness += song['loudness'];
      mode += song['mode'];
      speechiness += song['speechiness'];
      acousticness += song['acousticness'];
      instrumentalness += song['instrumentalness'];
      liveness += song['liveness'];
      valence += song['valence'];
      tempo += song['tempo'];
      duration_ms += song['duration_ms'];

    }

    avg_danceability = danceability/songs.length ;
    avg_energy = energy/songs.length ;
    avg_key = key/songs.length ;
    avg_loudness = loudness/songs.length ;
    avg_mode = mode/songs.length ;
    avg_speechiness = speechiness/songs.length ;
    avg_acousticness = acousticness/songs.length ;
    avg_instrumentalness = instrumentalness/songs.length ;
    avg_liveness = liveness/songs.length ;
    avg_valence = valence/songs.length ;
    avg_tempo = tempo/songs.length ;
    tot_duration_ms = duration_ms;

    most_repeated_artists = Map.fromEntries(
      artist_occurences.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value)),
    );

    most_repeated_year = Map.fromEntries(
      year_occurences.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value)),
    );

    print(avg_danceability);
    print(avg_energy);
    print(avg_key);
    print(avg_loudness);
    print(avg_mode);

    print(avg_speechiness);
    print(avg_acousticness);
    print(avg_liveness);
    print(avg_valence);
    print(avg_tempo);
    print(tot_duration_ms);
    print(most_repeated_artists);
    print(most_repeated_year);

    avg =  Song(
      id:  '',
      name: '',
      album: '',
      album_id: "[]",
      artists: "[]",
      artist_ids:  '',
      track_number: 0,
      disc_number: 0,
      explicit: false,
      danceability: avg_danceability ?? 0.0,
      energy:avg_energy ?? 0.0,
      key: avg_key.toInt() ?? 0,
      loudness: avg_loudness ?? 0,
      mode: avg_mode.toInt() ?? 0,
      speechiness: avg_speechiness ?? 0,
      acousticness: avg_acousticness ?? 0,
      instrumentalness: avg_instrumentalness ?? 0,
      liveness: avg_liveness ?? 0,
      valence: avg_valence ?? 0,
      tempo: avg_tempo ?? 0,
      duration_ms: tot_duration_ms.toInt() ?? 0,
      time_signature:  0,
      year: 0,
      month:0,
      day: 0,
      owner_id: 0,

    );

  }

  List<PieChartSectionData> getSections() {
    // Example data, replace it with your actual data
    List<Map<String, int>> decadeData = most_repeated_year.entries
        .map((entry) => {entry.key: entry.value})
        .toList();
    print(decadeData);
    return decadeData.asMap().entries.map((entry) {
      return PieChartSectionData(
        color: getColor(entry.key),
        value: entry.value.values.first.toDouble(),
        title: entry.value.keys.toString(),
        radius:100,
        titleStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
  }

  Color getColor(int index) {
    // You can define your own color scheme
    List<Color> colors = [Colors.blue, Colors.green, Colors.orange,Colors.red,Colors.yellow,Colors.purple,];
    return colors[index];
  }



  Future<List<dynamic>> fetchStarred() async {
    return await AuthService().getStarred();
  }

  Future<void> loadStarred() async {
    var starredSongs = await fetchStarred();
    setState(() {
      songs.addAll(starredSongs);
      avarages(songs);
    });
  }

  void _scrollListenerSong() {
    if (_scrollControllerSong.position.pixels == _scrollControllerSong.position.maxScrollExtent) {
      currentPageSong++;
      loadStarred();
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollControllerSong.addListener(_scrollListenerSong);
    loadStarred();
  }



  @override
  Widget build(BuildContext context) {
    final arguments =
    ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    userid = int.parse('${arguments?['userid']}');
    username = '${arguments?['username']}';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.grey,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(
                Icons.arrow_back,
                size: 40,
              ),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/personalPage',
                    arguments: {'userid': userid, 'username': username});
              },
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Center(
                  child: Text('Favorite Songs'),
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.logout,
                size: 40,
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Log Out ?'),
                      content: Text(
                        'Are you sure you want to log out?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/login',
                                arguments: {});
                          },
                          child: Text('Yes'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('No'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              //controller: _scrollControllerSong,
              scrollDirection: Axis.vertical,
              child: Column(
                children: [

                  Column(children: [
                    const SizedBox(height: 16),
                    Text(
                      'Duration: ${tot_duration_ms ~/ 60000}:${(tot_duration_ms %
                          60000 ~/ 1000).toString().padLeft(2, '0')} min',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.normal),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Most to Least Favorited Artists:',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.normal),
                    ),
                    const SizedBox(height: 16),
                    for (var artist in most_repeated_artists.keys)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(artist+'- (${most_repeated_artists[artist]}) songs '),
                        ],
                      ),
                    const SizedBox(height: 16),
                    Text(
                      'Favorite Music Eras:',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.normal),
                    ),
                    Container(
                      height :220,
                      width:220,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 0,
                          centerSpaceRadius: 5,
                          sections: getSections(),

                        ),
                      ),
                    ),

                  ],),
                  Text(
                    'Avarage Characteristics:',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.normal),
                  ),
                  const SizedBox(height: 16),
                  avg.getCharacteristicsChart(),
                  const SizedBox(height: 16),
                  for (var song in songs)
                    SongCard(
                        userid: userid,
                        username: username,
                        song: Song(
                          id: song['id']?? '',
                          name: song['name']?? '',
                          album: song['album']?? '',
                          album_id: song['album_id']?? '',
                          artists: song['artists']?? '[]',
                          artist_ids: song['artist_ids']?? '[]',
                          track_number: 0,
                          disc_number: 0,
                          explicit: song['explicit']?? false,
                          danceability: song['danceability']?? 0,
                          energy: song['energy']?? 0,
                          key: song['key']?? 0,
                          loudness: song['loudness']?? 0,
                          mode: song['mode']?? 0,
                          speechiness: song['speechiness']?? 0,
                          acousticness: song['acousticness']?? 0,
                          instrumentalness: song['instrumentalness']?? 0,
                          liveness: song['liveness']?? 0,
                          valence: song['valence']?? 0,
                          tempo: song['tempo']?? 0,
                          duration_ms: song['duration_ms']?? 0,
                          time_signature: song['time_signature']?? 0,
                          year: song['year']?? 0,
                          month: song['month']?? 0,
                          day: song['day']?? 0,
                          owner_id: song['owner_id']?? 0,)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}



class SongCard extends StatelessWidget {
  final String username;
  final int userid;
  final Song song;

  SongCard(
      {required this.userid,
        required this.username,
        required this.song});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        global_songId=  song.id;         /////////////////////////////////////////////////////////////////////////
        Navigator.pushReplacementNamed(context, '/songPage', arguments: {
          'userid': userid,
          'username': username,
          'songId': song.id
        });
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start, // Set to spaceBetween
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          SizedBox(width: 20),
          SizedBox(
            height: 90, // Set the desired height for the box
            width: 90, // Set the desired width for the box
            child: Container(
              margin: EdgeInsets.all(8.0),
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(8.0),
                color: song.getVibeColor_energy(),
              ),
              child: Center(
                child: FutureBuilder<String>(
                  future: AuthService().getSongCoverById(song.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasData) {
                        return Image.network(snapshot.data!);
                      } else {
                        // Handle the case when there's an error in fetching the image
                        return Text('Error loading image');
                      }
                    } else {
                      // While the future is still resolving, you can show a loading indicator
                      return CircularProgressIndicator();
                    }
                  },
                ),
              ),
            ),
          ),
          SizedBox(width: 4.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 45),
                Text(
                  song.name,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  song.artists[0],
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                ),
                SizedBox(height: 4),
              ],
            ),
          ),
          Flexible(
            child: SizedBox(
              width: 200,
            ),
          ),
          Column(
            children: [
              SizedBox(height: 35),
              IconButton(
                icon: Icon(
                  Icons.delete_forever_outlined,
                  size: 25,
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Remove From Favorites'),
                        content: Text(
                            'Are you sure you want to remove this from favorites?'),
                        actions: <Widget>[
                          TextButton(
                            child: Text('Cancel'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: Text('Delete'),
                            onPressed: () async{
                              await AuthService().UnstarASong(song.id);
                              Navigator.pushReplacementNamed(context, '/starredSongsPage',
                                  arguments: {'userid': userid, 'username': username});
                              //
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                color: Colors.grey,
              ),
            ],
          )
        ],
      ),
    );
  }
}