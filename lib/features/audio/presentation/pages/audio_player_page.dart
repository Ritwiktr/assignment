import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wave/config.dart';
import '../bloc/audio_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:wave/wave.dart';

class AudioPlayerPage extends StatelessWidget {
  const AudioPlayerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AudioBloc(),
      child: Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: MediaQuery.of(context).platformBrightness,
          ),
        ),
        child: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: const Text('Audio Player'),
            elevation: 0,
            backgroundColor: Colors.transparent,
            flexibleSpace: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          body: BlocListener<AudioBloc, AudioState>(
            listener: (context, state) {
              if (state.status == AudioStatus.error && state.error != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.error!),
                    backgroundColor: Theme.of(context).colorScheme.error,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }
            },
            child: const AudioPlayerContent(),
          ),
          bottomSheet: const MinimizedPlayer(),
        ),
      ),
    );
  }
}

class AudioPlayerContent extends StatelessWidget {
  const AudioPlayerContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioBloc, AudioState>(
      builder: (context, state) {
        return Stack(
          children: [
            AnimatedContainer(
              duration: const Duration(seconds: 1),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).colorScheme.primaryContainer,
                    Theme.of(context).colorScheme.surface,
                  ],
                ),
              ),
            ),
            if (state.status == AudioStatus.playing)
              Positioned.fill(
                child: WaveWidget(
                  config: CustomConfig(
                    gradients: [
                      [
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      ],
                    ],
                    durations: [5000],
                    heightPercentages: [0.3],
                    blur: const MaskFilter.blur(BlurStyle.solid, 5),
                  ),
                  waveAmplitude: 20,
                  size: const Size(double.infinity, double.infinity),
                ),
              ),
            Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top +
                          kToolbarHeight +
                          16,
                      bottom: 16,
                      left: 16,
                      right: 16,
                    ),
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      final assetPath = 'assets/audio/audio${index + 1}.mp3';
                      return AudioTrackTile(
                        assetPath: assetPath,
                        isPlaying: state.status == AudioStatus.playing &&
                            state.currentTrack == assetPath,
                        onTap: () {
                          context
                              .read<AudioBloc>()
                              .add(InitializeAudio(assetPath));
                        },
                      ).animate().fadeIn(
                            duration:
                                Duration(milliseconds: 200 + (index * 100)),
                          );
                    },
                  ),
                ),
                if (state.currentTrack.isNotEmpty && !state.isMinimized)
                  PlayerControls(state: state),
              ],
            ),
          ],
        );
      },
    );
  }
}

class PlayerControls extends StatelessWidget {
  final AudioState state;

  const PlayerControls({super.key, required this.state});

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  Container(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Center(
                      child: Icon(
                        Icons.music_note,
                        size: 64,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  if (state.status == AudioStatus.playing)
                    WaveWidget(
                      config: CustomConfig(
                        gradients: [
                          [
                            Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.3),
                            Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.5),
                          ],
                        ],
                        durations: [3000],
                        heightPercentages: [0.5],
                        blur: const MaskFilter.blur(BlurStyle.solid, 3),
                      ),
                      waveAmplitude: 10,
                      size: const Size(double.infinity, double.infinity),
                    ),
                ],
              ),
            ),
          )
              .animate(target: state.status == AudioStatus.playing ? 1 : 0)
              .scale(duration: const Duration(milliseconds: 300))
              .rotate(duration: const Duration(milliseconds: 500)),
          const SizedBox(height: 24),
          Text(
            state.currentTrack.split('/').last.split('.').first,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ).animate().slideY(
                duration: const Duration(milliseconds: 300),
                begin: 0.3,
                curve: Curves.easeOutCubic,
              ),
          const SizedBox(height: 24),
          if (state.status == AudioStatus.loading)
            const CircularProgressIndicator().animate().scale()
          else ...[
            ProgressBar(
                state: state,
                onSeek: (value) {
                  context
                      .read<AudioBloc>()
                      .add(SeekAudio(Duration(seconds: value.toInt())));
                }),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.shuffle,
                    color: state.isShuffled
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.7),
                  ),
                  iconSize: 24,
                  onPressed: () =>
                      context.read<AudioBloc>().add(ToggleShuffle()),
                ),
                IconButton(
                  icon: const Icon(Icons.skip_previous),
                  iconSize: 32,
                  color: Theme.of(context).colorScheme.primary,
                  onPressed: () =>
                      context.read<AudioBloc>().add(PlayPreviousTrack()),
                ),
                PlayPauseButton(
                  isPlaying: state.status == AudioStatus.playing,
                  onPressed: () => context.read<AudioBloc>().add(
                        state.status == AudioStatus.playing
                            ? PauseAudio()
                            : PlayAudio(),
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next),
                  iconSize: 32,
                  color: Theme.of(context).colorScheme.primary,
                  onPressed: () =>
                      context.read<AudioBloc>().add(PlayNextTrack()),
                ),
                IconButton(
                  icon: Icon(
                    Icons.repeat,
                    color: state.isLooping
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.7),
                  ),
                  iconSize: 24,
                  onPressed: () => context.read<AudioBloc>().add(ToggleLoop()),
                ),
              ],
            ).animate().slideY(
                  duration: const Duration(milliseconds: 300),
                  begin: 0.3,
                  curve: Curves.easeOutCubic,
                ),
            const SizedBox(height: 16),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.volume_down),
                  onPressed: () {
                    final newVolume = (state.volume - 0.1).clamp(0.0, 1.0);
                    context.read<AudioBloc>().add(SetVolume(newVolume));
                  },
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 2,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 6,
                      ),
                    ),
                    child: Slider(
                      value: state.volume,
                      onChanged: (value) {
                        context.read<AudioBloc>().add(SetVolume(value));
                      },
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.volume_up),
                  onPressed: () {
                    final newVolume = (state.volume + 0.1).clamp(0.0, 1.0);
                    context.read<AudioBloc>().add(SetVolume(newVolume));
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            IconButton(
              icon: const Icon(Icons.keyboard_arrow_down),
              onPressed: () =>
                  context.read<AudioBloc>().add(ToggleMinimizedPlayer()),
            ),
          ],
        ],
      ),
    );
  }
}

