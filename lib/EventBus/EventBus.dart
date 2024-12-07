import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

EventBus eventBus = EventBus();

class ControllerReloadEvent {
  ControllerReloadEvent(this.controller);

  VideoPlayerController controller;
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