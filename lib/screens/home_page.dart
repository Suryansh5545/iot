import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:iot/screens/predModel.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  static const endpointUrl =
      "https://api.thingspeak.com/update?api_key=82V7995XL4FP7PZM&field1=";

  List<num>? data = <num>[5, 4, 5.5, 5.1, 4.82, 4.33, 3.57, 4.52];

  Future<void> buttonPressed(int val) async {
    String finalUrl = val == 1 ? endpointUrl + "1" : endpointUrl + "0";
    var response = await http.get(Uri.parse(finalUrl));
    if (response.statusCode == 200) {
      print("Success");
    } else {
      print("Failed");
    }
  }

  Future<void> getData() async {
    var response = await http.get(Uri.parse(
        "https://api.thingspeak.com/channels/2286399/fields/1.json?api_key=D6STX145VZNXKII5&results"));

    if (response.statusCode == 200) {
      print("Success");
      for (var i in jsonDecode(response.body)["feeds"]) {
        if (i["field1"] != null) {
          if (data == null) {
            data = <num>[];
          }
          data!.add(num.parse(i["field1"]));
        }
      }
    } else {
      print("Failed");
    }
  }

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<num>? data = [];

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E6991),
        title: const Text(
          "Introduction to IOT",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Welcome to Dashboard",
                style: GoogleFonts.lato(
                  textStyle: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => widget.buttonPressed(1),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.green,
                  ),
                  child: const Text("ON"),
                ),
                ElevatedButton(
                  onPressed: () => widget.buttonPressed(0),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red,
                  ),
                  child: const Text("OFF"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: SfSparkLineChart(
                trackball: const SparkChartTrackball(
                  activationMode: SparkChartActivationMode.tap,
                ),
                marker: const SparkChartMarker(
                  displayMode: SparkChartMarkerDisplayMode.all,
                ),
                labelDisplayMode: SparkChartLabelDisplayMode.all,
                data: data ?? <num>[],
              ),
            ),
            ElevatedButton(
              onPressed: () => _getData(),
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text("Get Data"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PredModel(),
                  ),
                );
              },
              child: const Text("Navigate to PredModel"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _getData() async {
    setState(() {
      isLoading = true;
    });

    var response = await http.get(Uri.parse(
        "https://api.thingspeak.com/channels/2286399/fields/1.json?api_key=D6STX145VZNXKII5&results"));

    if (response.statusCode == 200) {
      print("Success");
      data = []; // Clear existing data
      for (var i in jsonDecode(response.body)["feeds"]) {
        if (i["field1"] != null) {
          data!.add(num.parse(i["field1"]));
        }
      }
      setState(() {
        isLoading = false;
      });
    } else {
      print("Failed");
      setState(() {
        isLoading = false;
      });
    }
  }
}