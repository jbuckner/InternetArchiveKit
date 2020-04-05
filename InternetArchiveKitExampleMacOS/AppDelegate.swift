//
//  AppDelegate.swift
//  InternetArchiveKitExampleMacOS
//
//  Created by Jason Buckner on 4/5/20.
//  Copyright © 2020 Jason Buckner. All rights reserved.
//

import Cocoa
import SwiftUI
import InternetArchiveKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

  var window: NSWindow!

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    // Create the SwiftUI view and set the context as the value for the managedObjectContext environment keyPath.
    // Add `@Environment(\.managedObjectContext)` in the views that will need the context.
    let contentView = ContentView().environment(\.managedObjectContext, persistentContainer.viewContext)

    // Create the window and set the content view. 
    window = NSWindow(
      contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
      styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
      backing: .buffered, defer: false)
    window.center()
    window.setFrameAutosaveName("Main Window")
    window.contentView = NSHostingView(rootView: contentView)
    window.makeKeyAndOrderFront(nil)

    let archive = InternetArchive()
    let query: InternetArchive.Query = InternetArchive.Query(clauses: ["collection": "etree", "mediatype": "collection"])
    archive.search(
      query: query,
      page: 0,
      rows: 10,
      fields: ["identifier", "title"],
      sortFields: [InternetArchive.SortField(field: "downloads", direction: .desc)],
      completion: { (response: InternetArchive.SearchResponse?, error: Error?) in

        guard let response = response else { return }

        self.persistentContainer.viewContext.performAndWait {
          response.response.docs.forEach { (metadata: InternetArchive.ItemMetadata) in
            let artist = NSEntityDescription.insertNewObject(
              forEntityName: "Artist", into: self.persistentContainer.viewContext) as! Artist
            artist.name = metadata.title?.value ?? "unknown"
            artist.identifier = metadata.identifier
          }
        }
    })
  }

  func applicationWillTerminate(_ aNotification: Notification) {
  }

  // MARK: - Core Data stack

  lazy var persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "InternetArchiveKitExampleMacOS")
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
      if let error = error {
        fatalError("Unresolved error \(error)")
      }
    })
    return container
  }()

  // MARK: - Core Data Saving and Undo support

  @IBAction func saveAction(_ sender: AnyObject?) {
    // Performs the save action for the application, which is to send the save:
    // message to the application's managed object context. Any encountered errors are presented to the user.
    let context = persistentContainer.viewContext

    if !context.commitEditing() {
      NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing before saving")
    }
    if context.hasChanges {
      do {
        try context.save()
      } catch {
        // Customize this code block to include application-specific recovery steps.
        let nserror = error as NSError
        NSApplication.shared.presentError(nserror)
      }
    }
  }

  func windowWillReturnUndoManager(window: NSWindow) -> UndoManager? {
    // Returns the NSUndoManager for the application.
    // In this case, the manager returned is that of the managed object context for the application.
    return persistentContainer.viewContext.undoManager
  }

  func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
    // Save changes in the application's managed object context before the application terminates.
    let context = persistentContainer.viewContext

    if !context.commitEditing() {
      NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing to terminate")
      return .terminateCancel
    }

    if !context.hasChanges {
      return .terminateNow
    }

    do {
      try context.save()
    } catch {
      let nserror = error as NSError

      // Customize this code block to include application-specific recovery steps.
      let result = sender.presentError(nserror)
      if (result) {
        return .terminateCancel
      }

      let question = NSLocalizedString(
        "Could not save changes while quitting. Quit anyway?",
        comment: "Quit without saves error question message")
      let info = NSLocalizedString(
        "Quitting now will lose any changes you have made since the last successful save",
        comment: "Quit without saves error question info");
      let quitButton = NSLocalizedString("Quit anyway", comment: "Quit anyway button title")
      let cancelButton = NSLocalizedString("Cancel", comment: "Cancel button title")
      let alert = NSAlert()
      alert.messageText = question
      alert.informativeText = info
      alert.addButton(withTitle: quitButton)
      alert.addButton(withTitle: cancelButton)

      let answer = alert.runModal()
      if answer == .alertSecondButtonReturn {
        return .terminateCancel
      }
    }
    // If we got here, it is time to quit.
    return .terminateNow
  }

}


struct AppDelegate_Previews: PreviewProvider {
  static var previews: some View {
    Text("Goodbye, Moon!")
  }
}
