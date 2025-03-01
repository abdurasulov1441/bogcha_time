import 'package:bogcha_time/app/router.dart';
import 'package:bogcha_time/common/style/app_colors.dart';
import 'package:bogcha_time/common/style/app_style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';

class GardenActivitiesPage extends StatefulWidget {
  const GardenActivitiesPage({super.key});

  @override
  _GardenActivitiesPageState createState() => _GardenActivitiesPageState();
}

class _GardenActivitiesPageState extends State<GardenActivitiesPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Map<String, VideoPlayerController> _videoControllers = {};
  final String _today = DateFormat('yyyy-MM-dd').format(DateTime.now());

  /// 🔹 Получение `gardenId`
  String? _getGardenId() {
    return _auth.currentUser?.uid; // ✅ У каждого сада `UID` = `gardenId`
  }

  /// 🔹 Получение списка сегодняшних событий сада
 Stream<QuerySnapshot> _getTodayActivities() {
  final String? gardenId = _getGardenId();
  if (gardenId == null) return const Stream.empty();

  DateTime now = DateTime.now();
  DateTime startOfDay = DateTime(now.year, now.month, now.day);
  DateTime endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

  return _firestore
      .collection('garden')
      .doc(gardenId)
      .collection('activities')
      .where('created_at', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
      .where('created_at', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
      .orderBy('created_at', descending: true)
      .snapshots();
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.foregroundColor),
            onPressed: () {
              // 📌 Переход на страницу добавления события
              context.push(Routes.gardenAddAcitivitiesPage);
            },
          ),
        ],
        backgroundColor: AppColors.defoltColor1,
        centerTitle: true,
        title: Text(
          "Bugungi tadbirlar",
          style: AppStyle.fontStyle.copyWith(
            fontSize: 20,
            color: AppColors.foregroundColor,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getTodayActivities(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "Hozircha bugungi tadbirlar yo‘q.",
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> activity =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;
              String activityId = snapshot.data!.docs[index].id;
              String mediaUrl = activity['media_url'];

              return Container(
                margin: const EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      offset: const Offset(3, 3),
                      blurRadius: 5,
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.8),
                      offset: const Offset(-3, -3),
                      blurRadius: 5,
                    ),
                  ],
                ),
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
                      Row(
                        children: [
                          const Icon(Icons.access_time, color: Colors.redAccent, size: 18),
                          const SizedBox(width: 5),
                          Text(
                            activity['time'] ?? 'Noma’lum',
                            style: AppStyle.fontStyle.copyWith(fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // 📌 Видео в Neumorphism стиле
                      _buildVideoPlayer(activityId, mediaUrl),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// 📌 **Компонент для видео (каждое видео с отдельным контроллером)**
  Widget _buildVideoPlayer(String activityId, String videoUrl) {
    if (!_videoControllers.containsKey(activityId)) {
      _videoControllers[activityId] = VideoPlayerController.network(videoUrl)
        ..initialize().then((_) {
          setState(() {}); // Перерисовка при инициализации
        });
    }

    VideoPlayerController controller = _videoControllers[activityId]!;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(3, 3),
            blurRadius: 5,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            offset: const Offset(-3, -3),
            blurRadius: 5,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: VideoPlayer(controller),
            ),
          ),
          IconButton(
            icon: Icon(
              controller.value.isPlaying
                  ? Icons.pause_circle_outline
                  : Icons.play_circle_outline,
              size: 60,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _stopAllVideos();
                controller.value.isPlaying ? controller.pause() : controller.play();
              });
            },
          ),
        ],
      ),
    );
  }

  /// 📌 **Функция для остановки всех видео**
  void _stopAllVideos() {
    for (var controller in _videoControllers.values) {
      if (controller.value.isPlaying) {
        controller.pause();
      }
    }
  }
}
