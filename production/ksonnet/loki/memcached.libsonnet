local memcached = import 'memcached/memcached.libsonnet';

memcached {
  // Memcached instance used to cache chunks.
  memcached_chunks: $.memcached {
    name: 'memcached',
    max_item_size: '2m',
    memory_limit_mb: 1024,
    memcached_container+::
     $.util.resourcesRequests("100m", "100Mi") +
     $.util.resourcesLimits("200m", "300Mi"),
    
  },

  // Dedicated memcached instance used to temporarily cache index lookups.
  memcached_index_queries: $.memcached {
    name: 'memcached-index-queries',
    max_item_size: '5m',
    memcached_container+::
     $.util.resourcesRequests("100m", "100Mi") +
     $.util.resourcesLimits("200m", "300Mi"),
  },

  // Dedicated memcached instance used to dedupe writes to the index.
  memcached_index_writes: $.memcached {
    name: 'memcached-index-writes',
    memcached_container+::
     $.util.resourcesRequests("100m", "100Mi") +
     $.util.resourcesLimits("200m", "300Mi"),
  },

  // Dedicated memcached instance used to cache query results.
  memcached_frontend: $.memcached {
    name: 'memcached-frontend',
    max_item_size: '5m',
    memcached_container+::
     $.util.resourcesRequests("100m", "100Mi") +
     $.util.resourcesLimits("200m", "300Mi"),
  },
}

