import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

EventBus eventBus = EventBus();

enum ControllerReloadStatus {
  start,
  end,
}

class ControllerReloadEvent {

  ControllerReloadEvent(this.controller, this.status);

  VideoPlayerController controller;
  ControllerReloadStatus status;
}

class UpdateAccessTokenEvent {
  UpdateAccessTokenEvent(this.success);
  bool success;
}

class TimeOutEvent {
  TimeOutEvent(this.message);
  String message;
}

class ThemeChangeEvent {
  final ThemeMode? themeMode;

  ThemeChangeEvent(this.themeMode);
}