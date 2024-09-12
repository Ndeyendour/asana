import 'package:asana/screen/login_page.dart';
import 'package:flutter/material.dart';

class BackgroundImageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          // Image de fond
          Image.asset(
            'images/ASANA.png',
            fit: BoxFit.cover,
          ),
          // Contenu superposé à l'image de fond
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Pousse le contenu vers le bas
            children: <Widget>[
              Spacer(), // Espace flexible pour pousser le contenu vers le bas
              // Contenu en bas de la page
              Column(
                children: <Widget>[
                  Text(
                    'Bienvenue',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Organisez vos tâches efficacement',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Navigation vers l'écran de connexion
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    child: Text('Commencer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                      textStyle: TextStyle(fontSize: 20),
                    ),
                  ),
                  SizedBox(height: 30), // Espacement supplémentaire en bas
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
