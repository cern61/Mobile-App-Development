// ignore_for_file: avoid_print
// ============================================================
//  🏫 SCHOOL MANAGEMENT SYSTEM  -  Dart OOP Homework
//  Concepts: Functions, Classes, Inheritance, Polymorphism,
//            Encapsulation (+ Abstraction)
//  Run with:  dart run school_system.dart
// ============================================================

import 'dart:io';
import 'dart:math';

// ------------------------------------------------------------
//  🎨 UI HELPERS (colors, banner, input, animations)
// ------------------------------------------------------------
class Ui {
  static const reset = '\x1B[0m',
      bold = '\x1B[1m',
      red = '\x1B[31m',
      green = '\x1B[32m',
      yellow = '\x1B[33m',
      blue = '\x1B[34m',
      magenta = '\x1B[35m',
      cyan = '\x1B[36m',
      gray = '\x1B[90m';

  static String paint(String text, String color) => '$color$text$reset';

  static void clear() => stdout.write('\x1B[2J\x1B[H');

  static void say(String message, {String color = cyan}) =>
      print(paint(message, color));

  static String ask(String question) {
    stdout.write(paint('  ➜ $question ', yellow));
    return (stdin.readLineSync() ?? '').trim();
  }

  static void pause() {
    stdout.write(paint('\n  Press ENTER to continue...', gray));
    stdin.readLineSync();
  }

  static void banner() {
    print(paint('╔══════════════════════════════════════════════╗', blue));
    print(paint('║', blue) +
        paint('        🏫  SCHOOL MANAGEMENT SYSTEM  🏫       ', bold + cyan) +
        paint('║', blue));
    print(paint('║', blue) +
        paint('            Dart  •  OOP  •  Homework         ', gray) +
        paint('║', blue));
    print(paint('╚══════════════════════════════════════════════╝', blue));
  }

  /// Animated progress bar.
  static void progress(String label, {int ms = 35}) {
    print('  ${paint(label, magenta)}');
    stdout.write('  [');
    for (var i = 0; i < 24; i++) {
      stdout.write(paint('█', green));
      sleep(Duration(milliseconds: ms));
    }
    print('] ${paint('100%', green)}');
  }

  /// Generic numbered picker: returns the chosen item or null.
  static T? pick<T>(String title, List<T> items, String Function(T) label) {
    if (items.isEmpty) {
      say('  Nothing to choose from yet. Add some data first!', color: yellow);
      return null;
    }
    print(paint('\n  $title', bold));
    for (var i = 0; i < items.length; i++) {
      print('   ${paint('${i + 1}', cyan)}) ${label(items[i])}');
    }
    final n = int.tryParse(ask('Your choice (number):'));
    if (n == null || n < 1 || n > items.length) {
      say('  ✘ Invalid choice.', color: red);
      return null;
    }
    return items[n - 1];
  }
}

// ------------------------------------------------------------
//  ❓ QUESTION BANK  (used by teachers to build exams)
// ------------------------------------------------------------
class Question {
  final String text;
  final List<String> options;
  final int answer; // index of the correct option

  const Question(this.text, this.options, this.answer);
}

class QuestionBank {
  static final Map<String, List<Question>> _bank = {
    'Dart': [
      const Question('Which keyword creates a compile-time constant?',
          ['final', 'const', 'var', 'static'], 1),
      const Question('Which function is the entry point of a Dart program?',
          ['start()', 'run()', 'main()', 'init()'], 2),
      const Question('What does the "?" mean in the type String? ?',
          ['It is a list', 'It is private', 'It is nullable', 'It is final'], 2),
      const Question('Which collection stores only UNIQUE items?',
          ['List', 'Set', 'Map', 'Queue'], 1),
      const Question('Which keyword waits for a Future to complete?',
          ['yield', 'async', 'then', 'await'], 3),
    ],
    'OOP': [
      const Question('Hiding data behind getters/setters is called...',
          ['Inheritance', 'Polymorphism', 'Encapsulation', 'Recursion'], 2),
      const Question('Which keyword lets a class inherit from another class?',
          ['implements', 'extends', 'with', 'import'], 1),
      const Question(
          'Same method name, different behavior depending on the object?',
          ['Polymorphism', 'Abstraction', 'Overflow', 'Casting'], 0),
      const Question('How do you make a member private in Dart?',
          ['private keyword', 'Prefix with _', 'Prefix with \$', 'Use hidden'], 1),
      const Question('A class that CANNOT be instantiated directly is...',
          ['final class', 'static class', 'abstract class', 'mixin class'], 2),
    ],
  };

  static List<String> get branches => _bank.keys.toList();

  /// Returns a shuffled copy so every exam feels fresh.
  static List<Question> forBranch(String branch) {
    final list = List<Question>.from(_bank[branch]!);
    list.shuffle(Random());
    return list;
  }
}

