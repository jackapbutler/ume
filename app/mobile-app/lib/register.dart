import 'package:app/onboard/pageview.dart';
import 'package:app/profile/form.dart';
import 'package:app/profile/state.dart';
import 'package:app/utils/analytics.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:app/home.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

const welcome = Text('Welcome to UMe!');

class BackgroundVideo extends StatefulWidget {
  final String videoPath;

  const BackgroundVideo({super.key, required this.videoPath});

  @override
  State<BackgroundVideo> createState() => _BackgroundVideoState();
}

class _BackgroundVideoState extends State<BackgroundVideo> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(
      widget.videoPath,
    ); // Use asset for local files

    _initializeVideoPlayerFuture = _controller.initialize().then((_) {
      _controller.setLooping(true); // Loop the video
      _controller.setVolume(0.0); // Mute the video
      _controller.play(); // Start playing
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: VideoPlayer(_controller),
              ),
            ),
          );
        } else {
          return const LoadingLogo();
        }
      },
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  final VoidCallback onSignInPressed;
  final VoidCallback onRegisterPressed;

  const WelcomeScreen({
    super.key,
    required this.onSignInPressed,
    required this.onRegisterPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const BackgroundVideo(videoPath: 'assets/video.mp4'),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Image(
                image: AssetImage('assets/logo_transparent.png'),
                height: 160,
              ),
              const SizedBox(height: 450.0),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: ElevatedButton(
                      onPressed: onRegisterPressed,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        textStyle: TextStyle(fontSize: 18),
                      ),
                      child: const Text('Create an Account'),
                    ),
                  ),
                  const SizedBox(height: 30.0),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: ElevatedButton(
                      onPressed: onSignInPressed,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        textStyle: TextStyle(fontSize: 18),
                      ),
                      child: const Text('Log In'),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  void _handleAuthChange(BuildContext context, AuthState state) {
    if (state is SigningIn || state is SigningUp) {
      const LoadingLogo();
    } else if (state is UserCreated) {
      logUserEvent('signup');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OnboardingScreen(
            user: state.credential.user!,
          ),
        ),
      );
    } else if (state is SignedIn) {
      logUserEvent('login');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Home(),
        ),
      );
    } else if (state is AuthFailed) {
      logUserEvent('auth_failed');
      // Show error message to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Authentication failed: ${state.exception.toString()}'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
    } else {
      print('Unhandled auth state: $state');
    }
  }

  RegisterScreen _registrationScreen() {
    return RegisterScreen(
      providers: [
        EmailAuthProvider(),
      ],
      actions: [
        AuthStateChangeAction<AuthState>((context, state) {
          _handleAuthChange(context, state);
        }),
      ],
      headerBuilder: (context, constraints, shrinkOffset) {
        return const Padding(
          padding: EdgeInsets.all(20),
          child: Image(image: AssetImage('assets/logo_transparent.png')),
        );
      },
      subtitleBuilder: (context, action) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: welcome,
        );
      },
      footerBuilder: (context, action) {
        return const Padding(padding: EdgeInsets.only(top: 16));
      },
      showPasswordVisibilityToggle: true,
    );
  }

  SignInScreen _signInScreen() {
    return SignInScreen(
      actions: [
        AuthStateChangeAction<AuthState>((context, state) {
          _handleAuthChange(context, state);
        }),
      ],
      providers: [EmailAuthProvider()],
      headerBuilder: (context, constraints, shrinkOffset) {
        return const Padding(
          padding: EdgeInsets.all(20),
          child: Image(image: AssetImage('assets/logo_transparent.png')),
        );
      },
      subtitleBuilder: (context, action) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: welcome,
        );
      },
      footerBuilder: (context, action) {
        return Padding(padding: EdgeInsets.only(top: 16));
      },
      showPasswordVisibilityToggle: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      initialData: FirebaseAuth.instance.currentUser,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingLogo();
        }

        final User? user = snapshot.data;
        if (user == null) {
          return WelcomeScreen(
            onSignInPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => _signInScreen()),
            ),
            onRegisterPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => _registrationScreen()),
            ),
          );
        } else {
          return FutureBuilder<FormData>(
            future: getFormResponse(user.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingLogo();
              }
              return snapshot.data?.metadata.docID == null
                  ? OnboardingScreen(user: user)
                  : Home();
            },
          );
        }
      },
    );
  }
}

class LoadingLogo extends StatelessWidget {
  const LoadingLogo({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Use your app's launcher icon
          ClipOval(
            child: Image(
              image: AssetImage('assets/logo.png'),
              width: 100, // Size of the icon
              height: 100,
              fit: BoxFit.cover, // Ensures the icon fits within the circle
            ),
          ),
        ],
      ),
    );
  }
}
