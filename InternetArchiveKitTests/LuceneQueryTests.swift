import XCTest
@testable import InternetArchiveKit

final class LuceneQueryTests: XCTestCase {
  func testEachCharacterIsRemoved() {
    for character in "+-&|!(){}[]^\"~*?:\\/" {
      XCTAssertEqual(LuceneQuery.sanitized("a\(character)b"), "a b", "character \(character)")
      XCTAssertEqual(LuceneQuery.sanitized("\(character)ab\(character)"), "ab", "character \(character)")
    }
  }

  func testPlainTextIsUnchanged() {
    XCTAssertEqual(LuceneQuery.sanitized("grateful dead 1977"), "grateful dead 1977")
  }

  func testMixedInput() {
    XCTAssertEqual(LuceneQuery.sanitized("  de+ad -- (grateful) [77]: \"live\"/  "), "de ad grateful 77 live")
  }

  func testEmptyResult() {
    XCTAssertEqual(LuceneQuery.sanitized(""), "")
    XCTAssertEqual(LuceneQuery.sanitized("+-&|!(){}[]^\"~*?:\\/ "), "")
    XCTAssertEqual(LuceneQuery.sanitized("AND OR NOT"), "")
  }

  func testReservedWordsAreDroppedInAnyCase() {
    XCTAssertEqual(LuceneQuery.sanitized("grateful AND dead"), "grateful dead")
    XCTAssertEqual(LuceneQuery.sanitized("a or b not c To d"), "a b c d")
    XCTAssertEqual(LuceneQuery.sanitized("android notable"), "android notable")
  }

  func testWordsMatchSanitized() {
    XCTAssertEqual(LuceneQuery.words(from: "a+b AND c"), ["a", "b", "c"])
  }
}
