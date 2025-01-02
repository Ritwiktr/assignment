import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';

enum AudioStatus { initial, loading, playing, paused, completed, error }

class AudioState {
  final AudioStatus status;
  final Duration position;
  final Duration duration;
  final String? error;
  final String currentTrack;
  final bool isMinimized;
  final double volume;
  final bool isShuffled;
  final bool isLooping;

  AudioState({
    this.status = AudioStatus.initial,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.error,
    this.currentTrack = '',
    this.isMinimized = false,
    this.volume = 1.0,
    this.isShuffled = false,
    this.isLooping = false,
  });

  AudioState copyWith({
    AudioStatus? status,
    Duration? position,
    Duration? duration,
    String? error,
    String? currentTrack,
    bool? isMinimized,
    double? volume,
    bool? isShuffled,
    bool? isLooping,
  }) {
    return AudioState(
      status: status ?? this.status,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      error: error ?? this.error,
      currentTrack: currentTrack ?? this.currentTrack,
      isMinimized: isMinimized ?? this.isMinimized,
      volume: volume ?? this.volume,
      isShuffled: isShuffled ?? this.isShuffled,
      isLooping: isLooping ?? this.isLooping,
    );
  }
}

abstract class AudioEvent {}

class InitializeAudio extends AudioEvent {
  final String assetPath;
  InitializeAudio(this.assetPath);
}

class PlayAudio extends AudioEvent {}

class PauseAudio extends AudioEvent {}

class StopAudio extends AudioEvent {}

class ToggleMinimizedPlayer extends AudioEvent {}

class PlayNextTrack extends AudioEvent {}

class PlayPreviousTrack extends AudioEvent {}

class ToggleShuffle extends AudioEvent {}

class ToggleLoop extends AudioEvent {}

class SeekAudio extends AudioEvent {
  final Duration position;
  SeekAudio(this.position);
}

class SetVolume extends AudioEvent {
  final double volume;
  SetVolume(this.volume);
}

class AudioBloc extends Bloc<AudioEvent, AudioState> {
  AudioPlayer? _audioPlayer;
  final List<String> _playlist = [
    'assets/audio/audio1.mp3',
    'assets/audio/audio2.mp3',
    'assets/audio/audio3.mp3',
    'assets/audio/audio4.mp3',
  ];
  List<String> _shuffledPlaylist = [];
  bool _isInitialized = false;

  AudioBloc() : super(AudioState()) {
    _initAudioPlayer();

    on<InitializeAudio>(_onInitializeAudio);
    on<PlayAudio>(_onPlayAudio);
    on<PauseAudio>(_onPauseAudio);
    on<StopAudio>(_onStopAudio);
    on<SeekAudio>(_onSeekAudio);
    on<ToggleMinimizedPlayer>(_onToggleMinimizedPlayer);
    on<PlayNextTrack>(_onPlayNextTrack);
    on<PlayPreviousTrack>(_onPlayPreviousTrack);
    on<SetVolume>(_onSetVolume);
    on<ToggleShuffle>(_onToggleShuffle);
    on<ToggleLoop>(_onToggleLoop);

    _shuffledPlaylist = List.from(_playlist);
  }

  void _initAudioPlayer() async {
    if (_isInitialized) return;

    _audioPlayer = AudioPlayer();
    _isInitialized = true;

    _audioPlayer?.positionStream.listen((position) {
      if (!isClosed) {
        emit(state.copyWith(position: position));
      }
    });

    _audioPlayer?.durationStream.listen((duration) {
      if (!isClosed && duration != null) {
        emit(state.copyWith(duration: duration));
      }
    });

    _audioPlayer?.playerStateStream.listen((playerState) {
      if (!isClosed) {
        _handlePlayerStateChange(playerState);
      }
    });

    _audioPlayer?.playbackEventStream.listen(
      null,
      onError: (Object e, StackTrace stackTrace) {
        print('A stream error occurred: $e');
        if (!isClosed) {
          emit(state.copyWith(
            status: AudioStatus.error,
            error: e.toString(),
          ));
        }
      },
    );
  }

  void _handlePlayerStateChange(PlayerState playerState) {
    if (playerState.processingState == ProcessingState.completed) {
      if (state.isLooping) {
        _audioPlayer?.seek(Duration.zero);
        _audioPlayer?.play();
      } else {
        add(PlayNextTrack());
      }
    } else if (playerState.processingState == ProcessingState.ready) {
      if (playerState.playing) {
        emit(state.copyWith(status: AudioStatus.playing));
      } else {
        emit(state.copyWith(status: AudioStatus.paused));
      }
    }
  }

