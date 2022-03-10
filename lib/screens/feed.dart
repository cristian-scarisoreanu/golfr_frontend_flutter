import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:golfr_flutter/main.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

import 'package:intl/intl.dart';
import '../models/scores.dart';
import '../utils/appbar.dart';
import 'login.dart';

class MyScores extends StatefulWidget {
  const MyScores(
      {Key? key,
      required this.id,
      required this.token,
      required this.scores,
      required this.onPressed,
      this.rebuild = false})
      : super(key: key);
  final int? id;
  final String? token;
  final List<Scores> scores;
  final ValueChanged<bool> onPressed;
  final bool rebuild;
  @override
  _MyScoresState createState() => _MyScoresState();
}

class _MyScoresState extends State<MyScores> {
  TextEditingController dateController = TextEditingController();
  String playedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  int totalScore = 0;
  final _formKey = GlobalKey<FormState>();
  String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
  late String error = "";

  @override
  void initState() {
    super.initState();
    dateController.text = today;
  }

  Future<bool> _deleteRequest(id) async {
    final response = await http.delete(
      Uri.http('localhost:3000', 'api/scores/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${widget.token}',
      },
    );

    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  void _handleOnPressed() {
    widget.onPressed(!widget.rebuild);
  }

  Future _deleteScore(id, context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Delete'),
            content: const Text('Are you sure you want to delete the score?'),
            actions: [
              TextButton(
                  onPressed: () async {
                    await _deleteRequest(id);
                    Navigator.pop(context);
                    _handleOnPressed();
                  },
                  child: const Text('Yes')),
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('No')),
            ],
          );
        });
  }

  Future<void> datePickerWidget() async {
    await DatePicker.showDatePicker(
      context,
      showTitleActions: true,
      minTime: DateTime(1999),
      maxTime: DateTime(2030),
      onConfirm: (date) {
        setState(() {
          dateController.text = DateFormat('yyyy-MM-dd').format(date);
        });
        playedDate = dateController.text;
      },
    );
  }

  Future<http.Response?> postScore(int totalScore, String playedAt) async {
    final request = jsonEncode({
      "score": {"total_score": totalScore, "played_at": playedAt}
    });

    final response = await http.post(
      Uri.http('localhost:3000', 'api/scores'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'content-type': 'application/json'
      },
      body: request,
    );
    String responseString = response.body;
    var decodedResponse = jsonDecode(responseString);
    if (response.statusCode == 200) {
      error = "";
    }
    if (response.statusCode == 400) {
      var errors = decodedResponse['errors'];
      error = errors.toString();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: SingleChildScrollView(
            physics: const ScrollPhysics(),
            child: Column(mainAxisSize: MainAxisSize.max, children: [
              Column(
                children: <Widget>[
                  const SizedBox(height: 5.0),
                  ExpansionTile(
                      childrenPadding: const EdgeInsets.all(10),
                      children: [
                        TextFormField(
                            initialValue: "80",
                            onSaved: (score) {
                              totalScore = int.parse(score!);
                            },
                            validator: (score) {
                              if (score!.isEmpty) {
                                return "Please enter the score";
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              labelText: 'Total Score',
                              prefixIcon: Icon(Icons.golf_course),
                            )),
                        TextFormField(
                            readOnly: true,
                            controller: dateController,
                            validator: (date) {
                              if (date!.isEmpty) {
                                return "Please enter a date";
                              }
                              return null;
                            },
                            onTap: datePickerWidget,
                            decoration: const InputDecoration(
                              labelText: 'Played Date',
                              prefixIcon: Icon(Icons.calendar_month),
                            )),
                        Container(
                          alignment: Alignment.center,
                          child: ElevatedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  _formKey.currentState!.save();
                                  await postScore(totalScore, playedDate);

                                  if (error.isNotEmpty) {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Row(children: const [
                                              Icon(
                                                Icons.report_gmailerrorred,
                                                color: Colors.red,
                                              ),
                                              SizedBox(width: 5),
                                              Text('Error'),
                                            ]),
                                            content: Text("Rules:\n$error"),
                                            actions: [
                                              TextButton(
                                                  onPressed: () async {
                                                    _handleOnPressed;
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text(
                                                    'Ok',
                                                    textAlign: TextAlign.center,
                                                  )),
                                            ],
                                          );
                                        });
                                  }
                                  _handleOnPressed();
                                }
                              },
                              child: const Text("  Post  ")),
                        )
                      ],
                      title: const Text(
                        "Want to post a score?",
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.normal),
                      )),
                ],
              ),
              ListView.builder(
                physics: const ScrollPhysics(),
                shrinkWrap: true,
                itemCount: widget.scores.length,
                itemBuilder: (context, index) {
                  final score = widget.scores[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: Colors.green.shade300,
                      ),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: ListTile(
                        leading: const Text(
                          '⛳',
                          style: TextStyle(fontSize: 35),
                        ),
                        minLeadingWidth: 0,
                        title: Text(playedDate,
                            style: const TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.grey,
                                fontSize: 13)),
                        subtitle: Text(
                            '${score.user_name} posted a score of ${score.total_score}',
                            style: const TextStyle(
                                fontStyle: FontStyle.normal,
                                color: Colors.black,
                                fontSize: 15)),
                        trailing: score.user_id == widget.id
                            ? IconButton(
                                icon: const Icon(
                                  Icons.highlight_remove,
                                  color: Colors.red,
                                ),
                                onPressed: () async {
                                  _deleteScore(score.id, context);
                                },
                              )
                            : null),
                  );
                },
              ),
            ])));
  }
}

class MyFeed extends StatefulWidget {
  final int? id;
  final String? token;
  const MyFeed({Key? key, required this.id, required this.token})
      : super(key: key);
  @override
  _MyFeedState createState() => _MyFeedState();
}

class _MyFeedState extends State<MyFeed> {
  late List<Scores> scores;
  bool refresh = false;

  Future<void> _logout() async {
    await forgetUser();
    Navigator.of(context).pushAndRemoveUntil(
        // the new route
      MaterialPageRoute(
          builder: (BuildContext context) => const MyLogin(loggedIn: false),
        ),
    (Route route) => false);
  }

  @override
  void initState() {
    super.initState();
    scores = [];
  }

  Future<Scores?> getScoreFeed() async {
    final token = widget.token;
    final response = await http.get(
      Uri.http('localhost:3000', 'api/feed'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    String responseString = response.body;
    var decodedResponse = jsonDecode(responseString);
    if (response.statusCode == 200) {
      scores = (decodedResponse['scores'] as List)
          .map((score) => Scores.fromJson(score))
          .toList();
    }
    return null;
  }

  void rebuildWidget(bool refresh) {
    setState(() {
      this.refresh = refresh;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: MyAppBar(
          actions: [
            IconButton(
              onPressed: _logout,
              iconSize: 27,
              color: Colors.white,
              icon: const Icon(Icons.logout),
            ),
            IconButton(
                onPressed: () => setState(() {}),
                icon: const Icon(Icons.refresh))
          ],
        ),
        body: FutureBuilder<Scores?>(
            future: getScoreFeed(),
            builder: (BuildContext context, AsyncSnapshot<Scores?> snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                return MyScores(
                    scores: scores,
                    id: widget.id,
                    token: widget.token,
                    onPressed: rebuildWidget,
                    rebuild: refresh);
              }
            }));
  }
}
