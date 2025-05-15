import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserModel extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? photoUrl;
  final List<String> favoriteBooks;
  final Map<String, int> readingProgress;
  final bool isGuest;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.isGuest = false,
    this.photoUrl,
    this.favoriteBooks = const [],
    this.readingProgress = const {},
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      photoUrl: data['photoUrl'],
      favoriteBooks: List<String>.from(data['favoriteBooks'] ?? []),
      readingProgress: Map<String, int>.from(data['readingProgress'] ?? {}),
      isGuest: data['isGuest'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'favoriteBooks': favoriteBooks,
      'readingProgress': readingProgress,
      'isGuest': isGuest,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  static UserModel fromFirebaseUser(User user) {
    return UserModel(
      id: user.uid,
      email: user.email ?? 'unknown@example.com',
      name: user.displayName ?? 'Unknown User',
      photoUrl: user.photoURL,
      isGuest: false,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        photoUrl,
        favoriteBooks,
        readingProgress,
        isGuest,
        createdAt,
        updatedAt,
      ];
}