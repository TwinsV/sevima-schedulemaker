import 'package:flutter/material.dart';

void main() {
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
  final List<int> _days = [1,3,7,30];
  final _inputController = TextEditingController();
  bool _showMenu = true;
  
  
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
                color: Colors.red,
                child: GridView.count(
                  crossAxisCount: 3,
                  scrollDirection: Axis.vertical,
                  children: List.generate(20, (index) => Container(
                    margin: const EdgeInsets.all(5),
                    height: 50,
                    color: Colors.black,
                  )),
                ),
              )
              ),
            
            _showMenu ? Expanded(
              flex: 3,
              child: Container(
                color: Colors.blue,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text('Buat Jadwal '),
                        Container(
                          height: ((maxH/15)*1),
                          width: maxW-150,
                          margin: EdgeInsets.only(top: 10, left:5),
                          child: TextFormField(
                            controller: _inputController,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              hintText: "example belajar HTML",
                              border: OutlineInputBorder()
                             ),
                          ),
                        ),
                      ],
                    )
                  ]),
              )
              ) : Container()
        ],
        ),        
        ]
      ),
      floatingActionButton: Align(
        alignment:_showMenu ? Alignment.bottomCenter : Alignment.bottomRight ,
        child: Container(
          margin: _showMenu ? EdgeInsets.only(bottom: ((maxH/15)*3)-50) : EdgeInsets.zero,
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
