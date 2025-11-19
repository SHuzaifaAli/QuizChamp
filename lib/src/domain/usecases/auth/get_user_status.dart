import 'package:dartz/dartz.dart';
import 'package:quiz_champ/src/core/error/failures.dart';
import 'package:quiz_champ/src/core/usecases/usecase.dart';
import 'package:quiz_champ/src/domain/entities/user_entity.dart';
import 'package:quiz_champ/src/domain/repositories/auth_repository.dart';

class GetUserStatus implements UseCase<UserEntity?, NoParams> {
  final AuthRepository repository;

  GetUserStatus(this.repository);

  @override
  Future<Either<Failure, UserEntity?>> call(NoParams params) async {
    return await repository.getUserStatus();
  }
}
