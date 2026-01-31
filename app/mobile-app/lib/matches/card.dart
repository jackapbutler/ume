import 'package:app/matches/state.dart';
import 'package:app/utils/analytics.dart';
import 'package:app/utils/snack.dart';
import 'package:app/utils/time.dart';
import 'package:flutter/material.dart';
import 'package:app/matches/match.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class MatchCard extends StatelessWidget {
  final Match match;

  MatchCard({required this.match});

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    logUserEvent('view_full_image', {'match': match.matchedUserId});
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () => Navigator.of(context).pop(), // Close on tap
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: Center(
              child: Image.network(imageUrl),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    MatchState matchState = context.read<MatchState>();

    return Card(
      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      child: ExpansionTile(
        leading: GestureDetector(
          onTap: () => _showFullScreenImage(context, match.imageUrl),
          child: CircleAvatar(
            backgroundImage: NetworkImage(match.imageUrl),
            radius: 30.0,
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              match.name,
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4.0),
            Row(
              children: [
                if (match.gender != null) ...[
                  Icon(
                    match.gender == 'Male' ? Icons.male : Icons.female,
                    size: 16.0,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8.0),
                ],
                if (match.age != null) ...[
                  Icon(Icons.cake, size: 16.0, color: Colors.grey),
                  const SizedBox(width: 4.0),
                  Text('${match.age}', style: TextStyle(fontSize: 14.0)),
                  const SizedBox(width: 8.0),
                ],
                if (match.locationName != null) ...[
                  Icon(Icons.location_on, size: 16.0, color: Colors.grey),
                  const SizedBox(width: 4.0),
                  Flexible(
                    child: Text(
                      match.locationName!,
                      style: TextStyle(fontSize: 14.0),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: Text(
          prettyTimeSinceNow(match.dateMatched),
          style: TextStyle(fontSize: 14.0, color: Colors.grey),
        ),
        children: [
          const SizedBox(height: 8.0),
          Wrap(
            spacing: 4.0,
            runSpacing: 4.0,
            children: match.highlightedThemes.map((theme) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Text(
                  theme,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 12.0,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(
              match.rationale,
              style: TextStyle(fontSize: 16.0, color: Colors.black54),
            ),
          ),
          const SizedBox(height: 16.0),
          if (match.youShowedInterest == false) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 32.0,
                  ),
                  onPressed: () => matchState.updateMatchInterest(match, true),
                ),
                const SizedBox(width: 20.0),
                IconButton(
                  icon: Icon(
                    Icons.cancel,
                    color: Colors.red,
                    size: 32.0,
                  ),
                  onPressed: () => matchState.updateMatchInterest(match, false),
                ),
              ],
            ),
          ],
          if (match.both) ...[
            const SizedBox(height: 16.0),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: match.phoneNumber != null
                      ? () async {
                          final smsUrl = Uri.parse('sms:${match.phoneNumber}');
                          logUserEvent(
                            'try_sms',
                            {'match': match.matchedUserId},
                          );
                          if (await canLaunchUrl(smsUrl)) {
                            await launchUrl(smsUrl);
                          } else {
                            CustomSnackBar(
                              context: context,
                              content: Text(
                                "Something went wrong, is your SMS app installed?",
                              ),
                              isError: true,
                            );
                          }
                        }
                      : null,
                  icon: Icon(Icons.message, color: Colors.white, size: 20.0),
                  label: Text(
                    'Chat on SMS',
                    style: TextStyle(color: Colors.white, fontSize: 12.0),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding:
                        EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
                  ),
                ),
                const SizedBox(width: 10.0),
                GestureDetector(
                  onTap: () async {
                    final String validWappNumber = match.phoneNumber!
                        .replaceFirst('+', ' ')
                        .replaceAll(' ', '');
                    final whatsappUrl =
                        Uri.parse('https://wa.me/$validWappNumber');
                    logUserEvent(
                      'try_whatsapp',
                      {'match': match.matchedUserId},
                    );
                    if (await canLaunchUrl(whatsappUrl)) {
                      await launchUrl(whatsappUrl);
                    } else {
                      CustomSnackBar(
                        context: context,
                        content: Text(
                          "Something went wrong, is WhatsApp installed?",
                        ),
                        isError: true,
                      );
                    }
                  },
                  child: Image.asset('assets/whatsapp_logo.png', scale: 2),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16.0),
        ],
      ),
    );
  }
}
