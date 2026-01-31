import 'dart:typed_data';

import 'package:app/api.dart';
import 'package:app/home.dart';
import 'package:app/profile/form.dart';
import 'package:app/profile/screen.dart';
import 'package:app/profile/state.dart';
import 'package:app/utils/image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import 'package:app/profile/decoration.dart';

class OnboardingScreen extends StatefulWidget {
  final User user;

  OnboardingScreen({required this.user});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState(user);
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final User user;
  final PageController _controller = PageController();
  final _formKey = GlobalKey<FormState>();
  final ValueNotifier<double> _progress = ValueNotifier<double>(0.0);
  final TextEditingController dobController = TextEditingController();
  final int totalSteps = 7;

  // User data
  String about = "No additional information has been provided.";
  Profile profile = Profile();
  ImageProvider loadedImage = AssetImage('assets/empty_profile.png');

  _OnboardingScreenState(this.user);

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemsWithSelection = makeOrientationItems(profile.orientation);
    final msController = MultiSelectController<String>();

    return Scaffold(
      body: Column(
        children: [
          ValueListenableBuilder<double>(
            valueListenable: _progress,
            builder: (context, value, child) {
              return LinearProgressIndicator(
                value: value,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              );
            },
          ),
          Expanded(
            child: Form(
              key: _formKey,
              child: PageView(
                controller: _controller,
                physics: NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  // Update progress excluding static pages
                  if (index < totalSteps) {
                    _progress.value = (index + 1) / totalSteps;
                  }
                },
                children: [
                  _buildPage(
                    key: PageStorageKey('name'),
                    title: 'What is your name?',
                    content: _buildTextInputField(
                      labelText: 'Name',
                      hintText: 'Enter your name',
                      onChanged: (value) => profile.name = value,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter your name'
                          : null,
                    ),
                    onNext: () => _nextPage(),
                  ),
                  _buildPage(
                    key: PageStorageKey('dob'),
                    title: 'What is your date of birth?',
                    content: TextFormField(
                      controller: dobController,
                      keyboardType: TextInputType.none,
                      decoration: InputDecoration(
                        labelText: 'Date of Birth',
                        hintText: 'DD/MM/YYYY',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                      onTap: () async {
                        DateTime? selectedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                          builder: (BuildContext context, Widget? child) {
                            return Theme(
                              data: ThemeData.light().copyWith(
                                primaryColor: Theme.of(context).primaryColor,
                                buttonTheme: ButtonThemeData(
                                  textTheme: ButtonTextTheme.primary,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (selectedDate != null) {
                          String fmtDate =
                              DateFormat('dd/MM/yyyy').format(selectedDate);
                          setState(() {
                            profile.dob = fmtDate;
                            dobController.text = fmtDate;
                            profile.setSensibleAgeRange(fmtDate);
                          });
                        }
                      },
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please select a date'
                          : null,
                    ),
                    onNext: () => _nextPage(),
                    onBack: () => _previousPage(),
                  ),
                  _buildPage(
                    key: PageStorageKey('phone'),
                    title: 'What is your phone number?',
                    content: IntlPhoneField(
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        hintText: 'Enter your phone number',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          profile.phoneNumber = value;
                        });
                      },
                      validator: (value) {
                        return value == null || value.number.isEmpty
                            ? 'Please enter your phone number'
                            : null;
                      },
                    ),
                    onNext: () {
                      if (profile.phoneNumber != null) {
                        _nextPage();
                      }
                    },
                    onBack: () => _previousPage(),
                  ),
                  _buildPage(
                    key: PageStorageKey('gender'),
                    title: 'What is your gender?',
                    content: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'I am',
                        hintText: 'Enter your gender',
                        border: OutlineInputBorder(),
                      ),
                      value:
                          profile.gender != null && profile.gender!.isNotEmpty
                              ? profile.gender
                              : null,
                      hint: Text('Select Gender'),
                      items: genders
                          .map((gender) => DropdownMenuItem(
                                value: gender,
                                child: Text(gender),
                              ))
                          .toList(),
                      onChanged: (value) => setState(() {
                        profile.gender = value ?? '';
                      }),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please select a gender'
                          : null,
                    ),
                    onNext: () => _nextPage(),
                    onBack: () => _previousPage(),
                  ),
                  _buildPage(
                    key: PageStorageKey('orientation'),
                    title: "What are you into?",
                    content: MultiDropdown<String>(
                      items: itemsWithSelection,
                      controller: msController,
                      searchEnabled: false,
                      chipDecoration: ChipDecoration(
                        deleteIcon: Icon(
                          Icons.close,
                          size: 16,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        labelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        wrap: true,
                        runSpacing: 2,
                        spacing: 10,
                      ),
                      fieldDecoration: orientationField,
                      dropdownDecoration: orientationDropDown,
                      dropdownItemDecoration: DropdownItemDecoration(
                        selectedIcon: Icon(
                          Icons.check_box,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      onSelectionChange: (selectedItems) => setState(() {
                        profile.orientation = selectedItems;
                        msController.closeDropdown();
                      }),
                    ),
                    onNext: () => _nextPage(),
                    onBack: () => _previousPage(),
                  ),
                  _buildPage(
                    key: PageStorageKey('photo'),
                    title: "Let's add a photo!",
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Center(
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 64,
                                backgroundImage: loadedImage,
                              ),
                              Positioned(
                                bottom: -5,
                                left: 80,
                                child: IconButton(
                                  icon: Icon(Icons.add_a_photo),
                                  onPressed: () async {
                                    Uint8List? img =
                                        await pickImage(ImageSource.gallery);
                                    if (img != null) {
                                      final snapshot =
                                          await uploadImage(user.uid, img);
                                      profile.profileImage =
                                          await snapshot.ref.getDownloadURL();
                                      setState(() {
                                        loadedImage = MemoryImage(img);
                                      });
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Choose a photo where you're smiling, and avoid group pictures to make you stand out!",
                          style: TextStyle(fontSize: 14.0),
                        ),
                      ],
                    ),
                    onNext: () {
                      if (profile.profileImage != null) _nextPage();
                    },
                    onBack: () => _previousPage(),
                  ),
                  _buildPage(
                    key: PageStorageKey('about'),
                    title: 'Finally, tell us about yourself',
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'This is your chance to shine! Tell us about yourself and what you are looking for.',
                          style: TextStyle(fontSize: 16.0),
                        ),
                        const SizedBox(height: 10),
                        _buildTextInputField(
                          labelText: 'You',
                          hintText:
                              'E.g., "I am a foodie who loves hiking and exploring new cultures. Looking for someone adventurous and kind."',
                          maxLines: 5,
                          onChanged: (value) => about = value,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please provide some details about yourself.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                    onNext: () => _submitDetails(),
                    onBack: () => _previousPage(),
                  ),
                  _buildStaticPage(
                    "UMe",
                    'assets/ume_gradient.gif',
                    'Chat with UMe, they will learn about you and what you are looking for in a partner.',
                    'Next',
                    _finishOnboarding,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _finishOnboarding() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Home(),
        ),
      );
    }
  }

  Widget _buildStaticPage(
    String content,
    String imagePath,
    String description,
    String nextText,
    VoidCallback onNext,
  ) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            content,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Center(
            child: ClipOval(
              child: Image.asset(
                imagePath,
                width: 300,
                height: 300,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            description,
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.5, // Half width
              child: ElevatedButton(
                onPressed: onNext,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                child: Text(nextText),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage({
    required PageStorageKey key,
    required String title,
    required Widget content,
    required VoidCallback onNext,
    VoidCallback? onBack,
  }) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: content,
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 30),
              if (onBack != null)
                Expanded(
                  child: ElevatedButton(
                    onPressed: onBack,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: Text('Back'),
                  ),
                ),
              if (onBack != null) const SizedBox(width: 20),
              Expanded(
                child: ElevatedButton(
                  onPressed: onNext,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: Text('Next'),
                ),
              ),
              const SizedBox(width: 30),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextInputField({
    required String labelText,
    required String hintText,
    int maxLines = 1,
    required Function(String) onChanged,
    required String? Function(String?)? validator,
  }) {
    return TextFormField(
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        border: OutlineInputBorder(),
      ),
      onChanged: onChanged,
      validator: validator,
    );
  }

  void _nextPage() {
    if (_formKey.currentState?.validate() ?? false) {
      _controller.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    _controller.previousPage(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _submitDetails() {
    if (_formKey.currentState?.validate() ?? false) {
      savePersona(about, user.uid);
      saveProfile(profile, user.uid);
      _nextPage();
    }
  }
}
