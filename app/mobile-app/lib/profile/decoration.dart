import 'package:multi_dropdown/multi_dropdown.dart';
import 'package:flutter/material.dart';

var orientationField = FieldDecoration(
  labelText: 'I am attracted to',
  hintText: 'Select all that apply',
  showClearIcon: false,
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
  ),
);

const orientationDropDown = DropdownDecoration(
  marginTop: 2,
  maxHeight: 500,
  header: Padding(
    padding: EdgeInsets.all(8),
    child: Text(
      'I am attracted to',
      textAlign: TextAlign.start,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
);
