import 'package:app/matches/state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/matches/card.dart';
import 'package:app/matches/match.dart';

class MatchList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final matchState = context.watch<MatchState>();

    return ListView(
      children: MatchState.sections.entries.map((entry) {
        List<Match> matches = matchState.categorizedMatches[entry.key]!;
        if (matches.isEmpty) return SizedBox.shrink();
        return Card(
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Column(
            children: [
              ListTile(
                title: Text(entry.key,
                    style: TextStyle(fontWeight: FontWeight.bold)),
                trailing: Icon(entry.value['expanded']
                    ? Icons.expand_less
                    : Icons.expand_more),
                onTap: () {
                  matchState.toggleSection(entry.key);
                },
              ),
              if (entry.value['expanded'])
                ...matches.map((match) => MatchCard(match: match)),
            ],
          ),
        );
      }).toList(),
    );
  }
}
