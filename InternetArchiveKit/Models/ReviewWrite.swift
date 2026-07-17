//
//  ReviewWrite.swift
//  InternetArchiveKit
//
//  Created by Jason Buckner on 7/17/26.
//  Copyright © 2026 Jason Buckner. All rights reserved.
//

import Foundation

extension InternetArchive {
  /**
   The result of a successful `submitReview()` or `deleteReview()` call.

   The write is queued as a catalog task; `taskId` points at it.
   `reviewUpdated` is true when a submit overwrote an existing review.
   */
  public struct ReviewWriteResult: Sendable {
    public let taskId: Int?
    public let reviewUpdated: Bool?

    public init(taskId: Int?, reviewUpdated: Bool?) {
      self.taskId = taskId
      self.reviewUpdated = reviewUpdated
    }
  }

  /// The POST body for `submitReview()`
  struct ReviewSubmission: Encodable {
    let title: String
    let body: String
    let stars: Int?
  }

  /// The review write response envelope, e.g.
  /// `{"success": true, "value": {"task_id": 123, "review_updated": false}}`.
  struct ReviewWriteEnvelope: Decodable {
    struct Value: Decodable {
      let taskId: Int?
      let reviewUpdated: Bool?
    }
    let success: Bool?
    let value: Value?
    let error: String?
  }

  /// The review read response envelope; `value` is the caller's own review in
  /// the same shape reviews take on the metadata response.
  struct ReviewReadEnvelope: Decodable {
    let success: Bool?
    let value: Review?
    let error: String?
  }
}
