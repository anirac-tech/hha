import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

typedef PromptID = String;

// TOD: Freezed
@immutable
class Prompt extends Equatable {
  const Prompt({required this.id, required this.text});
  final PromptID id;
  final String text;

  @override
  List<Object> get props => [text];

  @override
  bool get stringify => true;

  factory Prompt.fromMap(Map<String, dynamic> data, String id) => Prompt(
        id: id,
        text: data['text'] as String,
      );

  Map<String, dynamic> toMap() => {
        'text': text,
      };
}
