import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'login_page.dart'; // 👈 import login page

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const CodingApp());
}

class CodingApp extends StatelessWidget {
  const CodingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Programming Tutorials",
      initialRoute: '/login', // 👈 start from login page
      routes: {
        '/login': (context) => const LoginPage(),
        '/': (context) => const TutorialPage(),
        '/emi': (context) => const EMICalculator(),
        '/expense': (context) => const ExpenseFormPage(),
        '/expenseResult': (context) => const ExpenseResultPage(),
        '/search': (context) => const ExpenseSearchPage(),
        '/update': (context) => const ExpenseUpdatePage(),
      },
    );
  }
}

/// --------------------
/// Tutorial List Screen
/// --------------------
class Tutorial {
  final String title;
  final String language;
  final int id;
  const Tutorial({required this.title, required this.language, required this.id});
}

final List<Tutorial> tutorials = const [
  Tutorial(title: "Intro to Dart", language: "Dart", id: 101),
  Tutorial(title: "Variables in Dart", language: "Dart", id: 102),
  Tutorial(title: "Loops in Dart", language: "Dart", id: 103),
  Tutorial(title: "Intro to Python", language: "Python", id: 201),
  Tutorial(title: "Functions in Python", language: "Python", id: 202),
  Tutorial(title: "Intro to C", language: "C", id: 301),
  Tutorial(title: "Pointers in C", language: "C", id: 302),
];

class TutorialPage extends StatelessWidget {
  const TutorialPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Programming Tutorials"),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          )
        ],
      ),
      body: ListView.builder(
        itemCount: tutorials.length,
        itemBuilder: (context, index) {
          final tutorial = tutorials[index];
          return Column(
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.indigo.shade100,
                  child: Text(
                    tutorial.language[0],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(
                  tutorial.title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                subtitle: Text("ID: ${tutorial.id}"),
                trailing: Text(
                  tutorial.language,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
              const Divider(),
            ],
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'emi_btn',
            onPressed: () => Navigator.pushNamed(context, '/emi'),
            label: const Text('EMI Calculator'),
            icon: const Icon(Icons.calculate),
            backgroundColor: Colors.indigo,
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'expense_btn',
            onPressed: () => Navigator.pushNamed(context, '/expense'),
            label: const Text('Expense Manager'),
            icon: const Icon(Icons.account_balance_wallet),
            backgroundColor: Colors.green.shade700,
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'search_btn',
            onPressed: () => Navigator.pushNamed(context, '/search'),
            label: const Text('Search Expenses'),
            icon: const Icon(Icons.search),
            backgroundColor: Colors.orange,
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'update_btn',
            onPressed: () => Navigator.pushNamed(context, '/update'),
            label: const Text('Update Expense'),
            icon: const Icon(Icons.edit),
            backgroundColor: Colors.deepPurple,
          ),
        ],
      ),
    );
  }
}

/// --------------------------
/// EMI Calculator
/// --------------------------
class EMICalculator extends StatefulWidget {
  const EMICalculator({super.key});

  @override
  State<EMICalculator> createState() => _EMICalculatorState();
}

class _EMICalculatorState extends State<EMICalculator> {
  final _formKey = GlobalKey<FormState>();
  final _loanCtrl = TextEditingController();
  final _rateCtrl = TextEditingController();
  final _tenureCtrl = TextEditingController();

  double? _emi;
  double? _interest;

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;
    final p = double.parse(_loanCtrl.text);
    final r = double.parse(_rateCtrl.text) / 12 / 100;
    final n = int.parse(_tenureCtrl.text);

    final pow = (1 + r).pow(n);
    final emi = p * r * pow / (pow - 1);
    final total = emi * n;
    final interest = total - p;

    setState(() {
      _emi = emi;
      _interest = interest;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("EMI Calculator"), backgroundColor: Colors.indigo),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(children: [
            TextFormField(
              controller: _loanCtrl,
              decoration: const InputDecoration(labelText: 'Loan Amount', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _rateCtrl,
              decoration: const InputDecoration(labelText: 'Interest Rate (%)', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _tenureCtrl,
              decoration: const InputDecoration(labelText: 'Tenure (months)', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _calculate,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
              child: const Text('Calculate EMI'),
            ),
            const SizedBox(height: 20),
            if (_emi != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(children: [
                    Text('Monthly EMI: ₹${_emi!.toStringAsFixed(2)}'),
                    Text('Total Interest: ₹${_interest!.toStringAsFixed(2)}'),
                  ]),
                ),
              ),
          ]),
        ),
      ),
    );
  }
}

extension DoublePow on double {
  double pow(int exponent) {
    double res = 1;
    for (int i = 0; i < exponent; i++) res *= this;
    return res;
  }
}

