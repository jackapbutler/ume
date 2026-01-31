import 'package:app/utils/analytics.dart';
import 'package:app/utils/snack.dart';
import 'package:flutter/material.dart';
import 'package:app/api.dart';
import 'package:app/matches/match.dart';

class MatchState extends ChangeNotifier {
  List<Match> _matches = [];
  int previousLength = 0;
  int currentLength = 0;
  MatchmakingStatus? currentStatus;
  DateTime? lastLoaded;

  List<Match> get matches => _matches;

  static final Map<String, Map<String, dynamic>> sections = {
    'New Matches 😊': {
      'expanded': true,
      'filter': (Match m) => m.newToYou,
    },
    'Waiting for Response ⏳': {
      'expanded': false,
      'filter': (Match m) => m.youWaiting,
    },
    'Likes You ❤️': {
      'expanded': false,
      'filter': (Match m) => m.both,
    },
  };

  Map<String, List<Match>> get categorizedMatches {
    final Map<String, List<Match>> categorized = {};
    sections.forEach((key, value) {
      categorized[key] = matches.where(value['filter']).toList();
    });
    return categorized;
  }

  MatchState() {
    initialise();
  }

  Future<void> initialise() async {
    currentStatus = await getMatchStatus();
    loadMatches();
  }

  void toggleSection(String title) {
    if (sections[title] != null) {
      sections[title]!['expanded'] = !sections[title]!['expanded']!;
    }
    notifyListeners();
  }

  void updateMatchInterest(Match match, bool newInterest) {
    logUserEvent(
      'change_interest_to',
      {'match': match.matchedUserId, 'interest': newInterest.toString()},
    );
    match.updateInterest(newInterest);
    updateMatch(match);
    notifyListeners();
  }

  Future<void> loadMatches() async {
    logUserEvent('try_load_matches');
    if (currentStatus!.status == "DONE") {
      _matches = [];
      notifyListeners();
      await fetchLatestMatches();
      notifyListeners();
    }
  }

  Future<void> fetchLatestMatches() async {
    logUserEvent('try_fetch_latest_matches');
    final currentMatchInfo = await getMatches();
    _matches = currentMatchInfo.matches;
    previousLength = currentLength;
    currentLength = _matches.length;
    lastLoaded = DateTime.now();
  }

  Future<void> triggerMatch() async {
    logUserEvent('try_create_matches');
    await createMatches();
    await fetchLatestMatches();
    currentStatus = await getMatchStatus();
    notifyListeners();
  }

  CustomSnackBar renderMessage(BuildContext context) {
    if (currentStatus!.status == "IN_PROGRESS") {
      return CustomSnackBar(
        context: context,
        content: Text("⏳ Matches are being created!"),
      );
    } else if (currentLength == 0) {
      return CustomSnackBar(
        context: context,
        content: Text("😔 Sorry, no matches today!"),
      );
    } else if (previousLength < currentLength) {
      return CustomSnackBar(
        context: context,
        content: Text(
          "🎉 ${currentLength - previousLength} new matches loaded!",
        ),
      );
    } else if (previousLength == currentLength) {
      return CustomSnackBar(
        context: context,
        content: Text("🔥 See your updated matches!"),
      );
    } else {
      return CustomSnackBar(
        context: context,
        content: Text("🤔 Something went wrong!"),
      );
    }
  }

  bool alreadyLoaded() {
    return currentStatus!.lastFinished.isBefore(lastLoaded!);
  }

  String timeUntilNextRefresh() {
    final difference = currentStatus!.nextStarting.difference(DateTime.now());
    return "${difference.inHours}h ${difference.inMinutes % 60}m";
  }
}
