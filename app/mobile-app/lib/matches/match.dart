class Match {
  final String name;
  final String matchedUserId;
  final String imageUrl;
  final DateTime? dateMatched;
  final String rationale;
  final List<String> highlightedThemes;
  bool youShowedInterest;
  bool yourInterested;
  final bool theyShowedInterest;
  final bool theyInterested;
  final String? phoneNumber;
  final int? age;
  final String? gender;
  final String? locationName;

  Match({
    required this.name,
    required this.matchedUserId,
    required this.imageUrl,
    required this.dateMatched,
    required this.rationale,
    required this.highlightedThemes,
    required this.youShowedInterest,
    required this.yourInterested,
    required this.theyShowedInterest,
    required this.theyInterested,
    required this.phoneNumber,
    required this.age,
    required this.gender,
    required this.locationName,
  });

  bool get newToYou => youShowedInterest == false;
  bool get youExpressedInterest =>
      youShowedInterest == true && yourInterested == true;
  bool get youWaiting => youExpressedInterest && theyShowedInterest == false;
  bool get both => youExpressedInterest && theyInterested == true;

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      name: json['name'] as String,
      matchedUserId: json['matched_user_id'] as String,
      imageUrl: json['image_url'] as String,
      dateMatched: json['date_matched'] != null
          ? DateTime.parse(json['date_matched'])
          : null,
      rationale: json['rationale'] ?? '',
      highlightedThemes: (json['highlighted_themes'] as List<dynamic>)
          .map((theme) => theme as String)
          .toList(),
      youShowedInterest: json['you_showed_interest'] as bool,
      yourInterested: json['your_interested'] as bool,
      theyShowedInterest: json['they_showed_interest'] as bool,
      theyInterested: json['they_interested'] as bool,
      phoneNumber: json['phone_number'] as String?,
      age: json['age'] as int?,
      gender: json['gender'] as String?,
      locationName: json['location_name'] as String?,
    );
  }

  void updateInterest(bool showInterest) {
    if (youShowedInterest == false) {
      youShowedInterest = true;
    }
    yourInterested = showInterest;
  }
}

class MatchmakingStatus {
  final DateTime lastStarted;
  final DateTime lastFinished;
  final DateTime nextStarting;
  final String status;

  MatchmakingStatus({
    required this.lastStarted,
    required this.lastFinished,
    required this.nextStarting,
    required this.status,
  });

  factory MatchmakingStatus.fromJson(Map<String, dynamic> json) {
    return MatchmakingStatus(
      lastStarted: json['last_started'] != null
          ? DateTime.parse(json['last_started'])
          : DateTime.now(),
      lastFinished: json['last_finished'] != null
          ? DateTime.parse(json['last_finished'])
          : DateTime.now(),
      nextStarting: json['last_started'] != null
          ? DateTime.parse(json['last_started']).add(
              const Duration(days: 1),
            )
          : DateTime.now().add(
              const Duration(days: 1),
            ),
      status: json['status'] as String? ?? 'DONE',
    );
  }
}

class MatchResponse {
  final List<Match> matches;
  final DateTime? lastUpdated;

  MatchResponse({required this.matches, this.lastUpdated});

  factory MatchResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> matchesJson = json['matches'] as List<dynamic>;
    return MatchResponse(
      matches: matchesJson.map((match) => Match.fromJson(match)).toList(),
      lastUpdated: json['last_updated'] != null
          ? DateTime.parse(json['last_updated'])
          : null,
    );
  }
}

class RefreshMsg {
  final String message;

  RefreshMsg({required this.message});

  factory RefreshMsg.fromJson(Map<String, dynamic> json) {
    return RefreshMsg(message: json['message'] as String);
  }
}
