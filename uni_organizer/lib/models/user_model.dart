class UserProfile {
  final String uid;
  final String name;
  final String email;
  final String major;
  final String group;
  final String? photoUrl;

  UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    this.major = '',
    this.group = '',
    this.photoUrl,
  });

  factory UserProfile.fromMap(Map<String, dynamic> data, String uid) {
    return UserProfile(
      uid: uid,
      name: data['name'] ?? 'Student',
      email: data['email'] ?? '',
      major: data['major'] ?? '',
      group: data['group'] ?? '',
      photoUrl: data['photoUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'major': major,
      'group': group,
      'photoUrl': photoUrl,
    };
  }

  UserProfile copyWith({
    String? name,
    String? email,
    String? major,
    String? group,
    String? photoUrl,
  }) {
    return UserProfile(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      major: major ?? this.major,
      group: group ?? this.group,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}