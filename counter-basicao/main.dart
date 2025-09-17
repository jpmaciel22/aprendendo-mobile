import 'package:flutter/material.dart';
void main(){
  runApp(const App());
}

class App extends StatelessWidget{
  const App({Key? key}): super(key: key);
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void decrement(){
    setState(() {
      counter--;
    });
  }

  void increment(){
    setState(() {
      counter++;
    });
  }

  int counter = 0;

  @override
  Widget build(BuildContext context) {
    print("BUILDEI");
    return Scaffold(
        backgroundColor: Colors.black38,
        body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/images/seal.jpeg'),
                  fit: BoxFit.fill
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Text("Oi Tudo Bem?", style: TextStyle(fontSize: 26, color: Color(0xffff0055), fontWeight: FontWeight.w500, letterSpacing: 10),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Text("$counter", style: TextStyle(fontSize: 40, color: Colors.white),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor: counter == 0 ? Colors.white.withAlpha(50) : Colors.white,
                          fixedSize: const Size(30,30),
                          shape: RoundedRectangleBorder(
                              side: BorderSide(color: Colors.lightGreen, width: 5),
                              borderRadius: BorderRadius.circular(10)
                          )
                      ),
                      onPressed: counter == 0 ? null : decrement,
                      child: Text(
                        "Diminui",
                        style: TextStyle(
                          color: counter == 0 ? Colors.red:Colors.black54,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    SizedBox(width: 20,),
                    TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor: counter == 10 ? Colors.green : Colors.white,
                          fixedSize: const Size(120,120),
                          shape: RoundedRectangleBorder(
                              side: BorderSide(color: Colors.lightGreen, width: 5),
                              borderRadius: BorderRadius.circular(10)
                          )
                      ),
                      onPressed: counter == 10 ? null : increment,
                      child: Text(
                        "Aumenta",
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 20,
                        ),
                      ),
                    )
                  ],
                )
              ],
            )

        )
    );
  }
}
