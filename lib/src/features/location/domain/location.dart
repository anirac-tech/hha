import 'package:equatable/equatable.dart';
import 'package:starter_architecture_flutter_firebase/src/features/authentication/domain/app_user.dart';

// TODO: Freezed not equatable
class Location extends Equatable {
  const Location(
      {required this.userId, required this.dateTime, required this.name, required this.source});

  /*
  dateTime
1722684120000
(number)

latLng
"32.9654, -96.8921"
(string)

name
"Joe"
(string)

source
"pretendAppOpen"
(string)

userId
"3jb4MA25q8Sly85pxwhLecW679f2"
   */
  // for now userid functions as locationid bc table is only storing latest location
  final UserID userId;
  final DateTime dateTime;
  final String name;

  final String source;

  @override
  List<Object> get props => [userId, name, dateTime, source];

  @override
  bool get stringify => true;

  factory Location.fromMap(Map<dynamic, dynamic> value) {
    final dateTimeMilliseconds = value['dateTime'] as int;
    return Location(
      userId: value['userId'] as String,
      name: value['promptId'] as String? ?? '',
      dateTime: DateTime.fromMillisecondsSinceEpoch(dateTimeMilliseconds),
      source: value['response'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        'userId': userId,
        'dateTime': dateTime.millisecondsSinceEpoch,
        'name': name,
        'source': source
      };
}
