# 1.0.0

- Initial release.

# 1.0.1

- Fixed a bug where Redis::Client may have a block passed to some methods and if not passed would return 0 instead of true or false.

# 1.1.0

- Query count and Query time are now threadsafe.

# 1.2.0

- Use prepend over chaining in Redis::Client - [#4](https://github.com/peek/peek-redis/pull/4) by @ys
