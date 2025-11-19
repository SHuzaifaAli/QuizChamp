import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';

class QuestionTimerUseCase implements UseCase<Stream<int>, QuestionTimerParams> {
  @override
  Future<Either<Failure, Stream<int>>> call(QuestionTimerParams params) async {
    try {
      final controller = StreamController<int>();
      Timer? timer;
      int remainingSeconds = params.durationInSeconds;

      timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
        if (remainingSeconds <= 0) {
          controller.add(0);
          controller.close();
          t.cancel();
        } else {
          controller.add(remainingSeconds);
          remainingSeconds--;
        }
      });

      // Add initial value
      controller.add(remainingSeconds);

      // Handle stream cancellation
      controller.onCancel = () {
        timer?.cancel();
      };

      return Right(controller.stream);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to start timer: ${e.toString()}'));
    }
  }

  static void stopTimer(StreamSubscription? subscription) {
    subscription?.cancel();
  }
}

class QuestionTimerParams extends Equatable {
  final int durationInSeconds;

  const QuestionTimerParams({required this.durationInSeconds});

  @override
  List<Object?> get props => [durationInSeconds];
}