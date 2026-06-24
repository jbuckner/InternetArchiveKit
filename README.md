# Internet Archive Kit

[![CI](https://github.com/jbuckner/InternetArchiveKit/actions/workflows/ci.yml/badge.svg)](https://github.com/jbuckner/InternetArchiveKit/actions/workflows/ci.yml)

_InternetArchiveKit is a Swift library to interact with the Internet Archive API_

It was built to power [Live Music Archive](https://livemusicarchive.app), an app I developed for listening to the [Internet Archive](https://archive.org)'s collection of live music.

## General Information

The Internet Archive's structure is made up of `Items` and `Files`. `Items` are the top level "things", like audio, video, and books, that contain all of the metadata for the "thing". `Items` contain `Files`, which are the actual content of the `Item`. For instance, in a live music recording, the `Item` is a particular recording of a show with metadata about the show like artist, venue, taper, etc. The `Files` are the individual audio tracks from that show.

For more information about the Internet Archive's structure, see their [Python Library Documentation](https://archive.org/services/docs/api/index.html).

## Documentation

See the [documenation](https://jbuckner.github.io/InternetArchiveKit/) for a full API reference

## Basic Usage

```swift
import InternetArchiveKit

let query = InternetArchive.Query(
   clauses: ["collection": "etree", "mediatype": "collection"])
let archive = InternetArchive()

let results = await archive.search(query: query, page: 0, rows: 10)
switch results {
case .success(let items):
  // debugPrint(items)
case .failure(let error):
  // debugPrint(error)
}

let result = await archive.itemDetail(identifier: "sci2007-07-28.Schoeps")
switch result {
case .success(let item):
  // debugPrint(item)
case .failure(let error):
  // debugPrint(error)
}
```

For more advanced usage, see the test suite and the included sample app.

## Scraping large result sets

`search()` is great for paged, sorted, interactive queries, but archive.org caps it at the 10,000th result. To walk an entire result set (a whole collection, every recording for an artist), use `scrape()`. It pages forward with a cursor instead of page numbers, so it can read past that ceiling. Start with `cursor: nil`, then pass each response's `cursor` back in until it comes back `nil`:

```swift
let query = InternetArchive.Query(
  clauses: ["collection": "etree", "mediatype": "collection"])
let archive = InternetArchive()

var cursor: String? = nil
var identifiers: [String] = []

repeat {
  let result = await archive.scrape(
    query: query, fields: ["identifier"], sortFields: nil, cursor: cursor)
  switch result {
  case .success(let response):
    identifiers += response.items.map { $0.identifier }
    cursor = response.cursor  // nil on the last batch
  case .failure(let error):
    // debugPrint(error)
    cursor = nil
  }
} while cursor != nil
```

archive.org fixes the batch size server-side (~5,000 items per request). If you pass `sortFields`, custom-sorted scraping is still capped at 10,000 results, and `identifier`, if you sort on it, must be the last sort field.

## Limitations

Currently, InternetArchiveKit is read-only and does not have support for all of Internet Archive's data. Pull requests are welcome!
