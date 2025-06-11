import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart'; // Keep this import!

part 'answer_model.freezed.dart';
part 'answer_model.g.dart';

// IMPORTANT: DO NOT put @JsonSerializable() here.
// @JsonSerializable(explicitToJson: true) <-- REMOVE THIS LINE IF IT'S PRESENT HERE
@freezed
class Answer with _$Answer {
  // Freezed will automatically apply JsonSerializable functionality when
  // the factory .fromJson is present and json_serializable is in dev_dependencies.
  const factory Answer({
    @JsonKey(name: 'answerid', fromJson: _idToString) required String answerId,
    @JsonKey(name: 'userid', fromJson: _idToString) required String userId,
    @JsonKey(name: 'questionid', fromJson: _idToString)
    required String questionId,
    @JsonKey(name: 'answer') required String content,
    required String username,
    @JsonKey(name: 'firstname') String? firstName,
    @JsonKey(name: 'lastname') String? lastName,
    required String? profession,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Answer; // This defines the concrete implementation class as _Answer

  // This factory constructor is crucial. It tells json_serializable what to generate.
  factory Answer.fromJson(Map<String, dynamic> json) => _$AnswerFromJson(json);
}

String _idToString(dynamic id) => id.toString();
