//
//  File 2.swift
//
//
//  Created by Jason Buckner on 1/27/21.
//

import Foundation

extension InternetArchive {
  /**
   A review on an Internet Archive item
   */
  public struct Review: Decodable, Sendable {
    public let reviewbody: ModelField<IAString>?
    public let reviewtitle: String?
    public let reviewer: String?
    public let reviewerItemname: String?
    public let reviewdate: ModelField<IADate>?
    public let createdate: ModelField<IADate>?
    public let stars: ModelField<IADouble>?

    @available(*, deprecated, renamed: "reviewerItemname")
    public var reviewer_itemname: String? { reviewerItemname }

    public init(
      reviewbody: ModelField<IAString>? = nil,
      reviewtitle: String? = nil,
      reviewer: String? = nil,
      reviewerItemname: String? = nil,
      reviewdate: ModelField<IADate>? = nil,
      createdate: ModelField<IADate>? = nil,
      stars: ModelField<IADouble>? = nil
    ) {
      self.reviewbody = reviewbody
      self.reviewtitle = reviewtitle
      self.reviewer = reviewer
      self.reviewerItemname = reviewerItemname
      self.reviewdate = reviewdate
      self.createdate = createdate
      self.stars = stars
    }

    // `reviewer_itemname` intentionally has no default value: if both inits
    // were callable with zero arguments, `Review()` would be ambiguous.
    @available(*, deprecated, message: "Use init(reviewerItemname:) instead of init(reviewer_itemname:)")
    public init(
      reviewbody: ModelField<IAString>? = nil,
      reviewtitle: String? = nil,
      reviewer: String? = nil,
      reviewer_itemname: String?,
      reviewdate: ModelField<IADate>? = nil,
      createdate: ModelField<IADate>? = nil,
      stars: ModelField<IADouble>? = nil
    ) {
      self.init(
        reviewbody: reviewbody,
        reviewtitle: reviewtitle,
        reviewer: reviewer,
        reviewerItemname: reviewer_itemname,
        reviewdate: reviewdate,
        createdate: createdate,
        stars: stars
      )
    }
  }
}
