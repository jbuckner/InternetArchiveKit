//
//  InternetArchiveAuth.swift
//  InternetArchiveKit
//
//  Created by Jason Buckner on 7/17/26.
//  Copyright © 2026 Jason Buckner. All rights reserved.
//

import Foundation

extension InternetArchive {
  /**
   archive.org credentials for authenticated requests.

   The S3 key pair is attached to every request as
   `Authorization: LOW access:secret`. Get keys from
   [archive.org/account/s3.php](https://archive.org/account/s3.php), or
   programmatically from `login(email:password:)`.

   `cookies` are for website endpoints that want cookie auth rather than S3
   keys; when present they're attached as a `Cookie` header.

   InternetArchiveKit never stores credentials. Persisting them (for example
   in the Keychain) is the app's job.
   */
  public struct Credentials: Sendable {
    public let accessKey: String
    public let secretKey: String
    public let cookies: [String: String]

    public init(
      accessKey: String,
      secretKey: String,
      cookies: [String: String] = [:]
    ) {
      self.accessKey = accessKey
      self.secretKey = secretKey
      self.cookies = cookies
    }

    /// The `Authorization` header value for these credentials
    var authorizationHeaderValue: String {
      "LOW \(accessKey):\(secretKey)"
    }

    /// The `Cookie` header value, or nil when there are no cookies
    var cookieHeaderValue: String? {
      guard !cookies.isEmpty else { return nil }
      return cookies
        .sorted { $0.key < $1.key }
        .map { "\($0.key)=\($0.value)" }
        .joined(separator: "; ")
    }
  }

  /**
   The result of a successful `login(email:password:)` call.

   Carries the account's S3 keys and session cookies as `Credentials`, ready
   to pass to `InternetArchive(urlGenerator:urlSession:credentials:)`.
   */
  public struct Account: Sendable {
    public let credentials: Credentials
    public let screenname: String?

    public init(credentials: Credentials, screenname: String?) {
      self.credentials = credentials
      self.screenname = screenname
    }
  }

  /// The xauthn login response envelope, e.g.
  /// `{"success": true, "values": {"s3": {...}, "cookies": {...}, "screenname": "..."}}`
  /// or `{"success": false, "values": {"reason": "..."}}`.
  struct XAuthnEnvelope: Decodable {
    struct Values: Decodable {
      struct S3: Decodable {
        let access: String?
        let secret: String?
      }
      let s3: S3?
      let cookies: [String: String]?
      let screenname: String?
      let reason: String?
    }
    let success: Bool
    let values: Values?
  }
}
