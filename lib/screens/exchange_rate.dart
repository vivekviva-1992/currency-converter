import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ExchangeRate extends StatefulWidget {
  const ExchangeRate({super.key});

  @override
  State<ExchangeRate> createState() => _ExchangeRateState();
}

class _ExchangeRateState extends State<ExchangeRate> {
  final TextEditingController _controller = TextEditingController();
  String convertedValue = "";
  bool isLoading = true;
  String _baseCurrency = 'USD';
  String _targetCurrency = 'EUR';
  double _exchangeRate = 0.0;
  String _result = "";
  final List<String> _currencies = [
    'USD',
    'EUR',
    'GBP',
    'INR',
    'JPY',
    'AUD',
    'BOB',
    'BZD',
    'COP',
    'AWG'
  ];
  Future<void> fetchExchangeRate() async {
    //final apiKey=dotenv.env['EXCHANGE-API-KEY'];
    final url = Uri.parse(
        "https://v6.exchangerate-api.com/v6/9a5e051ed14c4f81f1093cd2/latest/$_baseCurrency");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _exchangeRate = data['conversion_rates'][_targetCurrency];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch exchange rate');
      }
    } catch (error) {
      print('Error fetching exchange rate:$error');
      setState(() {
        _exchangeRate = 0.0;
      });
    }
  }

  void convertCurrency() {
    if (_controller.text.isEmpty || _exchangeRate == 0.0) {
      setState(() {
        _result = "Enter a valid amount or fetch rates first";
      });
      return;
    }
    double amount = double.parse(_controller.text);
    double convertedAmount = amount * _exchangeRate;
    setState(() {
      _result =
          "$amount $_baseCurrency=${convertedAmount.toStringAsFixed(2)}$_targetCurrency";
    });
  }

  @override
  void initState() {
    super.initState();
    fetchExchangeRate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.orange[200],
        appBar: AppBar(
          title: Text(
            "Currency Converter",
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color.fromARGB(255, 49, 192, 21),
          centerTitle: true,
        ),
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 242, 251, 187),
                      Colors.blue.shade400
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _controller,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Enter Amount',
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        DropdownButton<String>(
                          value: _baseCurrency,
                          items: _currencies.map((String currency) {
                            return DropdownMenuItem(
                              value: currency,
                              child: Text(
                                currency,
                                style: TextStyle(fontSize: 24),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(
                              () {
                                _baseCurrency = value!;
                                fetchExchangeRate();
                              },
                            );
                          },
                        ),
                        Icon(Icons.swap_horiz),
                        DropdownButton<String>(
                          value: _targetCurrency,
                          items: _currencies.map((String currency) {
                            return DropdownMenuItem(
                              value: currency,
                              child: Text(
                                currency,
                                style: TextStyle(fontSize: 24),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(
                              () {
                                _targetCurrency = value!;
                                fetchExchangeRate();
                              },
                            );
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 50),
                    ElevatedButton(
                        onPressed: convertCurrency, child: Text("Convert")),
                    SizedBox(height: 20),
                    Text(
                      _exchangeRate != 0.0
                          ? "1 $_baseCurrency=${_exchangeRate.toStringAsFixed(4)}$_targetCurrency"
                          : "Fetching exchange rate....",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    Text(
                      _result,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.pink),
                    )
                  ],
                ),
              ));
  }
}
