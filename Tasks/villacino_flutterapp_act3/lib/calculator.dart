import 'package:flutter/material.dart';

class Calculator extends StatefulWidget {
  const Calculator({super.key});

  @override
  State<Calculator> createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  TextEditingController Num1Controller = TextEditingController();
  TextEditingController Num2Controller = TextEditingController();
  String Result = "";
  bool IsError = false;
  double CalcResult = 0;

  void Calculate(String Operator) {
    double Num1 = double.tryParse(Num1Controller.text) ?? 0;
    double Num2 = double.tryParse(Num2Controller.text) ?? 0;

    switch (Operator) {
      case '+':
        CalcResult = Num1 + Num2;
        break;
      case '-':
        CalcResult = Num1 - Num2;
        break;
      case '*':
        CalcResult = Num1 * Num2;
        break;
      case '/':
        if (Num2 == 0) {
          Errors("DivisionByZero");
        } else {
          CalcResult = Num1 / Num2;
        }
        break;
      default:
        Errors("Invalid");
    }

    setState(() {
      if (IsError) {
        Result;
        IsError = false;
      } else {
        FormatResult(CalcResult);
      }
    });
  }

  void Errors(String Reason) {
    switch (Reason) {
      case 'Empty':
        Result = "Error: Empty Field(s)";
        break;
      case 'Invalid':
        Result = "Error: Invalid Input(s)";
        break;
      case 'DivisionByZero':
        Result = "Error: Division by zero";
        break;
      default:
        Result = "Error: Unknown Error";
    }
    IsError = true;
  }

  void FormatResult(double Result) {
    if (Result % 1 == 0) {
      this.Result = Result.toInt().toString();
    } else {
      this.Result = Result.toString();
    }
  }

  Widget BuildOperatorButton(String Operator, Color Color) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        backgroundColor: Color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () => Calculate(Operator),
      child: Text(
        Operator,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Villacino Activity 3: Calculator"),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 255, 185, 208),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 255, 147, 183),
              Color.fromARGB(255, 255, 185, 208),
              Color.fromARGB(255, 255, 238, 246),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: Num1Controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Enter First Number",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: Num2Controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Enter Second Number",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                BuildOperatorButton('+', Colors.green),
                BuildOperatorButton('-', Colors.blue),
                BuildOperatorButton('*', Colors.orange),
                BuildOperatorButton('/', Colors.red),
              ],
            ),
            SizedBox(height: 30),
            Container(
              padding: EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  Result.isEmpty
                      ? "Result will be shown here."
                      : "Result: \n$Result",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Result.startsWith("Error")
                        ? Colors.red
                        : Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