/// --------------------------
/// Expense Manager + Firestore
/// --------------------------
class ExpenseData {
  final double income, rent, food, transport, others;
  ExpenseData({
    required this.income,
    required this.rent,
    required this.food,
    required this.transport,
    required this.others,
  });
  double get total => rent + food + transport + others;
  double get balance => income - total;
}

class ExpenseFormPage extends StatefulWidget {
  const ExpenseFormPage({super.key});
  @override
  State<ExpenseFormPage> createState() => _ExpenseFormPageState();
}

class _ExpenseFormPageState extends State<ExpenseFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _income = TextEditingController(),
      _rent = TextEditingController(),
      _food = TextEditingController(),
      _transport = TextEditingController(),
      _others = TextEditingController();

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final e = ExpenseData(
      income: double.parse(_income.text),
      rent: double.parse(_rent.text),
      food: double.parse(_food.text),
      transport: double.parse(_transport.text),
      others: double.parse(_others.text),
    );
    Navigator.pushNamed(context, '/expenseResult', arguments: e);
  }

  Widget _field(String label, TextEditingController c) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: c,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      keyboardType: TextInputType.number,
      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Monthly Budget'), backgroundColor: Colors.green.shade700),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(children: [
            _field('Income', _income),
            _field('Rent / EMI', _rent),
            _field('Food', _food),
            _field('Transport', _transport),
            _field('Others', _others),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700),
              child: const Text('Calculate'),
            ),
          ]),
        ),
      ),
    );
  }
}

class ExpenseResultPage extends StatelessWidget {
  const ExpenseResultPage({super.key});
  Future<void> _save(BuildContext context, ExpenseData e) async {
    await FirebaseFirestore.instance.collection('expenses').add({
      'income': e.income,
      'rent': e.rent,
      'food': e.food,
      'transport': e.transport,
      'others': e.others,
      'total': e.total,
      'balance': e.balance,
      'timestamp': FieldValue.serverTimestamp(),
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved to Firestore!')));
  }

  @override
  Widget build(BuildContext context) {
    final e = ModalRoute.of(context)!.settings.arguments as ExpenseData;
    return Scaffold(
      appBar: AppBar(title: const Text('Result'), backgroundColor: Colors.green.shade700),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Text('Remaining Balance: ₹${e.balance.toStringAsFixed(2)}',
              style: TextStyle(color: e.balance < 0 ? Colors.red : Colors.green, fontWeight: FontWeight.bold, fontSize: 20)),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: () => _save(context, e), style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700), child: const Text('💾 Save')),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExpenseHistoryPage())), style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo), child: const Text('📜 History')),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: () => Navigator.popUntil(context, ModalRoute.withName('/')), style: ElevatedButton.styleFrom(backgroundColor: Colors.grey), child: const Text('Back')),
        ]),
      ),
    );
  }
}

