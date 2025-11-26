import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';

abstract class SharingService {
  Future<Either<Failure, String>> generateShareableLink();
  Future<Either<Failure, void>> shareAppLink(String link);
  Future<Either<Failure, void>> shareInviteCode(String code);
  Future<Either<Failure, String>> generateInviteCode();
}
