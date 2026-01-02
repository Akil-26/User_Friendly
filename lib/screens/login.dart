import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal,
        body: Center(
          child: Column(
            children: [
              CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('images/resume_profile_pic-2-removebg-preview.png'),
               ),
              SizedBox(height: 10),
              Text(
                'Akil',
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Myfont',
                  letterSpacing: 1,
                ),
              ),
              Text(
                'Flutter Developer',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Myfont',
                  letterSpacing: 2.5,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(18.0),
                child:Card(
                  child: Row(
                    children: [
                      ListTile(
                        leading: Icon(Icons.phone,color:Colors.black,),
                        title: Text('+91 7904122501',),
                        ),
                      ListTile(
                        leading: Icon(Icons.email,color:Colors.black,),
                        title: Text('akil20052622@gmail.com',),
                        ),
                    ],
                  ),
                  ),
                ),
            ],
          ),
        )
      );
  }
}