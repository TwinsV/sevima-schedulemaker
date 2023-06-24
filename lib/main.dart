import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;


Future<void> main() async{
  await dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Schedule Maker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Schedule Maker'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;
   
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}



class _MyHomePageState extends State<MyHomePage> {
  static const List<String> _days = ['1','3','5','7'];
  TextEditingController _inputController = TextEditingController();
  FocusNode _inputFocus = FocusNode();
  bool _showMenu = true;
  String _selectedDay = '1';
  
  createSchedule() async{
  final response = await http.post(
      Uri.parse('https://api.openai.com/v1/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${dotenv.env['token']}'
      },
      body: jsonEncode(
        {
          "model": "text-davinci-003",
          "prompt": "buatkan saya jadwal " + _inputController.text + " dalam " + _selectedDay + " hari maksimal 5 tugas dalam sehari dalam format dictionary key hari ke n dan list materi secara lengkap dengan tanda double quote untuk string",
          "max_tokens": 1000,
          "temperature": 0,
          "top_p": 1,
        },
      ),
    );
    
    setState(() {
      var _responseModel = jsonDecode(response.body);
      var responseTxt = _responseModel['choices'][0]['text'];
      Map<String, dynamic> jadwal = json.decode(responseTxt.toString());
      debugPrint(responseTxt);
      print('jadwal = ${jadwal.toString()}');
      print(jadwal.length);
    });
  }
  
  @protected
  void initState() {
    super.initState();
    
  }
  @override
  Widget build(BuildContext context) {
    double maxW = MediaQuery.of(context).size.width;
    double maxH = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(widget.title, textAlign: TextAlign.center,)),
      ),
      body: Stack(
        children: [
          Column(
          children: [
            Expanded(
              flex: _showMenu ? 12 : 15,
              child: Container(
                // margin: EdgeInsets.only(top: 10),
                color: Colors.red.shade100,
                child: ListView(
                  scrollDirection: Axis.vertical,
                  children: List.generate(7, (index) => Container(
                    alignment: Alignment.topLeft,
                    margin: const EdgeInsets.all(10),
                    height: 150,
                    width: maxW - 20,
                    color: Colors.red.shade300,
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.topCenter,
                          child: Text('\nTitle\n', style: TextStyle(fontSize: 16),)),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Column(
                            children: List.generate(5, ((index) {
                            return Text('data',);
                          })),
                      
                          ),
                        )
                      ],
                    ),
                  )),
                ),
              )
              ),
            
            _showMenu ? Expanded(
              flex: _inputFocus.hasFocus ? 12 : 3,
              child: Container(
                color: Colors.white70,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text('Buat Jadwal '),
                        Container(
                          height: ((maxH/15)*1) - 5,
                          width: maxW-175,
                          margin: EdgeInsets.only(top: 10, left:5),
                          child: TextFormField(
                            controller: _inputController,
                            focusNode: _inputFocus,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              hintText: "example belajar HTML",
                              border: OutlineInputBorder()
                             ),
                             onEditingComplete: ((){
                              setState(() {
                                _inputFocus.unfocus();
                              });
                             }),
                          ),
                        ),
                        
                        DropdownButton<String>(
                          value: _selectedDay,
                          items: _days.map((String value){
                            return DropdownMenuItem(
                              value: value,
                              child: Container(
                                width: 50,
                                height: ((maxH/15)*1) - 5,
                                child: Center(child: Text(" " +value+' Hari', textAlign: TextAlign.center,)),
                              ));
                        }).toList(), onChanged: ((_newValue){
                          setState(() {
                            if(_newValue != null){
                              _selectedDay = _newValue;
                            }
                          });
                        })),
                      ],
                    ),


                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(2, ((index) {
                      return Container(
                        width: maxW/3,
                        height: ((maxH/15)*1) - 5,
                        child: ElevatedButton(
                          onPressed: (() {
                            if(index == 1){
                              if(_inputController.text.isNotEmpty){
                                createSchedule();
                              }else{
                                debugPrint('kosong bos');
                              }
                            }
                          }),
                          child: Text(
                            index == 0 ? 'Info' : 'Generate'  
                          )),
                      );
                    }))
                    ,)

                  ]
                  ),
              )
              ) : Container()
        ],
        ),        
        ]
      ),
      floatingActionButton: Align(
        alignment:_showMenu ? Alignment.bottomCenter : Alignment.bottomRight ,
        child: Container(
          margin: _showMenu && _inputFocus.hasFocus ? EdgeInsets.only(bottom: ((maxH/15)*3)-30) : _showMenu ? EdgeInsets.only(bottom: ((maxH/15)*3)-50) : EdgeInsets.zero,
          child: FloatingActionButton(
            mini: true,
              onPressed: (() {
                setState(() {
                      if(_showMenu){
                        _showMenu = false;
                      }else{
                        _showMenu = true;
                      }
                    });
              }),
              child: Icon(
                _showMenu ? Icons.arrow_drop_down : Icons.arrow_drop_up
              ),
                  
            ),
        ),
      ),
    );
  }
}

