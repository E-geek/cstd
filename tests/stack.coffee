{assert} = require 'chai'
{Stack} = require '../lib/stack.coffee'
{CSObject} = require '../lib/object.coffee'
{Container} = require '../lib/container.coffee'
{Node} = require '../lib/node.coffee'

describe 'Stack', ->
  describe 'structure', ->
    it 'class', ->
      assert.ok Stack
      assert.isFunction Stack
      assert.isFunction Stack.fromArray
      assert.lengthOf Stack.fromArray, 1

    it 'proto', ->
      assert.isFunction Stack::destructor
      assert.lengthOf Stack::destructor, 0
      assert.isNumber Stack::length
      assert.isFunction Stack::push
      assert.lengthOf Stack::push, 1
      assert.isFunction Stack::pop
      assert.lengthOf Stack::pop, 0
      assert.isFunction Stack::clear
      assert.lengthOf Stack::clear, 0
      assert.isFunction Stack::add
      assert.lengthOf Stack::add, 0, 'dynamic arguments list'
      # protected elements
      assert.ok Stack::_f
      assert.instanceOf Stack::_f, Node

    it 'Container class', ->
      assert.isFunction Stack.isContainer
      assert.lengthOf Stack.isContainer, 1
      assert.isFunction Stack.fromJSON
      assert.lengthOf Stack.fromJSON, 2, 'data[, quiet]'

    it 'Container proto', ->
      assert.strictEqual Stack::length, -1
      assert.instanceOf Stack::_f, Node
      assert.isFunction Stack::copy
      assert.lengthOf Stack::copy, 1
      assert.isFunction Stack::values
      assert.lengthOf Stack::values, 0
      assert.isFunction Stack::has
      assert.lengthOf Stack::has, 1, 'who'
      assert.isFunction Stack::toString
      assert.lengthOf Stack::toString, 0
      assert.isFunction Stack::toJSON
      assert.lengthOf Stack::toJSON, 0

  describe 'behavior', ->
    it 'errors', ->
      fn = ->
        new Stack 12
      assert.throws fn, TypeError, 'Stack constructor haven\'t arguments'
      fn2 = ->
        q = new Stack()
        q.push 1,2
      assert.throws fn2, TypeError, 'one push, one element'
      fn6 = ->
        q = new Stack()
        q.push()
      assert.throws fn6, TypeError, 'push without value'
      fn7 = ->
        q = new Stack()
        q.add()
      assert.throws fn7, TypeError, 'add without value'
      fn3 = ->
        q = new Stack()
        q.pop()
      assert.throws fn3, Error, 'stack is empty'
      fn4 = ->
        q = new Stack()
        q.push 1
        q.pop 1
      assert.throws fn4, TypeError, 'pop haven\'t arguments'
      fn5 = ->
        q = new Stack()
        q.clear 1
      assert.throws fn5, TypeError, 'clear haven\'t arguments'
      fn8 = ->
        q = Stack.fromArray()
      assert.throws fn8, Error, 'no arguments'
      fn9 = ->
        q = Stack.fromArray 'ast'
      assert.throws fn9, TypeError, 'argument is not array'
      fn10 = ->
        q = Stack.fromArray {}
      assert.throws fn10, TypeError, 'argument is not array'
      fn11 = ->
        q = Stack.fromArray [], []
      assert.throws fn11, Error, 'tooo much arguments'

    describe 'errors Container', ->
      it 'copy', ->
        f = ->
          q = new Stack()
          q.copy null
        assert.throws f, TypeError, 'flag `arrayStrategy` should be boolean'
        f = ->
          q = new Stack()
          q.copy yes, 2
        assert.throws f, TypeError, 'copy have one optional argument'

      it 'values', ->
        f = ->
          q = new Stack()
          q.values null
        assert.throws f, TypeError, 'values haven\'t arguments'
        f = ->
          q = new Stack()
          q.values 1, 2
        assert.throws f, TypeError, 'values haven\'t arguments'

      it 'has', ->
        f = ->
          q = new Stack()
          q.has()
        assert.throws f, TypeError, 'has should have one argument'
        f = ->
          q = new Stack()
          q.has(1, 2)
        assert.throws f, TypeError, 'has should have one argument'

      it 'toJSON', ->
        f = ->
          q = new Stack()
          q.toJSON null
        assert.throws f, TypeError, 'toJSON haven\'t arguments'
        f = ->
          q = new Stack()
          q.toJSON 1, 2
        assert.throws f, TypeError, 'toJSON haven\'t arguments'

      it '@isContainer', ->
        f = ->
          Stack.isContainer()
        assert.throws f, Error, 'isContainer should have one argument'
        f = ->
          Stack.isContainer(1, 2)
        assert.throws f, Error, 'isContainer should have one argument'

      it '@fromJSON', ->

        f = ->
          Stack.fromJSON()
        assert.throws f, Error, 'fromJSON should have one or two args'
        f = ->
          Stack.fromJSON({}, yes, 3)
        assert.throws f, Error, 'fromJSON should have one or two args'
        f = ->
          Stack.fromJSON '{a,b,c}'
        assert.throws f, TypeError, '`data` is not a object'
        e = Stack.fromJSON null, yes
        assert.instanceOf e, TypeError
        assert.equal e.message, '`data` is not a object'

        f = ->
          Stack.fromJSON {}, 1
        assert.throws f, TypeError, 'flag `quiet` must be a boolean'

        f = ->
          Stack.fromJSON {}
        assert.throws f, TypeError, 'format `data` is incorrect'
        e = Stack.fromJSON {}, yes
        assert.instanceOf e, TypeError
        assert.equal e.message, 'format `data` is incorrect'

        f = ->
          Stack.fromJSON {type: 'Stack', data: 'a'}
        assert.throws f, Error, 'format `data` is incorrect: data is not a array'
        e = Stack.fromJSON {type: 'Stack', data: 'a'}, yes
        assert.instanceOf e, Error
        assert.equal e.message, 'format `data` is incorrect: data is not a array'

        if typeof Object.keys isnt 'function'
          throw new ReferenceError '
            node is too old: required >= 0.5.1
            or polyfill for Object.keys, but versions < 0.6.0 is unstable, you can read
            https://raw.githubusercontent.com/nodejs/node-v0.x-archive/master/ChangeLog'
        f = ->
          Stack.fromJSON {type: 'Stack', data: [], other: 0}
        assert.throws f, Error, 'format `data` is incorrect: another keys have'
        e = Stack.fromJSON {type: 'Stack', data: [], other: 0}, yes
        assert.instanceOf e, Error
        assert.equal e.message, 'format `data` is incorrect: another keys have'

        f = ->
          Stack.fromJSON {type: 'Lepra', data: []}
        assert.throws f, TypeError, 'type and class name is not conform'
        e = Stack.fromJSON {type: 'Lepra', data: []}, yes
        assert.instanceOf e, TypeError
        assert.equal e.message, 'type and class name is not conform'

    describe 'correct', ->
      it 'push', ->
        q = new Stack()
        assert.instanceOf q, Stack
        assert.instanceOf q, CSObject
        assert.lengthOf q, 0
        q.push 1
        assert.lengthOf q, 1

      it 'pop', ->
        q = new Stack()
        obj = {}
        q.push obj
        assert.equal q.pop(), obj
        assert.lengthOf q, 0

      it 'add', ->
        q = new Stack()
        q.add 1, 2, 3
        assert.lengthOf q, 3
        assert.equal q.pop(), 3
        assert.equal q.pop(), 2
        assert.equal q.pop(), 1
        assert.lengthOf q, 0

        q2 = new Stack()
        q2.push 1
        q2.add 2, 3
        q2.push 4
        assert.lengthOf q2, 4
        assert.equal q2.pop(), 4
        assert.equal q2.pop(), 3
        assert.equal q2.pop(), 2
        assert.equal q2.pop(), 1
        assert.lengthOf q2, 0

      it 'clear', ->
        q = new Stack()
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
        assert.equal q.pop(), 3
        assert.equal q.pop(), 2
        assert.equal q.pop(), 1
        assert.lengthOf q, 0


      it 'fromArray', ->
        arr = [true, 'nya', 3, {}]
        s = Stack.fromArray arr
        assert.lengthOf s, 4
        assert.instanceOf s, Stack
        assert.strictEqual s.pop(), arr[3]
        assert.strictEqual v = s.pop(), arr[2]
        assert.strictEqual v, 3
        assert.strictEqual s.pop(), arr[1]
        assert.strictEqual v = s.pop(), arr[0]
        assert.strictEqual v, true
        assert.lengthOf s, 0
        s = Stack.fromArray []
        assert.lengthOf s, 0
        assert.instanceOf s, Stack
        
    describe 'correct Container', ->
      it 'copy', ->
        q = Stack.fromArray [1, 2, 3]
        q2 = q.copy()
        assert.notEqual q, q2
        assert.instanceOf q2, Stack
        assert.instanceOf q2, Container
        assert.equal q._f.v, q2._f.v
        assert.equal q._f.n.v, q2._f.n.v
        assert.equal q._f.n.n.v, q2._f.n.n.v
        assert.equal q.length, q2.length
        assert.strictEqual 3, q.pop()
        assert.strictEqual 3, q2.pop()
        assert.strictEqual 2, q.pop()
        assert.strictEqual 2, q2.pop()
        assert.strictEqual 1, q.pop()
        assert.strictEqual 1, q2.pop()
        assert.lengthOf q, 0
        assert.lengthOf q2, 0
        q2.add 1, 2
        q2.push 3
        assert.lengthOf q2, 3
        assert.strictEqual 3, q2.pop()
        assert.strictEqual 2, q2.pop()
        assert.strictEqual 1, q2.pop()

        q.push 1
        q.add 2, 3
        q2 = q.copy yes
        assert.notEqual q, q2
        assert.instanceOf q2, Stack
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
        q = Stack.fromArray [1]
        values = q.values()
        assert.isArray values
        assert.lengthOf values, 1
        assert.equal values[0], 1
        b = {a:0}

        realValues = [1,2,3, b]
        q = Stack.fromArray realValues
        values = q.values()
        assert.isArray values
        assert.lengthOf values, 4
        assert.equal values[0], 1
        assert.equal values[1], 2
        assert.equal values[2], 3
        assert.equal values[3], b
        values[3].a = 1
        assert.strictEqual q._f.v.a, 1

      it 'has', ->
        b = {}
        q = Stack.fromArray [1,2,3,b]
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
        cc0 = new Stack()
        assert.strictEqual cc0.toString(), ''

        cc = Stack.fromArray [1, '2', null, 'undefined', b, f, true]
        str = cc.toString()
        assert.equal str,
          'true->[object Object]->abra->"undefined"->null->"2"->1'

    it 'destroy', ->
      s = new Stack()
      s.push 1
      assert.lengthOf s, 1
      assert.equal s._f.v, 1
      f = s._f
      assert.isNull s.destructor()
      assert.isNull s._f
      assert.isNull f.n
      assert.isNull f.p
      assert.isNull f.v
      assert.lengthOf s, -1

      s = new Stack()
      s.push 1
      s.push 2
      assert.lengthOf s, 2
      assert.equal s._f.v, 2
      f = s._f
      assert.isNull s.destructor()
      assert.isNull s._f
      assert.lengthOf s, -1
      assert.isNull f.n
      assert.isNull f.p
      assert.isNull f.v

      s = new Stack()
      assert.isNull s.destructor()
      assert.lengthOf s, -1
