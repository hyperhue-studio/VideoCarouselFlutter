import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Carrusel de vídeos con controles',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const MyHomePage(title: 'Carrusel de vídeos con controles'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late PageController _pageController;
  late List<VideoPlayerController> _controllers;
  late Future<void> _initializeVideoPlayerFuture;
  int _currentPage = 0;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);
    _controllers = [
      VideoPlayerController.asset('assets/videos/testvid1.mp4'),
      VideoPlayerController.asset('assets/videos/testvid2.mp4'),
      VideoPlayerController.asset('assets/videos/testvid3.mp4'),
    ];
    _initializeVideoPlayerFuture = Future.wait(
      _controllers.map((controller) => controller.initialize()),
    );

    _pageController.addListener(_onPageChanged);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _controllers.forEach((controller) {
      controller.dispose();
    });
    super.dispose();
  }

  void _onPageChanged() {
    int newPage = _pageController.page!.round();
    if (newPage != _currentPage) {
      setState(() {
        // Detener y reiniciar el vídeo actual
        _stopVideo(_currentPage);
        _currentPage = newPage;
      });
    }
  }

  void _playPauseVideo(int index) {
    if (_controllers[index].value.isPlaying) {
      _controllers[index].pause();
      setState(() {
        _isPlaying = false;
      });
    } else {
      _controllers[index].play();
      setState(() {
        _isPlaying = true;
      });
    }
  }

  void _stopVideo(int index) {
    _controllers[index].pause();
    _controllers[index].seekTo(Duration.zero);
    setState(() {
      _isPlaying = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FutureBuilder(
              future: _initializeVideoPlayerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return AspectRatio(
                    aspectRatio: _controllers[_currentPage].value.aspectRatio,
                    child: VideoPlayer(_controllers[_currentPage]),
                  );
                } else {
                  return const CircularProgressIndicator();
                }
              },
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      if (_currentPage > 0) {
                        _stopVideo(_currentPage);
                        _currentPage--;
                        _pageController.animateToPage(
                          _currentPage,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    });
                  },
                  icon: const Icon(Icons.arrow_back_ios),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _playPauseVideo(_currentPage);
                    });
                  },
                  icon: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      if (_currentPage < _controllers.length - 1) {
                        _stopVideo(_currentPage);
                        _currentPage++;
                        _pageController.animateToPage(
                          _currentPage,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    });
                  },
                  icon: const Icon(Icons.arrow_forward_ios),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Controles de reproducción
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _controllers[_currentPage].seekTo(Duration.zero);
                      _controllers[_currentPage].play();
                    });
                  },
                  icon: const Icon(Icons.replay),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _controllers[_currentPage].pause();
                    });
                  },
                  icon: const Icon(Icons.stop),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
