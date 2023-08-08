import 'package:flutter/material.dart';
import 'package:getnet_pos_helper/getnet_pos_helper.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Teste GetNet'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  String? serviceStatus;

  String? printerStatus;

  String? mifareStatus;

  String? scannerStatus;

  @override
  void initState() {
    super.initState();
    checkService();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            LabeledValue('Service Status', serviceStatus ?? ""),
            LabeledValue('Printer:', printerStatus ?? ""),
            LabeledValue('Mifare:', mifareStatus ?? ""),
            LabeledValue('Scanner:', scannerStatus ?? ""),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            FloatingActionButton(
              onPressed: nfc,
              child: const Icon(Icons.airplay),
            ),
            const SizedBox(
              width: 10,
            ),
            FloatingActionButton(
              onPressed: scan,
              backgroundColor: Colors.red[900],
              child: const Icon(Icons.camera_alt),
            ),
            const SizedBox(
              width: 10,
            ),
            FloatingActionButton(
              onPressed: impressao,
              backgroundColor: Colors.green[900],
              child: const Icon(Icons.print),
            ),
            const SizedBox(
              width: 10,
            ),
            FloatingActionButton(
              onPressed: payment,
              backgroundColor: Colors.orange[900],
              child: const Icon(Icons.credit_card),
            ),
          ],
        ),
      ),
    );
  }

  void impressao() {
    setState(() {
      printerStatus = null;
    });
    GetnetPos.print(
      [
        "Header is the first line",
        "Content line 1",
        "Content line 2",
      ],
    )
        .then((_) => setState(() {
              printerStatus = 'Normal';
            }))
        .catchError((e) => setState(() {
              printerStatus = 'Error: ${e.code} -> ${e.message}';
            }));
  }

  void payment() {
    setState(() {
      printerStatus = null;
    });
    //Amount: 12 digitos os ultimos 2 casas decimais
    GetnetPos.payment("000000001234", "credit", "1")
        .then((_) => setState(() {
              printerStatus = 'Normal';
            }))
        .catchError((e) => setState(() {
              printerStatus = 'Error: ${e.code} -> ${e.message}';
            }));
  }

  void nfc() {
    setState(() {
      mifareStatus = 'Mantenha o cartão próximo!';
    });
    Future.delayed(const Duration(seconds: 2), () {
      GetnetPos.getMifareCardSN()
          .then((csn) => setState(() {
                mifareStatus = 'Leitura: $csn';
              }))
          .catchError((e) => setState(() {
                mifareStatus = 'Error: ${e.code} -> ${e.message}';
              }));
    });
  }

  void checkService() async {
    var status = await GetnetPos.checkService(label: '');
    setState(() {
      serviceStatus = status;
    });
  }

  void scan() {
    setState(() {
      scannerStatus = null;
    });
    GetnetPos.scan()
        .then((result) => setState(() {
              scannerStatus = 'Leitura: $result';
            }))
        .catchError((e) => setState(() {
              debugPrint(e.toString());
              scannerStatus = 'Error: ${e.code} -> ${e.message}';
            }));
  }
}

class LabeledValue extends StatelessWidget {
  final String label;
  final String value;
  const LabeledValue(
    this.label,
    this.value, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: RichText(
        text: TextSpan(
          text: label,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(fontWeight: FontWeight.bold),
          children: [
            TextSpan(
              text: value,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
