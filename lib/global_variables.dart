import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';
import 'package:meetoplay/models/meetings.dart';
  
List<Marker> globalMarkers = [];
List<Meeting> globalMeetings = [];

const orange = Color(0xffff6b35);
const pink = Color(0xfff7c59f);
const white = Color(0xffefefd0);
const darkBlue = Color(0xff004e89);
const lightBlue = Color(0xff1a659e);
const specialActionButtonColor = Color(0xfffd5b28);

const List<String> sportsList = [
  'Piłka nożna',
  'Koszykówka',
  'Tenis',
  'Siatkówka',
  'Bieganie',
  'Pływanie',
  'Rowery',
];

final currentUser = FirebaseAuth.instance.currentUser;
