import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

final FirebaseStorage _fbasestorage = FirebaseStorage.instance;

Future<TaskSnapshot> uploadImage(String? userId, Uint8List image) async {
  Reference ref = _fbasestorage.ref().child('profileImage/$userId.png');
  UploadTask uploadTask = ref.putData(image);
  TaskSnapshot taskSnapshot = await uploadTask;
  return taskSnapshot;
}

Future<Uint8List?> pickImage(ImageSource source) async {
  final ImagePicker imagePicker = ImagePicker();
  XFile? pickedFile = await imagePicker.pickImage(source: source);
  if (pickedFile != null) {
    return await pickedFile.readAsBytes();
  } else {
    print('No image selected.');
    return null;
  }
}
