//
//  Tasks.swift
//  InternetArchiveKit
//
//  Created by Jason Buckner on 7/17/26.
//  Copyright © 2026 Jason Buckner. All rights reserved.
//

import Foundation

extension InternetArchive {
  /**
   A task listing from the Tasks API, returned by `tasks()`.

   `catalog` holds queued and running tasks, `history` holds finished ones.
   Pass `cursor` back to `tasks(cursor:)` to page through long histories.
   */
  public struct TaskListing: Decodable, Sendable {
    public let summary: TaskSummary?
    public let catalog: [TaskInfo]?
    public let history: [TaskInfo]?
    public let cursor: String?

    public init(
      summary: TaskSummary? = nil,
      catalog: [TaskInfo]? = nil,
      history: [TaskInfo]? = nil,
      cursor: String? = nil
    ) {
      self.summary = summary
      self.catalog = catalog
      self.history = history
      self.cursor = cursor
    }
  }

  /// Counts of an item's or account's outstanding tasks by state
  public struct TaskSummary: Decodable, Sendable {
    public let queued: Int?
    public let running: Int?
    public let error: Int?
    public let paused: Int?

    public init(
      queued: Int? = nil,
      running: Int? = nil,
      error: Int? = nil,
      paused: Int? = nil
    ) {
      self.queued = queued
      self.running = running
      self.error = error
      self.paused = paused
    }
  }

  /**
   One row in a task listing.

   Every field is optional because catalog and history rows carry different
   columns. The row's `args` blob is free-form and isn't modeled.
   */
  public struct TaskInfo: Decodable, Sendable {
    public let taskId: Int?
    public let identifier: String?
    public let cmd: String?
    public let submitter: String?
    public let submittime: String?
    public let priority: Int?
    public let server: String?

    enum CodingKeys: String, CodingKey {
      case taskId
      case identifier
      case cmd
      case submitter
      case submittime
      case priority
      case server
    }

    public init(
      taskId: Int? = nil,
      identifier: String? = nil,
      cmd: String? = nil,
      submitter: String? = nil,
      submittime: String? = nil,
      priority: Int? = nil,
      server: String? = nil
    ) {
      self.taskId = taskId
      self.identifier = identifier
      self.cmd = cmd
      self.submitter = submitter
      self.submittime = submittime
      self.priority = priority
      self.server = server
    }
  }

  /**
   The result of a successful `submitTask()` call.
   */
  public struct TaskSubmission: Decodable, Sendable {
    public let taskId: Int?
    public let log: String?

    public init(taskId: Int?, log: String?) {
      self.taskId = taskId
      self.log = log
    }
  }

  /// The POST body for `submitTask()`
  struct TaskSubmissionRequest: Encodable {
    let identifier: String
    let cmd: String
    let args: [String: String]
    let priority: Int?
  }

  /// The tasks listing response envelope
  struct TasksEnvelope: Decodable {
    let success: Bool?
    let value: TaskListing?
    let error: String?
  }

  /// The task submission response envelope
  struct TaskSubmissionEnvelope: Decodable {
    let success: Bool?
    let value: TaskSubmission?
    let error: String?
  }
}
