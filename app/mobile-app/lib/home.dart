import 'package:app/chat/screen.dart';
import 'package:app/chat/state.dart';
import 'package:app/feedback.dart';
import 'package:app/profile/screen.dart';
import 'package:app/profile/state.dart';
import 'package:app/matches/screen.dart';
import 'package:app/utils/analytics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  Home({super.key});

  @override
  State<Home> createState() => _HomePageState();
}

class _HomePageState extends State<Home> {
  int _selectedIndex = 0;
  bool _isProfileVisible = false;

  List<BottomNavigationBarItem> get bottomBarItems {
    return const <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        icon: Icon(Icons.question_answer),
        label: 'Chat',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.favorite),
        label: 'Matches',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final ProfileState pState = context.watch<ProfileState>();
    final ChatState chatState = context.watch<ChatState>();
    final Color selectedColor = Theme.of(context).colorScheme.primary;
    final Color unselectedColor = Theme.of(context).colorScheme.outlineVariant;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 4.0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const ClipOval(
              child: Image(
                image: AssetImage('assets/logo.png'),
                height: 40,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 10),
            Text('UMe',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                )),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.feedback,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            onPressed: () => openFeedback(
              context: context,
              title: "Feedback",
              category: "general",
              afterFeedback: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Feedback submitted!')),
                );
                Navigator.of(context).pop();
              },
              onCancel: () => Navigator.of(context).pop(),
            ),
          ),
          IconButton(
            icon: Container(
              width: 40.0,
              height: 40.0,
              decoration: BoxDecoration(
                color: const Color(0xff7c94b6),
                image: DecorationImage(
                  image: pState.image,
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.all(Radius.circular(50.0)),
                border: Border.all(
                  color: _isProfileVisible
                      ? Theme.of(context).colorScheme.secondary
                      : Theme.of(context).colorScheme.onPrimary,
                  width: 3.0,
                ),
              ),
            ),
            onPressed: () {
              setState(() {
                logUserEvent('view_profile');
                _isProfileVisible = true;
              });
            },
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (_isProfileVisible) {
            return ProfileScreen();
          } else if (_selectedIndex == 0 &&
              chatState.chatMode == ChatMode.discover) {
            return ChatScreen();
          } else if (_selectedIndex == 1) {
            return MatchScreen();
          } else {
            return Container();
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: bottomBarItems,
        currentIndex: _selectedIndex,
        selectedItemColor: _isProfileVisible ? unselectedColor : selectedColor,
        unselectedItemColor: unselectedColor,
        onTap: (index) => setState(() {
          _selectedIndex = index;
          _isProfileVisible = false;
          if (index == 1) {
            logUserEvent('view_matches');
          } else {
            logUserEvent('view_chat');
          }
        }),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
