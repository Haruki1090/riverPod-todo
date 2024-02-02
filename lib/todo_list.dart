import 'package:freezed_annotation/freezed_annotation.dart';
part 'todo_list.freezed.dart';

@freezed
class TodoList with _$TodoList {
  const factory TodoList({
    required String title, ///タイトル
    required bool isDone, ///完了フラグ
  }) = _TodoList;
}
