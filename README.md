# Redis Search

A search interface for Resque failures inside Redis

## Usage from irb

```
search = Search.new(host='localhost', port=6379)
search.starting = DateTime.parse("2014/10/09 00:00:00 UTC")
search.ending = DateTime.parse("2014/10/09 00:00:00 UTC")
search.terms = Regexp.new('foo')
search.queue = 'QueueName'
search.run()
```

## Usage from a terminal

```
ruby -r ./search -e 's=Search.new();s.run()' | tee /path/to/output
```

Returns a collection of search results matching the criteria

Due to the large data sets this can operate on, this will not parse on more than 1000 results matching a search. You will have to narrow the search criteria first by reducing the starting and ending date ranges.
