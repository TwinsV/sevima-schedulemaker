import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';


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
  final TextEditingController _inputController = TextEditingController();
  List<FileSystemEntity> file = [];
  final FocusNode _inputFocus = FocusNode();
  bool _showMenu = true;
  bool _loading = false;
  String _selectedDay = '1';
  var jadwal = {};



  createSchedule() async{
    setState(() {
      _inputFocus.unfocus();
      _showMenu = false;
      _loading = true;
    });
    try{
  final response = await http.post(
      Uri.parse('https://api.openai.com/v1/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${dotenv.env['token']}'
      },
      body: jsonEncode(
        {
          "model": "text-davinci-003",
          "prompt": "buatkan saya jadwal " + _inputController.text + " dalam " + _selectedDay + " hari maksimal 5 tugas dalam sehari dalam format dictionary key hari ke n dan list materi secara lengkap dengan tanda double quote untuk string tugas maksimal 5 kata",
          "max_tokens": 1000,
          "temperature": 0,
          "top_p": 1,
        },
      ),
    );
    
    var _responseModel = jsonDecode(response.body);
    var responseTxt = _responseModel['choices'][0]['text'];
    var jadwal_temp = json.decode(responseTxt.toString());
    if(jadwal_temp.length > int.parse(_selectedDay)){
      jadwal = {};
      for (int i = 0; i < int.parse(_selectedDay); i++){
        var key = jadwal_temp.keys.elementAt(i);
        var value = jadwal_temp.values.elementAt(i);
        jadwal.addAll({
          key:value
        }
          );
      }
    }else{
      jadwal = jadwal_temp;
    }
    setState(() {
      jadwal;
      _inputController.text = '';
      _loading = false;
      _write(json.encode(jadwal), 'jadwal');
    });
    }catch(e){
      setState(() {
        _loading = false;
        _showToast(context, 'Terjadi Masalah Cek Koneksi Internet lalu Coba Lagi!', 50);
      });
    }
  }
   _read(String fileName) async {
    try {
      final Directory directory = await getApplicationDocumentsDirectory();
      final Directory dir = Directory('${directory.path}/data_list/');
      file = dir.listSync().toList();
      if (file.isEmpty){
        var response =  await rootBundle.loadString('assets/example.json');
        jadwal = jsonDecode(response);
      }else{
        try {
          final File file = File('${directory.path}/data_list/' + fileName + '.json');
          var response = await file.readAsString();
          jadwal = jsonDecode(response);
        } catch (e) {
          return 'error';
        }
      }  
      
    } catch (e) {
      var response =  await rootBundle.loadString('assets/example.json');
      jadwal = jsonDecode(response);
      
    }
    
  }

  _write(String text, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    bool check = File('${directory.path}/data_list/$fileName.json').existsSync();
    if(check){
      final File file = File('${directory.path}/data_list/$fileName.json');
      await file.writeAsString(text);
    }else {
      File('${directory.path}/data_list/$fileName.json').create(recursive: true);
      Directory('${directory.path}/data_list/').create(recursive: true);
      final File file = File('${directory.path}/data_list/$fileName.json');
      await file.writeAsString(text);
    }
  }



  void _showToast(BuildContext context, String text, var margin) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
        margin: EdgeInsets.only(bottom: margin),
        content: Text(text, textAlign: TextAlign.center,),
      ),
    );
  }


  @protected
  void initState() {
    super.initState();
    setState(() {
      _read('jadwal').then((d){
        debugPrint('SCHEDULE = '+jadwal.toString());
        setState(() {
          jadwal;
        });
      });
    });
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
                  children: List.generate(jadwal.length, (index) {
                    final title = jadwal.keys.elementAt(index);
                    final values = jadwal.values.elementAt(index);
                    return Container(
                    alignment: Alignment.topLeft,
                    margin: const EdgeInsets.all(10),
                    height: 150,
                    width: maxW - 20,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.red.shade300,
                    ),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            margin: const EdgeInsets.all(8),
                            child: Text('$title', style: TextStyle(fontSize: 18),))),
                        Column(
                          children: List.generate(values.length, ((index2) {
                          final number = (index2+1).toString();
                          return Align(
                            alignment: Alignment.topLeft,
                            child: Text('  $number. ${values[index2]}',
                            ),
                          );
                        })),
                      
                        )
                      ],
                    ),
                  );
                  }),
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
                        const Text('Buat Jadwal '),
                        Container(
                          height: ((maxH/15)*1) - 5,
                          width: maxW-175,
                          margin: const EdgeInsets.only(top: 10, left:5),
                          child: TextFormField(
                            controller: _inputController,
                            focusNode: _inputFocus,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                              hintText: "belajar HTML",
                              border:  OutlineInputBorder()
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


                  Center(
                    child: Container(
                          width: maxW/3,
                          height: ((maxH/15)*1) - 5,
                          child: ElevatedButton(
                            onPressed: (() {
                              
                                if(_inputController.text.isNotEmpty){
                                  createSchedule();
                                }else{
                                  debugPrint('kosong bos');
                                }
                              
                            }),
                            child: Text(
                              'Generate'  
                            )),
                        ),
                  ),
                  ]
                  ),
              )
              ) : Container()
        ],
        ),
        _loading ? Container(
          width: maxW,
          height: maxH,
          color: Colors.red.shade700,
          child: Center(child: Text("Loading...", style: TextStyle(fontSize: 18),)),
        ) : Container()       
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

