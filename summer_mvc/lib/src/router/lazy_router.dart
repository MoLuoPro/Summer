part of router;

mixin LazyRouter {
  late final Router _router;
  Router get router => _router;

  lazyRouter() {
    if (_router == null) {
      _router = Router();
    }
  }
}
