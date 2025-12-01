import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:quiz_champ/src/core/error/failures.dart';
import 'package:quiz_champ/src/data/datasources/auth_remote_datasource.dart';
import 'package:quiz_champ/src/data/services/user_service.dart';
import 'package:quiz_champ/src/domain/entities/user_entity.dart';
import 'package:quiz_champ/src/domain/repositories/auth_repository.dart';

import '../../presentation/widgets/common/error_widget.dart';

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
      log("🔥 [AuthRepository] Starting Google Sign-In process...");
      
      final userModel = await remoteDataSource.signInWithGoogle();
      log("✅ [AuthRepository] Google Sign-In successful. User: ${userModel.displayName}");
      
      // Create/update user document in Firestore
      log("📝 [AuthRepository] Creating/updating user document in Firestore...");
      await userService.ensureUserDocumentExists();
      log("✅ [AuthRepository] User document created/updated successfully");
      
      return Right(userModel);
    } on Failure catch (e) {
      log("❌ [AuthRepository] Failure during Google Sign-In: ${e.toString()}");
      CustomErrorWidget(message: e.toString());
      return Left(e);
    } catch (e, stackTrace) {
      log("💥 [AuthRepository] Unexpected error during Google Sign-In: ${e.toString()}");
      log("📚 [AuthRepository] Stack trace: $stackTrace");
      CustomErrorWidget(message: e.toString());
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      log("👋 [AuthRepository] Starting sign out process...");
      await userService.updateUserOffline();
      await remoteDataSource.signOut();
      log("✅ [AuthRepository] Sign out successful");
      return const Right(null);
    } on Failure catch (e) {
      log("❌ [AuthRepository] Failure during sign out: ${e.toString()}");
      CustomErrorWidget(message: e.toString());
      return Left(e);
    } catch (e, stackTrace) {
      log("💥 [AuthRepository] Unexpected error during sign out: ${e.toString()}");
      log("📚 [AuthRepository] Stack trace: $stackTrace");
      CustomErrorWidget(message: e.toString());
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getUserStatus() async {
    try {
      log("🔍 [AuthRepository] Checking user authentication status...");
      final userModel = await remoteDataSource.getSignedInUser();
      
      if (userModel != null) {
        log("✅ [AuthRepository] User is authenticated: ${userModel.displayName}");
        // Ensure user document exists and update login status
        log("📝 [AuthRepository] Updating user login status...");
        await userService.ensureUserDocumentExists();
        log("✅ [AuthRepository] User status updated successfully");
      } else {
        log("❌ [AuthRepository] User is not authenticated");
      }
      
      return Right(userModel);
    } on Failure catch (e) {
      log("❌ [AuthRepository] Failure checking user status: ${e.toString()}");
      CustomErrorWidget(message: e.toString());
      return Left(e);
    } catch (e, stackTrace) {
      log("💥 [AuthRepository] Unexpected error checking user status: ${e.toString()}");
      log("📚 [AuthRepository] Stack trace: $stackTrace");
      CustomErrorWidget(message: e.toString());
      return Left(AuthFailure(message: e.toString()));
    }
  }
}
