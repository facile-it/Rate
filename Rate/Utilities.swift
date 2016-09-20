func ignoreInput<T>(_ function: @escaping () -> ()) -> (T) -> () {
    return { _ in function() }
}
