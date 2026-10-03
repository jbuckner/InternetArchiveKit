//
//  LuceneQuery.swift
//  InternetArchiveKit
//

import Foundation

/// Helpers for putting user-entered text inside a Lucene query on archive.org.
public enum LuceneQuery {
  /// The characters `sanitized(_:)` and `words(from:)` remove.
  public static let removedCharacters: CharacterSet = CharacterSet(
    charactersIn: "+-&|!(){}[]^\"~*?:\\/"
  )

  /// Words Lucene treats as operators (`TO` is the range operator). They are
  /// dropped whatever their case, so `and` and `AND` both go.
  static let reservedWords: Set<String> = ["and", "or", "not", "to"]

  /// The words of `text` with every Lucene syntax character removed and the
  /// reserved words `AND`, `OR`, `NOT` and `TO` dropped.
  public static func words(from text: String) -> [String] {
    let cleaned = String(
      String.UnicodeScalarView(
        text.unicodeScalars.map { removedCharacters.contains($0) ? " " : $0 }
      )
    )
    return cleaned.split(whereSeparator: \.isWhitespace)
      .map(String.init)
      .filter { !reservedWords.contains($0.lowercased()) }
  }

  /// Makes user-entered text safe to put inside a Lucene query.
  ///
  /// Each character in `+ - & | ! ( ) { } [ ] ^ " ~ * ? : \ /` becomes a space,
  /// the words `AND`, `OR`, `NOT` and `TO` (any case) are dropped, runs of
  /// whitespace collapse to one space and the ends are trimmed. The result is
  /// empty when nothing searchable is left.
  ///
  /// This removes characters instead of backslash-escaping them on purpose.
  /// Checked live, archive.org's Elasticsearch rejects the escaped operators:
  /// `title:(grateful AND de\+ad)` and `title:(grateful \- dead)` both come
  /// back as `[BACKEND_ERROR] Invalid or no response from Elasticsearch`,
  /// while the unescaped forms work.
  ///
  /// The reserved words are dropped so a typed `AND`, `OR` or `NOT` can't change
  /// what the query means. Dropping them also matches Movie's `VideoCatalog`,
  /// so it can switch to this helper with no change in results.
  public static func sanitized(_ text: String) -> String {
    words(from: text).joined(separator: " ")
  }
}
