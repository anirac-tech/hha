import 'package:equatable/equatable.dart';
import 'package:starter_architecture_flutter_firebase/src/features/chat/domain/prompt.dart';

typedef ResponseID = String;

// ie AIResponse
class Response extends Equatable {
  const Response({
    required this.id,
    required this.promptId,
    required this.dateTime,
    required this.response,
  });
  final ResponseID id;
  final PromptID promptId;
  final DateTime dateTime;
  final String response;

  @override
  List<Object> get props => [id, promptId, dateTime, response];

  @override
  bool get stringify => true;

  factory Response.fromMap(Map<dynamic, dynamic> value, ResponseID id) {
    final dateTimeMilliseconds = value['dateTime'] as int;
    return Response(
      id: id,
      promptId: value['promptId'] as String,
      dateTime: DateTime.fromMillisecondsSinceEpoch(dateTimeMilliseconds),
      response: value['response'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        'promptId': promptId,
        'dateTime': dateTime.millisecondsSinceEpoch,
        'response': response,
      };
}
