import 'package:asana/const/colors.dart';
import 'package:asana/data/firestor.dart';
import 'package:asana/model/notes_model.dart';
import 'package:asana/screen/edit_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

// ignore: must_be_immutable
class Task_Widget extends StatefulWidget {
  final Note _note;
  Task_Widget(this._note, {super.key});

  @override
  State<Task_Widget> createState() => _Task_WidgetState();
}

class _Task_WidgetState extends State<Task_Widget> {
  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  // Initialiser les notifications
  void _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    tz.initializeTimeZones(); // Initialisation des fuseaux horaires pour planifier des notifications
  }

  // Fonction pour partager une tâche
  void shareTask(String title, String subtitle) {
    Share.share('Check out this task: $title\nSubtitle: $subtitle');
  }

  // Fonction pour planifier une notification
  void scheduleNotification(String title, String body, DateTime scheduledTime) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      importance: Importance.max,
      priority: Priority.high,
    );

    var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0, // ID de la notification
      title, // Titre
      body, // Corps
      tz.TZDateTime.from(scheduledTime, tz.local), // Heure planifiée convertie en TZDateTime
      platformChannelSpecifics, // Détails de la notification
      androidAllowWhileIdle: true, // Permettre les notifications en veille
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
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

  // Méthode pour obtenir la couleur en fonction de la priorité
  Color getPriorityColor(String priority) {
    switch (priority) {
      case 'Haute':
        return Colors.red; // Couleur rouge pour haute priorité
      case 'Moyenne':
        return Colors.orange; // Couleur orange pour priorité moyenne
      case 'Faible':
        return Colors.green; // Couleur verte pour basse priorité
      default:
        return Colors.grey; // Couleur par défaut pour les priorités non spécifiées
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
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 100),
                            GestureDetector(
                              onTap: () {
                                _selectDateTime(context); // Appel de la fonction de sélection de la date et de l'heure
                              },
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: Colors.yellow,
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
                            Firestore_Datasource().isdone(widget._note.id, isDone);
                          },
                        ),
                      ],
                    ),
                    Text(
                      widget._note.subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    Spacer(),
                    Row(
                      children: [
                        // Affichage de la couleur de priorité
                        Container(
                          width: 13,
                          height: 13,
                          decoration: BoxDecoration(
                            color: getPriorityColor(widget._note.priority ?? 'Moyenne'),
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 10),
                        edit_time(),
                      ],
                    ),
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
            width: 45,
            height: 20,
            decoration: BoxDecoration(
              color: custom_green,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  Image.asset('images/icon_time.png'),
                  SizedBox(width: 5),
                  Text(
                    widget._note.time,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => Edit_Screen(widget._note),
              ));
            },
            child: Container(
              width: 50,
              height: 20,
              decoration: BoxDecoration(
                color: Color(0xffE2F6F1),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                child: Row(
                  children: [
                    Image.asset('images/icon_edit.png'),
                    SizedBox(width: 5),
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
              width: 40, // Réduction de la largeur du bouton de partage
              height: 20, // Réduction de la hauteur du bouton de partage
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 231, 9, 175),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.share, color: Colors.white, size: 16), // Icône de partage
                    SizedBox(width: 4),
                    // // Text(
                    // //   'Share',
                    // //   style: TextStyle(
                    // //     color: Colors.white,
                    // //     fontSize: 5,
                    // //     fontWeight: FontWeight.bold,
                    // //   ),
                    // ),
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