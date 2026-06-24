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

## `search()` vs `scrape()`

Both run the same Lucene-style query against the same index, but they're built for different jobs.

- **`search()`** (advancedsearch.php) is for **interactive, paged queries**: show page 3, sort by relevance, get a result count. Use it behind a search box or a paginated list.
- **`scrape()`** (the Scrape API) is for **reading an entire result set**: every recording in a collection, every show for an artist. It's the only way to get more than 10,000 results.

| | `search()` | `scrape()` |
| --- | --- | --- |
| Pagination | random access (`page` / `rows`) | forward-only `cursor` |
| Results reachable | first 10,000 | the whole set |
| Batch size | you choose (`rows`) | `.count` for one batch, else ~5,000 |
| Total match count | `response.numFound` | `total` |
| Results live in | `response.docs` | `items` |
| Sorting | any | any, but a custom sort caps out at 10,000 results |
| Relevance ranking and facets | yes | no |

Rule of thumb: if you're showing results to a person a page at a time, reach for `search()`. If you're pulling a whole collection down to process or cache, reach for `scrape()`.

### Scraping

`scrape()` pages forward with a cursor. Start with `pagination: nil`, then pass each response's `cursor` back as `.cursor(...)` until it comes back `nil`:

```swift
let query = InternetArchive.Query(
  clauses: ["collection": "etree", "mediatype": "collection"])
let archive = InternetArchive()

var pagination: InternetArchive.ScrapePagination? = nil
var identifiers: [String] = []

repeat {
  let result = await archive.scrape(
    query: query, fields: ["identifier"], sortFields: nil, pagination: pagination)
  switch result {
  case .success(let response):
    identifiers += response.items.map { $0.identifier }
    pagination = response.cursor.map { .cursor($0) }  // nil on the last batch ends the loop
  case .failure(let error):
    // debugPrint(error)
    pagination = nil
  }
} while pagination != nil
```

A few nuances:

- **Pagination is a single value, by design.** `pagination` is either `.cursor(...)` to resume or `.count(n)` to size a batch, never both: archive.org ignores the cursor if you also send a `count`, so the type makes that broken combination unrepresentable. Pass `nil` for the first batch at the server's default size (~5,000 items).
- **`.count` is for a bounded pull.** Use `.count(n)` (100–10,000) to grab up to 10,000 matches in one request, or a smaller first page before scrolling. It sizes only the batch it rides on; once you continue with `.cursor`, batches revert to the server default (~5,000). To page through everything, leave `pagination` `nil` and scroll by cursor (what archive.org's own `internetarchive` Python client does).
- **A custom sort caps scraping at 10,000 results.** Leave `sortFields` empty to scroll the full set (it walks in `identifier` order). If you do sort and include `identifier`, it has to be the last sort field.
- **No relevance ranking or faceting.** The Scrape API doesn't offer either; if you need them, use `search()`.

Need only the count? `scrapeTotal(query:)` returns the match total without fetching any items:

```swift
let result = await archive.scrapeTotal(query: query)
// result == .success(9250)
```

## Limitations

Currently, InternetArchiveKit is read-only and does not have support for all of Internet Archive's data. Pull requests are welcome!
