import 'package:asana/const/colors.dart';
import 'package:asana/data/firestor.dart';
import 'package:asana/model/notes_model.dart';
import 'package:asana/screen/edit_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:share_plus/share_plus.dart';
import 'package:asana/main.dart'; // Importez votre instance de notification

// ignore: must_be_immutable
class Task_Widget extends StatefulWidget {
  Note _note;
  Task_Widget(this._note, {super.key});

  @override
  State<Task_Widget> createState() => _Task_WidgetState();
}

class _Task_WidgetState extends State<Task_Widget> {
  // Fonction pour partager une tâche
  void shareTask(String title, String subtitle) {
    Share.share('Check out this task: $title\nSubtitle: $subtitle');
  }

  // Fonction pour planifier une notification
  void scheduleNotification(String title, String body, DateTime scheduledTime) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your_channel_id', 'your_channel_name', 
      importance: Importance.max, priority: Priority.high,
    );

    var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.schedule(
      0, // ID de la notification
      title, // Titre
      body, // Corps
      scheduledTime, // Heure planifiée
      platformChannelSpecifics, // Détails de la notification
      androidAllowWhileIdle: true,
    );
  }

  // Fonction pour choisir la date et l'heure
  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        final DateTime selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        // Planifiez la notification
        scheduleNotification(widget._note.title, widget._note.subtitle, selectedDateTime);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDone = widget._note.isDon;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Container(
        width: double.infinity,
        height: 130,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              // image
              imageee(),
              SizedBox(width: 15),
              // title and subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Title and Notification Button
                        Row(
                          children: [
                            Text(
                              widget._note.title,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 10),
                            GestureDetector(
                              onTap: () {
                                _selectDateTime(context); // Appel de la fonction de sélection de la date et de l'heure
                              },
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Icon(
                                  Icons.alarm,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Checkbox(
                          activeColor: custom_green,
                          value: isDone,
                          onChanged: (value) {
                            setState(() {
                              isDone = !isDone;
                            });
                            Firestore_Datasource()
                                .isdone(widget._note.id, isDone);
                          },
                        )
                      ],
                    ),
                    Text(
                      widget._note.subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey.shade400
                      ),
                    ),
                    Spacer(),
                    edit_time()
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget edit_time() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 90,
            height: 28,
            decoration: BoxDecoration(
              color: custom_green,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              child: Row(
                children: [
                  Image.asset('images/icon_time.png'),
                  SizedBox(width: 10),
                  Text(
                    widget._note.time,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 20),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => Edit_Screen(widget._note),
              ));
            },
            child: Container(
              width: 90,
              height: 28,
              decoration: BoxDecoration(
                color: Color(0xffE2F6F1),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: Row(
                  children: [
                    Image.asset('images/icon_edit.png'),
                    SizedBox(width: 10),
                    Text(
                      'Edit',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              shareTask(widget._note.title, widget._note.subtitle);
            },
            child: Container(
              width: 70, // Réduction de la largeur du bouton de partage
              height: 24, // Réduction de la hauteur du bouton de partage
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 4,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center, // Centrage du contenu
                  children: [
                    Icon(Icons.share, color: Colors.white, size: 15), // Réduction de la taille de l'icône
                    SizedBox(width: 6),
                    Text(
                      'Share',
                      style: TextStyle(
                        fontSize: 8, // Réduction de la taille du texte
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget imageee() {
    return Container(
      height: 130,
      width: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        image: DecorationImage(
          image: AssetImage('images/${widget._note.image}.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