class ExpenseHistoryPage extends StatelessWidget {
  const ExpenseHistoryPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Expense History'), backgroundColor: Colors.indigo),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('expenses').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('No saved records.'));
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (c, i) {
              final d = docs[i].data() as Map<String, dynamic>;
              return Card(
                child: ListTile(
                  title: Text('Income: ₹${d['income']} | Balance: ₹${d['balance']}'),
                  subtitle: Text('Total: ₹${d['total']}'),
                  trailing: Icon((d['balance'] ?? 0) < 0 ? Icons.warning : Icons.check_circle,
                      color: (d['balance'] ?? 0) < 0 ? Colors.red : Colors.green),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// --------------------------
/// Search Expense (Ex 8)
/// --------------------------
class ExpenseSearchPage extends StatefulWidget {
  const ExpenseSearchPage({super.key});
  @override
  State<ExpenseSearchPage> createState() => _ExpenseSearchPageState();
}

class _ExpenseSearchPageState extends State<ExpenseSearchPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  List<Map<String, dynamic>> _results = [];
  bool _loading = false;
  String _msg = '';

  Future<void> _search() async {
    final q = double.tryParse(_searchCtrl.text.trim());
    if (q == null) {
      setState(() => _msg = 'Enter a valid number');
      return;
    }
    setState(() {
      _loading = true;
      _msg = '';
      _results = [];
    });
    try {
      final inc = await FirebaseFirestore.instance.collection('expenses').where('income', isEqualTo: q).get();
      final bal = await FirebaseFirestore.instance.collection('expenses').where('balance', isEqualTo: q).get();
      final all = [...inc.docs, ...bal.docs];
      if (all.isEmpty) {
        setState(() {
          _msg = 'No records found.';
          _loading = false;
        });
      } else {
        setState(() {
          _results = all.map((e) => e.data() as Map<String, dynamic>).toList();
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _msg = 'Error: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Expense Records'), backgroundColor: Colors.orange),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(controller: _searchCtrl, decoration: const InputDecoration(labelText: 'Enter Income or Balance', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          ElevatedButton.icon(onPressed: _search, icon: const Icon(Icons.search), label: const Text('Search'), style: ElevatedButton.styleFrom(backgroundColor: Colors.orange)),
          const SizedBox(height: 20),
          if (_loading)
            const CircularProgressIndicator()
          else if (_msg.isNotEmpty)
            Text(_msg, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
          else if (_results.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _results.length,
                  itemBuilder: (c, i) {
                    final e = _results[i];
                    return Card(
                      child: ListTile(
                        title: Text('Income: ₹${e['income']} | Balance: ₹${e['balance']}'),
                        subtitle: Text('Total: ₹${e['total']} (Food: ₹${e['food']}, Rent: ₹${e['rent']})'),
                        trailing: Icon((e['balance'] ?? 0) < 0 ? Icons.warning : Icons.check_circle,
                            color: (e['balance'] ?? 0) < 0 ? Colors.red : Colors.green),
                      ),
                    );
                  },
                ),
              ),
        ]),
      ),
    );
  }
}

/// --------------------------
/// Update Expense (Ex 9)
/// --------------------------
class ExpenseUpdatePage extends StatefulWidget {
  const ExpenseUpdatePage({super.key});
  @override
  State<ExpenseUpdatePage> createState() => _ExpenseUpdatePageState();
}

class _ExpenseUpdatePageState extends State<ExpenseUpdatePage> {
  final _incomeCtrl = TextEditingController();
  final _rentCtrl = TextEditingController();
  final _foodCtrl = TextEditingController();
  final _transportCtrl = TextEditingController();
  final _othersCtrl = TextEditingController();

  String _msg = '';
  bool _loading = false;
  DocumentSnapshot? _doc;

  Future<void> _search() async {
    final income = double.tryParse(_incomeCtrl.text.trim());
    if (income == null) {
      setState(() => _msg = 'Enter valid income.');
      return;
    }
    setState(() {
      _loading = true;
      _msg = '';
      _doc = null;
    });

    try {
      final q = await FirebaseFirestore.instance
          .collection('expenses')
          .where('income', isEqualTo: income)
          .limit(1)
          .get();

      if (q.docs.isEmpty) {
        setState(() {
          _msg = 'No record found.';
          _loading = false;
        });
      } else {
        final d = q.docs.first;
        final data = d.data();
        _rentCtrl.text = data['rent'].toString();
        _foodCtrl.text = data['food'].toString();
        _transportCtrl.text = data['transport'].toString();
        _othersCtrl.text = data['others'].toString();
        setState(() {
          _doc = d;
          _msg = 'Record found. Edit and update.';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _msg = 'Error: $e';
        _loading = false;
      });
    }
  }

  Future<void> _update() async {
    if (_doc == null) {
      setState(() => _msg = 'Search first.');
      return;
    }
    try {
      final rent = double.tryParse(_rentCtrl.text) ?? 0;
      final food = double.tryParse(_foodCtrl.text) ?? 0;
      final trans = double.tryParse(_transportCtrl.text) ?? 0;
      final others = double.tryParse(_othersCtrl.text) ?? 0;
      final income = double.tryParse(_incomeCtrl.text) ?? 0;
      final total = rent + food + trans + others;
      final bal = income - total;

      await FirebaseFirestore.instance.collection('expenses').doc(_doc!.id).update({
        'rent': rent,
        'food': food,
        'transport': trans,
        'others': others,
        'total': total,
        'balance': bal,
      });
      setState(() => _msg = '✅ Record updated successfully!');
    } catch (e) {
      setState(() => _msg = 'Error: $e');
    }
  }

  Widget _field(String label, TextEditingController c) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: c,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // ✅ resizes layout when keyboard opens
      appBar: AppBar(
        title: const Text('Update Expense Record'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(), // ✅ dismiss keyboard on tap
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _incomeCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Enter Income (for search)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _search,
                  icon: const Icon(Icons.search),
                  label: const Text('Search Record'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 20),
                if (_loading)
                  const Center(child: CircularProgressIndicator())
                else if (_msg.isNotEmpty)
                  Text(
                    _msg,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                const SizedBox(height: 10),
                if (_doc != null) ...[
                  _field('Rent / EMI', _rentCtrl),
                  _field('Food', _foodCtrl),
                  _field('Transport', _transportCtrl),
                  _field('Others', _othersCtrl),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _update,
                    icon: const Icon(Icons.save),
                    label: const Text('Update Record'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                ],
                const SizedBox(height: 100), // ✅ extra space for keyboard
              ],
            ),
          ),
        ),
      ),
    );
  }
}

