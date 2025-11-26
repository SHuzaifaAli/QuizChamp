import 'package:dartz/dartz.dart';
import 'package:quiz_champ/src/core/error/failures.dart';
import 'package:quiz_champ/src/data/datasources/auth_remote_datasource.dart';
import 'package:quiz_champ/src/data/services/user_service.dart';
import 'package:quiz_champ/src/domain/entities/user_entity.dart';
import 'package:quiz_champ/src/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final UserService userService;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.userService,
  });

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    try {
      final userModel = await remoteDataSource.signInWithGoogle();
      // Create/update user document in Firestore
      await userService.ensureUserDocumentExists();
      return Right(userModel);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await userService.updateUserOffline();
      await remoteDataSource.signOut();
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getUserStatus() async {
    try {
      final userModel = await remoteDataSource.getSignedInUser();
      if (userModel != null) {
        // Ensure user document exists and update login status
        await userService.ensureUserDocumentExists();
      }
      return Right(userModel);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }
}
