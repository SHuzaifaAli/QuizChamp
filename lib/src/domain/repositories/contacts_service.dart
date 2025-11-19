import 'package:dartz/dartz.dart';
import '../entities/friend_request_entity.dart';
import '../../core/error/failures.dart';

abstract class ContactsService {
  Future<Either<Failure, List<Contact>>> getContacts();
  Future<Either<Failure, void>> sendInvitation(Contact contact, String invitationLink);
  Future<Either<Failure, String>> generateInvitationLink(String userId);
  Future<Either<Failure, String?>> processInvitationLink(String link);
  Future<Either<Failure, bool>> hasContactsPermission();
  Future<Either<Failure, bool>> requestContactsPermission();
}