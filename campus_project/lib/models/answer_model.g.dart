// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'answer_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AnswerImpl _$$AnswerImplFromJson(Map<String, dynamic> json) => _$AnswerImpl(
      answerId: _idToString(json['answerid']),
      userId: _idToString(json['userid']),
      questionId: _idToString(json['questionid']),
      content: json['answer'] as String,
      username: json['username'] as String,
      firstName: json['firstname'] as String?,
      lastName: json['lastname'] as String?,
      profession: json['profession'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$AnswerImplToJson(_$AnswerImpl instance) =>
    <String, dynamic>{
      'answerid': instance.answerId,
      'userid': instance.userId,
      'questionid': instance.questionId,
      'answer': instance.content,
      'username': instance.username,
      'firstname': instance.firstName,
      'lastname': instance.lastName,
      'profession': instance.profession,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
