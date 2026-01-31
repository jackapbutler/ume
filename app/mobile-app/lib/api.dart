import 'package:app/chat/message.dart';
import 'package:app/chat/state.dart';
import 'package:app/utils/user.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:app/matches/match.dart';
import 'package:app/utils/analytics.dart';

const apiUrl = String.fromEnvironment('API_URL');
const apiKey = String.fromEnvironment('API_KEY');

Future<T> makeHttpRequest<T>(
  String url,
  String method, {
  dynamic body,
  required T Function(Map<String, dynamic>) fromJson,
}) async {
  final Map<String, String> headers = {
    'Content-Type': 'application/json',
    'api-key': apiKey
  };
  http.Response response;

  // Determine the HTTP method and make the request
  switch (method) {
    case 'GET':
      response = await http.get(Uri.parse(url), headers: headers);
    case 'POST':
      response = await http.post(Uri.parse(url),
          headers: headers, body: body != null ? jsonEncode(body) : null);
    default:
      throw Exception('Unsupported HTTP method: $method');
  }

  // Check the response status and process accordingly
  if (response.statusCode == 200) {
    final responseBody =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    return fromJson(responseBody);
  } else {
    throw Exception(
      'Request failed with status: ${response.statusCode} and body: ${response.body}',
    );
  }
}

Future<Message> getChatResponse(List<Chat> messages, bool firstMessage) async {
  String? userId = currentUserId();
  String timeoutMessage = firstMessage
      ? "I'm sorry, something has gone wrong our end. Please try again later."
      : "Ok! That's all for now, let's chat again later.";

  if (userId != null) {
    const String url = '$apiUrl/chat/response';
    final Map<String, dynamic> requestData = {
      'user_id': userId,
      'messages': messages.map((chat) => chat.toJson()).toList(),
    };
    return await makeHttpRequest<Message>(url, 'POST',
        body: requestData,
        fromJson: (jsonBody) => Message.fromJson(jsonBody)).timeout(
      Duration(seconds: 6),
      onTimeout: () {
        logUserEvent('chat_timeout');
        return Message(
          message: timeoutMessage,
          conversationEnded: true,
          model: 'n/a',
        );
      },
    );
  } else {
    throw Exception('Failed to get user id.');
  }
}

Future<Message> getOpening(ChatMode mode) async {
  String? userId = currentUserId();

  if (userId != null) {
    String modeStr = mode == ChatMode.discover ? 'discover' : 'coach';
    final String url =
        '$apiUrl/chat/opening?user_id=$userId&chat_mode=$modeStr';
    return await makeHttpRequest<Message>(url, 'GET',
        fromJson: (jsonBody) => Message.fromJson(jsonBody));
  } else {
    throw Exception('Failed to get user id.');
  }
}

Future<void> distilPersona(List<Chat> messages) async {
  String? userId = currentUserId();

  if (userId != null) {
    const String url = '$apiUrl/chat/distil';
    final Map<String, dynamic> requestData = {
      'user_id': userId,
      'messages': messages.map((chat) => chat.toJson()).toList()
    };
    return await makeHttpRequest<void>(url, 'POST',
        body: requestData, fromJson: (jsonBody) => {});
  } else {
    throw Exception('Failed to get user id.');
  }
}

Future<void> savePersona(String persona, String userId) async {
  const String url = '$apiUrl/chat/persona';
  final Map<String, dynamic> requestData = {
    'user_id': userId,
    'description': persona,
  };
  return await makeHttpRequest<void>(url, 'POST',
      body: requestData, fromJson: (jsonBody) => {});
}

Future<void> deleteUserData() async {
  String? userId = currentUserId();

  if (userId != null) {
    final String url = '$apiUrl/profile/delete?user_id=$userId';
    return await makeHttpRequest<void>(url, 'POST', fromJson: (jsonBody) => {});
  } else {
    throw Exception('Failed to get user id.');
  }
}

Future<Persona> getPersona() async {
  String? userId = currentUserId();

  if (userId != null) {
    final String url = '$apiUrl/chat/persona?user_id=$userId';
    return await makeHttpRequest<Persona>(url, 'GET',
        fromJson: (jsonBody) => Persona.fromJson(jsonBody));
  } else {
    throw Exception('Failed to get user id.');
  }
}

Future<MatchResponse> getMatches() async {
  String? userId = currentUserId();
  if (userId != null) {
    final String url = '$apiUrl/matches/get?user_id=$userId';
    return await makeHttpRequest<MatchResponse>(url, 'GET',
        fromJson: (jsonBody) => MatchResponse.fromJson(jsonBody));
  } else {
    throw Exception('Failed to get user id.');
  }
}

Future<void> createMatches() async {
  String? userId = currentUserId();
  if (userId != null) {
    final String url = '$apiUrl/matches/create?user_id=$userId';
    return await makeHttpRequest<void>(url, 'POST', fromJson: (jsonBody) => {});
  } else {
    throw Exception('Failed to get user id.');
  }
}

Future<MatchmakingStatus> getMatchStatus() async {
  const String url = '$apiUrl/matches/status';
  return await makeHttpRequest<MatchmakingStatus>(url, 'GET',
      fromJson: (jsonBody) => MatchmakingStatus.fromJson(jsonBody));
}

Future<void> updateMatch(Match match) async {
  String? userId = currentUserId();

  if (userId != null) {
    const String url = '$apiUrl/matches/update';
    final Map<String, dynamic> requestData = {
      'user_id': userId,
      'matched_user_id': match.matchedUserId,
      'show_interest': match.youShowedInterest,
    };
    return await makeHttpRequest<void>(url, 'POST',
        body: requestData, fromJson: (jsonBody) => {});
  } else {
    throw Exception('Failed to get user id.');
  }
}

Future<void> sendFeedback(String text, String category) {
  String? userId = currentUserId();

  if (userId != null) {
    final String url =
        '$apiUrl/profile/feedback?user_id=$userId&text=$text&category=$category';
    return makeHttpRequest<void>(url, 'POST', fromJson: (jsonBody) => {});
  } else {
    throw Exception('Failed to get user id.');
  }
}
