# Redis Search

A search interface for Resque failures inside Redis

## Usage

```
search = Search.new(host='localhost', port=6379)
search.starting = DateTime.parse('10/2/2014')
search.ending = DateTime.parse('10/3/2014')
search.terms = Regexp.new('foo')
search.queue = 'QueueName'
search.run()
```

Returns a collection of search results matching the criteria

Due to the large data sets this can operate on, this will not parse on more than 1000 results matching a search. You will have to narrow the search criteria first.
