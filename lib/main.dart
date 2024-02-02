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
final todoListProvider = StateProvider((ref) => <Todo>[]);

///Todoのクラス
class Todo {
  final String title;
  bool isDone;

  Todo({
    required this.title,
    this.isDone = false,
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      ref.watch(todoListProvider.notifier).update((state) {
        var newTodo = Todo(
          title: editedControllerValue.text,
          isDone: false,
        );
        ///stateをコピーして新しいTodoを追加(削除ボタン用にListをコピーする必要があるため)
        var newState = List<Todo>.from(state);
        newState.add(newTodo);
        ///同様にチェックボックス用にもコピー
        var newState2 = List<Todo>.from(state);

        return newState;
      });
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
            TextFormField(
              decoration: const InputDecoration(
                hintText: 'ToDoを入力してください',
              ),
              controller: editedControllerValue,
            ),
            const SizedBox(height: 20,),
            ElevatedButton(
              onPressed: () {
                add();
                editedControllerValue.clear();
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
                          var newState = List<Todo>.from(state);
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
                          var newState = List<Todo>.from(state);
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
