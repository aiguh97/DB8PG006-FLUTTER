import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:just_audio/just_audio.dart';

class ScreenTwo extends StatefulWidget {
  final int levelNumber;
  const ScreenTwo({super.key, required this.levelNumber});

  @override
  State<ScreenTwo> createState() => _ScreenTwoState();
}

class _ScreenTwoState extends State<ScreenTwo> {
  final AudioPlayer player = AudioPlayer();
  final FlutterTts flutterTts = FlutterTts();

  late OnDeviceTranslator translator;

  String subTitle = '';
  String questionEn = '';
  String questionTranslated = '';
  List<Map<String, dynamic>> options = [];

  String selectedOption = '';
  bool isCorrectedAnswerSelected = false;

  static const Color greenPrimary = Color(0xFF4CAF50);

  @override
  void initState() {
    super.initState();
    _setup();
  }

  Future<void> _setup() async {
    await _initTranslator();
    await _initializeTts();
    await _fetchTask();
  }

  Future<void> _initTranslator() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();
    final userLang = userDoc['language'] ?? 'German';
    final targetLang = _mapLanguageToEnum(userLang);

    translator = OnDeviceTranslator(
      sourceLanguage: TranslateLanguage.english,
      targetLanguage: targetLang,
    );
  }

  TranslateLanguage _mapLanguageToEnum(String lang) {
    switch (lang.toLowerCase()) {
      case 'german':
        return TranslateLanguage.german;
      case 'spanish':
        return TranslateLanguage.spanish;
      case 'french':
        return TranslateLanguage.french;
      case 'italian':
        return TranslateLanguage.italian;
      case 'korean':
        return TranslateLanguage.korean;
      default:
        return TranslateLanguage.german;
    }
  }

  Future<void> _initializeTts() async {
    final ttsLang = _getTtsCode(translator.targetLanguage);
    await flutterTts.setLanguage(ttsLang);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setPitch(1.0);
  }

  String _getTtsCode(TranslateLanguage lang) {
    switch (lang) {
      case TranslateLanguage.spanish:
        return 'es';
      case TranslateLanguage.french:
        return 'fr';
      case TranslateLanguage.italian:
        return 'it';
      case TranslateLanguage.korean:
        return 'ko';
      default:
        return 'de';
    }
  }

  @override
  void dispose() {
    super.dispose();
    player.dispose();
    flutterTts.stop();
    translator.close();
  }

  Future<void> _fetchTask() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('levels')
          .doc('level_${widget.levelNumber}')
          .collection('tasks')
          .doc('task_2')
          .get();
      if (doc.exists) {
        subTitle = doc['subtitle'] ?? '';
        questionEn = doc['question'] ?? '';

        final originalOptions = List<Map<String, dynamic>>.from(
          doc['options'] ?? [],
        );

        questionTranslated = await translator.translateText(questionEn);

        options = [];
        for (var opt in originalOptions) {
          final translatedText = await translator.translateText(opt['text']);
          options.add({
            'textEn': opt['text'],
            'textTranslated': translatedText,
            'isCorrext': opt['isCorrect'],
          });
        }
        setState(() {});
      }
    } catch (e) {
      throw ('Error fetching or translating task: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
