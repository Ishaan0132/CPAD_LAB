import 'dart:html';
import 'dart:convert';

class Task {
  String title;
  bool completed;

  Task(
    this.title, {
    this.completed = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'completed': completed,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      json['title'] as String,
      completed: json['completed'] as bool,
    );
  }
}

void main() {
  // ============================================================
  // DOM ELEMENTS
  // ============================================================

  final taskInput =
      querySelector('#taskInput') as InputElement;

  final addButton =
      querySelector('#addButton') as ButtonElement;

  final taskList =
      querySelector('#taskList') as UListElement;

  final remainingCount =
      querySelector('#remainingCount') as Element;

  final taskSummary =
      querySelector('#taskSummary') as Element;

  final emptyState =
      querySelector('#emptyState') as Element;

  final emptyTitle =
      querySelector('#emptyTitle') as Element;

  final emptyText =
      querySelector('#emptyText') as Element;

  final clearCompleted =
      querySelector('#clearCompleted') as ButtonElement;

  final filterButtons =
      querySelectorAll('.filter');

  // ============================================================
  // APPLICATION DATA
  // ============================================================

  List<Task> tasks = [];

  String currentFilter = 'all';

  // This will be assigned below.
  late void Function() renderTasks;

  // ============================================================
  // LOAD TASKS FROM LOCAL STORAGE
  // ============================================================

  final savedTasks =
      window.localStorage['dart_tasks'];

  if (savedTasks != null) {
    try {
      final decoded = jsonDecode(savedTasks);

      tasks = (decoded as List)
          .map(
            (item) => Task.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    } catch (error) {
      tasks = [];
    }
  }

  // ============================================================
  // SAVE TASKS
  // ============================================================

  void saveTasks() {
    final encoded = jsonEncode(
      tasks
          .map((task) => task.toJson())
          .toList(),
    );

    window.localStorage['dart_tasks'] = encoded;
  }

  // ============================================================
  // UPDATE STATISTICS
  // ============================================================

  void updateStatistics() {
    final remaining = tasks
        .where((task) => !task.completed)
        .length;

    final completed = tasks
        .where((task) => task.completed)
        .length;

    remainingCount.text =
        remaining.toString();

    if (tasks.isEmpty) {
      taskSummary.text = '0 tasks';
    } else {
      taskSummary.text =
          '${tasks.length} tasks • $completed completed';
    }
  }

  // ============================================================
  // CREATE TASK DOM ELEMENT
  // ============================================================

  LIElement createTaskElement(
    Task task,
    int index,
  ) {
    final listItem = LIElement()
      ..classes.add('task');

    // Add completed class if necessary.
    if (task.completed) {
      listItem.classes.add('completed');
    }

    // ----------------------------------------------------------
    // CHECKBOX
    // ----------------------------------------------------------

    final checkbox = DivElement()
      ..classes.add('task-checkbox');

    checkbox.text =
        task.completed ? '✓' : '';

    // ----------------------------------------------------------
    // TASK TEXT
    // ----------------------------------------------------------

    final text = SpanElement()
      ..classes.add('task-text')
      ..text = task.title;

    // ----------------------------------------------------------
    // DELETE BUTTON
    // ----------------------------------------------------------

    final deleteButton = ButtonElement()
      ..classes.add('delete-button')
      ..text = '×'
      ..title = 'Delete task';

    // ----------------------------------------------------------
    // ADD CHILDREN TO TASK
    // ----------------------------------------------------------

    listItem.children.add(checkbox);
    listItem.children.add(text);
    listItem.children.add(deleteButton);

    // ==========================================================
    // TOGGLE TASK
    // ==========================================================

    checkbox.onClick.listen((event) {
      task.completed = !task.completed;

      saveTasks();

      renderTasks();
    });

    // ==========================================================
    // DELETE TASK
    // ==========================================================

    deleteButton.onClick.listen((event) {
      tasks.removeAt(index);

      saveTasks();

      renderTasks();
    });

    return listItem;
  }

  // ============================================================
  // RENDER TASKS
  // ============================================================

  renderTasks = () {
    // Remove all currently displayed tasks.
    taskList.children.clear();

    List<Task> filteredTasks;

    // ----------------------------------------------------------
    // APPLY FILTER
    // ----------------------------------------------------------

    switch (currentFilter) {
      case 'active':
        filteredTasks = tasks
            .where((task) => !task.completed)
            .toList();
        break;

      case 'completed':
        filteredTasks = tasks
            .where((task) => task.completed)
            .toList();
        break;

      default:
        filteredTasks = List<Task>.from(tasks);
    }

    // ----------------------------------------------------------
    // DISPLAY FILTERED TASKS
    // ----------------------------------------------------------

    for (final task in filteredTasks) {
      final originalIndex =
          tasks.indexOf(task);

      taskList.children.add(
        createTaskElement(
          task,
          originalIndex,
        ),
      );
    }

    // ----------------------------------------------------------
    // EMPTY STATE
    // ----------------------------------------------------------

    if (filteredTasks.isEmpty) {
      emptyState.style.display = 'block';

      if (tasks.isEmpty) {
        emptyTitle.text = 'No tasks yet';

        emptyText.text =
            'Add your first task above to get started.';
      } else if (currentFilter == 'active') {
        emptyTitle.text = 'All caught up!';

        emptyText.text =
            'You have completed all your tasks.';
      } else if (currentFilter == 'completed') {
        emptyTitle.text =
            'No completed tasks';

        emptyText.text =
            'Complete a task and it will appear here.';
      }
    } else {
      emptyState.style.display = 'none';
    }

    // Update counters.
    updateStatistics();
  };

  // ============================================================
  // ADD TASK
  // ============================================================

  void addTask() {
    final title =
        taskInput.value?.trim() ?? '';

    // Don't allow empty tasks.
    if (title.isEmpty) {
      taskInput.focus();
      return;
    }

    // Create a new task.
    tasks.add(
      Task(title),
    );

    // Clear input.
    taskInput.value = '';

    // Save to local storage.
    saveTasks();

    // Update the DOM.
    renderTasks();

    // Put cursor back into input.
    taskInput.focus();
  }

  // ============================================================
  // ADD BUTTON EVENT
  // ============================================================

  addButton.onClick.listen((event) {
    addTask();
  });

  // ============================================================
  // ENTER KEY EVENT
  // ============================================================

  taskInput.onKeyDown.listen((event) {
    if (event.key == 'Enter') {
      addTask();
    }
  });

  // ============================================================
  // FILTER BUTTON EVENTS
  // ============================================================

  for (final button in filterButtons) {
    button.onClick.listen((event) {
      currentFilter =
          button.attributes['data-filter'] ?? 'all';

      // Remove active class from all filters.
      for (final filter in filterButtons) {
        filter.classes.remove('active');
      }

      // Add active class to selected filter.
      button.classes.add('active');

      // Re-render tasks.
      renderTasks();
    });
  }

  // ============================================================
  // CLEAR COMPLETED TASKS
  // ============================================================

  clearCompleted.onClick.listen((event) {
    tasks.removeWhere(
      (task) => task.completed,
    );

    saveTasks();

    renderTasks();
  });

  // ============================================================
  // INITIAL RENDER
  // ============================================================

  renderTasks();
}
