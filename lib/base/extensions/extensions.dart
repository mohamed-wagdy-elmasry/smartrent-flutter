import 'package:flutter/material.dart';
import 'package:get/get.dart';

extension SupperRoute on String {
  get toNamed => Get.toNamed(this);
  get offAllNamed => Get.offAllNamed(this);
  get offNamed => Get.offNamed(this);
}

extension SupperEdgeInsets on dynamic {
  // EdgeInsets
  get edgeHorizontal => EdgeInsets.symmetric(horizontal: this);
  get edgeVertical => EdgeInsets.symmetric(vertical: this);
  get edgeTop => EdgeInsets.only(top: this);
  get edgeBottom => EdgeInsets.only(bottom: this);
  get edgeLeft => EdgeInsets.only(left: this);
  get edgeRight => EdgeInsets.only(right: this);

  /// Radius
  get radiusEx => BorderRadius.circular(this);
  get radiusTopEx => BorderRadius.only(
    topLeft: Radius.circular(this),
    topRight: Radius.circular(this),
  );
}

String maskString(String input, int numCharsToMask) {
  if (input.length <= numCharsToMask) {
    return '*' * input.length;
  }

  String maskedPart = '';
  int count = 0;

  for (int i = 0; i < input.length; i++) {
    if (input[i] == ' ' || input[i] == '/') {
      maskedPart += input[i];
    } else if (count < numCharsToMask) {
      maskedPart += '*';
      count++;
    } else {
      maskedPart += input[i];
    }
  }

  return maskedPart;
}

String addSpacesEveryFourChars(String input) {
  StringBuffer buffer = StringBuffer();
  for (int i = 0; i < input.length; i++) {
    if (i > 0 && i % 4 == 0) {
      buffer.write(' ');
    }
    buffer.write(input[i]);
  }
  return buffer.toString();
}
