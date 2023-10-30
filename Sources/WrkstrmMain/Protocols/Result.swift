public enum Result<Model> {
  case success(Model)

  case failure(Error)
}
