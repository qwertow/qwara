import 'package:event_bus/event_bus.dart';
import 'package:video_player/video_player.dart';

EventBus eventBus = EventBus();

class ControllerReloadEvent {
  ControllerReloadEvent(this.controller);

  VideoPlayerController controller;
}