import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:translator/translator.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class TranslatePage extends StatefulWidget {
  const TranslatePage({Key? key}) : super(key: key);

  @override
  _TranslatePageState createState() => _TranslatePageState();
}

class _TranslatePageState extends State<TranslatePage> {
  final translator = GoogleTranslator();
  final FlutterTts flutterTts = FlutterTts();

  String _inputText = '';
  String _outputText = '';
  String _selectedLanguage = 'en';
  final List<Map<String, String>> _languages = [
    {'name': 'Inglês', 'code': 'en', 'flag': '🇺🇸'},
    {'name': 'Espanhol', 'code': 'es', 'flag': '🇪🇸'},
    {'name': 'Francês', 'code': 'fr', 'flag': '🇫🇷'},
    {'name': 'Italiano', 'code': 'it', 'flag': '🇮🇹'},
    {'name': 'Alemão', 'code': 'de', 'flag': '🇩🇪'},
    {'name': 'Japonês', 'code': 'ja', 'flag': '🇯🇵'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Translate&Speak'),
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.black
        ),
      ),
      body: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background_image.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 22),
                _buildInputTextField(),
                const SizedBox(height: 22),
                _buildLanguageSelector(),
                const SizedBox(height: 22),
                _buildTranslateButton(),
                const SizedBox(height: 22),
                _buildOutputText(),
                const SizedBox(height: 22),
                _buildSpeakButton(),
                const SizedBox(height: 22),
              ],
            ),
          ),
        ),
    );
  }

  Widget _buildOutputText() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 22),
      shadowColor: Colors.black,
      elevation: 12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.input, size: 24),
            title: const Text(
              'Original:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              _inputText,
              style: const TextStyle(fontSize: 18),
            ),
          ),
          const Divider(height: 0),
          ListTile(
            leading: const Icon(Icons.output, size: 24),
            title: const Text(
              'Tradução:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              _outputText,
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeakButton() {
    bool isLoading = false;

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.5),
            spreadRadius: -3,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () async {
          setState(() {
            isLoading = true;
          });

          await flutterTts.setLanguage(_selectedLanguage);
          await flutterTts.speak(_outputText);

          setState(() {
            isLoading = false;
          });
        },
        icon: isLoading
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: Colors.white,
          ),
        )
            : const Icon(Icons.volume_up),
        label: const Text(
          'Ouvir tradução',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }


  Future<void> _translate() async {
    try {
      final translation =
      await translator.translate(_inputText, to: _selectedLanguage);
      setState(() {
        _outputText = translation.text;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error translating: $e');
      }
    }
  }

  Widget _buildTranslateButton() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.5),
            spreadRadius: -3,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () async {
          await _translate();
        },
        icon: const Icon(Icons.translate),
        label: const Text('Traduzir', style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold
        )),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.5),
            spreadRadius: -3,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: DropdownButton<String>(
          isExpanded: true,
          value: _selectedLanguage,
          underline: const SizedBox(),
          icon: const Icon(Icons.arrow_drop_down),
          iconSize: 30,
          style: const TextStyle(fontSize: 22, color: Colors.black),
          items: _languages
              .map((language) => DropdownMenuItem<String>(
            value: language['code'],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  language['name']!,
                  style: const TextStyle(fontSize: 22),
                ),
                Text(
                  language['flag']!,
                  style: const TextStyle(fontSize: 24),
                ),
              ],
            ),
          ))
              .toList(),
          onChanged: (selectedLanguage) {
            setState(() {
              _selectedLanguage = selectedLanguage!;
            });
          },
        ),
      ),
    );
  }

  Widget _buildInputTextField() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 22),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.3),
            spreadRadius: -3,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.grey[400]!),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _inputText = value;
                  });
                },
                maxLines: null,
                style: const TextStyle(fontSize: 18),
                decoration: const InputDecoration(
                  hintText: 'Digite ou fale o texto',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 45,
            height: 45,
            child: Container(
              padding: const EdgeInsets.all(2.0),
              child: ElevatedButton(
                onPressed: _startRecording,
                style: ElevatedButton.styleFrom(
                  primary: const Color.fromRGBO(180, 20, 20, 1),
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(0),
                ),
                child: const Icon(
                  Icons.mic,
                  size: 30,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10,)
        ],
      ),
    );
  }

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isRecording = false;

  void _startRecording() async {
    if (!_isRecording) {
      _isRecording = true;
      bool available = await _speech.initialize();
      if (available) {
        _speech.listen(
          onResult: (result) {
            setState(() {
              _inputText = result.recognizedWords;
            });
          },
          cancelOnError: true, // adiciona esta linha para cancelar a gravação em caso de erro
        );
      }
    } else {
      _isRecording = false;
      _speech.stop();
    }
  }
}
