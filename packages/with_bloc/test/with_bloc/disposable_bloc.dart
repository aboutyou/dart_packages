import 'package:state_queue/state_queue.dart';

class DisposableBloc extends StateQueue<int> {
  DisposableBloc({
    this.onDispose,
  }) : super(0);

  final void Function() onDispose;

  @override
  void dispose() {
    super.dispose();

    onDispose();
  }
}
