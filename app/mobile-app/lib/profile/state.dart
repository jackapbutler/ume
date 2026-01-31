import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:app/utils/user.dart';
import 'package:app/utils/image.dart';
import 'package:app/profile/form.dart';

final FirebaseFirestore _fbasestore = FirebaseFirestore.instance;

void saveProfile(Profile profileData, String userId) {
  final registration = profileData.toFirestore();
  registration['user_id'] = userId; // add user id

  var docRef = _fbasestore.collection("profile").doc(userId);
  docRef.get().then((docSnapshot) {
    if (docSnapshot.exists) {
      // Document exists, perform update
      docRef.update(registration);
    } else {
      // Document doesn't exist, set new document with userId as docID
      docRef.set(registration);
    }
  });
}

Future<FormData> getFormResponse(String? userId) async {
  if (userId != null) {
    final ref = _fbasestore
        .collection("profile")
        .where("user_id", isEqualTo: userId)
        .withConverter(
          fromFirestore: Profile.fromFirestore,
          toFirestore: (Profile form, _) => form.toFirestore(),
        );
    final QuerySnapshot<Profile> userForm = await ref.get();
    if (userForm.docs.isNotEmpty) {
      final meta = FormMetadata(userForm.docs[0].id, false);
      return FormData(userForm.docs[0].data(), meta);
    }
  }
  // Return a new instance with empty strings
  return FormData(Profile(), FormMetadata(null, true));
}

class ProfileState extends ChangeNotifier {
  String? _profileImageDownloadUrl;
  Uint8List? _image;
  dynamic get image {
    // priority is uploaded image, then download url then null
    if (_image != null) {
      // Return the uploaded image if available
      return MemoryImage(_image!);
    } else {
      if (_profileImageDownloadUrl != null) {
        // Return the download URL if the uploaded image is not available
        return NetworkImage(_profileImageDownloadUrl!);
      } else {
        return AssetImage("assets/empty_profile.png");
      }
    }
  }

  String? userId = currentUserId();
  late Profile _profileData;
  late FormMetadata _metadata;
  late Map<String, dynamic> _initialData;
  bool _awaitingForm = true;
  bool _pressedEdit = true;
  bool _changedImage = false;
  bool _unsavedChanges = false;
  bool get changedImage => _changedImage;

  Profile get pData => _profileData;
  FormMetadata get metadata => _metadata;
  bool get awaitingForm => _awaitingForm;
  bool get unsavedChanges => _unsavedChanges;
  bool get pressedEdit => _pressedEdit;
  bool get allowingInput => !_awaitingForm && _pressedEdit;
  bool get validForm => _formKey.currentState!.validate();
  bool get locationAllowed => pData.location != null && pData.location!.consent;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  GlobalKey<FormState> get formKey => _formKey;

  ProfileState() {
    _loadFormResponse();
  }

  void markAsChanged() {
    _unsavedChanges = !mapEquals(_initialData, pData.toFirestore());
    notifyListeners();
  }

  void setImage(Uint8List img) {
    _image = img;
    _changedImage = true;
    notifyListeners();
  }

  void decreaseAgeGap(int index) {
    updateAgeRange(index, _profileData.ageRange[index] - 1);
  }

  void increaseAgeGap(int index) {
    updateAgeRange(index, _profileData.ageRange[index] + 1);
  }

  void updateAgeRange(int index, int value) {
    if (index == 0) {
      if (value <= _profileData.ageRange[1] && value >= 18) {
        _profileData.ageRange = [value, _profileData.ageRange[1]];
      }
    } else {
      if (value >= _profileData.ageRange[0]) {
        _profileData.ageRange = [_profileData.ageRange[0], value];
      }
    }
    notifyListeners();
  }

  void _loadFormResponse() async {
    final FormData response = await getFormResponse(userId);
    _profileData = response.formResponse;
    _metadata = response.metadata;
    _profileImageDownloadUrl = _profileData.profileImage;
    _awaitingForm = false;
    _initialData = _profileData.toFirestore();
    notifyListeners();
  }

  void toggleEdit() {
    _pressedEdit = !_pressedEdit;
    notifyListeners();
  }

  void reinitialiseData() {
    _initialData = _profileData.toFirestore();
    notifyListeners();
  }

  void saveForm() {
    _formKey.currentState!.save();
    String? userId = currentUserId();
    if (userId != null) {
      saveProfile(_profileData, userId);
      metadata.notSubmitted = false;
      _unsavedChanges = false;
      notifyListeners();
    }
  }

  Future<void> uploadProfileImage() async {
    String? userId = currentUserId();
    TaskSnapshot taskSnapshot = await uploadImage(userId, _image!);
    _profileImageDownloadUrl = await taskSnapshot.ref.getDownloadURL();
    _profileData.profileImage = _profileImageDownloadUrl; // update form
    _changedImage = false;
  }
}
