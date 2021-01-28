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
  public struct Review: Decodable {
    public let reviewbody: String?
    public let reviewtitle: String?
    public let reviewer: String?
    public let reviewer_itemname: String?
    public let reviewdate: ModelField<IADate>?
    public let createdate: ModelField<IADate>?
    public let stars: ModelField<IADouble>?

    public init(
      reviewbody: String? = nil,
      reviewtitle: String? = nil,
      reviewer: String? = nil,
      reviewer_itemname: String? = nil,
      reviewdate: ModelField<IADate>? = nil,
      createdate: ModelField<IADate>? = nil,
      stars: ModelField<IADouble>? = nil
    ) {
      self.reviewbody = reviewbody
      self.reviewtitle = reviewtitle
      self.reviewer = reviewer
      self.reviewer_itemname = reviewer_itemname
      self.reviewdate = reviewdate
      self.createdate = createdate
      self.stars = stars
    }
  }
}
