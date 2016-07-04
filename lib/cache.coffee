{ BaseCache } = require './cache/base.coffee'
{ LRUCache } = require './cache/lru.coffee'

# Связующее звено для кешей разных уровней
module.exports = { BaseCache, LRUCache }
