import Testing

@Test func test() async throws {
  let packages = LicenseProvider.packages
  let expectedValues: Set<String> = [
    "LicenseProvider",
    "swift-algorithms",
    "swift-async-algorithms",
    "swift-collections",
    "swift-numerics"
  ]
  #expect(Set(packages.map(\.name)) == expectedValues)
}
