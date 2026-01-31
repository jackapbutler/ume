import 'dart:typed_data';

import 'package:app/profile/form.dart';
import 'package:app/utils/analytics.dart';
import 'package:app/utils/user.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import 'package:provider/provider.dart';
import 'package:app/profile/state.dart';
import 'package:app/profile/decoration.dart';
import 'package:app/utils/snack.dart';
import 'package:app/utils/location.dart';
import 'package:image_picker/image_picker.dart';
import 'package:app/utils/image.dart';

const List<String> genders = ["Male", "Female", "Non-Binary"];

List<DropdownMenuItem<String>> makeGenderDropdown() {
  return genders.map((String category) {
    return DropdownMenuItem(
      value: category,
      child: Row(
        children: <Widget>[Text(category)],
      ),
    );
  }).toList();
}

List<DropdownItem<String>> makeOrientationItems(List<String>? orientation) {
  return genders
      .map((g) => DropdownItem(
            label: g,
            value: g,
            selected: orientation?.contains(g) ?? false,
            disabled: false,
          ))
      .toList();
}

class FormBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ProfileState pState = context.watch<ProfileState>();
    if (pState.awaitingForm) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return _buildForm(context, pState);
    }
  }

  Widget _buildForm(BuildContext context, ProfileState pState) {
    final dobController = TextEditingController(text: pState.pData.dob ?? '');
    final minAgeController =
        TextEditingController(text: pState.pData.ageRange[0].toString());
    final maxAgeController =
        TextEditingController(text: pState.pData.ageRange[1].toString());

    final itemsWithSelection = makeOrientationItems(pState.pData.orientation);
    final msController = MultiSelectController<String>();

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Form(
                  key: pState.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          PopupMenuButton<int>(
                            icon: Icon(Icons.settings),
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 1,
                                child: Text('Sign Out'),
                              ),
                              PopupMenuItem(
                                value: 2,
                                child: Text('Delete Account'),
                              ),
                            ],
                            onSelected: (value) async {
                              if (value == 1) {
                                await signOut(context);
                              } else if (value == 2) {
                                await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Confirm Deletion'),
                                      content: Text(
                                        'Are you sure you want to delete your account? This cannot be undone.',
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(false);
                                          },
                                          child: Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            deleteUser(context);
                                            Navigator.of(context).pop(true);
                                          },
                                          child: Text('Delete'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            },
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                      ),
                      Center(
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 64,
                              backgroundImage: pState.image,
                            ),
                            Positioned(
                              bottom: -5,
                              left: 80,
                              child: IconButton(
                                icon: Icon(Icons.add_a_photo),
                                onPressed: () async {
                                  if (!pState.allowingInput) {
                                    return;
                                  } else {
                                    Uint8List? img =
                                        await pickImage(ImageSource.gallery);
                                    if (img != null) {
                                      pState.setImage(img);
                                      pState.markAsChanged();
                                    }
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TextFormField(
                        initialValue: pState.pData.name,
                        readOnly: !pState.allowingInput,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          hintText: 'Enter your name',
                          contentPadding: EdgeInsets.all(10),
                          border: OutlineInputBorder(),
                          enabled: pState.allowingInput,
                        ),
                        onChanged: (value) {
                          pState.pData.name = value;
                          pState.markAsChanged();
                        },
                      ),
                      const SizedBox(height: 20),
                      IntlPhoneField(
                        // add initial values, ok if null
                        initialValue: pState.pData.phoneNumber?.number,
                        initialCountryCode:
                            pState.pData.phoneNumber?.countryISOCode,
                        enabled: pState.allowingInput,
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          hintText: 'Enter your phone number',
                          contentPadding: EdgeInsets.all(10),
                          border: OutlineInputBorder(),
                          enabled: pState.allowingInput,
                        ),
                        onChanged: (value) {
                          pState.pData.phoneNumber = value;
                          pState.markAsChanged();
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: dobController,
                        readOnly: !pState.allowingInput,
                        keyboardType: TextInputType.none, // Disable keyboard
                        decoration: InputDecoration(
                          labelText: 'Date of Birth',
                          hintText: 'Enter your date of birth',
                          contentPadding: EdgeInsets.all(10),
                          border: OutlineInputBorder(),
                          enabled: pState.allowingInput,
                        ),
                        onTap: () async {
                          if (pState.allowingInput) {
                            DateTime? initialDate = pState.pData.dob != null
                                ? DateFormat('dd/MM/yyyy')
                                    .parse(pState.pData.dob!)
                                : DateTime.now();

                            DateTime? selectedDate = await showDatePicker(
                              context: context,
                              initialDate: initialDate,
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                              builder: (BuildContext context, Widget? child) {
                                return Theme(
                                  data: ThemeData.light().copyWith(
                                    primaryColor:
                                        Theme.of(context).colorScheme.primary,
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
                              pState.pData.dob = fmtDate;
                              dobController.text = fmtDate;
                              pState.markAsChanged();
                            }
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField(
                        items: makeGenderDropdown(),
                        value: pState.pData.gender,
                        decoration: InputDecoration(
                          labelText: 'I am',
                          hintText: 'Enter your gender',
                          contentPadding: EdgeInsets.all(10),
                          border: OutlineInputBorder(),
                          enabled: pState.allowingInput,
                        ),
                        onChanged: pState.allowingInput
                            ? (value) {
                                pState.pData.gender = value as String?;
                                pState.markAsChanged();
                              }
                            : null,
                      ),
                      const SizedBox(height: 5),
                      CheckboxListTile(
                        title: Text(
                          pState.locationAllowed
                              ? 'Location: ${pState.pData.location?.name ?? 'Unknown'}'
                              : 'Share Location',
                          style: TextStyle(fontSize: 16),
                        ),
                        value: pState.locationAllowed,
                        onChanged: pState.allowingInput
                            ? (bool? checked) async {
                                if (checked == true) {
                                  try {
                                    Position position =
                                        await determinePosition();
                                    final placeName = await getPlaceName(
                                      position.latitude,
                                      position.longitude,
                                    );
                                    pState.pData.location = Location(
                                      position.latitude,
                                      position.longitude,
                                      true,
                                      placeName,
                                    );
                                    pState.markAsChanged();
                                  } catch (e) {
                                    // ignore: use_build_context_synchronously
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Unable to fetch location: $e',
                                        ),
                                      ),
                                    );
                                  }
                                } else {
                                  pState.pData.location = null;
                                  pState.markAsChanged();
                                }
                              }
                            : null,
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      const SizedBox(height: 5),
                      ExpansionTile(
                        title: Text(
                          'Preferences',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        children: <Widget>[
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Minimum Age Incrementer
                              Flexible(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.remove),
                                      onPressed: pState.allowingInput
                                          ? () {
                                              pState.decreaseAgeGap(0);
                                              pState.markAsChanged();
                                            }
                                          : null,
                                    ),
                                    Expanded(
                                      child: TextFormField(
                                        textAlign: TextAlign.center,
                                        controller: minAgeController,
                                        keyboardType: TextInputType.number,
                                        readOnly: !pState.allowingInput,
                                        decoration: InputDecoration(
                                          labelText: 'Min Age',
                                          border: OutlineInputBorder(),
                                          enabled: pState.allowingInput,
                                          contentPadding: EdgeInsets.all(10),
                                        ),
                                        style: TextStyle(fontSize: 16),
                                        onFieldSubmitted: (value) {
                                          final int intVal = int.parse(value);
                                          pState.updateAgeRange(0, intVal);
                                          pState.markAsChanged();
                                        },
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.add),
                                      onPressed: pState.allowingInput
                                          ? () {
                                              pState.increaseAgeGap(0);
                                              pState.markAsChanged();
                                            }
                                          : null,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Maximum Age Incrementer
                              Flexible(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.remove),
                                      onPressed: pState.allowingInput
                                          ? () {
                                              pState.decreaseAgeGap(1);
                                              pState.markAsChanged();
                                            }
                                          : null,
                                    ),
                                    Expanded(
                                      child: TextFormField(
                                        textAlign: TextAlign.center,
                                        controller: maxAgeController,
                                        keyboardType: TextInputType.number,
                                        readOnly: !pState.allowingInput,
                                        decoration: InputDecoration(
                                          labelText: 'Max Age',
                                          border: OutlineInputBorder(),
                                          enabled: pState.allowingInput,
                                          contentPadding: EdgeInsets.all(10),
                                        ),
                                        style: TextStyle(fontSize: 16),
                                        onFieldSubmitted: (value) {
                                          final int intVal = int.parse(value);
                                          pState.updateAgeRange(1, intVal);
                                          pState.markAsChanged();
                                        },
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.add),
                                      onPressed: pState.allowingInput
                                          ? () {
                                              pState.increaseAgeGap(1);
                                              pState.markAsChanged();
                                            }
                                          : null,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          AbsorbPointer(
                            absorbing: !pState.allowingInput,
                            child: MultiDropdown<String>(
                              items: itemsWithSelection,
                              controller: msController,
                              enabled: pState.allowingInput,
                              searchEnabled: false,
                              chipDecoration: ChipDecoration(
                                deleteIcon: Icon(
                                  Icons.close,
                                  size: 16,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                labelStyle: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
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
                              onSelectionChange: (selectedItems) {
                                pState.pData.orientation = selectedItems;
                                pState.markAsChanged();
                                msController.closeDropdown();
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Distance Range (Km)',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Slider(
                                value: pState.pData.distanceRangeKm != null
                                    ? pState.pData.distanceRangeKm!.toDouble()
                                    : 10000.0,
                                min: 1.0,
                                max: 10000.0,
                                divisions: 99,
                                label: "${pState.pData.distanceRangeKm} Km",
                                onChanged: pState.allowingInput
                                    ? (double newValue) {
                                        pState.pData.distanceRangeKm =
                                            newValue.toInt();
                                        pState.markAsChanged();
                                      }
                                    : null,
                              ),
                            ],
                          )
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: FractionallySizedBox(
                          widthFactor: 0.5,
                          child: ElevatedButton(
                            onPressed: pState.unsavedChanges
                                ? () async {
                                    if (pState.validForm) {
                                      if (pState.pressedEdit) {
                                        pState.toggleEdit();
                                      }
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        CustomSnackBar(
                                          context: context,
                                          content: Text('Saving ...'),
                                        ),
                                      );
                                      if (pState.changedImage) {
                                        await pState.uploadProfileImage();
                                      }
                                      pState.saveForm();
                                      pState.reinitialiseData();
                                      pState.toggleEdit();
                                      logUserEvent('try_profile_update');
                                    }
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              foregroundColor: pState.unsavedChanges
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.secondary,
                            ),
                            child: const Text('Save'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FormBody(),
    );
  }
}