// ------------------------------------------------------------
//  📝 EXAM + RESULT
// ------------------------------------------------------------
class Exam {
  static int _counter = 0;

  final int id;
  final String subject;
  final Teacher teacher;
  final List<Question> questions;
  final List<ExamResult> results = [];

  Exam(this.subject, this.teacher, this.questions) : id = ++_counter;

  String get title => 'Exam #$id • $subject • by ${teacher.name}';
}

class ExamResult {
  final Student student;
  final Exam exam;
  final int correct;
  final int total;
  final int bonus;

  ExamResult(this.student, this.exam, this.correct, this.total, this.bonus);

  int get score => min(100, (correct / total * 90).round() + bonus);

  String get grade {
    if (score >= 90) return 'A';
    if (score >= 80) return 'B';
    if (score >= 70) return 'C';
    if (score >= 60) return 'D';
    return 'F';
  }
}

// ------------------------------------------------------------
//  🧍 PERSON  (abstract base class)
//  -> ENCAPSULATION: _name is private, accessed via getter/setter
//  -> ABSTRACTION  : study() is abstract, subclasses must implement it
// ------------------------------------------------------------
abstract class Person {
  static int _counter = 0;

  final int id;
  String _name = ''; // private field (encapsulation)

  Person(String name) : id = ++_counter {
    this.name = name; // goes through the validating setter
  }

  String get name => _name;

  set name(String value) {
    if (value.trim().length < 2) {
      throw ArgumentError('Name must have at least 2 characters.');
    }
    _name = value.trim();
  }

  String get role;
  String get emoji;

  /// Abstract method -> every subclass gives its own behavior (polymorphism).
  void study(String topic);

  String describe() => '$emoji ${Ui.paint(role, Ui.bold)} #$id — $_name';

  @override
  String toString() => describe();
}

// ------------------------------------------------------------
//  👩‍🏫 TEACHER  (inherits Person)
// ------------------------------------------------------------
class Teacher extends Person {
  final String branch;
  final List<Exam> _givenExams = []; // private list

  Teacher(super.name, this.branch);

  @override
  String get role => 'Teacher';

  @override
  String get emoji => '👩‍🏫';

  List<Exam> get givenExams => List.unmodifiable(_givenExams);

  /// POLYMORPHISM: a teacher "studies" to prepare a lecture.
  @override
  void study(String topic) {
    Ui.say('\n  $emoji $name is preparing a lecture about "$topic"...',
        color: Ui.magenta);
    Ui.progress('Preparing slides & examples');
    Ui.say('  ✔ Lecture ready! $name starts teaching "$topic" to the class.',
        color: Ui.green);
  }

  /// Teacher creates an exam from his/her own branch.
  Exam giveExam() {
    final exam = Exam(branch, this, QuestionBank.forBranch(branch));
    _givenExams.add(exam);
    Ui.say('\n  $emoji $name created a new exam:', color: Ui.magenta);
    Ui.say('     ${exam.title}  (${exam.questions.length} questions)',
        color: Ui.green);
    return exam;
  }
}

// ------------------------------------------------------------
//  🎓 STUDENT  (inherits Person)
// ------------------------------------------------------------
class Student extends Person {
  final Map<String, int> _studySessions = {}; // subject -> sessions
  final List<ExamResult> _results = [];

  Student(super.name);

  @override
  String get role => 'Student';

  @override
  String get emoji => '🎓';

  List<ExamResult> get results => List.unmodifiable(_results);

  double get average => _results.isEmpty
      ? 0
      : _results.map((r) => r.score).reduce((a, b) => a + b) / _results.length;

  int sessionsFor(String subject) => _studySessions[subject] ?? 0;

  /// Each study session = +2 bonus points on exams (max +10).
  int bonusFor(String subject) => min(sessionsFor(subject) * 2, 10);

  bool hasTaken(Exam exam) => _results.any((r) => r.exam.id == exam.id);

  /// POLYMORPHISM: a student studies to learn (different from teacher).
  @override
  void study(String topic) {
    _studySessions[topic] = sessionsFor(topic) + 1;
    Ui.say('\n  $emoji $name is studying "$topic"...', color: Ui.magenta);
    Ui.progress('Reading notes & solving examples');
    Ui.say(
        '  ✔ Study session #${sessionsFor(topic)} done! '
        'Exam bonus for $topic: +${bonusFor(topic)}',
        color: Ui.green);
  }

