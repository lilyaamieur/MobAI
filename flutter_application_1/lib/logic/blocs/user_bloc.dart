import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_1/logic/repositories/user_repository.dart';
import 'package:flutter_application_1/logic/events/user_event.dart';
import 'package:flutter_application_1/logic/states/user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository userRepository;

  UserBloc(this.userRepository) : super(UserInitial()) {
    // ✅ Fetch User
    on<FetchUser>((event, emit) async {
      emit(UserLoading());
      try {
        final user = await userRepository.getUserById(event.userId);
        if (user != null) {
          emit(UserLoaded(user));
        } else {
          emit(UserError("User not found"));
        }
      } catch (e) {
        emit(UserError(e.toString()));
      }
    });

    // ✅ Update User
    on<UpdateUser>((event, emit) async {
      try {
        await userRepository.updateUser(event.user);
        emit(UserUpdated());
      } catch (e) {
        emit(UserError(e.toString()));
      }
    });

    // ✅ Create New User
    on<CreateUser>((event, emit) async {
      try {
        await userRepository.createUser(event.user);
        emit(UserCreated());
      } catch (e) {
        emit(UserError(e.toString()));
      }
    });

    // ✅ Delete User
    on<DeleteUser>((event, emit) async {
      try {
        await userRepository.deleteUser(event.userId);
        emit(UserDeleted());
      } catch (e) {
        emit(UserError(e.toString()));
      }
    });
  }
}
