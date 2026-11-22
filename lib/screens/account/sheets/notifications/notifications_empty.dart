import 'package:material_ui/material_ui.dart';

class NotificationsEmpty extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const SliverToBoxAdapter(
    child: SizedBox.shrink(),
  );
}
