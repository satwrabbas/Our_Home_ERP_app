import 'package:our_home_erp_app/app/app.dart';
import 'package:our_home_erp_app/bootstrap.dart';

Future<void> main() async {
  await bootstrap(() => const App());
}
