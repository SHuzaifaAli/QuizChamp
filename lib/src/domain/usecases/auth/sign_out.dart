import 'package:dartz/dartz.dart';
import 'package:quiz_champ/src/core/error/failures.dart';
import 'package:quiz_champ/src/core/usecases/usecase.dart';
import 'package:quiz_champ/src/domain/repositories/auth_repository.dart';

class SignOut implements UseCase<void, NoParams> {
  final AuthRepository repository;

  SignOut(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.signOut();
  }
}
