import 'package:freezed_annotation/freezed_annotation.dart';

part 'nothing.freezed.dart';
part 'nothing.g.dart';

@freezed
abstract class Nothing with _$Nothing {
  const factory Nothing() = _Nothing;

  factory Nothing.fromJson(Map<String, dynamic> json) =>
      _$NothingFromJson(json);
}

const nothing = Nothing();
