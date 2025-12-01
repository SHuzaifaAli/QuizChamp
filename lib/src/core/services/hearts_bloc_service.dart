import 'package:quiz_champ/src/core/di/injection_container.dart';
import 'package:quiz_champ/src/presentation/blocs/hearts/hearts_bloc.dart';
import 'package:quiz_champ/src/presentation/blocs/hearts/hearts_event.dart';

/// Global HeartsBloc service to ensure single instance across the app
class HeartsBlocService {
  static HeartsBloc? _instance;
  
  static HeartsBloc get instance {
    _instance ??= sl<HeartsBloc>();
    return _instance!;
  }
  
  /// Initialize the global HeartsBloc with hearts from Firebase
  static void initialize() {
    instance.add(LoadHearts());
  }
  
  /// Dispose the global HeartsBloc
  static void dispose() {
    _instance?.close();
    _instance = null;
  }
}
