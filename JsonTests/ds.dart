/*  This tests deserializing a nested 
  object structed json to corresponding 
  strongly typed object.

  Since Dart does not support generics this approach can be adopted.
  The performance implication is untested.

  I am using the dio library here to mock an api response that fits my model objects
*/

import 'package:dio/dio.dart';
import 'dart:convert';

void main() async {
  var options = BaseOptions(responseType: ResponseType.json);
  var dio = Dio(options);
  dio.interceptors.add(TestInterceptor());
  var response = await dio.get("https://jsonplaceholder.typicode.com/users/1");
  var json = jsonDecode(response.data);
  //print(json.runtimeType);
  var strongTyped = CreateUserResponseModel.fromJson(json);
  print("object type ${strongTyped.runtimeType}");

  // Top Level Object
  print("message: ${strongTyped.message}");
  print("status: ${strongTyped.status}");

  // Second Level Object: Data
  print("access token: ${strongTyped.data.accessToken}");
  print("user id: ${strongTyped.data.id}");
}

class TestInterceptor extends InterceptorsWrapper {
  @override
  Future onResponse(Response response) {
    response.data = jsonEncode({
      "status": 0,
      "message": "User created successfully",
      "data": {
        "id": "ghdg-erds-ssdr-sdf4-4fes",
        "accessToken": "abcdefgh",
      }
    });
    return super.onResponse(response);
  }
}

class CreateUserResponseModel extends ApiResponseBase {
  final UserResponseModelData data;
  CreateUserResponseModel({this.data});

  factory CreateUserResponseModel.fromJson(dynamic json) {
    var model = CreateUserResponseModel(
      data: UserResponseModelData.fromJson(
        json["data"], // strong typing
      ),
    );

    model.setBaseProperties(json);
    return model; // return strongly typed instance
  }
}

class UserResponseModelData {
  final String accessToken;
  final String id;
  UserResponseModelData({this.accessToken, this.id});

  factory UserResponseModelData.fromJson(dynamic json) {
    return UserResponseModelData(
      accessToken: json["accessToken"],
      id: json["id"],
    );
  }
}

class ApiResponseBase {
  ApiResponseStatus status;
  String message;

  setBaseProperties(dynamic json) {
    message = json["message"];
    status = ApiResponseStatus.values[json["status"]];
  }
}

enum ApiResponseStatus {
  success,
  error,
}
