import 'package:equatable/equatable.dart';
import 'package:flutter_application_1/data/models/user.dart';

abstract class UserEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// ✅ Fetch User
class FetchUser extends UserEvent {
  final int userId;

  FetchUser(this.userId);

  @override
  List<Object?> get props => [userId];
}

// ✅ Update User
class UpdateUser extends UserEvent {
  final UserModel user;

  UpdateUser(this.user);

  @override
  List<Object?> get props => [user];
}

// ✅ Create New User
class CreateUser extends UserEvent {
  final UserModel user;

  CreateUser(this.user);

  @override
  List<Object?> get props => [user];
}

// ✅ Delete User
class DeleteUser extends UserEvent {
  final int userId;

  DeleteUser(this.userId);

  @override
  List<Object?> get props => [userId];
}
