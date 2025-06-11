import 'dart:convert';
import 'package:flutter/foundation.dart';

class User {
  final int? id; // Optional since it's not available during registration
  final String username;
  final String? firstName;
  final String? lastName;
  final String? profession;
  final String? email;
  final String? password;
  final int? roleId; // Added for role management
  final String? token; // Added for authentication token

  User({
    this.id,
    required this.username,
    this.firstName,
    this.lastName,
    this.profession,
    this.email,
    this.password,
    this.roleId = 2, // Default to regular user role
    this.token, // Initialize the token
  });

  // Factory constructor to create a User from a JSON map (usually returned by an API).
  factory User.fromJson(Map<String, dynamic> json) {
    debugPrint('User.fromJson received: $json'); // Debug print raw JSON
    final parsedId =
        json['userid'] != null ? int.parse(json['userid'].toString()) : null;
    debugPrint('Parsed ID: $parsedId'); // Debug print parsed ID
    return User(
      id: parsedId,
      username: json['username']?.toString() ?? '',
      firstName: json['firstname']?.toString(),
      lastName: json['lastname']?.toString(),
      profession: json['profession']?.toString(),
      email: json['email']?.toString(),
      roleId:
          json['role_id'] != null ? int.parse(json['role_id'].toString()) : 2,
      token: json['token']?.toString(), // Parse token from JSON
      // Don't include password in fromJson as it shouldn't be returned by the API
    );
  }

  // Method to convert a User object back into a JSON map (useful for sending data back to the API if needed).
  Map<String, dynamic> toJson() {
    final map = {
      'username': username,
      if (firstName != null) 'firstname': firstName,
      if (lastName != null) 'lastname': lastName,
      if (profession != null) 'profession': profession,
      if (email != null) 'email': email,
      if (password != null) 'password': password,
      'role_id': roleId ?? 2,
    };
    if (id != null)
      map['id'] = id.toString(); // Convert id to string for API consistency
    if (token != null) map['token'] = token;
    return map;
  }

  // Optional: A getter for the full name, constructed from firstName and lastName.
  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (firstName != null) {
      return firstName!;
    } else if (lastName != null) {
      return lastName!;
    } else {
      return username; // Fallback to username if no name parts are available.
    }
  }

  // Optional: A getter to check if the user is an admin
  bool get isAdmin => roleId == 1;

  // Optional: A method to create a copy of the user with some fields updated
  User copyWith({
    int? id,
    String? username,
    String? firstName,
    String? lastName,
    String? profession,
    String? email,
    String? password,
    int? roleId,
    String? token,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      profession: profession ?? this.profession,
      email: email ?? this.email,
      password: password ?? this.password,
      roleId: roleId ?? this.roleId,
      token: token ?? this.token,
    );
  }
}
