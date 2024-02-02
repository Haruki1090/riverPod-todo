import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

///StateProvider
final todoListProvider = StateProvider((ref) => <TodoList>[]);

///Todoのクラス
class TodoList {
  final String title;
  bool isDone;

  TodoList({
    required this.title,
    this.isDone = false,
  });

  TodoList copyWith({String? title, bool? isDone}) => TodoList(
    title: title ?? 'タイトルなし',
    isDone: isDone ?? false,
  );

}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(title: 'Riverpod Todo'),
    );
  }
}

class MyHomePage extends ConsumerWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final editedControllerValue = TextEditingController();
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todoList = ref.watch(todoListProvider);

    void add() {
      ///追加ボタンを押したときの処理
      ref.read(todoListProvider.notifier).update((state) {
        ///新しいTodoを作成
        var newTodo = TodoList(
          title: editedControllerValue.text,
          isDone: false,
        );
        ///Stateを更新
        var newState = List<TodoList>.from(state);
        ///同じタイトルのTodoがあれば上書き、なければ追加
        var index = newState.indexWhere((todo) => todo.title == newTodo.title);
        if (index != -1) {
          newState[index] = newState[index].copyWith(title: newTodo.title ,isDone: newTodo.isDone);
        } else {
          ///indexが-1であれば、同じタイトルのTodoがないということ -> 追加
          newState.add(newTodo);
        }
        ///Stateを更新
        return newState;
      });

      editedControllerValue.clear();
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      decoration: const InputDecoration(
                        hintText: 'ToDoを入力してください',
                      ),
                      controller: editedControllerValue,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 5,),
            ElevatedButton(
              onPressed: () {
                add();
              },
              child: const Text('追加'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: todoList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    ///リストの左側にチェックボックスを追加
                    leading: Checkbox(
                      value: todoList[index].isDone,
                      onChanged: (bool? value) {
                        ref.read(todoListProvider.notifier).update((state) {
                          var newState = List<TodoList>.from(state);
                          newState[index].isDone = value!;
                          return newState;
                        });
                      },
                    ),
                    title: Text(todoList[index].title),
                    ///リストの右側に削除ボタンを追加
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        ref.read(todoListProvider.notifier).update((state) {
                          var newState = List<TodoList>.from(state);
                          newState.removeAt(index);
                          return newState;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
