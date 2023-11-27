import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/sparkcharts.dart';

class PredModel extends StatefulWidget {
  @override
  _PredModelState createState() => _PredModelState();
}

class _PredModelState extends State<PredModel> {
  List<num> input = List.filled(5, 0);
  var predValue = "";
  @override
  void initState() {
    super.initState();
    predValue = "click predict button";
  }

  // Future<void> predData() async {
  //   List<num>? data = <num>[];
  //   var response = await http.get(Uri.parse(
  //   "https://api.thingspeak.com/channels/2286399/fields/2.json?api_key=D6STX145VZNXKII5&results"));

  //   if (response.statusCode == 200) {
  //     print("Success");
  //     for (var i in jsonDecode(response.body)["feeds"]) {
  //       if (i["field1"] != null) {
  //         if (data == null) {
  //           data = <num>[];
  //         }
  //         data.add(num.parse(i["field1"]));
  //       }
  //     }
  //   } else {
  //     print("Failed");
  //   }
  //   final interpreter = await Interpreter.fromAsset('assets/predmodel.tflite');
  //   print(interpreter.getInputTensor(0).shape);
  //   print(interpreter.getOutputTensor(0).shape);
  //   var input = [
  //     [4,3,2,1,4]
  //   ];
  //   var output = List.filled(1, 0).reshape([1, 1]);
  //   interpreter.run(input, output);
  //   print(output[0][0]);

  //   this.setState(() {
  //     predValue = output[0][0].toString();
  //   });
  // }

Future<void> predData() async {
  var response = await http.get(Uri.parse(
      "https://api.thingspeak.com/channels/2286399/fields/2.json?api_key=D6STX145VZNXKII5&results=5"));

  if (response.statusCode == 200) {
    print("Success");
    print(response.body);
    List<num> newData = [];
    for (var i in jsonDecode(response.body)["feeds"]) {
      if (i["field2"] != null) {
        newData.add(num.parse(i["field2"]));
      }
    }

    // Update the input list with the latest 5 values
    if (newData.length >= 5) {
      input = newData.sublist(newData.length - 5);
    } else {
      input.setAll(0, List.filled(5 - newData.length, 0));
      input.setAll(5 - newData.length, newData);
    }

    // Run the model multiple times using the new predicted value as input
    for (int i = 0; i < 5; i++) {
      print(input);
      final interpreter = await Interpreter.fromAsset('assets/predmodel.tflite');
      print(interpreter.getInputTensor(0).shape);
      print(interpreter.getOutputTensor(0).shape);

      // Use the input list for model inference
      var output = List.filled(1, 0).reshape([1, 1]);
      interpreter.run([input], output);
      print(output[0][0]);

      setState(() {
        predValue = output[0][0].toString();
        // Update the input list with the new predicted value
        input.setAll(0, input.sublist(1)..add(num.parse(predValue)));
      });
    }
  } else {
    print("Failed");
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "change the input values in code to get the prediction",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 12),
            MaterialButton(
              color: Colors.blue,
              child: Text(
                "predict",
                style: TextStyle(fontSize: 25),
              ),
              onPressed: predData,
            ),
            SizedBox(height: 12),
            Text(
              "Predicted value :  $predValue ",
              style: TextStyle(color: Colors.red, fontSize: 23),
            ),
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
                data: input.where((value) => value.isFinite).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}