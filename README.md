# Internet Archive Kit

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Build Status](https://travis-ci.com/jbuckner/InternetArchiveKit.svg?branch=master)](https://travis-ci.com/jbuckner/InternetArchiveKit)
[![codecov](https://codecov.io/gh/jbuckner/InternetArchiveKit/branch/master/graph/badge.svg)](https://codecov.io/gh/jbuckner/InternetArchiveKit)

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

## Limitations

Currently, InternetArchiveKit is read-only and does not have support for all of Internet Archive's data. Pull requests are welcome!
