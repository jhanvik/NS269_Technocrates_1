import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sih/chartseries.dart';
import 'package:sih/dropdownitems.dart';
import 'package:sih/graph.dart';
import 'package:sih/language.dart';
import 'package:sih/main.dart';
import 'package:sih/persistent.dart';
import 'package:sih/profitables.dart';
import 'localization.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

/*




 */

class YeildPredictor extends StatefulWidget {
  @override
  _YeildPredictorState createState() => _YeildPredictorState();
}

class _YeildPredictorState extends State<YeildPredictor> {
  String url;
  String graphUrl;

  List<String> states = [
    'Andhra Pradesh',
    'Arunachal Pradesh',
    'Bihar',
  ];

  var data;
  String cropYear;
  String area;
  String stateName;
  String districtName;
  String cropName;
  String season;
  String rainfall;

  String queryText = 'Predicting...';
  String yeKya1 = 'loading';
  String yeKya2 = 'loading';
  List<ChartSeries> graphList = [];

  bool isLoading = true;
  bool show = false;

  bool showGraph = false;
  bool showDistricts = false;
  bool graphHasData = false;

  var graphData;
  ScrollController controller = ScrollController();

  Position _currentPosition;

  @override
  Widget build(BuildContext context) {
    Future getdata(url) async {
      print(url);
      http.Response response = await http.get(url);
      print('2 : ' + url);
      return response.body;
    }

    Future<Position> _getCurrentLocation() async {
      final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

      Position position = await geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
      setState(() {
        _currentPosition = position;
      });

      return _currentPosition;
    }

    void _changeLanguage(Language language) async {
      Locale _temp = await setLocale(language.languageCode);

      MyApp.setLocale(context, _temp);
    }

    List<ChartSeries> graphData(cropYearList, cropProductionList) {
      for (int i = cropYearList.length - 1; i >= 0; i--) {
        graphList.add(ChartSeries(
            year: cropYearList[i],
            production: num.parse(cropProductionList[i]),
            barColor: charts.ColorUtil.fromDartColor(Colors.greenAccent)));
      }
      return graphList;
    }

    wrongInputs() {
      showDialog(
          context: context,
          builder: (context) {
            return StatefulBuilder(
              builder: (BuildContext context, setState) {
                return AlertDialog(
                  contentTextStyle:
                      TextStyle(fontSize: 14, color: Colors.black),
                  backgroundColor: Colors.white,
                  title: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3.0),
                    child: Text('Sorry !!'),
                  ),
                  content: Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                        'The data for these selections is not available so the results would not be accurate . Try our profitable crops suggestor to know more suitable crops.'),
                  ),
                  actions: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: RaisedButton(
                        color: Colors.green[400],
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Profitables()),
                          );
                        },
                        child: Text(
                          'Goto Profitables',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                  ],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  contentPadding: EdgeInsets.all(8),
                );
              },
            );
          },
          barrierDismissible: true);
    }

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text(DemoLocalization.of(context)
            .getTranslatedValue('yield prediction')),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonHideUnderline(
              child: DropdownButton(
                onChanged: (Language language) {
                  _changeLanguage(language);
                },
                icon: Icon(
                  Icons.language,
                  color: Colors.white,
                ),
                items: Language.languageList()
                    .map<DropdownMenuItem<Language>>((lang) => DropdownMenuItem(
                          value: lang,
                          child: Row(
                            children: <Widget>[Text(lang.name)],
                          ),
                        ))
                    .toList(),
              ),
            ),
          )
        ],
      ),
      body: ListView(
        controller: controller,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: TextField(
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      area = (num.parse(value) * 0.404685642).toString();
                      print(area);
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                            style: BorderStyle.none, color: Colors.green),
                      ),
                      hintText: DemoLocalization.of(context)
                          .getTranslatedValue('area(acre)'),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Container(
                    height: 60,
                    padding: EdgeInsets.only(left: 6),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton(
                        isExpanded: true,
                        hint: Text(getTranslated(context, 'state name')),
                        value: stateName == null ? null : stateName,
                        items: DropDownItems().states().map((value) {
                          return DropdownMenuItem(
                            child: new Text(getTranslated(context, value)),
                            value: value,
                            onTap: () {
                              setState(() {
                                districtName = null;
                              });
                            },
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            stateName = newValue;

                            showDistricts = true;
                            print(stateName);
                          });
                        },
                      ),
                    ),
                  ),
                ),
                showDistricts
                    ? Padding(
                        padding: EdgeInsets.only(bottom: 12.0),
                        child: Container(
                          height: 60,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green)),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 6.0),
                            child: DropdownButton(
                              isExpanded: true,
                              underline: Container(
                                height: 1,
                                color: Colors.transparent,
                              ),
                              hint:
                                  Text(getTranslated(context, 'district name')),
                              value: districtName == null ? null : districtName,
                              items: DropDownItems()
                                  .districts(stateName)
                                  .map((value) {
                                return DropdownMenuItem(
                                  child: Text(getTranslated(context, value)),
                                  value: value,
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  districtName = newValue;
                                  print(districtName);
                                });
                              },
                            ),
                          ),
                        ),
                      )
                    : Container(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Container(
                    height: 60,
                    padding: EdgeInsets.only(left: 6),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton(
                        isExpanded: true,
                        hint: Text(getTranslated(context, 'crop name')),
                        value: cropName == null ? null : cropName,
                        items: DropDownItems().cropNames().map((value) {
                          return DropdownMenuItem(
                            child: new Text(getTranslated(context, value)),
                            value: value,
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            cropName = newValue;

                            print(cropName);
                          });
                        },
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Container(
                    height: 60,
                    padding: EdgeInsets.only(left: 6),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton(
                        isExpanded: true,
                        hint: Text(getTranslated(context, 'season')),
                        value: season == null ? null : season,
                        items: DropDownItems().seasons().map((value) {
                          return DropdownMenuItem(
                            child: new Text(getTranslated(context, value)),
                            value: value,
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            season = newValue;

                            print(season);
                          });
                        },
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RaisedButton(
                    onPressed: () async {
                      setState(() {
                        show = true;
                      });
                      _currentPosition = await _getCurrentLocation();
                      url = 'http://192.168.0.104:7000/yeild_predictor_api?' +
                          'area=' +
                          area.toString() +
                          '&state_name=' +
                          stateName.toString() +
                          '&district_name=' +
                          districtName.toString() +
                          '&crop=' +
                          cropName.toString() +
                          '&season=' +
                          season.toString() +
                          '&latitude=' +
                          _currentPosition.latitude.toString() +
                          '&longitude=' +
                          _currentPosition.longitude.toString();

                      print('URL : ' + url);

                      data = await getdata(url);

                      var graphHas = await getdata(
                          'http://192.168.0.104:7000/yeildpredictor_graph');
                      // <========= Assigning values=============>

                      //<============== noraml data===========>

                      var decodedData = jsonDecode(data);
                      var predict = decodedData['prediction'];
                      var graphHasDecoded = jsonDecode(graphHas);

                      /*  var graphData = await getdata(
                          'http://192.168.0.132:7000/yeildpredictor_graph'); */

                      //<============== graph data ===============>

                      print(predict.toString() + '==============');
                      print(graphHasDecoded['crop_year_for_graph'].toString() +
                          '_______________');
                      print(graphHasDecoded['crop_year_for_graph'].length == 0
                          ? 'true========'
                          : 'false=========');

                      setState(() {
                        queryText =
                            (num.parse(predict.toString()) * 1000).toString();
                        isLoading = false;
                        showGraph = true;
                        graphHasDecoded['crop_year_for_graph'].length == 0
                            ? graphHasData = false
                            : graphHasData = true;
                        if (graphHasData == false) {
                          wrongInputs();
                        }
                      });
                    },
                    color: Colors.green[400],
                    child: Text(
                      getTranslated(context, 'predict'),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                show
                    ? isLoading
                        ? Center(
                            child: CircularProgressIndicator(),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              getTranslated(context, 'yield prediction') +
                                  ' : ' +
                                  getNumberTranslated(
                                      context, queryText.toString()) +
                                  getTranslated(context, 'kg'),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                          )
                    : Container(),
                showGraph
                    ? Divider(
                        color: Colors.greenAccent,
                        thickness: 1.5,
                      )
                    : Container(),
                graphHasData
                    ? Text(
                        ' **The graph data analysis is purely based on previous year yeild and no prediction or ML model is used.',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 10),
                      )
                    : Container(),
                showGraph
                    ? Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Container(
                          decoration:
                              BoxDecoration(border: Border.all(width: 1)),
                          child: graphHasData
                              ? new FutureBuilder<dynamic>(
                                  future: getdata(
                                      'http://192.168.0.104:7000/yeildpredictor_graph'), // a Future<String> or null
                                  builder: (BuildContext context,
                                      AsyncSnapshot<dynamic> snapshot) {
                                    switch (snapshot.connectionState) {
                                      case ConnectionState.none:
                                        return new Text(
                                            'Press button to start');
                                      case ConnectionState.waiting:
                                        return new Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      default:
                                        if (snapshot.hasError)
                                          return new Text(
                                              'Error: ${snapshot.error}');
                                        else {
                                          var data = jsonDecode(snapshot.data);
                                          List cropYear =
                                              data['crop_year_for_graph'];
                                          List cropProduction =
                                              data['production_for_graph'];
                                          print(cropYear[0] == null
                                              ? 'true'
                                              : 'false');

                                          return cropYear[0] == null
                                              ? Text(
                                                  'Graph not avilable , Try another inputs')
                                              : Graph(
                                                  data: graphData(cropYear,
                                                      cropProduction));
                                        }
                                    }
                                  },
                                )
                              : Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                      'Graph not avilable , Try another inputs'),
                                ),
                        ),
                      )
                    : Container()
              ],
            ),
          ),
        ],
      ),
    );
  }
}