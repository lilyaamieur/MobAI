import 'package:equatable/equatable.dart';
import 'package:flutter_application_1/data/models/user.dart';

abstract class UserState extends Equatable {
  @override
  List<Object?> get props => [];
}

// ✅ Initial State
class UserInitial extends UserState {}

// ✅ Loading State
class UserLoading extends UserState {}

// ✅ Loaded State (User Fetched Successfully)
class UserLoaded extends UserState {
  final UserModel user;
  UserLoaded(this.user);

  @override
  List<Object?> get props => [user];
}

// ✅ User Updated State
class UserUpdated extends UserState {}

// ✅ User Created State
class UserCreated extends UserState {}

// ✅ User Deleted State
class UserDeleted extends UserState {}

// ✅ Error State
class UserError extends UserState {
  final String message;
  UserError(this.message);

  @override
  List<Object?> get props => [message];
}
