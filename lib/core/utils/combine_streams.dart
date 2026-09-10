import 'dart:async';

/// Dependency-free `combineLatest`, used by presentation controllers that join
/// two or more repository streams into one view model.
///
/// The project has no reactive-extensions package (`rxdart` is not a
/// dependency — see pubspec.yaml), and Firestore-backed screens routinely need
/// to join several collections client-side anyway, so this is written once
/// here rather than per controller.
Stream<R> combine2<A, B, R>(
  Stream<A> streamA,
  Stream<B> streamB,
  R Function(A a, B b) combine,
) {
  late final StreamController<R> controller;
  A? a;
  B? b;
  bool hasA = false, hasB = false;
  final List<StreamSubscription<Object?>> subs = <StreamSubscription<Object?>>[];

  void emit() {
    if (hasA && hasB) {
      controller.add(combine(a as A, b as B));
    }
  }

  controller = StreamController<R>.broadcast(
    onListen: () {
      subs
        ..add(streamA.listen((A v) {
          a = v;
          hasA = true;
          emit();
        },),)
        ..add(streamB.listen((B v) {
          b = v;
          hasB = true;
          emit();
        },),);
    },
    onCancel: () {
      for (final StreamSubscription<Object?> sub in subs) {
        unawaited(sub.cancel());
      }
      subs.clear();
    },
  );
  return controller.stream;
}

Stream<R> combine3<A, B, C, R>(
  Stream<A> streamA,
  Stream<B> streamB,
  Stream<C> streamC,
  R Function(A a, B b, C c) combine,
) {
  late final StreamController<R> controller;
  A? a;
  B? b;
  C? c;
  bool hasA = false, hasB = false, hasC = false;
  final List<StreamSubscription<Object?>> subs = <StreamSubscription<Object?>>[];

  void emit() {
    if (hasA && hasB && hasC) {
      controller.add(combine(a as A, b as B, c as C));
    }
  }

  controller = StreamController<R>.broadcast(
    onListen: () {
      subs
        ..add(streamA.listen((A v) {
          a = v;
          hasA = true;
          emit();
        },),)
        ..add(streamB.listen((B v) {
          b = v;
          hasB = true;
          emit();
        },),)
        ..add(streamC.listen((C v) {
          c = v;
          hasC = true;
          emit();
        },),);
    },
    onCancel: () {
      for (final StreamSubscription<Object?> sub in subs) {
        unawaited(sub.cancel());
      }
      subs.clear();
    },
  );
  return controller.stream;
}

Stream<R> combine5<A, B, C, D, E, R>(
  Stream<A> streamA,
  Stream<B> streamB,
  Stream<C> streamC,
  Stream<D> streamD,
  Stream<E> streamE,
  R Function(A a, B b, C c, D d, E e) combine,
) {
  late final StreamController<R> controller;
  A? a;
  B? b;
  C? c;
  D? d;
  E? e;
  bool hasA = false, hasB = false, hasC = false, hasD = false, hasE = false;
  final List<StreamSubscription<Object?>> subs = <StreamSubscription<Object?>>[];

  void emit() {
    if (hasA && hasB && hasC && hasD && hasE) {
      controller.add(combine(a as A, b as B, c as C, d as D, e as E));
    }
  }

  controller = StreamController<R>.broadcast(
    onListen: () {
      subs
        ..add(streamA.listen((A v) {
          a = v;
          hasA = true;
          emit();
        },),)
        ..add(streamB.listen((B v) {
          b = v;
          hasB = true;
          emit();
        },),)
        ..add(streamC.listen((C v) {
          c = v;
          hasC = true;
          emit();
        },),)
        ..add(streamD.listen((D v) {
          d = v;
          hasD = true;
          emit();
        },),)
        ..add(streamE.listen((E v) {
          e = v;
          hasE = true;
          emit();
        },),);
    },
    onCancel: () {
      for (final StreamSubscription<Object?> sub in subs) {
        unawaited(sub.cancel());
      }
      subs.clear();
    },
  );
  return controller.stream;
}
