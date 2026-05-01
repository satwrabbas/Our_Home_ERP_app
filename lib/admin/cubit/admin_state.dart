part of 'admin_cubit.dart';

enum AdminStatus { initial, loading, success, failure }

class AdminState extends Equatable {
  const AdminState({
    this.status = AdminStatus.initial,
    this.users = const [],
    this.roles = const[],
    this.errorMessage,
  });

  final AdminStatus status;
  final List<LocalUser> users;
  final List<AppRole> roles;
  final String? errorMessage;

  AdminState copyWith({
    AdminStatus? status,
    List<LocalUser>? users,
    List<AppRole>? roles,
    String? errorMessage,
  }) {
    return AdminState(
      status: status ?? this.status,
      users: users ?? this.users,
      roles: roles ?? this.roles,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, users, roles, errorMessage];
}