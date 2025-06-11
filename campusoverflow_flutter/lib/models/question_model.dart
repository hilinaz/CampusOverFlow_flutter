class Question {
  final String questionId;
  final String title;
  final String description;
  final String username;
  final String? tag;
  final String? profession;
  final String? firstName;
  final String? lastName;
  final String userId;

  Question({
    required this.questionId,
    required this.title,
    required this.description,
    required this.username,
    this.tag,
    this.profession,
    this.firstName,
    this.lastName,
    required this.userId,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      questionId: json['questionid'],
      title: json['title'],
      description: json['description'],
      username: json['username'],
      tag: json['tag'],
      profession: json['profession'],
      firstName: json['firstname'],
      lastName: json['lastname'],
      userId: json['userid'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'tag': tag,
      'profession': profession,
    };
  }
}
