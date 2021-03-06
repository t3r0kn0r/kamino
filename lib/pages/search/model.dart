import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:kamino/api/tmdb.dart' as tmdb;
import 'package:kamino/main.dart';

class SearchResult {
  final String mediaType;
  final int id, pageCount;
  final String title, posterPath,backdropPath, year;

  SearchResult(this.mediaType, this.id, this.title,
      this.posterPath, this.backdropPath, this.year, this.pageCount);

  String get tv => mediaType;
  String get checkPoster => posterPath;
  int get showID => id;

  SearchResult.fromJson(Map json)
      : mediaType = json["media_type"], id = json["id"],
        title = json["original_name"] != null ?
        json["original_name"]: json["original_title"],
        pageCount = json["total_pages"],
        posterPath = json["poster_path"],
        backdropPath = json["backdrop_path"],
        year = json["release_date"] == null ?
        json["first_air_date"] :  json["release_date"];
}

class API {
  final http.Client _client = http.Client();

  static String _url =
      "${tmdb.root_url}/search/multi${tmdb.default_arguments}" +
      "&include_adult=false&query=";

  Future<List<SearchResult>>  get(String query) async {
    List<SearchResult> list = [];

    await _client
        .get(Uri.parse(_url + query))
        .catchError((error){
          log.severe("An error occurred: " + error);
        })
        .then((res) => res.body)
        .then(jsonDecode)
        .then((json) => json["results"])
        .then((movies) => movies.forEach((movie){
          var result = SearchResult.fromJson(movie);

          // Filter out results without a year or backdrop (poster).
          if(result.year != null && result.posterPath != null)
            list.add(result);
        }));

    list.removeWhere((item) => item.mediaType != "movie" && item.mediaType != "tv");
    list.removeWhere((item) => item.id == null);

    return list;
  }
}