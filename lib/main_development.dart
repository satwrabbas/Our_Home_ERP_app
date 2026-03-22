import 'package:our_home_erp_app/app/app.dart';
import 'package:our_home_erp_app/bootstrap.dart';

void main() {
  // نقوم بتمرير الـ erpRepository إلى التطبيق الأساسي (App)
  bootstrap((erpRepository) => App(erpRepository: erpRepository));
}