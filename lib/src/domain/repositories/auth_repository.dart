import 'package:dartz/dartz.dart';
import 'package:quiz_champ/src/core/error/failures.dart';
import 'package:quiz_champ/src/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> signInWithGoogle();
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, UserEntity?>> getUserStatus();
}
