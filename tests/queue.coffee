{assert} = require 'chai'
{Container} = require '../lib/container.coffee'
{Queue} = require '../lib/queue.coffee'
{CSObject} = require '../lib/object.coffee'
{Node} = require '../lib/node.coffee'

describe 'Queue', ->
  describe 'structure', ->
    it 'class', ->
      assert.ok Queue
      assert.isFunction Queue
      assert.isFunction Queue.fromArray
      assert.lengthOf Queue.fromArray, 1

    it 'proto', ->
      assert.isFunction Queue::destructor
      assert.lengthOf Queue::destructor, 0
      assert.isNumber Queue::length
      assert.isFunction Queue::push
      assert.lengthOf Queue::push, 1
      assert.isFunction Queue::pop
      assert.lengthOf Queue::pop, 0
      assert.isFunction Queue::clear
      assert.lengthOf Queue::clear, 0
      assert.isFunction Queue::add
      assert.lengthOf Queue::add, 0, 'dynamic arguments list'
      # protected elements
      assert.ok Queue::_f
      assert.instanceOf Queue::_f, Node
      assert.ok Queue::_b
      assert.instanceOf Queue::_b, Node

    it 'Container class', ->
      assert.isFunction Queue.isContainer
      assert.lengthOf Queue.isContainer, 1
      assert.isFunction Queue.fromJSON
      assert.lengthOf Queue.fromJSON, 2, 'data[, quiet]'

    it 'Container proto', ->
      assert.strictEqual Queue::length, -1
      assert.instanceOf Queue::_f, Node
      assert.isFunction Queue::copy
      assert.lengthOf Queue::copy, 1
      assert.isFunction Queue::values
      assert.lengthOf Queue::values, 0
      assert.isFunction Queue::has
      assert.lengthOf Queue::has, 1, 'who'
      assert.isFunction Queue::toString
      assert.lengthOf Queue::toString, 0
      assert.isFunction Queue::toJSON
      assert.lengthOf Queue::toJSON, 0


  describe 'behavior', ->
    it 'errors', ->
      fn = ->
        new Queue 12
      assert.throws fn, TypeError, 'Queue constructor haven\'t arguments'
      fn2 = ->
        q = new Queue()
        q.push 1,2
      assert.throws fn2, TypeError, 'one push, one element'
      fn6 = ->
        q = new Queue()
        q.push()
      assert.throws fn6, TypeError, 'push without value'
      fn7 = ->
        q = new Queue()
        q.add()
      assert.throws fn7, TypeError, 'add without value'
      fn3 = ->
        q = new Queue()
        q.pop()
      assert.throws fn3, Error, 'queue is empty'
      fn4 = ->
        q = new Queue()
        q.push 1
        q.pop 1
      assert.throws fn4, TypeError, 'pop haven\'t arguments'
      fn5 = ->
        q = new Queue()
        q.clear 1
      assert.throws fn5, TypeError, 'clear haven\'t arguments'
      fn8 = ->
        q = Queue.fromArray()
      assert.throws fn8, Error, 'no arguments'
      fn9 = ->
        q = Queue.fromArray 'ast'
      assert.throws fn9, TypeError, 'argument is not array'
      fn10 = ->
        q = Queue.fromArray {}
      assert.throws fn10, TypeError, 'argument is not array'
      fn11 = ->
        q = Queue.fromArray [], []
      assert.throws fn11, Error, 'tooo much arguments'

    describe 'errors Container', ->
      it 'copy', ->
        f = ->
          q = new Queue()
          q.copy null
        assert.throws f, TypeError, 'flag `arrayStrategy` should be boolean'
        f = ->
          q = new Queue()
          q.copy yes, 2
        assert.throws f, TypeError, 'copy have one optional argument'

      it 'values', ->
        f = ->
          q = new Queue()
          q.values null
        assert.throws f, TypeError, 'values haven\'t arguments'
        f = ->
          q = new Queue()
          q.values 1, 2
        assert.throws f, TypeError, 'values haven\'t arguments'

      it 'has', ->
        f = ->
          q = new Queue()
          q.has()
        assert.throws f, TypeError, 'has should have one argument'
        f = ->
          q = new Queue()
          q.has(1, 2)
        assert.throws f, TypeError, 'has should have one argument'

      it 'toJSON', ->
        f = ->
          q = new Queue()
          q.toJSON null
        assert.throws f, TypeError, 'toJSON haven\'t arguments'
        f = ->
          q = new Queue()
          q.toJSON 1, 2
        assert.throws f, TypeError, 'toJSON haven\'t arguments'

      it '@isContainer', ->
        f = ->
          Queue.isContainer()
        assert.throws f, Error, 'isContainer should have one argument'
        f = ->
          Queue.isContainer(1, 2)
        assert.throws f, Error, 'isContainer should have one argument'

      it '@fromJSON', ->

        f = ->
          Queue.fromJSON()
        assert.throws f, Error, 'fromJSON should have one or two args'
        f = ->
          Queue.fromJSON({}, yes, 3)
        assert.throws f, Error, 'fromJSON should have one or two args'
        f = ->
          Queue.fromJSON '{a,b,c}'
        assert.throws f, TypeError, '`data` is not a object'
        e = Queue.fromJSON null, yes
        assert.instanceOf e, TypeError
        assert.equal e.message, '`data` is not a object'

        f = ->
          Queue.fromJSON {}, 1
        assert.throws f, TypeError, 'flag `quiet` must be a boolean'

        f = ->
          Queue.fromJSON {}
        assert.throws f, TypeError, 'format `data` is incorrect'
        e = Queue.fromJSON {}, yes
        assert.instanceOf e, TypeError
        assert.equal e.message, 'format `data` is incorrect'

        f = ->
          Queue.fromJSON {type: 'Queue', data: 'a'}
        assert.throws f, Error, 'format `data` is incorrect: data is not a array'
        e = Queue.fromJSON {type: 'Queue', data: 'a'}, yes
        assert.instanceOf e, Error
        assert.equal e.message, 'format `data` is incorrect: data is not a array'

        if typeof Object.keys isnt 'function'
          throw new ReferenceError '
            node is too old: required >= 0.5.1
            or polyfill for Object.keys, but versions < 0.6.0 is unstable, you can read
            https://raw.githubusercontent.com/nodejs/node-v0.x-archive/master/ChangeLog'
        f = ->
          Queue.fromJSON {type: 'Queue', data: [], other: 0}
        assert.throws f, Error, 'format `data` is incorrect: another keys have'
        e = Queue.fromJSON {type: 'Queue', data: [], other: 0}, yes
        assert.instanceOf e, Error
        assert.equal e.message, 'format `data` is incorrect: another keys have'

        f = ->
          Queue.fromJSON {type: 'Lepra', data: []}
        assert.throws f, TypeError, 'type and class name is not conform'
        e = Queue.fromJSON {type: 'Lepra', data: []}, yes
        assert.instanceOf e, TypeError
        assert.equal e.message, 'type and class name is not conform'

    describe 'correct', ->

      it 'new', ->
        q = new Queue()
        assert.instanceOf q, Queue
        assert.instanceOf q, Container
        assert.instanceOf q, CSObject
        assert.lengthOf q, 0

      it 'push', ->
        q = new Queue()
        assert.instanceOf q, Queue
        assert.instanceOf q, CSObject
        assert.lengthOf q, 0
        q.push 1
        assert.lengthOf q, 1

      it 'pop', ->
        q = new Queue()
        obj = {}
        q.push obj
        assert.equal q.pop(), obj
        assert.lengthOf q, 0

      it 'add', ->
        q = new Queue()
        q.add 1, 2, 3
        assert.lengthOf q, 3
        assert.equal q.pop(), 1
        assert.equal q.pop(), 2
        assert.equal q.pop(), 3
        assert.lengthOf q, 0

        q2 = new Queue()
        q2.push 1
        q2.add 2, 3
        q2.push 4
        assert.lengthOf q2, 4
        assert.equal q2.pop(), 1
        assert.equal q2.pop(), 2
        assert.equal q2.pop(), 3
        assert.equal q2.pop(), 4
        assert.lengthOf q2, 0

      it 'clear', ->
        q = new Queue()
        q.add 1, 2, 3
        assert.lengthOf q, 3
        assert.equal q.clear(), q
        assert.lengthOf q, 0
        assert.isNull q.clear(), 'return null if try clear empty list'
        assert.lengthOf q, 0
        q.push 1
        assert.lengthOf q, 1
        q.add 2, 3
        assert.lengthOf q, 3
        assert.equal q.pop(), 1
        assert.equal q.pop(), 2
        assert.equal q.pop(), 3
        assert.lengthOf q, 0

      it 'fromArray', ->
        arr = [true, 'nya', 3, {}]
        q = Queue.fromArray arr
        assert.instanceOf q, Queue
        assert.lengthOf q, 4
        assert.strictEqual v = q.pop(), arr[0]
        assert.strictEqual v, true
        assert.strictEqual q.pop(), arr[1]
        assert.strictEqual v = q.pop(), arr[2]
        assert.strictEqual v, 3
        assert.strictEqual q.pop(), arr[3]
        assert.lengthOf q, 0

        q = Queue.fromArray []
        assert.instanceOf q, Queue
        assert.lengthOf q, 0

    describe 'correct Container', ->
      it 'copy', ->
        q = Queue.fromArray [1, 2, 3]
        q2 = q.copy()
        assert.notEqual q, q2
        assert.instanceOf q2, Queue
        assert.instanceOf q2, Container
        assert.equal q._f.v, q2._f.v
        assert.equal q._f.n.v, q2._f.n.v
        assert.equal q._f.n.n.v, q2._f.n.n.v
        assert.equal q.length, q2.length
        assert.strictEqual 1, q.pop()
        assert.strictEqual 1, q2.pop()
        assert.strictEqual 2, q.pop()
        assert.strictEqual 2, q2.pop()
        assert.strictEqual 3, q.pop()
        assert.strictEqual 3, q2.pop()
        assert.lengthOf q, 0
        assert.lengthOf q2, 0
        q2.add 1, 2, 3
        assert.lengthOf q2, 3
        assert.strictEqual 1, q2.pop()
        assert.strictEqual 2, q2.pop()
        assert.strictEqual 3, q2.pop()

        q.add 1, 2, 3
        q2 = q.copy yes
        assert.notEqual q, q2
        assert.instanceOf q2, Queue
        assert.instanceOf q2, Container
        assert.equal q._f.v, q2._f.v
        assert.equal q._f.n.v, q2._f.n.v
        assert.equal q._f.n.n.v, q2._f.n.n.v
        assert.equal q.length, q2.length
        assert.strictEqual q2.pop(), q.pop()
        assert.strictEqual q2.pop(), q.pop()
        assert.strictEqual q2.pop(), q.pop()
        assert.lengthOf q, 0
        assert.lengthOf q2, 0

      it 'values', ->
        q = Queue.fromArray [1]
        values = q.values()
        assert.isArray values
        assert.lengthOf values, 1
        assert.equal values[0], 1
        b = {a:0}

        realValues = [1,2,3, b]
        q = Queue.fromArray realValues
        values = q.values()
        assert.isArray values
        assert.lengthOf values, 4
        assert.equal values[0], 1
        assert.equal values[1], 2
        assert.equal values[2], 3
        assert.equal values[3], b
        values[3].a = 1
        assert.strictEqual q._f.n.n.n.v.a, 1

      it 'has', ->
        b = {}
        q = Queue.fromArray [1,2,3,b]
        assert.isTrue q.has 1
        assert.isTrue q.has 2
        assert.isTrue q.has 3
        assert.isTrue q.has b
        assert.isFalse q.has null
        assert.isFalse q.has false
        assert.isFalse q.has true
        assert.isFalse q.has '1'

      it 'toString', ->
        b =
          toString: -> 'abra'
        f = {a: 1} # '[object Object]'
        cc0 = new Queue()
        assert.strictEqual cc0.toString(), ''

        cc = Queue.fromArray [1, '2', null, 'undefined', b, f, true]
        str = cc.toString()
        assert.equal str,
          '1->"2"->null->"undefined"->abra->[object Object]->true'

    it 'destroy', ->
      q = new Queue()
      q.push 1
      assert.lengthOf q, 1
      assert.equal q._f, q._b
      assert.equal q._f.v, 1
      f = q._f
      assert.isNull q.destructor()
      assert.isNull q._f
      assert.isNull q._b
      assert.isNull f.n
      assert.isNull f.p
      assert.isNull f.v
      assert.lengthOf q, 0

      q = new Queue()
      q.push 1
      q.push 2
      assert.lengthOf q, 2
      assert.notEqual q._f, q._b
      assert.equal q._f.v, 1
      assert.equal q._b.v, 2
      f = q._f
      b = q._b
      assert.isNull q.destructor()
      assert.isNull q._f
      assert.isNull q._b
      assert.lengthOf q, 0
      assert.isNull f.n
      assert.isNull f.p
      assert.isNull f.v
      assert.isNull b.n
      assert.isNull b.p
      assert.isNull b.v