  Future<void> _onInitializeAudio(
    InitializeAudio event,
    Emitter<AudioState> emit,
  ) async {
    if (_audioPlayer == null) {
      _initAudioPlayer();
    }

    try {
      if (state.currentTrack == event.assetPath &&
          state.status != AudioStatus.completed) {
        if (state.status == AudioStatus.playing) {
          add(PauseAudio());
        } else {
          add(PlayAudio());
        }
        return;
      }

      emit(state.copyWith(status: AudioStatus.loading));
      await _audioPlayer?.stop();
      await _audioPlayer?.setAsset(event.assetPath);
      final duration = await _audioPlayer?.duration;

      if (duration == null) {
        throw Exception('Could not load audio file: ${event.assetPath}');
      }

      emit(state.copyWith(
        status: AudioStatus.paused,
        duration: duration,
        currentTrack: event.assetPath,
        position: Duration.zero,
        error: null,
      ));

      add(PlayAudio());
    } catch (e) {
      print('Error initializing audio: $e');
      emit(state.copyWith(
        status: AudioStatus.error,
        error: 'Could not load audio file: ${e.toString()}',
      ));
    }
  }

  Future<void> _onPlayAudio(PlayAudio event, Emitter<AudioState> emit) async {
    if (_audioPlayer == null || state.currentTrack.isEmpty) return;

    try {
      await _audioPlayer?.play();
    } catch (e) {
      print('Error playing audio: $e');
      emit(state.copyWith(
        status: AudioStatus.error,
        error: 'Error playing audio: ${e.toString()}',
      ));
    }
  }

  Future<void> _onPauseAudio(PauseAudio event, Emitter<AudioState> emit) async {
    try {
      await _audioPlayer?.pause();
    } catch (e) {
      print('Error pausing audio: $e');
      emit(state.copyWith(
        status: AudioStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onStopAudio(StopAudio event, Emitter<AudioState> emit) async {
    try {
      await _audioPlayer?.stop();
      emit(state.copyWith(
        status: AudioStatus.paused,
        position: Duration.zero,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AudioStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onSeekAudio(SeekAudio event, Emitter<AudioState> emit) async {
    if (_audioPlayer == null) return;

    try {
      await _audioPlayer?.seek(event.position);
    } catch (e) {
      print('Error seeking audio: $e');
      emit(state.copyWith(
        status: AudioStatus.error,
        error: e.toString(),
      ));
    }
  }

  void _onToggleMinimizedPlayer(
    ToggleMinimizedPlayer event,
    Emitter<AudioState> emit,
  ) {
    emit(state.copyWith(isMinimized: !state.isMinimized));
  }

  Future<void> _onPlayNextTrack(
    PlayNextTrack event,
    Emitter<AudioState> emit,
  ) async {
    if (state.currentTrack.isEmpty) return;

    final currentPlaylist = state.isShuffled ? _shuffledPlaylist : _playlist;
    final currentIndex = currentPlaylist.indexOf(state.currentTrack);

    if (currentIndex < currentPlaylist.length - 1) {
      final nextTrack = currentPlaylist[currentIndex + 1];
      add(InitializeAudio(nextTrack));
    } else if (state.isLooping) {
      add(InitializeAudio(currentPlaylist[0]));
    }
  }

  Future<void> _onPlayPreviousTrack(
    PlayPreviousTrack event,
    Emitter<AudioState> emit,
  ) async {
    if (state.currentTrack.isEmpty) return;

    final currentPlaylist = state.isShuffled ? _shuffledPlaylist : _playlist;
    final currentIndex = currentPlaylist.indexOf(state.currentTrack);

    if (currentIndex > 0) {
      final previousTrack = currentPlaylist[currentIndex - 1];
      add(InitializeAudio(previousTrack));
    } else if (state.isLooping) {
      add(InitializeAudio(currentPlaylist[currentPlaylist.length - 1]));
    }
  }

  Future<void> _onSetVolume(SetVolume event, Emitter<AudioState> emit) async {
    if (_audioPlayer == null) return;

    try {
      await _audioPlayer?.setVolume(event.volume);
      emit(state.copyWith(volume: event.volume));
    } catch (e) {
      print('Error setting volume: $e');
      emit(state.copyWith(
        status: AudioStatus.error,
        error: e.toString(),
      ));
    }
  }

  void _onToggleShuffle(ToggleShuffle event, Emitter<AudioState> emit) {
    if (!state.isShuffled) {
      _shuffledPlaylist.shuffle();
      emit(state.copyWith(isShuffled: true));
    } else {
      _shuffledPlaylist = List.from(_playlist);
      emit(state.copyWith(isShuffled: false));
    }
  }

  void _onToggleLoop(ToggleLoop event, Emitter<AudioState> emit) {
    emit(state.copyWith(isLooping: !state.isLooping));
    if (_audioPlayer != null) {
      _audioPlayer!.setLoopMode(
        state.isLooping ? LoopMode.one : LoopMode.off,
      );
    }
  }

  @override
  Future<void> close() async {
    await _audioPlayer?.dispose();
    _audioPlayer = null;
    _isInitialized = false;
    return super.close();
  }
}
