import 'package:app/profile/state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/utils/snack.dart';
import 'package:app/matches/list.dart';
import 'package:app/matches/state.dart';

class MatchScreen extends StatelessWidget {
  const MatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    MatchState matchState = context.watch<MatchState>();
    ProfileState profileState = context.read<ProfileState>();

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              // Countdown Timer
              Container(
                padding: const EdgeInsets.all(8.0),
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: Center(
                  child: Text(
                    matchState.currentStatus == null
                        ? "Loading ..."
                        : profileState.pData.neverRefreshedMatches == true
                            ? "Pull down to refresh matches!"
                            : matchState.currentStatus?.status == "IN_PROGRESS"
                                ? "Running matchmaking ..."
                                : "New matches in ${matchState.timeUntilNextRefresh()}",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),

              // Main Content with Pull-to-Refresh
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    if (profileState.pData.neverRefreshedMatches) {
                      profileState.pData.neverRefreshedMatches = false;
                      await matchState.triggerMatch();
                      saveProfile(profileState.pData, profileState.userId!);
                    } else {
                      await matchState.loadMatches();
                    }
                    CustomSnackBar snackBar = matchState.renderMessage(context);
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  },
                  child: Stack(
                    children: [MatchList()],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
