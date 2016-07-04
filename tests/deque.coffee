{assert} = require 'chai'
{Deque} = require '../lib/deque.coffee'
{Container} = require '../lib/container.coffee'
{CSObject} = require '../lib/object.coffee'
{Node} = require '../lib/node.coffee'

describe 'Deque', ->
  describe 'structure', ->
    it 'class', ->
      assert.ok Deque
      assert.isFunction Deque
      assert.isFunction Deque.fromArray
      assert.lengthOf Deque.fromArray, 1

    it 'proto', ->
      assert.isFunction Deque::destructor
      assert.lengthOf Deque::destructor, 0
      assert.isNumber Deque::length
      assert.isFunction Deque::push
      assert.lengthOf Deque::push, 1
      assert.isFunction Deque::pop
      assert.lengthOf Deque::pop, 0
      assert.isFunction Deque::pushBack
      assert.lengthOf Deque::pushBack, 1
      assert.isFunction Deque::popBack
      assert.lengthOf Deque::popBack, 0
      assert.isFunction Deque::pushFront
      assert.lengthOf Deque::pushFront, 1
      assert.isFunction Deque::popFront
      assert.lengthOf Deque::popFront, 0
      assert.isFunction Deque::clear
      assert.lengthOf Deque::clear, 0
      assert.isFunction Deque::add
      assert.lengthOf Deque::add, 0, 'dynamic arguments list'
      # protected elements
      assert.ok Deque::_f
      assert.instanceOf Deque::_f, Node
      assert.ok Deque::_b
      assert.instanceOf Deque::_b, Node

    it 'Container class', ->
      assert.isFunction Deque.isContainer
      assert.lengthOf Deque.isContainer, 1
      assert.isFunction Deque.fromJSON
      assert.lengthOf Deque.fromJSON, 2, 'data[, quiet]'

    it 'Container proto', ->
      assert.strictEqual Deque::length, -1
      assert.instanceOf Deque::_f, Node
      assert.isFunction Deque::copy
      assert.lengthOf Deque::copy, 1
      assert.isFunction Deque::values
      assert.lengthOf Deque::values, 0
      assert.isFunction Deque::has
      assert.lengthOf Deque::has, 1, 'who'
      assert.isFunction Deque::toString
      assert.lengthOf Deque::toString, 0
      assert.isFunction Deque::toJSON
      assert.lengthOf Deque::toJSON, 0

  describe 'behavior', ->
    describe 'errors', ->
      it 'new', ->
        fn = ->
          new Deque 12
        assert.throws fn, TypeError, 'Deque constructor haven\'t arguments'
      it 'push', ->
        fn2 = ->
          dq = new Deque()
          dq.pushBack 1,2
        assert.throws fn2, TypeError, 'one push, one element'
        fn2 = ->
          dq = new Deque()
          dq.push 1,2
        assert.throws fn2, TypeError, 'one push, one element'
        fn2 = ->
          dq = new Deque()
          dq.pushFront 1,2
        assert.throws fn2, TypeError, 'one push, one element'
        fn3 = ->
          dq = new Deque()
          dq.pushBack()
        assert.throws fn3, TypeError, 'push without value'
        fn3 = ->
          dq = new Deque()
          dq.push()
        assert.throws fn3, TypeError, 'push without value'
        fn3 = ->
          dq = new Deque()
          dq.pushFront()
        assert.throws fn3, TypeError, 'push without value'
      it 'add', ->
        fn7 = ->
          dq = new Deque()
          dq.add()
        assert.throws fn7, TypeError, 'add without value'
      it 'pop', ->
        fn3 = ->
          dq = new Deque()
          dq.pop()
        assert.throws fn3, Error, 'deque is empty'
        fn4 = ->
          dq = new Deque()
          dq.push 1
          dq.pop 1
        assert.throws fn4, TypeError, 'pop haven\'t arguments'
        fn3 = ->
          dq = new Deque()
          dq.popFront()
        assert.throws fn3, Error, 'deque is empty'
        fn4 = ->
          dq = new Deque()
          dq.push 1
          dq.popFront 1
        assert.throws fn4, TypeError, 'pop haven\'t arguments'
        fn3 = ->
          dq = new Deque()
          dq.popBack()
        assert.throws fn3, Error, 'deque is empty'
        fn4 = ->
          dq = new Deque()
          dq.push 1
          dq.popBack 1
        assert.throws fn4, TypeError, 'pop haven\'t arguments'
      it 'clear', ->
        fn5 = ->
          dq = new Deque()
          dq.clear 1
        assert.throws fn5, TypeError, 'clear haven\'t arguments'
      it ':fromArray', ->
        fn8 = ->
          dq = Deque.fromArray()
        assert.throws fn8, Error, 'no arguments'
        fn9 = ->
          dq = Deque.fromArray 'ast'
        assert.throws fn9, TypeError, 'argument is not array'
        fn10 = ->
          dq = Deque.fromArray {}
        assert.throws fn10, TypeError, 'argument is not array'
        fn11 = ->
          dq = Deque.fromArray [], []
        assert.throws fn11, Error, 'tooo much arguments'

    describe 'errors Container', ->
      it 'copy', ->
        f = ->
          q = new Deque()
          q.copy null
        assert.throws f, TypeError, 'flag `arrayStrategy` should be boolean'
        f = ->
          q = new Deque()
          q.copy yes, 2
        assert.throws f, TypeError, 'copy have one optional argument'

      it 'values', ->
        f = ->
          q = new Deque()
          q.values null
        assert.throws f, TypeError, 'values haven\'t arguments'
        f = ->
          q = new Deque()
          q.values 1, 2
        assert.throws f, TypeError, 'values haven\'t arguments'

      it 'has', ->
        f = ->
          q = new Deque()
          q.has()
        assert.throws f, TypeError, 'has should have one argument'
        f = ->
          q = new Deque()
          q.has(1, 2)
        assert.throws f, TypeError, 'has should have one argument'

      it 'toJSON', ->
        f = ->
          q = new Deque()
          q.toJSON null
        assert.throws f, TypeError, 'toJSON haven\'t arguments'
        f = ->
          q = new Deque()
          q.toJSON 1, 2
        assert.throws f, TypeError, 'toJSON haven\'t arguments'

      it '@isContainer', ->
        f = ->
          Deque.isContainer()
        assert.throws f, Error, 'isContainer should have one argument'
        f = ->
          Deque.isContainer(1, 2)
        assert.throws f, Error, 'isContainer should have one argument'

      it '@fromJSON', ->

        f = ->
          Deque.fromJSON()
        assert.throws f, Error, 'fromJSON should have one or two args'
        f = ->
          Deque.fromJSON({}, yes, 3)
        assert.throws f, Error, 'fromJSON should have one or two args'
        f = ->
          Deque.fromJSON '{a,b,c}'
        assert.throws f, TypeError, '`data` is not a object'
        e = Deque.fromJSON null, yes
        assert.instanceOf e, TypeError
        assert.equal e.message, '`data` is not a object'

        f = ->
          Deque.fromJSON {}, 1
        assert.throws f, TypeError, 'flag `quiet` must be a boolean'

        f = ->
          Deque.fromJSON {}
        assert.throws f, TypeError, 'format `data` is incorrect'
        e = Deque.fromJSON {}, yes
        assert.instanceOf e, TypeError
        assert.equal e.message, 'format `data` is incorrect'

        f = ->
          Deque.fromJSON {type: 'Deque', data: 'a'}
        assert.throws f, Error, 'format `data` is incorrect: data is not a array'
        e = Deque.fromJSON {type: 'Deque', data: 'a'}, yes
        assert.instanceOf e, Error
        assert.equal e.message, 'format `data` is incorrect: data is not a array'

        if typeof Object.keys isnt 'function'
          throw new ReferenceError '
            node is too old: required >= 0.5.1
            or polyfill for Object.keys, but versions < 0.6.0 is unstable, you can read
            https://raw.githubusercontent.com/nodejs/node-v0.x-archive/master/ChangeLog'
        f = ->
          Deque.fromJSON {type: 'Deque', data: [], other: 0}
        assert.throws f, Error, 'format `data` is incorrect: another keys have'
        e = Deque.fromJSON {type: 'Deque', data: [], other: 0}, yes
        assert.instanceOf e, Error
        assert.equal e.message, 'format `data` is incorrect: another keys have'

        f = ->
          Deque.fromJSON {type: 'Lepra', data: []}
        assert.throws f, TypeError, 'type and class name is not conform'
        e = Deque.fromJSON {type: 'Lepra', data: []}, yes
        assert.instanceOf e, TypeError
        assert.equal e.message, 'type and class name is not conform'

    describe 'correct', ->
      
      it 'new', ->
        q = new Deque()
        assert.instanceOf q, Deque
        assert.instanceOf q, Container
        assert.instanceOf q, CSObject
        assert.lengthOf q, 0
        
      it 'push', ->
        dq = new Deque()
        assert.instanceOf dq, Deque
        assert.instanceOf dq, CSObject
        assert.lengthOf dq, 0
        dq.push 1
        assert.lengthOf dq, 1
        dq.pushBack 2
        assert.lengthOf dq, 2
        dq.pushFront 0
        assert.lengthOf dq, 3
        assert.equal dq._f.v, 0
        assert.equal dq._f.n.v, 1
        assert.equal dq._f.n.n.v, 2
        assert.equal dq._f.n.n, dq._b
        dq = new Deque()
        dq.pushFront(1)
        assert.equal dq._f.v, 1
        assert.lengthOf dq, 1

      it 'pop', ->
        dq = new Deque()
        obj = {}
        dq.push obj
        assert.equal dq.pop(), obj
        assert.lengthOf dq, 0
        dq.push 1
        dq.push 2
        dq.push 3
        dq.push 4
        assert.equal dq.pop(), 1
        assert.equal dq.popFront(), 2
        assert.equal dq.popBack(), 4
        assert.equal dq.pop(), 3
        assert.lengthOf dq, 0
        dq.push(1)
        assert.equal dq.popBack(), 1
        assert.lengthOf dq, 0

      it 'add', ->
        dq = new Deque()
        dq.add 1, 2, 3
        assert.lengthOf dq, 3
        assert.equal dq.pop(), 1
        assert.equal dq.pop(), 2
        assert.equal dq.pop(), 3
        assert.lengthOf dq, 0

        dq2 = new Deque()
        dq2.push 1
        dq2.add 2, 3
        dq2.push 4
        assert.lengthOf dq2, 4
        assert.equal dq2.pop(), 1
        assert.equal dq2.pop(), 2
        assert.equal dq2.pop(), 3
        assert.equal dq2.pop(), 4
        assert.lengthOf dq2, 0

      it 'clear', ->
        dq = new Deque()
        dq.add 1, 2, 3
        assert.lengthOf dq, 3
        assert.equal dq.clear(), dq
        assert.lengthOf dq, 0
        assert.isNull dq.clear(), 'return null if try clear empty list'
        assert.lengthOf dq, 0
        dq.push 1
        assert.lengthOf dq, 1
        dq.add 2, 3
        assert.lengthOf dq, 3
        assert.equal dq.pop(), 1
        assert.equal dq.pop(), 2
        assert.equal dq.pop(), 3
        assert.lengthOf dq, 0


      it 'fromArray', ->
        arr = [true, 'nya', 3, {}]
        dq = Deque.fromArray arr
        assert.instanceOf dq, Deque
        assert.lengthOf dq, 4
        assert.strictEqual v = dq.pop(), arr[0]
        assert.strictEqual v, true
        assert.strictEqual dq.pop(), arr[1]
        assert.strictEqual v = dq.pop(), arr[2]
        assert.strictEqual v, 3
        assert.strictEqual dq.pop(), arr[3]
        assert.lengthOf dq, 0
        dq = new Deque.fromArray []
        assert.instanceOf dq, Deque
        assert.lengthOf dq, 0
        
    describe 'correct Container', ->
      it 'copy', ->
        q = Deque.fromArray [1, 2, 3]
        q2 = q.copy()
        assert.notEqual q, q2
        assert.instanceOf q2, Deque
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
        assert.instanceOf q2, Deque
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
        q = Deque.fromArray [1]
        values = q.values()
        assert.isArray values
        assert.lengthOf values, 1
        assert.equal values[0], 1
        b = {a:0}

        realValues = [1,2,3, b]
        q = Deque.fromArray realValues
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
        q = Deque.fromArray [1,2,3,b]
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
        cc0 = new Deque()
        assert.strictEqual cc0.toString(), ''

        cc = Deque.fromArray [1, '2', null, 'undefined', b, f, true]
        str = cc.toString()
        assert.equal str,
          '1->"2"->null->"undefined"->abra->[object Object]->true'

    it 'destroy', ->
      dq = new Deque()
      dq.push 1
      assert.lengthOf dq, 1
      assert.equal dq._f, dq._b
      assert.equal dq._f.v, 1
      f = dq._f
      assert.isNull dq.destructor()
      assert.isNull dq._f
      assert.isNull dq._b
      assert.isNull f.n
      assert.isNull f.p
      assert.isNull f.v
      assert.lengthOf dq, 0

      dq = new Deque()
      dq.push 1
      dq.push 2
      assert.lengthOf dq, 2
      assert.notEqual dq._f, dq._b
      assert.equal dq._f.v, 1
      assert.equal dq._b.v, 2
      f = dq._f
      b = dq._b
      assert.isNull dq.destructor()
      assert.isNull dq._f
      assert.isNull dq._b
      assert.lengthOf dq, 0
      assert.isNull f.n
      assert.isNull f.p
      assert.isNull f.v
      assert.isNull b.n
      assert.isNull b.p
      assert.isNull b.v