class ProgressBar extends StatelessWidget {
  final AudioState state;
  final Function(double) onSeek;

  const ProgressBar({
    super.key,
    required this.state,
    required this.onSeek,
  });

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            activeTrackColor: Theme.of(context).colorScheme.primary,
            inactiveTrackColor:
                Theme.of(context).colorScheme.primary.withOpacity(0.2),
            thumbColor: Theme.of(context).colorScheme.primary,
            overlayColor:
                Theme.of(context).colorScheme.primary.withOpacity(0.2),
          ),
          child: Slider(
            value: state.position.inSeconds.toDouble(),
            max: state.duration.inSeconds.toDouble(),
            onChanged: onSeek,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(state.position),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                _formatDuration(state.duration),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class PlayPauseButton extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onPressed;

  const PlayPauseButton({
    super.key,
    required this.isPlaying,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.primary,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Icon(
            isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            size: 40,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ),
    ).animate(target: isPlaying ? 1 : 0).scale(
          duration: const Duration(milliseconds: 200),
          begin: const Offset(0.9, 0.9),
          end: const Offset(1, 1),
        );
  }
}

class MinimizedPlayer extends StatelessWidget {
  const MinimizedPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioBloc, AudioState>(
      builder: (context, state) {
        if (!state.isMinimized || state.currentTrack.isEmpty) {
          return const SizedBox.shrink();
        }

        return GestureDetector(
          onTap: () {
            context.read<AudioBloc>().add(ToggleMinimizedPlayer());
          },
          onVerticalDragEnd: (details) {
            if (details.primaryVelocity! < 0) {
              context.read<AudioBloc>().add(ToggleMinimizedPlayer());
            }
          },
          child: Container(
            height: 72,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Theme.of(context).colorScheme.primaryContainer,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Stack(
                      children: [
                        Icon(
                          Icons.music_note,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        if (state.status == AudioStatus.playing)
                          WaveWidget(
                            config: CustomConfig(
                              gradients: [
                                [
                                  Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.3),
                                  Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.5),
                                ],
                              ],
                              durations: [2000],
                              heightPercentages: [0.5],
                              blur: const MaskFilter.blur(BlurStyle.solid, 2),
                            ),
                            waveAmplitude: 5,
                            size: const Size(double.infinity, double.infinity),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.currentTrack.split('/').last.split('.').first,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      LinearProgressIndicator(
                        value: state.position.inSeconds /
                            state.duration.inSeconds.clamp(1, double.infinity),
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.skip_previous),
                      iconSize: 24,
                      onPressed: () {
                        context.read<AudioBloc>().add(PlayPreviousTrack());
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        state.status == AudioStatus.playing
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                      ),
                      iconSize: 32,
                      onPressed: () {
                        if (state.status == AudioStatus.playing) {
                          context.read<AudioBloc>().add(PauseAudio());
                        } else {
                          context.read<AudioBloc>().add(PlayAudio());
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_next),
                      iconSize: 24,
                      onPressed: () {
                        context.read<AudioBloc>().add(PlayNextTrack());
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ).animate().slideY(
              begin: 1,
              end: 0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
            );
      },
    );
  }
}

class AudioTrackTile extends StatelessWidget {
  final String assetPath;
  final bool isPlaying;
  final VoidCallback onTap;

  const AudioTrackTile({
    super.key,
    required this.assetPath,
    required this.isPlaying,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isPlaying ? 4 : 1,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isPlaying
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.primaryContainer,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      isPlaying ? Icons.music_note : Icons.music_note_outlined,
                      color: isPlaying
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.primary,
                    ),
                    if (isPlaying)
                      CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      assetPath.split('/').last.split('.').first,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: isPlaying
                                ? Theme.of(context).colorScheme.primary
                                : null,
                            fontWeight:
                                isPlaying ? FontWeight.bold : FontWeight.normal,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '3:45 • 4.2MB',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                          ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.more_vert,
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) =>
                        TrackOptionsSheet(trackPath: assetPath),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TrackOptionsSheet extends StatelessWidget {
  final String trackPath;

  const TrackOptionsSheet({
    super.key,
    required this.trackPath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          _buildOptionTile(
            context,
            icon: Icons.playlist_add,
            title: 'Add to playlist',
            onTap: () {
              Navigator.pop(context);
            },
          ),
          _buildOptionTile(
            context,
            icon: Icons.share,
            title: 'Share',
            onTap: () {
              Navigator.pop(context);
            },
          ),
          _buildOptionTile(
            context,
            icon: Icons.info_outline,
            title: 'Track info',
            onTap: () {
              Navigator.pop(context);
            },
          ),
          _buildOptionTile(
            context,
            icon: Icons.download,
            title: 'Download',
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }
}