  /// Interactive exam: the student answers every question.
  ExamResult takeExam(Exam exam) {
    Ui.say('\n  $emoji $name starts: ${exam.title}', color: Ui.magenta);
    var correct = 0;

    for (var i = 0; i < exam.questions.length; i++) {
      final q = exam.questions[i];
      print('\n  ${Ui.paint('Question ${i + 1}/${exam.questions.length}', Ui.magenta)}'
          '  ${Ui.paint(q.text, Ui.bold)}');
      for (var j = 0; j < q.options.length; j++) {
        print('     ${Ui.paint(String.fromCharCode(65 + j), Ui.cyan)}) ${q.options[j]}');
      }
      final picked = _askLetter(q.options.length);
      if (picked == q.answer) {
        correct++;
        Ui.say('  ✔ Correct!', color: Ui.green);
      } else {
        Ui.say(
            '  ✘ Wrong. Correct answer: '
            '${String.fromCharCode(65 + q.answer)}) ${q.options[q.answer]}',
            color: Ui.red);
      }
    }

    final result = ExamResult(
        this, exam, correct, exam.questions.length, bonusFor(exam.subject));
    _results.add(result);
    exam.results.add(result);
    return result;
  }

  int _askLetter(int count) {
    while (true) {
      final s = Ui.ask(
              'Your answer (A-${String.fromCharCode(64 + count)}):')
          .toUpperCase();
      if (s.length == 1) {
        final i = s.codeUnitAt(0) - 65;
        if (i >= 0 && i < count) return i;
      }
      Ui.say('  Please type a valid letter.', color: Ui.red);
    }
  }
}

// ------------------------------------------------------------
//  🗂️ SECRETARY  (inherits Person) - registers teachers & students
// ------------------------------------------------------------
class Secretary extends Person {
  final List<Teacher> _teachers = [];
  final List<Student> _students = [];

  Secretary(super.name);

  @override
  String get role => 'Secretary';

  @override
  String get emoji => '🗂️ ';

  List<Teacher> get teachers => List.unmodifiable(_teachers);
  List<Student> get students => List.unmodifiable(_students);
  List<Exam> get allExams => _teachers.expand((t) => t.givenExams).toList();

  /// POLYMORPHISM: a secretary "studies" documents.
  @override
  void study(String topic) {
    Ui.say('\n  $emoji $name is organizing the files about "$topic"...',
        color: Ui.magenta);
    Ui.progress('Filing documents');
    Ui.say('  ✔ All "$topic" documents are archived.', color: Ui.green);
  }

  Teacher addTeacher(String name, String branch) {
    final teacher = Teacher(name, branch);
    _teachers.add(teacher);
    Ui.say('\n  ✔ ${teacher.emoji} Teacher "${teacher.name}" ($branch) '
        'was added by $name.', color: Ui.green);
    return teacher;
  }

  Student addStudent(String name) {
    final student = Student(name);
    _students.add(student);
    Ui.say('\n  ✔ ${student.emoji} Student "${student.name}" '
        'was added by ${this.name}.', color: Ui.green);
    return student;
  }

  List<Person> get everyone => [this, ..._teachers, ..._students];
}

// ------------------------------------------------------------
//  🕹️ MENU ACTIONS (plain functions)
// ------------------------------------------------------------
void showMenu() {
  final items = {
    '1': '➕ Add a teacher',
    '2': '➕ Add a student',
    '3': '👥 List all people',
    '4': '📖 Teacher: prepare & teach a lecture',
    '5': '📚 Student: study a subject',
    '6': '📝 Teacher: create an exam',
    '7': '✍️  Student: take an exam',
    '8': '🏆 Leaderboard & report cards',
    '9': '🎭 Polymorphism demo (everyone studies)',
    '10': '⚡ Load demo data',
    '0': '🚪 Exit',
  };
  print('');
  items.forEach((k, v) => print('   ${Ui.paint(k.padLeft(2), Ui.cyan)}  $v'));
  print('');
}

void addTeacherAction(Secretary s) {
  final name = Ui.ask('Teacher name:');
  final branch = Ui.pick<String>(
      'Choose the teacher\'s branch:', QuestionBank.branches, (b) => b);
  if (branch == null) return;
  s.addTeacher(name, branch);
}

void addStudentAction(Secretary s) => s.addStudent(Ui.ask('Student name:'));

void listPeopleAction(Secretary s) {
  print(Ui.paint('\n  ── Everyone in the school ──', Ui.bold));
  for (final p in s.everyone) {
    final extra = p is Teacher ? '  (branch: ${p.branch})' : '';
    print('   ${p.describe()}${Ui.paint(extra, Ui.gray)}');
  }
}

void teachAction(Secretary s) {
  final t = Ui.pick<Teacher>('Which teacher?', s.teachers,
      (t) => '${t.emoji} ${t.name} (${t.branch})');
  if (t == null) return;
  final topic = Ui.ask('Lecture topic:');
  t.study(topic.isEmpty ? t.branch : topic);
}

void studentStudyAction(Secretary s) {
  final st = Ui.pick<Student>('Which student?', s.students,
      (st) => '${st.emoji} ${st.name}');
  if (st == null) return;
  final subject = Ui.pick<String>(
      'Which subject?', QuestionBank.branches, (b) => b);
  if (subject == null) return;
  st.study(subject);
}

