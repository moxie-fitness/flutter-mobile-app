import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:jaguar_serializer/jaguar_serializer.dart';
import 'package:moxie_fitness/models/models.dart';

abstract class IBaseModel {
  String getModelNameForApi();
}

class BaseModel implements IBaseModel {
  /// Created by & Updated by
  DateTime created_at;
  DateTime updated_at;
  DateTime deleted_at;

  Future<Map> store({JsonRepo repo, Serializer serializer}) async {
    final headers = await getAuthHeader();
    var body =
        json.encode(repo == null ? serializer.toMap(this) : repo.to(this));
    var url = getApiBaseUrl + getModelNameForApi();
    var response = await http.post('$url', headers: headers, body: body);
    return json.decode(response.body);
  }

  ///
  /// Query & find the model with the given Id in [item]
  ///
  /// example: show(new Exercise(id: 22))) to find [Exercise] with id = 22
  ///
  static Future<Map> show(item) async {
    final headers = await getAuthHeader();
    var url = '${getApiBaseUrl + item.getModelNameForApi()}/${item.id}';
    var response = await http.get(url, headers: headers);
    return json.decode(response.body);
  }

  Future<Map> update(id, Serializer serializer) async {
    final headers = await getAuthHeader();
    var body = json.encode(serializer.toMap(this));
    var url = '${getApiBaseUrl + getModelNameForApi()}/$id';
    var response = await http.put('$url', headers: headers, body: body);
    return json.decode(response.body);
  }

  // TODO: Still needs to be tested
  Future<String> destroy(String id) async {
    final headers = await getAuthHeader();
    var response = await http.delete(
        '${getApiBaseUrl + getModelNameForApi()}/$id',
        headers: headers);
    return response.toString();
  }

  static Future<Map<String, String>> getAuthHeader(
      [ContentType type = ContentType.json]) async {
    final user = await FirebaseAuth.instance.currentUser();
    final String token = await user.getIdToken();
    final String authKey = "Authorization";
    final String authBearer = "Bearer $token";
    final String contentTypeKey = "Content-Type";
    final String contentType = type == ContentType.json
        ? "application/json"
        : "application/x-www-form-urlencoded";
    print('Firebase Token: $token');
    return new Map<String, String>()
      ..putIfAbsent(authKey, () => authBearer)
      ..putIfAbsent(contentTypeKey, () => contentType);
  }

  static String get getApiBaseUrl {
    // return "http://192.168.0.121:8000/";
    return "https://us-central1-moxiefitness-4cadf.cloudfunctions.net/api/";
  }

  @override
  String getModelNameForApi() {
    throw Exception('Must be implemented by Models');
  }
}

enum ContentType { json, urlencoded }
