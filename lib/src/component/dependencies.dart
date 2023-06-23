// import '../redux/index.dart';
// import 'basic.dart';
//
// Reducer<T> _noop<T>() => (T state, Action action) => state;
//
// class Dependencies<T> {
//   final Set<BasicComponent<T>> components;
//
//   Dependencies({
//     required this.components,
//   });
//
//   Reducer<T>? createReducer() {
//     final List<Reducer<T>> subs = <Reducer<T>>[];
//     if (components != null && components.isNotEmpty) {
//       subs.addAll(components.map<Reducer<T>>(
//             (BasicComponent<T> e) =>
//             e.createReducer(),
//       ));
//     }
//
//     return combineReducers(<Reducer<T>>[combineReducers(subs) ?? _noop<T>()]);
//   }
// }