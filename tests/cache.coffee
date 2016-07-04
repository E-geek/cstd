{assert} = require 'chai'
{Queue} = require '../lib/queue.coffee'
{CSObject} = require '../lib/object.coffee'
{BaseCache, LRUCache} = require '../lib/cache.coffee'
{NodeQueue} = require '../lib/cache/node_queue.coffee'



describe 'Cache', ->
  describe 'BaseCache', ->
    describe 'and Map', ->
      if typeof Map isnt 'function'
        return
      BC = undefined
      before ->
        class BC2 extends BaseCache
          length: 0
          constructor: (size) ->
            super(size)
        BC = BC2
      describe 'structure', ->
        it 'class', ->
          assert.ok BaseCache
          assert.isFunction BaseCache
          assert.lengthOf BaseCache, 1, 'max size'
          assert.isTrue BaseCache.isAbstract

        it 'proto', ->
          assert.isFunction BaseCache::destructor
          assert.lengthOf BaseCache::destructor, 0
          assert.isNumber BaseCache::length
          assert.equal BaseCache::length, -1

          assert.isFunction BaseCache::set
          assert.lengthOf BaseCache::set, 2
          assert.isFunction BaseCache::get
          assert.lengthOf BaseCache::get, 1
          assert.isFunction BaseCache::clear
          assert.lengthOf BaseCache::clear, 0

      describe 'behavior', ->
        describe 'errors', ->
          it 'new', ->
            fn = ->
              new BaseCache()
            assert.throws fn, TypeError, '`BaseCache` is abstract'
            fn = ->
              new BC(false)
            assert.throws fn, TypeError, '`size` should be a number'
            fn = ->
              new BC(-2)
            assert.throws fn, RangeError, '`size` less than 1'
            fn = ->
              new BC(0)
            assert.throws fn, RangeError, '`size` less than 1'

          it 'get', ->
            fn = ->
              bc = new BC()
              bc.get()
            assert.throws fn, Error, '`get` have `key` argument'
            fn = ->
              bc = new BC()
              bc.get(1, 2)
            assert.throws fn, Error, '`get` have `key` argument'
            fn = ->
              bc = new BC()
              bc.get({})
            assert.throws fn, TypeError, '`key` must be a string or number'
            fn = ->
              bc = new BC()
              bc.get(false)
            assert.throws fn, TypeError, '`key` must be a string or number'

          it 'set', ->
            fn = ->
              bc = new BC()
              bc.set()
            assert.throws fn, Error, '`set` have `key` and `value` arguments'
            fn = ->
              bc = new BC()
              bc.set(1)
            assert.throws fn, Error, '`set` have `key` and `value` arguments'
            fn = ->
              bc = new BC()
              bc.set(1, 2, 3)
            assert.throws fn, Error, '`set` have `key` and `value` arguments'
            fn = ->
              bc = new BC()
              bc.set({}, '')
            assert.throws fn, Error, '`key` must be a string or number'
            fn = ->
              bc = new BC()
              bc.set(false, '')
            assert.throws fn, Error, '`key` must be a string or number'

          it 'clear', ->
            fn = ->
              bc = new BC()
              bc.clear(1)
            assert.throws fn, Error, '`clear` have not arguments'
            fn = ->
              bc = new BC()
              bc.clear(yes)
            assert.throws fn, Error, '`clear` have not arguments'
            fn = ->
              bc = new BC()
              bc.clear(null)
            assert.throws fn, Error, '`clear` have not arguments'

        describe 'correct', ->
          it 'new', ->
            bc = new BC(10)
            assert.instanceOf bc, BC
            assert.instanceOf bc, BaseCache
            assert.instanceOf bc, CSObject
            assert.equal bc.maxSize, 10
            assert.lengthOf bc, 0
            if typeof Map is 'function'
              assert.instanceOf bc._data, Map
            else
              assert.isObject bc._data
            assert.instanceOf bc._control, Queue

          it 'set', ->
            bc = new BC(10)
            assert.lengthOf bc, 0
            assert.equal bc, bc.set '/', 123
            assert.lengthOf bc, 1
            assert.equal bc, bc.set 123, 456
            assert.lengthOf bc, 2
            assert.equal bc.maxSize, 10
            for i in [0..10]
              bc.set i, i
            assert.lengthOf bc, 10

          it 'get', ->
            bc = new BC(10)
            assert.lengthOf bc, 0
            assert.equal bc, bc.set '/', 123
            assert.equal 123, bc.get '/'
            assert.lengthOf bc, 1
            assert.equal bc, bc.set 123, 456
            assert.equal 456, bc.get 123
            assert.lengthOf bc, 2
            assert.equal bc.maxSize, 10
            for i in [0..10]
              bc.set i, i
              assert.equal i, bc.get i
            assert.lengthOf bc, 10
            assert.isUndefined bc.get '/'
            assert.isUndefined bc.get 123
            assert.equal bc.get(8), 8
            assert.equal bc.set(8, 18), bc
            assert.equal bc.get(8), 18

          it 'clear', ->
            bc = new BC(10)
            assert.lengthOf bc, 0
            for i in [0..20]
              bc.set i, i
              assert.equal i, bc.get i
            assert.lengthOf bc, 10
            assert.equal bc, bc.clear()
            assert.lengthOf bc, 0
            assert.isUndefined bc.get(20)
            assert.isUndefined bc.get(18)
            assert.isUndefined bc.get(11)
            assert.isUndefined bc.get(1)
            assert.isUndefined bc.get(5)
            for i in [0..20]
              bc.set i, i
              assert.equal i, bc.get i
            assert.equal bc.get(20), 20
            assert.equal bc.get(19), 19
            assert.equal bc.get(18), 18
            assert.equal bc.get(11), 11
            assert.lengthOf bc, 10
            assert.equal bc, bc.clear()
            assert.lengthOf bc, 0

          it 'destructor', ->
            bc = new BC(10)
            for i in [0..20]
              bc.set i, i
              assert.equal i, bc.get i
            assert.isNull bc.destructor()
            assert.equal bc.length, -1
            assert.equal bc.maxSize, -1
            assert.isNull bc._data
            assert.isNull bc._control

    describe 'without Map', ->
      BC = undefined
      if typeof Map is 'function'
        map = global.Map

        before ->
          global.Map = null
          delete require.cache[require.resolve('../lib/cache/base.coffee')]
          {BaseCache} = require '../lib/cache/base.coffee'
          class BC2 extends BaseCache
            constructor: (size) ->
              super(size)
          BC = BC2

        after ->
          global.Map = map
          delete require.cache[require.resolve('../lib/cache/base.coffee')]
          {BaseCache} = require '../lib/cache/base.coffee'
          return
      else
        before ->
          class BC2 extends BaseCache
            constructor: (size) ->
              super(size)
          BC = BC2
          return

      describe 'structure', ->
        it 'class', ->
          assert.ok BaseCache
          assert.isFunction BaseCache
          assert.lengthOf BaseCache, 1, 'max size'
          assert.isTrue BaseCache.isAbstract

        it 'proto', ->
          assert.isFunction BaseCache::destructor
          assert.lengthOf BaseCache::destructor, 0
          assert.isNumber BaseCache::length
          assert.equal BaseCache::length, -1

          assert.isFunction BaseCache::set
          assert.lengthOf BaseCache::set, 2
          assert.isFunction BaseCache::get
          assert.lengthOf BaseCache::get, 1
          assert.isFunction BaseCache::clear
          assert.lengthOf BaseCache::clear, 0

      describe 'behavior', ->
        describe 'errors', ->
          it 'new', ->
            fn = ->
              new BaseCache()
            assert.throws fn, TypeError, '`BaseCache` is abstract'
            fn = ->
              new BC(false)
            assert.throws fn, TypeError, '`size` should be a number'
            fn = ->
              new BC(-2)
            assert.throws fn, RangeError, '`size` less than 1'
            fn = ->
              new BC(0)
            assert.throws fn, RangeError, '`size` less than 1'

          it 'get', ->
            fn = ->
              bc = new BC()
              bc.get()
            assert.throws fn, Error, '`get` have `key` argument'
            fn = ->
              bc = new BC()
              bc.get(1, 2)
            assert.throws fn, Error, '`get` have `key` argument'
            fn = ->
              bc = new BC()
              bc.get({})
            assert.throws fn, TypeError, '`key` must be a string or number'
            fn = ->
              bc = new BC()
              bc.get(false)
            assert.throws fn, TypeError, '`key` must be a string or number'

          it 'set', ->
            fn = ->
              bc = new BC()
              bc.set()
            assert.throws fn, Error, '`set` have `key` and `value` arguments'
            fn = ->
              bc = new BC()
              bc.set(1)
            assert.throws fn, Error, '`set` have `key` and `value` arguments'
            fn = ->
              bc = new BC()
              bc.set(1, 2, 3)
            assert.throws fn, Error, '`set` have `key` and `value` arguments'
            fn = ->
              bc = new BC()
              bc.set({}, '')
            assert.throws fn, Error, '`key` must be a string or number'
            fn = ->
              bc = new BC()
              bc.set(false, '')
            assert.throws fn, Error, '`key` must be a string or number'

          it 'clear', ->
            fn = ->
              bc = new BC()
              bc.clear(1)
            assert.throws fn, Error, '`clear` have not arguments'
            fn = ->
              bc = new BC()
              bc.clear(yes)
            assert.throws fn, Error, '`clear` have not arguments'
            fn = ->
              bc = new BC()
              bc.clear(null)
            assert.throws fn, Error, '`clear` have not arguments'

        describe 'correct', ->
          it 'new', ->
            bc = new BC(10)
            assert.instanceOf bc, BC
            assert.instanceOf bc, BaseCache
            assert.instanceOf bc, CSObject
            assert.equal bc.maxSize, 10
            assert.lengthOf bc, 0
            if typeof Map is 'function'
              assert.instanceOf bc._data, Map
            else
              assert.isObject bc._data
            assert.instanceOf bc._control, Queue

          it 'set', ->
            bc = new BC(10)
            assert.lengthOf bc, 0
            assert.equal bc, bc.set '/', 123
            assert.lengthOf bc, 1
            assert.equal bc, bc.set 123, 456
            assert.lengthOf bc, 2
            assert.equal bc.maxSize, 10
            for i in [0..10]
              bc.set i, i
            assert.lengthOf bc, 10

          it 'get', ->
            bc = new BC(10)
            assert.lengthOf bc, 0
            assert.equal bc, bc.set '/', 123
            assert.equal 123, bc.get '/'
            assert.lengthOf bc, 1
            assert.equal bc, bc.set 123, 456
            assert.equal 456, bc.get 123
            assert.lengthOf bc, 2
            assert.equal bc.maxSize, 10
            for i in [0..10]
              bc.set i, i
              assert.equal i, bc.get i
            assert.lengthOf bc, 10
            assert.isUndefined bc.get '/'
            assert.isUndefined bc.get 123
            assert.equal bc.get(8), 8
            assert.equal bc.set(8, 18), bc
            assert.equal bc.get(8), 18

          it 'clear', ->
            bc = new BC(10)
            assert.lengthOf bc, 0
            for i in [0..20]
              bc.set i, i
              assert.equal i, bc.get i
            assert.lengthOf bc, 10
            assert.equal bc, bc.clear()
            assert.lengthOf bc, 0
            assert.isUndefined bc.get(20)
            assert.isUndefined bc.get(18)
            assert.isUndefined bc.get(11)
            assert.isUndefined bc.get(1)
            assert.isUndefined bc.get(5)
            for i in [0..20]
              bc.set i, i
              assert.equal i, bc.get i
            assert.equal bc.get(20), 20
            assert.equal bc.get(19), 19
            assert.equal bc.get(18), 18
            assert.equal bc.get(11), 11
            assert.lengthOf bc, 10
            assert.equal bc, bc.clear()
            assert.lengthOf bc, 0

          it 'destructor', ->
            bc = new BC(10)
            for i in [0..20]
              bc.set i, i
              assert.equal i, bc.get i
            assert.isNull bc.destructor()
            assert.equal bc.length, -1
            assert.equal bc.maxSize, -1
            assert.isNull bc._data
            assert.isNull bc._control

  describe 'LRUCache', ->
    BC = undefined
    describe 'and Map', ->
      before ->
        {BaseCache} = require '../lib/cache.coffee'
        class BC2 extends BaseCache
          constructor: (size) ->
            super(size)
        BC = BC2
      describe 'structure', ->
        it 'class', ->
          assert.ok LRUCache
          assert.isFunction LRUCache
          assert.lengthOf LRUCache, 1, 'max size'
          assert.isUndefined LRUCache.isAbstract

        it 'proto', ->
          assert.isFunction LRUCache::destructor
          assert.lengthOf LRUCache::destructor, 0
          assert.isNumber LRUCache::length
          assert.equal LRUCache::length, -1

          assert.isFunction LRUCache::set
          assert.lengthOf LRUCache::set, 2
          assert.isFunction LRUCache::get
          assert.lengthOf LRUCache::get, 1
          assert.isFunction LRUCache::clear
          assert.lengthOf LRUCache::clear, 0

        describe 'behavior', ->
          describe 'errors', ->
            it 'new', ->
              fn = ->
                new LRUCache(false)
              assert.throws fn, TypeError, '`size` should be a number'
              fn = ->
                new LRUCache(-2)
              assert.throws fn, RangeError, '`size` less than 1'
              fn = ->
                new LRUCache(0)
              assert.throws fn, RangeError, '`size` less than 1'

            it 'get', ->
              fn = ->
                bc = new LRUCache()
                bc.get()
              assert.throws fn, Error, '`get` have `key` argument'
              fn = ->
                bc = new LRUCache()
                bc.get(1, 2)
              assert.throws fn, Error, '`get` have `key` argument'
              fn = ->
                bc = new LRUCache()
                bc.get({})
              assert.throws fn, TypeError, '`key` must be a string or number'
              fn = ->
                bc = new LRUCache()
                bc.get(false)
              assert.throws fn, TypeError, '`key` must be a string or number'


            it 'set', ->
              fn = ->
                bc = new LRUCache()
                bc.set()
              assert.throws fn, Error, '`set` have `key` and `value` arguments'
              fn = ->
                bc = new LRUCache()
                bc.set(1)
              assert.throws fn, Error, '`set` have `key` and `value` arguments'
              fn = ->
                bc = new LRUCache()
                bc.set(1, 2, 3)
              assert.throws fn, Error, '`set` have `key` and `value` arguments'
              fn = ->
                bc = new LRUCache()
                bc.set({}, '')
              assert.throws fn, Error, '`key` must be a string or number'
              fn = ->
                bc = new LRUCache()
                bc.set(false, '')
              assert.throws fn, Error, '`key` must be a string or number'


            it 'clear', ->
              fn = ->
                bc = new LRUCache()
                bc.clear(1)
              assert.throws fn, Error, '`clear` have not arguments'
              fn = ->
                bc = new LRUCache()
                bc.clear(yes)
              assert.throws fn, Error, '`clear` have not arguments'
              fn = ->
                bc = new LRUCache()
                bc.clear(null)
              assert.throws fn, Error, '`clear` have not arguments'

          describe 'correct', ->
            it 'new', ->
              bc = new LRUCache(10)
              assert.instanceOf bc, LRUCache
              assert.instanceOf bc, BaseCache
              assert.instanceOf bc, CSObject
              assert.equal bc.maxSize, 10
              assert.lengthOf bc, 0
              if typeof Map is 'function'
                assert.instanceOf bc._data, Map
              else
                assert.isObject bc._data
              assert.instanceOf bc._control, NodeQueue

            it 'set', ->
              bc = new LRUCache(10)
              assert.lengthOf bc, 0
              assert.equal bc, bc.set '123', 123
              assert.lengthOf bc, 1
              assert.equal bc, bc.set 123, 456
              assert.lengthOf bc, 2
              assert.equal 123, bc.get '123'
              assert.equal 456, bc.get 123
              assert.equal bc.maxSize, 10
              for i in [0..10]
                bc.set i, i
              assert.lengthOf bc, 10

            it 'get', ->
              bc = new LRUCache(10)
              assert.lengthOf bc, 0
              assert.equal bc, bc.set '/', 123
              assert.equal 123, bc.get '/'
              assert.lengthOf bc, 1
              assert.equal bc, bc.set 123, 456
              assert.isUndefined bc.get '123'
              assert.equal 456, bc.get 123
              assert.lengthOf bc, 2
              assert.equal bc.maxSize, 10
              for i in [0..10]
                bc.set i, i
                assert.equal i, bc.get i
              assert.lengthOf bc, 10
              assert.isUndefined bc.get '/'
              assert.isUndefined bc.get 123
              bc
              .set '123', 123
              .set 456, 456
              for i in [0...5]
                bc.set i, i
                assert.equal i, bc.get i
              assert.equal 456, bc.get 456
              assert.equal 123, bc.get '123'
              for i in [5...10]
                bc.set i, i
                assert.equal i, bc.get i
              assert.strictEqual 456, bc.get 456
              assert.strictEqual 123, bc.get '123'
              assert.isUndefined bc.get 0
              assert.isUndefined bc.get 1
              assert.equal bc, bc.set 456, '456'
              assert.strictEqual '456', bc.get 456


            it 'clear', ->
              bc = new LRUCache(10)
              assert.lengthOf bc, 0
              for i in [0..20]
                bc.set i, i
                assert.equal i, bc.get i
              assert.lengthOf bc, 10
              assert.equal bc, bc.clear()
              assert.lengthOf bc, 0
              assert.isUndefined bc.get(20)
              assert.isUndefined bc.get(18)
              assert.isUndefined bc.get(11)
              assert.isUndefined bc.get(1)
              assert.isUndefined bc.get(5)
              for i in [0..20]
                bc.set i, i
                assert.equal i, bc.get i
              assert.equal bc.get(20), 20
              assert.equal bc.get(19), 19
              assert.equal bc.get(18), 18
              assert.equal bc.get(11), 11
              bc.set 123, 123
              bc.set '123', '123'
              assert.isUndefined bc.get 10 # out
              assert.isUndefined bc.get 12
              assert.isUndefined bc.get 13
              assert.strictEqual 123, bc.get 123
              assert.strictEqual '123', bc.get '123'
              assert.lengthOf bc, 10
              assert.equal bc, bc.clear()
              assert.lengthOf bc, 0

            it 'destructor', ->
              bc = new LRUCache(10)
              for i in [0..20]
                bc.set i, i
                assert.equal i, bc.get i
              assert.isNull bc.destructor()
              assert.equal bc.length, -1
              assert.equal bc.maxSize, -1
              assert.isNull bc._data
              assert.isNull bc._control

    describe 'without Map', ->

      if typeof Map is 'function'
        map = global.Map
        BC = undefined

        before ->
          global.Map = null
          delete require.cache[require.resolve('../lib/cache/lru.coffee')]
          delete require.cache[require.resolve('../lib/cache/base.coffee')]
          delete require.cache[require.resolve('../lib/cache.coffee')]
          {LRUCache, BaseCache} = require '../lib/cache.coffee'
          class BC2 extends BaseCache
            constructor: (size) ->
              super(size)
          BC = BC2
          return

        after ->
          global.Map = map
          delete require.cache[require.resolve('../lib/cache/lru.coffee')]
          delete require.cache[require.resolve('../lib/cache/base.coffee')]
          delete require.cache[require.resolve('../lib/cache.coffee')]
          {LRUCache, BaseCache} = require '../lib/cache.coffee'
          return

      describe 'structure', ->
        it 'class', ->
          assert.ok LRUCache
          assert.isFunction LRUCache
          assert.lengthOf LRUCache, 1, 'max size'
          assert.isUndefined LRUCache.isAbstract

        it 'proto', ->
          assert.isFunction LRUCache::destructor
          assert.lengthOf LRUCache::destructor, 0
          assert.isNumber LRUCache::length
          assert.equal LRUCache::length, -1

          assert.isFunction LRUCache::set
          assert.lengthOf LRUCache::set, 2
          assert.isFunction LRUCache::get
          assert.lengthOf LRUCache::get, 1
          assert.isFunction LRUCache::clear
          assert.lengthOf LRUCache::clear, 0

        describe 'behavior', ->
          describe 'errors', ->
            it 'new', ->
              fn = ->
                new LRUCache(false)
              assert.throws fn, TypeError, '`size` should be a number'
              fn = ->
                new LRUCache(-2)
              assert.throws fn, RangeError, '`size` less than 1'
              fn = ->
                new LRUCache(0)
              assert.throws fn, RangeError, '`size` less than 1'

            it 'get', ->
              fn = ->
                bc = new LRUCache()
                bc.get()
              assert.throws fn, Error, '`get` have `key` argument'
              fn = ->
                bc = new LRUCache()
                bc.get(1, 2)
              assert.throws fn, Error, '`get` have `key` argument'
              fn = ->
                bc = new LRUCache()
                bc.get({})
              assert.throws fn, TypeError, '`key` must be a string or number'
              fn = ->
                bc = new LRUCache()
                bc.get(false)
              assert.throws fn, TypeError, '`key` must be a string or number'


            it 'set', ->
              fn = ->
                bc = new LRUCache()
                bc.set()
              assert.throws fn, Error, '`set` have `key` and `value` arguments'
              fn = ->
                bc = new LRUCache()
                bc.set(1)
              assert.throws fn, Error, '`set` have `key` and `value` arguments'
              fn = ->
                bc = new LRUCache()
                bc.set(1, 2, 3)
              assert.throws fn, Error, '`set` have `key` and `value` arguments'
              fn = ->
                bc = new LRUCache()
                bc.set({}, '')
              assert.throws fn, Error, '`key` must be a string or number'
              fn = ->
                bc = new LRUCache()
                bc.set(false, '')
              assert.throws fn, Error, '`key` must be a string or number'


            it 'clear', ->
              fn = ->
                bc = new LRUCache()
                bc.clear(1)
              assert.throws fn, Error, '`clear` have not arguments'
              fn = ->
                bc = new LRUCache()
                bc.clear(yes)
              assert.throws fn, Error, '`clear` have not arguments'
              fn = ->
                bc = new LRUCache()
                bc.clear(null)
              assert.throws fn, Error, '`clear` have not arguments'

          describe 'correct', ->
            it 'new', ->
              bc = new LRUCache(10)
              assert.instanceOf bc, LRUCache
              assert.instanceOf bc, BaseCache
              assert.instanceOf bc, CSObject
              assert.equal bc.maxSize, 10
              assert.lengthOf bc, 0
              if typeof Map is 'function'
                assert.instanceOf bc._data, Map
              else
                assert.isObject bc._data
              assert.instanceOf bc._control, NodeQueue

            it 'set', ->
              bc = new LRUCache(10)
              assert.lengthOf bc, 0
              assert.equal bc, bc.set '123', 123
              assert.lengthOf bc, 1
              assert.equal bc, bc.set 123, 456
              assert.lengthOf bc, 2
              assert.equal 123, bc.get '123'
              assert.equal 456, bc.get 123
              assert.equal bc.maxSize, 10
              for i in [0..10]
                bc.set i, i
              assert.lengthOf bc, 10

            it 'get', ->
              bc = new LRUCache(10)
              assert.lengthOf bc, 0
              assert.equal bc, bc.set '/', 123
              assert.equal 123, bc.get '/'
              assert.lengthOf bc, 1
              assert.equal bc, bc.set 123, 456
              assert.isUndefined bc.get '123'
              assert.equal 456, bc.get 123
              assert.lengthOf bc, 2
              assert.equal bc.maxSize, 10
              for i in [0..10]
                bc.set i, i
                assert.equal i, bc.get i
              assert.lengthOf bc, 10
              assert.isUndefined bc.get '/'
              assert.isUndefined bc.get 123
              bc
              .set '123', 123
              .set 456, 456
              for i in [0...5]
                bc.set i, i
                assert.equal i, bc.get i
              assert.equal 456, bc.get 456
              assert.equal 123, bc.get '123'
              for i in [5...10]
                bc.set i, i
                assert.equal i, bc.get i
              assert.strictEqual 456, bc.get 456
              assert.strictEqual 123, bc.get '123'
              assert.isUndefined bc.get 0
              assert.isUndefined bc.get 1
              assert.equal bc, bc.set 456, '456'
              assert.strictEqual '456', bc.get 456

            it 'clear', ->
              bc = new LRUCache(10)
              assert.lengthOf bc, 0
              for i in [0..20]
                bc.set i, i
                assert.equal i, bc.get i
              assert.lengthOf bc, 10
              assert.equal bc, bc.clear()
              assert.lengthOf bc, 0
              assert.isUndefined bc.get(20)
              assert.isUndefined bc.get(18)
              assert.isUndefined bc.get(11)
              assert.isUndefined bc.get(1)
              assert.isUndefined bc.get(5)
              for i in [0..20]
                bc.set i, i
                assert.equal i, bc.get i
              assert.equal bc.get(20), 20
              assert.equal bc.get(19), 19
              assert.equal bc.get(18), 18
              assert.equal bc.get(11), 11
              bc.set 123, 123
              bc.set '123', '123'
              assert.isUndefined bc.get 10 # out
              assert.isUndefined bc.get 12
              assert.isUndefined bc.get 13
              assert.strictEqual 123, bc.get 123
              assert.strictEqual '123', bc.get '123'
              assert.lengthOf bc, 10
              assert.equal bc, bc.clear()
              assert.lengthOf bc, 0

            it 'destructor', ->
              bc = new LRUCache(10)
              for i in [0..20]
                bc.set i, i
                assert.equal i, bc.get i
              assert.isNull bc.destructor()
              assert.equal bc.length, -1
              assert.equal bc.maxSize, -1
              assert.isNull bc._data
              assert.isNull bc._control
