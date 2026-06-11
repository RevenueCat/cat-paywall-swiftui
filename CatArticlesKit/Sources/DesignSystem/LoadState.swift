/// Generic async UI state used by feature view models.
public enum LoadState<Value> {
    case loading
    case loaded(Value)
    case failed(String)
}
