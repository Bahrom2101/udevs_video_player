import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:udevs_video_player/udevs_video_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _udevsVideoPlayerPlugin = UdevsVideoPlayer();

  playVideo() async {
    List<Season> seasons = [];
    List<Movie> movies1 = [];
    movies1.add(Movie(
      title: 'Женщина-Халк: Адвокат',
      description:
          'После переливания крови двоюродная сестра Брюса Бэннера юристка Дженнифер Уолтерс получает способность во время стресса перевоплощаться в сверхсильное существо. Дженнифер предстоит научиться управлять этим даром и применять его во благо при этом продолжать работать в недавно созданном Отделе по правам сверхлюдей.',
      image:
          'https://cdn.uzd.udevs.io/uzdigital/images/ec80c248-ddb8-4b68-98b1-0d59e9a1acdd.jpg',
      duration: 2122,
      resolutions: {
        'Auto':
            'https://cdn.uzd.udevs.io/uzdigital/videos/772a7a12977cd08a10b6f6843ae80563/master.m3u8',
        '1080p':
            'https://cdn.uzd.udevs.io/uzdigital/videos/772a7a12977cd08a10b6f6843ae80563/1080p/index.m3u8',
        '720p':
            'https://cdn.uzd.udevs.io/uzdigital/videos/772a7a12977cd08a10b6f6843ae80563/720p/index.m3u8',
        '480p':
            'https://cdn.uzd.udevs.io/uzdigital/videos/772a7a12977cd08a10b6f6843ae80563/480p/index.m3u8',
        '360p':
            'https://cdn.uzd.udevs.io/uzdigital/videos/772a7a12977cd08a10b6f6843ae80563/360p/index.m3u8',
        '240p':
            'https://cdn.uzd.udevs.io/uzdigital/videos/772a7a12977cd08a10b6f6843ae80563/240p/index.m3u8',
      },
    ));
    movies1.add(Movie(
      title: 'Женщина-Халк: Адвокат',
      description:
          'После переливания крови двоюродная сестра Брюса Бэннера юристка Дженнифер Уолтерс получает способность во время стресса перевоплощаться в сверхсильное существо. Дженнифер предстоит научиться управлять этим даром и применять его во благо при этом продолжать работать в недавно созданном Отделе по правам сверхлюдей.',
      image:
          'https://cdn.uzd.udevs.io/uzdigital/images/ec80c248-ddb8-4b68-98b1-0d59e9a1acdd.jpg',
      duration: 1669,
      resolutions: {
        'Auto':
            'https://cdn.uzd.udevs.io/uzdigital/videos/a298d71ece9105727c7c2e3bc219ef86/master.m3u8',
        '1080p':
            'https://cdn.uzd.udevs.io/uzdigital/videos/a298d71ece9105727c7c2e3bc219ef86/1080p/index.m3u8',
        '720p':
            'https://cdn.uzd.udevs.io/uzdigital/videos/a298d71ece9105727c7c2e3bc219ef86/720p/index.m3u8',
        '480p':
            'https://cdn.uzd.udevs.io/uzdigital/videos/a298d71ece9105727c7c2e3bc219ef86/480p/index.m3u8',
        '360p':
            'https://cdn.uzd.udevs.io/uzdigital/videos/a298d71ece9105727c7c2e3bc219ef86/360p/index.m3u8',
        '240p':
            'https://cdn.uzd.udevs.io/uzdigital/videos/a298d71ece9105727c7c2e3bc219ef86/240p/index.m3u8',
      },
    ));
    movies1.add(Movie(
      title: 'Женщина-Халк: Адвокат',
      description:
          'После переливания крови двоюродная сестра Брюса Бэннера юристка Дженнифер Уолтерс получает способность во время стресса перевоплощаться в сверхсильное существо. Дженнифер предстоит научиться управлять этим даром и применять его во благо при этом продолжать работать в недавно созданном Отделе по правам сверхлюдей.',
      image:
          'https://cdn.uzd.udevs.io/uzdigital/images/ec80c248-ddb8-4b68-98b1-0d59e9a1acdd.jpg',
      duration: 1669,
      resolutions: {
        'Auto':
            'https://cdn.uzd.udevs.io/uzdigital/videos/a298d71ece9105727c7c2e3bc219ef86/master.m3u8',
        '1080p':
            'https://cdn.uzd.udevs.io/uzdigital/videos/a298d71ece9105727c7c2e3bc219ef86/1080p/index.m3u8',
        '720p':
            'https://cdn.uzd.udevs.io/uzdigital/videos/a298d71ece9105727c7c2e3bc219ef86/720p/index.m3u8',
        '480p':
            'https://cdn.uzd.udevs.io/uzdigital/videos/a298d71ece9105727c7c2e3bc219ef86/480p/index.m3u8',
        '360p':
            'https://cdn.uzd.udevs.io/uzdigital/videos/a298d71ece9105727c7c2e3bc219ef86/360p/index.m3u8',
        '240p':
            'https://cdn.uzd.udevs.io/uzdigital/videos/a298d71ece9105727c7c2e3bc219ef86/240p/index.m3u8',
      },
    ));
    movies1.add(Movie(
      title: 'Женщина-Халк: Адвокат',
      description:
          'После переливания крови двоюродная сестра Брюса Бэннера юристка Дженнифер Уолтерс получает способность во время стресса перевоплощаться в сверхсильное существо. Дженнифер предстоит научиться управлять этим даром и применять его во благо при этом продолжать работать в недавно созданном Отделе по правам сверхлюдей.',
      image:
          'https://cdn.uzd.udevs.io/uzdigital/images/ec80c248-ddb8-4b68-98b1-0d59e9a1acdd.jpg',
      duration: 1669,
      resolutions: {
        'Auto':
            'https://cdn.uzd.udevs.io/uzdigital/videos/a298d71ece9105727c7c2e3bc219ef86/master.m3u8',
        '1080p':
            'https://cdn.uzd.udevs.io/uzdigital/videos/a298d71ece9105727c7c2e3bc219ef86/1080p/index.m3u8',
        '720p':
            'https://cdn.uzd.udevs.io/uzdigital/videos/a298d71ece9105727c7c2e3bc219ef86/720p/index.m3u8',
        '480p':
            'https://cdn.uzd.udevs.io/uzdigital/videos/a298d71ece9105727c7c2e3bc219ef86/480p/index.m3u8',
        '360p':
            'https://cdn.uzd.udevs.io/uzdigital/videos/a298d71ece9105727c7c2e3bc219ef86/360p/index.m3u8',
        '240p':
            'https://cdn.uzd.udevs.io/uzdigital/videos/a298d71ece9105727c7c2e3bc219ef86/240p/index.m3u8',
      },
    ));
    movies1.add(Movie(
      title: 'Женщина-Халк: Адвокат',
      description:
          'После переливания крови двоюродная сестра Брюса Бэннера юристка Дженнифер Уолтерс получает способность во время стресса перевоплощаться в сверхсильное существо. Дженнифер предстоит научиться управлять этим даром и применять его во благо при этом продолжать работать в недавно созданном Отделе по правам сверхлюдей.',
      image:
          'https://cdn.uzd.udevs.io/uzdigital/images/ec80c248-ddb8-4b68-98b1-0d59e9a1acdd.jpg',
      duration: 1669,
      resolutions: {
        'Auto':
            'https://cdn.uzd.udevs.io/uzdigital/videos/a298d71ece9105727c7c2e3bc219ef86/master.m3u8',
        '1080p':
            'https://cdn.uzd.udevs.io/uzdigital/videos/a298d71ece9105727c7c2e3bc219ef86/1080p/index.m3u8',
        '720p':
            'https://cdn.uzd.udevs.io/uzdigital/videos/a298d71ece9105727c7c2e3bc219ef86/720p/index.m3u8',
        '480p':
            'https://cdn.uzd.udevs.io/uzdigital/videos/a298d71ece9105727c7c2e3bc219ef86/480p/index.m3u8',
        '360p':
            'https://cdn.uzd.udevs.io/uzdigital/videos/a298d71ece9105727c7c2e3bc219ef86/360p/index.m3u8',
        '240p':
            'https://cdn.uzd.udevs.io/uzdigital/videos/a298d71ece9105727c7c2e3bc219ef86/240p/index.m3u8',
      },
    ));
    seasons.add(Season(title: '1 Season', movies: movies1));
    seasons.add(Season(title: '2 Season', movies: movies1));
    List<ProgramsInfo> programsInfoList = [];
    try {
      var s = await _udevsVideoPlayerPlugin.playVideo(
              playerConfig: PlayerConfiguration(
            initialResolution: {
              'Auto':
                  'https://cdn.uzd.udevs.io/uzdigital/videos/772a7a12977cd08a10b6f6843ae80563/master.m3u8'
            },
            resolutions: {
              'Auto':
                  'https://cdn.uzd.udevs.io/uzdigital/videos/772a7a12977cd08a10b6f6843ae80563/master.m3u8',
              '1080p':
                  'https://cdn.uzd.udevs.io/uzdigital/videos/772a7a12977cd08a10b6f6843ae80563/1080p/index.m3u8',
              '720p':
                  'https://cdn.uzd.udevs.io/uzdigital/videos/772a7a12977cd08a10b6f6843ae80563/720p/index.m3u8',
              '480p':
                  'https://cdn.uzd.udevs.io/uzdigital/videos/772a7a12977cd08a10b6f6843ae80563/480p/index.m3u8',
              '360p':
                  'https://cdn.uzd.udevs.io/uzdigital/videos/772a7a12977cd08a10b6f6843ae80563/360p/index.m3u8',
              '240p':
                  'https://cdn.uzd.udevs.io/uzdigital/videos/772a7a12977cd08a10b6f6843ae80563/240p/index.m3u8',
            },
            qualityText: 'Quality',
            speedText: 'Speed',
            lastPosition: 1000,
            duration: 1669,
            title: 'Женщина-Халк: Адвокат',
            isSerial: false,
            episodeButtonText: 'Episodes',
            nextButtonText: 'Next',
            seasons: seasons,
            isLive: false,
            tvProgramsText: 'Programs',
            programsInfoList: programsInfoList,
            showController: true,
            playVideoFromAsset: false,
            assetPath: 'assets/splash.mp4',
            locale: "en",
          )) ??
          'nothing';
      if (kDebugMode) {
        print('result: $s');
      }
    } on PlatformException {
      debugPrint('Failed to get platform version.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: playVideo,
            child: const Text('Play'),
          ),
        ),
      ),
    );
  }
}
