import Testing

@testable import WrkstrmFoundation

@Suite("StringCasing")
struct StringCasingTests {
  @Test
  func titlecasedCamelCase() {
    let input = "thisIsATitleCasedString"
    let expected = "This Is A Title Cased String"
    #expect(input.titlecased() == expected)
  }

  @Test
  func titlecasedPascalCase() {
    let input = "ThisIsATitleCasedString"
    let expected = "This Is A Title Cased String"
    #expect(input.titlecased() == expected)
  }
}
