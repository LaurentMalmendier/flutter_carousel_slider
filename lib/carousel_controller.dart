import 'dart:async';

import 'package:flutter/material.dart';

import 'carousel_options.dart';
import 'carousel_state.dart';
import 'utils.dart';

abstract class CarouselController {
  bool get ready;

  Future<Null> get onReady;

  Future<void> nextPage({Duration duration, Curve curve});

  Future<void> previousPage({Duration duration, Curve curve});

  void jumpToPage(int page);

  Future<void> animateToPage(int page, {Duration duration, Curve curve});

  void startAutoPlay();

  void stopAutoPlay();

  factory CarouselController() => CarouselControllerImpl();
}

class CarouselControllerImpl implements CarouselController {
  final Completer<Null> _readyCompleter = Completer<Null>();

//LaurentM
  CarouselState state;

  set state(CarouselState state) {
    state = state;
    if (!_readyCompleter.isCompleted) {
      _readyCompleter.complete();
    }
  }

  void _setModeController() =>
      state.changeMode(CarouselPageChangedReason.controller);

  @override
  bool get ready => state != null;

  @override
  Future<Null> get onReady => _readyCompleter.future;

  /// Animates the controlled [CarouselSlider] to the next page.
  ///
  /// The animation lasts for the given duration and follows the given curve.
  /// The returned [Future] resolves when the animation completes.
  Future<void> nextPage(
      {Duration duration = const Duration(milliseconds: 300),
      Curve curve = Curves.linear}) async {
    final bool isNeedResetTimer = state.options.pauseAutoPlayOnManualNavigate;
    if (isNeedResetTimer) {
      state.onResetTimer();
    }
    _setModeController();
    await state.pageController.nextPage(duration: duration, curve: curve);
    if (isNeedResetTimer) {
      state.onResumeTimer();
    }
  }

  /// Animates the controlled [CarouselSlider] to the previous page.
  ///
  /// The animation lasts for the given duration and follows the given curve.
  /// The returned [Future] resolves when the animation completes.
  Future<void> previousPage(
      {Duration duration = const Duration(milliseconds: 300),
      Curve curve = Curves.linear}) async {
    final bool isNeedResetTimer = state.options.pauseAutoPlayOnManualNavigate;
    if (isNeedResetTimer) {
      state.onResetTimer();
    }
    _setModeController();
    await state.pageController.previousPage(duration: duration, curve: curve);
    if (isNeedResetTimer) {
      state.onResumeTimer();
    }
  }

  /// Changes which page is displayed in the controlled [CarouselSlider].
  ///
  /// Jumps the page position from its current value to the given value,
  /// without animation, and without checking if the new value is in range.
  void jumpToPage(int page) {
    final index = getRealIndex(state.pageController.page.toInt(),
        state.realPage - state.initialPage, state.itemCount);

    _setModeController();
    final int pageToJump = state.pageController.page.toInt() + page - index;
    return _tate.pageController.jumpToPage(pageToJump);
  }

  /// Animates the controlled [CarouselSlider] from the current page to the given page.
  ///
  /// The animation lasts for the given duration and follows the given curve.
  /// The returned [Future] resolves when the animation completes.
  Future<void> animateToPage(int page,
      {Duration duration = const Duration(milliseconds: 300),
      Curve curve = Curves.linear}) async {
    final bool isNeedResetTimer = state.options.pauseAutoPlayOnManualNavigate;
    if (isNeedResetTimer) {
      state.onResetTimer();
    }
    final index = getRealIndex(state.pageController.page.toInt(),
        state.realPage - state.initialPage, state.itemCount);
    _setModeController();
    await state.pageController.animateToPage(
        state.pageController.page.toInt() + page - index,
        duration: duration,
        curve: curve);
    if (isNeedResetTimer) {
      state.onResumeTimer();
    }
  }

  /// Starts the controlled [CarouselSlider] autoplay.
  ///
  /// The carousel will only autoPlay if the [autoPlay] parameter
  /// in [CarouselOptions] is true.
  void startAutoPlay() {
    state.onResumeTimer();
  }

  /// Stops the controlled [CarouselSlider] from autoplaying.
  ///
  /// This is a more on-demand way of doing this. Use the [autoPlay]
  /// parameter in [CarouselOptions] to specify the autoPlay behaviour of the carousel.
  void stopAutoPlay() {
    state.onResetTimer();
  }
}