void createExamAction(Secretary s) {
  final t = Ui.pick<Teacher>('Which teacher gives the exam?', s.teachers,
      (t) => '${t.emoji} ${t.name} (${t.branch})');
  t?.giveExam();
}

void takeExamAction(Secretary s) {
  final st = Ui.pick<Student>('Which student takes the exam?', s.students,
      (st) => '${st.emoji} ${st.name}');
  if (st == null) return;
  final exam = Ui.pick<Exam>('Which exam?', s.allExams, (e) {
    final done = st.hasTaken(e) ? Ui.paint(' [already taken]', Ui.gray) : '';
    return '${e.title}$done';
  });
  if (exam == null) return;
  if (st.hasTaken(exam)) {
    Ui.say('  ✘ ${st.name} has already taken this exam.', color: Ui.red);
    return;
  }
  final r = st.takeExam(exam);
  print(Ui.paint('\n  ═══ RESULT ═══', Ui.bold));
  print('  Correct answers : ${r.correct}/${r.total}');
  print('  Study bonus     : +${r.bonus}');
  final color = r.score >= 70 ? Ui.green : (r.score >= 50 ? Ui.yellow : Ui.red);
  print('  Final score     : ${Ui.paint('${r.score}', color)}  '
      '(Grade ${Ui.paint(r.grade, color)})');
  if (r.score >= 90) print(Ui.paint('  🎉 Outstanding work!', Ui.green));
}

void leaderboardAction(Secretary s) {
  if (s.students.isEmpty) {
    Ui.say('  No students yet.', color: Ui.yellow);
    return;
  }
  final ranked = List<Student>.from(s.students)
    ..sort((a, b) => b.average.compareTo(a.average));

  print(Ui.paint('\n  ── 🏆 Leaderboard ──', Ui.bold));
  const medals = ['🥇', '🥈', '🥉'];
  for (var i = 0; i < ranked.length; i++) {
    final st = ranked[i];
    final medal = i < 3 ? medals[i] : '  ';
    final bar = '█' * (st.average / 5).round();
    print('   $medal ${st.name.padRight(14)} '
        '${Ui.paint(bar, Ui.green)} ${st.average.toStringAsFixed(1)}');
  }

  print(Ui.paint('\n  ── 📄 Report cards ──', Ui.bold));
  for (final st in ranked) {
    print('   ${st.emoji} ${Ui.paint(st.name, Ui.cyan)}');
    if (st.results.isEmpty) {
      print(Ui.paint('      (no exams taken yet)', Ui.gray));
    }
    for (final r in st.results) {
      print('      • ${r.exam.subject.padRight(6)} '
          'score ${r.score.toString().padLeft(3)}  grade ${r.grade}  '
          '${Ui.paint('(Exam #${r.exam.id})', Ui.gray)}');
    }
  }
}

/// POLYMORPHISM: same call (study) -> different behavior for each class.
void polymorphismDemo(Secretary s) {
  final topic = Ui.ask('Topic everyone should study:');
  for (final Person p in s.everyone) {
    p.study(topic.isEmpty ? 'Dart' : topic); // dynamic dispatch!
  }
}

void loadDemoData(Secretary s) {
  s.addTeacher('Ada Lovelace', 'Dart');
  s.addTeacher('Alan Turing', 'OOP');
  s.addStudent('Grace Hopper');
  s.addStudent('Linus Torvalds');
  s.addStudent('Margaret Hamilton');
}

// ------------------------------------------------------------
//  🚀 MAIN
// ------------------------------------------------------------
void main() {
  final secretary = Secretary('Ms. Secretary');

  while (true) {
    Ui.clear();
    Ui.banner();
    Ui.say('  Welcome! Secretary on duty: ${secretary.name} ${secretary.emoji}',
        color: Ui.gray);
    showMenu();

    final choice = Ui.ask('Select an option:');
    try {
      switch (choice) {
        case '1':
          addTeacherAction(secretary);
        case '2':
          addStudentAction(secretary);
        case '3':
          listPeopleAction(secretary);
        case '4':
          teachAction(secretary);
        case '5':
          studentStudyAction(secretary);
        case '6':
          createExamAction(secretary);
        case '7':
          takeExamAction(secretary);
        case '8':
          leaderboardAction(secretary);
        case '9':
          polymorphismDemo(secretary);
        case '10':
          loadDemoData(secretary);
        case '0':
          Ui.say('\n  👋 Goodbye! See you at school.\n', color: Ui.cyan);
          return;
        default:
          Ui.say('  ✘ Unknown option.', color: Ui.red);
      }
    } on ArgumentError catch (e) {
      Ui.say('\n  ✘ ${e.message}', color: Ui.red);
    }
    Ui.pause();
  }
}