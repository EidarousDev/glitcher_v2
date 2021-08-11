import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:glitcher/screens/chats/audio_player.dart';
import 'package:glitcher/style/colors.dart';
import 'package:provider/provider.dart';

typedef void OnError(Exception exception);

enum PlayerState { stopped, playing, paused }

class AudioMessagePlayer extends StatefulWidget {
  final String url;
  AudioMessagePlayer({Key key, @required this.url}) : super(key: key);

  @override
  _AudioMessagePlayerState createState() => _AudioMessagePlayerState();
}

class _AudioMessagePlayerState extends State<AudioMessagePlayer> {
  _AudioMessagePlayerState();

  MyAudioPlayer _myAudioPlayer;

  get isPlaying => _myAudioPlayer.isPlaying;

  @override
  void initState() {
    super.initState();
    _myAudioPlayer = MyAudioPlayer(urlList: [widget.url]);
  }

  @override
  void dispose() {
    _myAudioPlayer.stop();
    super.dispose();
  }

  Future play() async {
    print('audio url: ${widget.url}');
    await _myAudioPlayer.play();
  }

  Future pause() async {
    await _myAudioPlayer.pause();
  }

  Future stop() async {
    await _myAudioPlayer.stop();
  }

  Widget _buildPlayer() => Consumer<MyAudioPlayer>(
      builder: (context, myAudioPlayer, child) => Container(
            padding: EdgeInsets.all(0),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              !isPlaying
                  ? IconButton(
                      onPressed: isPlaying ? null : () => play(),
                      iconSize: 24.0,
                      icon: Icon(Icons.play_arrow),
                      color: kDarkCard,
                    )
                  : IconButton(
                      onPressed: isPlaying ? () => pause() : null,
                      iconSize: 24.0,
                      icon: Icon(Icons.pause),
                      color: kDarkCard,
                    ),
              myAudioPlayer.duration == null
                  ? Container()
                  : SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: Colors.grey.shade400,
                        thumbColor: kDarkCard,
                        trackHeight: 3.0,
                        thumbShape:
                            RoundSliderThumbShape(enabledThumbRadius: 6.0),
                        overlayShape:
                            RoundSliderOverlayShape(overlayRadius: 12.0),
                      ),
                      child: Slider(
                          value: myAudioPlayer.position?.inMilliseconds
                                  ?.toDouble() ??
                              0.0,
                          onChanged: (double value) {
                            myAudioPlayer
                                .seek(Duration(seconds: value ~/ 1000));

                            if (!isPlaying) {
                              play();
                            }
                          },
                          min: 0.0,
                          max: myAudioPlayer.duration != null
                              ? myAudioPlayer.duration?.inMilliseconds
                                  ?.toDouble()
                              : 1.7976931348623157e+308),
                    ),
            ]),
          ));

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MyAudioPlayer>(
        create: (context) => _myAudioPlayer, child: _buildPlayer());
  }
}
