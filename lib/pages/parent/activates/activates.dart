import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bogcha_time/common/style/app_colors.dart';
import 'package:bogcha_time/common/style/app_style.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

class Activates extends StatefulWidget {
  const Activates({super.key});

  @override
  _ParentActivitiesPageState createState() => _ParentActivitiesPageState();
}

class _ParentActivitiesPageState extends State<Activates> {
  late Future<Map<String, Stream<QuerySnapshot>>> _activitiesFuture;

  @override
  void initState() {
    super.initState();
    _activitiesFuture = _getParentActivities();
  }

  Future<Map<String, Stream<QuerySnapshot>>> _getParentActivities() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? gardenId = prefs.getString('garden_id');
    String? childId = prefs.getString('child_id');

    if (gardenId == null) return {};

    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);
    DateTime endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    FirebaseFirestore firestore = FirebaseFirestore.instance;


    Stream<QuerySnapshot> commonActivities = firestore
        .collection('garden')
        .doc(gardenId)
        .collection('activities')
        .where('created_at', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('created_at', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .where('child_id', ) 
        .orderBy('created_at', descending: true)
        .snapshots();


    Stream<QuerySnapshot> childActivities = firestore
        .collection('garden')
        .doc(gardenId)
        .collection('activities')
        .where('created_at', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('created_at', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .where('child_id', isEqualTo: childId) 
        .orderBy('created_at', descending: true)
        .snapshots();

    return {
      "common": commonActivities,
      "child": childActivities,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.defoltColor1,
        centerTitle: true,
        title: Text(
          "Farzandingiz va umumiy tadbirlar",
          style: AppStyle.fontStyle.copyWith(
            fontSize: 20,
            color: AppColors.foregroundColor,
          ),
        ),
      ),
      body: FutureBuilder<Map<String, Stream<QuerySnapshot>>>(
        future: _activitiesFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: snapshot.data!["common"],
                  builder: (context, snapshot) {
                    return _buildActivitiesList(snapshot, "Umumiy tadbirlar");
                  },
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: snapshot.data!["child"],
                  builder: (context, snapshot) {
                    return _buildActivitiesList(snapshot, "Farzandingiz tadbirlari");
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }


  Widget _buildActivitiesList(AsyncSnapshot<QuerySnapshot> snapshot, String title) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          "$title - Hozircha tadbirlar yo‘q.",
          style: AppStyle.fontStyle.copyWith(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: snapshot.data!.docs.map((doc) {
        Map<String, dynamic> activity = doc.data() as Map<String, dynamic>;

        return _buildActivityCard(activity);
      }).toList(),
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> activity) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              activity['name'] ?? "Noma’lum tadbir",
              style: AppStyle.fontStyle.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              "⏰ Vaqti: ${activity['time'] ?? 'Noma’lum'}",
              style: AppStyle.fontStyle.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 10),
            if (activity['media_url'] != null)
              _buildVideoPlayer(activity['media_url']),
          ],
        ),
      ),
    );
  }


  Widget _buildVideoPlayer(String videoUrl) {
    return StatefulBuilder(
      builder: (context, setState) {
        VideoPlayerController controller = VideoPlayerController.network(videoUrl);
        return FutureBuilder(
          future: controller.initialize(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  AspectRatio(
                    aspectRatio: controller.value.aspectRatio,
                    child: VideoPlayer(controller),
                  ),
                  IconButton(
                    icon: Icon(
                      controller.value.isPlaying ? Icons.pause_circle_outline : Icons.play_circle_outline,
                      size: 60,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        controller.value.isPlaying ? controller.pause() : controller.play();
                      });
                    },
                  ),
                ],
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        );
      },
    );
  }
}
