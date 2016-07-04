{assert} = require 'chai'
{List} = require '../lib/list.coffee'
{CSObject} = require '../lib/object.coffee'
{Node} = require '../lib/node.coffee'

describe 'List', ->
  describe 'structure', ->
    it 'class', ->
      assert.ok List
      assert.isFunction List
      assert.isFunction List.fromArray
      assert.lengthOf List.fromArray, 1

    it 'proto', ->
      assert.isFunction List::destructor
      assert.lengthOf List::destructor, 0
      assert.isNumber List::length
      assert.equal List::length, 0
      assert.isNumber List::index
      assert.equal List::index, -1

      assert.isFunction List::pushBack
      assert.lengthOf List::pushBack, 1
      assert.isFunction List::popBack
      assert.lengthOf List::popBack, 0
      assert.isFunction List::pushFront
      assert.lengthOf List::pushFront, 1
      assert.isFunction List::popFront
      assert.lengthOf List::popFront, 0

      assert.isFunction List::append
      assert.lengthOf List::append, 1
      assert.isFunction List::prepend
      assert.lengthOf List::prepend, 1
      assert.isFunction List::add
      assert.lengthOf List::add, 0, 'dynamic arguments list'

      assert.isFunction List::swap
      assert.lengthOf List::swap, 1, '[rev = no]'

      assert.isFunction List::go, 'move pointer to `n` steps'
      assert.lengthOf List::go, 1
      assert.isFunction List::next, 'move pointer to next step'
      assert.lengthOf List::next, 0
      assert.isFunction List::prev, 'move pointer to prev step'
      assert.lengthOf List::prev, 0
      assert.isFunction List::begin, 'move pointer to first elem'
      assert.lengthOf List::begin, 0
      assert.isFunction List::end, 'move pointer to last elem'
      assert.lengthOf List::end, 0

      assert.isFunction List::getFront, 'get first value without remove'
      assert.lengthOf List::getFront, 0
      assert.isFunction List::getBack, 'get last value without remove'
      assert.lengthOf List::getBack, 0
      assert.isFunction List::currentNode, 'return current node'
      assert.lengthOf List::currentNode, 0
      assert.isFunction List::get, 'return current value'
      assert.lengthOf List::get, 0
      assert.isFunction List::set, 'set value for current pointer.
          list.set("some") is list.currentNode().v = "some" '
      assert.lengthOf List::set, 1

      assert.isFunction List::erase
      assert.lengthOf List::erase, 3, 'first pointer position begin start[, last position=start [, returnNodes = yes]]'
      assert.isFunction List::clear
      assert.lengthOf List::clear, 0
      # protected elements
      assert.ok List::_p
      assert.instanceOf List::_p, Node
      assert.ok List::_f
      assert.instanceOf List::_f, Node
      assert.ok List::_b
      assert.instanceOf List::_b, Node

  describe 'behavior', ->
    describe 'errors', ->
      it 'new', ->
        fn = ->
          new List 12
        assert.throws fn, TypeError, 'List constructor haven\'t arguments'

      it 'push', ->
        fn2 = ->
          l = new List()
          l.pushBack 1,2
        assert.throws fn2, TypeError, 'one pushBack, one element'
        fn2 = ->
          l = new List()
          l.pushFront 1,2
        assert.throws fn2, TypeError, 'one pushFront, one element'
        fn3 = ->
          l = new List()
          l.pushBack()
        assert.throws fn3, TypeError, 'pushBack without value'
        fn3 = ->
          l = new List()
          l.pushFront()
        assert.throws fn3, TypeError, 'pushFront without value'

      it 'append/prepend', ->
        fn = ->
          l = new List
          l.append 1, 2
        assert.throws fn, TypeError, 'more than one append'
        fn2 = ->
          l = new List
          l.prepend 1, 2
        assert.throws fn2, TypeError, 'more than one prepend'
        fn = ->
          l = new List
          l.append()
        assert.throws fn, TypeError, 'append nothing'
        fn2 = ->
          l = new List
          l.prepend()
        assert.throws fn2, TypeError, 'prepend nothing'

      it 'add', ->
        fn7 = ->
          l = new List()
          l.add()
        assert.throws fn7, TypeError, 'add without value'

      it 'pop', ->
        fn3 = ->
          l = new List()
          l.popFront()
        assert.throws fn3, Error, 'list is empty'
        fn4 = ->
          l = new List()
          l.pushFront 1
          l.popFront 1
        assert.throws fn4, TypeError, 'popFront haven\'t arguments'
        fn3 = ->
          l = new List()
          l.popBack()
        assert.throws fn3, Error, 'list is empty'
        fn4 = ->
          l = new List()
          l.pushFront 1
          l.popBack 1
        assert.throws fn4, TypeError, 'popBack haven\'t arguments'

      it 'go', ->
        fn = ->
          l = new List
          l.go()
        assert.throws fn, Error, '`step` is required'
        fn = ->
          l = new List
          l.go('+1')
        assert.throws fn, TypeError, '`step` must be a Number'
        fn = ->
          l = new List
          l.go(1, 2)
        assert.throws fn, Error, 'too many arguments'

      it 'next/prev', ->
        fn = ->
          l = new List
          l.next null
        assert.throws fn, Error, 'next haven\'t arguments'
        fn = ->
          l = new List
          l.prev '-2'
        assert.throws fn, Error, 'prev haven\'t arguments'

      it 'begin/end', ->
        fn = ->
          l = new List
          l.begin null
        assert.throws fn, Error, 'begin haven\'t arguments'
        fn = ->
          l = new List
          l.end '-2'
        assert.throws fn, Error, 'end haven\'t arguments'

      it 'getFront/getBac/currentNode/get', ->
        fn = ->
          l = new List
          l.getFront null
        assert.throws fn, Error, 'getFront haven\'t arguments'
        fn = ->
          l = new List
          l.getFront()
        assert.throws fn, Error, 'list is empty'
        fn = ->
          l = new List
          l.getBack '-2'
        assert.throws fn, Error, 'getBack haven\'t arguments'
        fn = ->
          l = new List
          l.getBack()
        assert.throws fn, Error, 'list is empty'
        fn = ->
          l = new List
          l.currentNode null
        assert.throws fn, Error, 'currentNode haven\'t arguments'
        fn = ->
          l = new List
          l.currentNode()
        assert.throws fn, Error, 'list is empty'
        fn = ->
          l = new List
          l.get '-2'
        assert.throws fn, Error, 'get haven\'t arguments'
        fn = ->
          l = new List
          l.get()
        assert.throws fn, Error, 'list is empty'

      it 'swap', ->
        fn = ->
          l = new List
          l.swap()
        assert.throws fn, Error, 'for swap require 2 nodes minimum'
        fn = ->
          l = new List()
          l.add 1
          l.swap()
        assert.throws fn, Error, 'for swap require 2 nodes minimum'
        fn = ->
          l = new List()
          l.add 1, 2
          l.next()
          l.swap()
        assert.throws fn, Error, 'it is last element, swap impossible'
        fn = ->
          l = new List()
          l.add 1, 2
          l.swap(yes) # revert
        assert.throws fn, Error, 'it is first element, reverse swap impossible'

      it 'set', ->
        fn = ->
          l = new List
          l.set()
        assert.throws fn, Error, 'can\'t set nothing to value'
        fn = ->
          l = new List
          l.set(1)
        assert.throws fn, Error, 'can\'t set to empty list'
        fn = ->
          l = new List
          l.pushFront 0
          .set(1, 2)
        assert.throws fn, Error, 'too many arguments'

      it 'erase', ->
        fn = ->
          l = new List
          l.erase({})
        assert.throws fn, TypeError, '`start` must be a number or boolean'
        fn = ->
          l = new List
          l.erase(1, {})
        assert.throws fn, TypeError, '`end` must be a number or boolean'
        fn = ->
          l = new List
          l.erase(1, 2, no, 4)
        assert.throws fn, Error, 'too many arguments'
        fn = ->
          l = new List()
          l.erase()
        assert.throws fn, RangeError, 'list is empty'
        fn = ->
          l = new List()
          l.erase 0
        assert.throws fn, RangeError, 'list is empty'
        fn = ->
          l = new List()
          l.add 0
          l.erase -1
        assert.throws fn, RangeError, '`start` less than 0'
        fn = ->
          l = new List()
          l.add 1
          l.erase 1
        assert.throws fn, RangeError, '`start` more than last index'
        fn = ->
          l = new List()
          l.add 0
          l.erase 0, -1
        assert.throws fn, RangeError, '`end` less than index of `start`'
        fn = ->
          l = new List()
          l.add 0
          l.erase 0, no, 0
        assert.throws fn, TypeError, '`end` must be a number'
        fn = ->
          l = new List()
          l.add 0
          l.erase 0, {}
        assert.throws fn, TypeError, '`end` must be a number'
        fn = ->
          l = new List()
          l.add 1
          l.erase 0, 1
        assert.throws fn, RangeError, '`end` more than last index'
        fn = ->
          l = new List()
          l.add 0
          l.erase 0, 0, {}
        assert.throws fn, TypeError, '`returnNodes` must be a boolean'

      it 'clear', ->
        fn5 = ->
          l = new List()
          l.clear 1
        assert.throws fn5, TypeError, 'clear haven\'t arguments'
      it ':fromArray', ->
        fn8 = ->
          List.fromArray()
        assert.throws fn8, Error, 'no arguments'
        fn9 = ->
          List.fromArray 'ast'
        assert.throws fn9, TypeError, 'argument is not array'
        fn10 = ->
          List.fromArray {}
        assert.throws fn10, TypeError, 'argument is not array'
        fn11 = ->
          List.fromArray [], []
        assert.throws fn11, Error, 'too much arguments'

    describe 'correct', ->
      it 'new', ->
        l = new List()
        assert.instanceOf l, List
        assert.instanceOf l, CSObject
        assert.equal l.index, -1
        assert.lengthOf l, 0

      it 'pushBack', ->
        l = new List()
        assert.equal l, l.pushFront 1
        assert.equal l.index, 0
        assert.lengthOf l, 1
        assert.equal l, l.pushBack 2
        assert.equal l.index, 0
        assert.lengthOf l, 2
        assert.equal l, l.pushFront 0
        assert.equal l.index, 1
        assert.lengthOf l, 3
        assert.equal l._f.v, 0
        assert.equal l._f.n.v, 1
        assert.equal l._f.n.n.v, 2
        assert.equal l._f.n.n, l._b

      it 'pop', ->
        l = new List()
        obj = {}
        l.pushBack obj
        assert.equal l.popBack(), obj
        assert.isNull l._b.n
        assert.isNull l._f.p
        assert.equal l._b, l._f
        assert.lengthOf l, 0
        l.pushBack 1
        l.pushBack 2
        l.pushBack 3
        l.pushBack 4
        assert.equal l.popBack(), 4
        assert.isNull l._b.n
        assert.equal l.index, 0
        assert.equal l.get(), 1
        assert.equal l.popFront(), 1
        assert.isNull l._f.p
        assert.equal l.index, 0
        assert.equal l.get(), 2
        assert.equal l.popBack(), 3
        assert.isNull l._b.n
        assert.equal l.index, 0
        assert.equal l.get(), 2
        assert.equal l.popFront(), 2
        assert.isNull l._f.p
        assert.lengthOf l, 0
        assert.equal l.index, -1

      it 'add', ->
        l = new List()
        l.pushFront 1
        assert.equal l, l.add 2, 3, obj = {}
        assert.equal l.index, 0
        assert.lengthOf l, 4
        # check links
        assert.equal l.get(), 1
        assert.equal l.begin().get(), 1
        assert.equal l.next().get(), 2
        assert.equal l.next().get(), 3
        assert.equal l.next().get(), obj
        # reverse go
        assert.equal l.end().get(), obj
        assert.equal l.prev().get(), 3
        assert.equal l.prev().get(), 2
        assert.equal l.prev().get(), 1
        # check erase
        assert.equal l.popFront(), 1
        assert.equal l.popFront(), 2
        assert.equal l.popFront(), 3
        assert.lengthOf l, 1
        assert.equal l._f.v, obj

      it 'get', ->
        l = new List()
        l.add 1, 2, 3, 4
        assert.equal l.get(), 1
        assert.lengthOf l, 4
        assert.equal l.index, 0
        l.pushFront 0
        assert.equal l.index, 1
        assert.equal l.get(), 1
        l.popFront()
        assert.equal l.index, 0
        assert.equal l.get(), 1
        l.popFront()
        assert.equal l.index, 0
        assert.equal l.get(), 2, 'erase current element => go prev or go next'

      it 'next', ->
        l = new List()
        assert.isNull l.next()
        l.add 1,2,3,4
        assert.equal l, l.next()
        assert.equal l.index, 1
        assert.equal l.get(), 2
        assert.equal l, l.next()
        assert.equal l.index, 2
        assert.equal l.get(), 3
        assert.equal l.next().get(), 4
        assert.isNull l.next()
        assert.equal l.get(), 4

      it 'prev', ->
        l = new List()
        assert.isNull l.prev()
        l.pushFront 4
        l.pushFront 3
        l.pushFront 2
        l.pushFront 1
        assert.equal l.get(), 4
        assert.equal l.index, 3
        assert.equal l, l.prev()
        assert.equal l.get(), 3
        assert.equal l.index, 2
        assert.equal l, l.prev()
        assert.equal l.get(), 2
        assert.equal l.index, 1
        assert.equal l.prev().get(), 1
        assert.isNull l.prev()
        assert.equal l.get(), 1

      it 'append', ->
        l = new List()
        assert.equal l, l.append(1)
        assert.lengthOf l, 1
        assert.equal l.index, 0
        assert.equal l.get(), 1
        assert.equal l, l.append(2)
        assert.lengthOf l, 2
        assert.equal l.index, 0
        assert.equal l.get(), 1
        assert.equal l, l.append(3)
        assert.lengthOf l, 3
        assert.equal l.index, 0
        assert.equal l.get(), 1
        assert.equal l.next().get(), 3
        assert.equal l.index, 1
        assert.equal l.next().get(), 2
        assert.equal l.index, 2

      it 'prepend', ->
        l = new List()
        assert.equal l, l.prepend(1)
        assert.lengthOf l, 1
        assert.equal l.index, 0
        assert.equal l.get(), 1
        assert.equal l, l.prepend(2)
        assert.lengthOf l, 2
        assert.equal l.index, 1
        assert.equal l.get(), 1
        assert.equal l, l.prepend(3)
        assert.lengthOf l, 3
        assert.equal l.index, 2
        assert.equal l.get(), 1
        assert.equal l.prev().get(), 3
        assert.equal l.index, 1
        assert.equal l.prev().get(), 2
        assert.equal l.index, 0

      it 'go', ->
        l = new List()
        assert.isNull l.go(0)
        assert.isNull l.go(1)
        assert.isNull l.go(-1)
        l.add 1,2,3,4
        assert.equal l.index, 0
        assert.equal l.get(), 1
        assert.equal l, l.go(2)
        assert.equal l.index, 2
        assert.equal l.get(), 3
        assert.equal l, l.go(-1)
        assert.equal l.index, 1
        assert.equal l.get(), 2
        assert.equal l, l.go(2)
        assert.equal l.index, 3
        assert.equal l.get(), 4
        assert.equal l, l.go(-3)
        assert.equal l.index, 0
        assert.equal l.get(), 1
        assert.isNull l.go(4)
        assert.equal l.index, 0
        assert.equal l.get(), 1
        assert.equal l, l.go(0)
        assert.equal l.index, 0
        assert.equal l.get(), 1

      it 'begin', ->
        l = new List()
        assert.isNull l.begin()
        l.add 1,2,3,4
        assert.equal l.next().next().next().get(), 4
        assert.equal l, l.begin()
        assert.equal l.index, 0
        assert.equal l.get(), 1

      it 'end', ->
        l = new List()
        assert.isNull l.end()
        l.add 1,2,3,4
        assert.equal l, l.end()
        assert.equal l.index, 3
        assert.equal l.get(), 4
        assert.equal l.go(-3).get(), 1
        assert.equal l.end().get(), 4

      it 'getFront', ->
        l = new List()
        l.add 1,2,3,4
        .go 3
        assert.equal l.get(), 4
        assert.equal l.getFront(), 1
        assert.equal l.index, 3
        assert.equal l.get(), 4
        l.popBack()
        l.popBack()
        l.popBack()
        assert.equal l.index, 0
        assert.equal l.get(), 1
        assert.equal l.getFront(), 1
        assert.equal l.index, 0
        assert.equal l.get(), 1

      it 'getBack', ->
        l = new List()
        l.add 1,2,3,4
        assert.equal l.get(), 1
        assert.equal l.getBack(), 4
        assert.equal l.index, 0
        assert.equal l.get(), 1
        l.popFront()
        l.popFront()
        l.popFront()
        assert.equal l.index, 0
        assert.equal l.get(), 4
        assert.equal l.getBack(), 4
        assert.equal l.index, 0
        assert.equal l.get(), 4

      it 'currentNode', ->
        l = new List()
        o1 = {}
        o2 = {}
        o3 = {}
        l.add o2
        .prepend o1
        .append o3
        assert.equal l.get(), o2
        node = l.currentNode()
        assert.instanceOf node, Node
        assert.equal node.v, o2
        assert.equal node.p.v, o1
        assert.equal node.n.v, o3

      it 'swap', ->
        l = new List()
        l.add 1, 2, 3
        assert.equal l.index, 0
        assert.lengthOf l, 3
        assert.equal l.get(), 1
        assert.equal l.swap(), l

        assert.equal l.index, 0
        assert.lengthOf l, 3
        assert.equal l.get(), 2
        assert.equal l.swap(), l
        assert.equal l.get(), 1
        assert.equal l.index, 0

        l.next().swap()
        assert.equal l.get(), 3
        assert.equal l.index, 1
        l.next().swap(yes)
        assert.equal l.get(), 3
        assert.equal l.index, 2
        l.prev().swap(yes)
        assert.equal l.get(), 1
        assert.equal l.index, 1
        assert.equal l.prev().get(), 2
        assert.equal l.index, 0
        assert.lengthOf l, 3


      it 'set', ->
        l = new List()
        l.add 1,2,3,4
        assert.equal l, l.set 'saitama'
        assert.equal l.get(), 'saitama'
        assert.equal l.next().get(), 2
        assert.equal l, l.set 'naomi'
        assert.equal l.get(), 'naomi'
        l.prev()
        assert.equal l.get(), 'saitama'
        assert.equal l.next().get(), 'naomi'
        assert.equal l.next().get(), 3
        assert.equal l.next().get(), 4

      it 'erase', ->
        l = new List()
        l.add 1,2,3,4
        tn = l.next().currentNode()
        l.begin()
        n = l.erase 1
        assert.equal n, tn
        assert.isNull n.n
        assert.isNull n.p
        assert.equal n.v, 2
        assert.lengthOf l, 3
        assert.equal l.index, 0
        assert.equal l.begin().get(), 1
        assert.equal l.next().get(), 3
        assert.equal l.next().get(), 4
        assert.equal l.end().get(), 4
        assert.equal l.prev().get(), 3
        assert.equal l.prev().get(), 1
        # remove under-self
        l.append(2).next()
        assert.equal l.index, 1
        assert.equal l.get(), 2
        assert.equal l, l.erase 1, no
        assert.lengthOf l, 3
        assert.equal l.index, 0
        assert.equal l.begin().get(), 1
        assert.equal l.next().get(), 3
        assert.equal l.next().get(), 4
        assert.equal l.end().get(), 4
        assert.equal l.prev().get(), 3
        assert.equal l.prev().get(), 1
        # remove before index
        l.append(2).next().next()
        assert.equal l.index, 2
        assert.equal l.get(), 3
        assert.lengthOf l, 4
        assert.equal l, l.erase 1, no
        assert.lengthOf l, 3
        assert.equal l.index, 1
        assert.equal l.get(), 3
        assert.equal l.begin().get(), 1
        assert.equal l.next().get(), 3
        assert.equal l.next().get(), 4
        assert.equal l.end().get(), 4
        assert.equal l.prev().get(), 3
        assert.equal l.prev().get(), 1

        l.clear().add 1
        assert.equal l, l.erase(no)

        l
        .add 1,2,3,4,5,6
        .end()
        #remove first
        assert.equal l.erase().v, 6
        assert.equal l.get(), 5
        assert.equal l.index, 4
        assert.equal l.prev().erase().v, 4
        assert.equal l.get(), 3
        assert.equal l.index, 2
        assert.equal l.begin().erase().v, 1
        assert.equal l.get(), 2
        assert.equal l.index, 0
        assert.lengthOf l, 3

      it 'erase:range', ->
        l = new List()
        l.add 1, 3, 4 # as prev
        l.add 5, 6
        tn = l.next().currentNode()
        tn2 = l.next().currentNode()
        tn3 = l.next().currentNode()
        #assert.notEqual tn, n
        assert.equal tn.v, 3
        assert.equal tn2.v, 4
        assert.equal tn3.v, 5
        assert.lengthOf l, 5
        erResult = l.erase 1,3
        assert.isArray erResult
        assert.lengthOf erResult, 3
        assert.lengthOf l, 2
        assert.deepEqual erResult, [tn, tn2, tn3]
        assert.isNull tn.n
        assert.isNull tn.p
        assert.equal tn.v, 3
        assert.isNull tn2.n
        assert.isNull tn2.p
        assert.equal tn2.v, 4
        assert.isNull tn3.n
        assert.isNull tn3.p
        assert.equal tn3.v, 5
        assert.equal l.index, 0
        assert.equal l.get(), 1
        assert.equal l.next().get(), 6
        assert.equal l.prev().get(), 1
        assert.equal l, l.erase 0, 1, no
        assert.lengthOf l, 0
        assert.equal l.index, -1
        assert.equal l._f, l._b
        assert.equal l._f, l._p

      it 'erase:range:(-end)', ->
        l = new List()
        l.add 1,2,3,4
        l.end()
        assert.equal l.index, 3
        result = l.erase 2, 0
        assert.lengthOf l, 2
        assert.equal l.index, 1
        assert.equal l.get(), 2
        assert.lengthOf result, 2
        assert.equal result[0].v, 3
        assert.equal result[1].v, 4

        l.add 3,4,5,6
        assert.lengthOf l, 6
        assert.equal l.index, 1

        result = l.erase 2, -1
        assert.lengthOf l, 3
        assert.equal l.index, 1
        assert.equal l.get(), 2
        assert.lengthOf result, 3
        assert.equal result[0].v, 3
        assert.equal result[1].v, 4
        assert.equal result[2].v, 5
        assert.equal l.next().get(), 6
        assert.equal l.prev().get(), 2
        assert.equal l.prev().get(), 1
        assert.equal l.end().get(), 6

      it 'erase:first', ->
        l = new List()
        l.add 1,2
        l.next()
        assert.equal l.index, 1
        n = l.erase 0
        assert.equal n.v, 1
        assert.isNull n.p
        assert.isNull n.n
        assert.equal l.get(), 2
        assert.lengthOf l, 1
        assert.equal l.index, 0
        assert.equal l.getFront(), 2
        assert.equal l.end().get(), 2
        n = l.erase 0
        assert.lengthOf l, 0
        assert.notEqual n, l._f
        assert.equal l.index, -1
        assert.equal l._f, l._b
        assert.equal l._f, l._p
        assert.isNull l._f.v
        assert.isNull l._f.n
        assert.isNull l._f.p


      it 'erase:end', ->
        l = new List()
        l.add 1,2,3
        l.end()
        assert.equal l.index, 2
        n = l.erase 2
        assert.equal n.v, 3
        assert.isNull n.p
        assert.isNull n.n
        assert.equal l.get(), 2
        assert.lengthOf l, 2
        assert.equal l.index, 1
        assert.equal l.begin().get(), 1
        assert.equal l.getBack(), 2
        n = l.erase 1
        n = l.erase 0
        assert.lengthOf l, 0
        assert.notEqual n, l._f
        assert.equal l.index, -1
        assert.equal l._f, l._b
        assert.equal l._f, l._p
        assert.isNull l._f.v
        assert.isNull l._f.n
        assert.isNull l._f.p

        l.destructor()
        l = List.fromArray [0,1,2,3,4]
        assert.equal l.get(), 0
        n = l.erase(3)
        assert.equal n.v, 3
        assert.isNull n.p
        assert.isNull n.n
        assert.lengthOf l, 4
        assert.equal l.end().get(), 4
        assert.equal l.prev().get(), 2
        assert.equal l.prev().get(), 1
        assert.equal l.next().get(), 2
        assert.equal l.next().get(), 4
        l.destructor()

      it 'erase: dual', ->
        l = List.fromArray [0,1,2,3,4]
        res = l.erase(0, 1)
        assert.equal res[0].v, 0
        assert.equal res[1].v, 1
        assert.lengthOf l, 3
        assert.equal l.get(), 2
        assert.equal l.next().get(), 3
        assert.equal l.next().get(), 4
        assert.equal l.end().get(), 4
        assert.equal l.prev().get(), 3
        assert.equal l.prev().get(), 2
        assert.equal l.begin().get(), 2

        l.clear().add 0,1,2,3,4
        .next().next()
        assert.equal l.get(), 2
        assert.equal l.index, 2
        res = l.erase(0, 1)
        assert.equal res[0].v, 0
        assert.equal res[1].v, 1
        assert.equal l.index, 0
        assert.lengthOf l, 3
        assert.equal l.get(), 2
        assert.equal l.next().get(), 3
        assert.equal l.next().get(), 4
        assert.equal l.end().get(), 4
        assert.equal l.prev().get(), 3
        assert.equal l.prev().get(), 2
        assert.equal l.begin().get(), 2

      it 'clear', ->
        l = new List()
        l.add 1, 2, 3
        assert.lengthOf l, 3
        assert.equal l.clear(), l
        assert.lengthOf l, 0
        assert.equal l.index, -1
        assert.isNull l.clear(), 'return null if try clear empty list'
        assert.equal l.index, -1
        assert.lengthOf l, 0
        l.pushBack 1
        assert.lengthOf l, 1
        assert.equal l.index, 0
        l.add 2, 3
        assert.lengthOf l, 3
        assert.equal l.begin().get(), 1
        assert.equal l.next().get(), 2
        assert.equal l.next().get(), 3
        assert.equal l.index, 2
        l.clear()
        assert.lengthOf l, 0
        assert.equal l.index, -1

      it 'fromArray', ->
        arr = [true, 'nya', 3, {}]
        l = List.fromArray arr
        assert.instanceOf l, List
        assert.lengthOf l, 4
        assert.equal l.index, 0
        assert.strictEqual v = l.get(), arr[0]
        assert.strictEqual v, true
        assert.strictEqual l.next().get(), arr[1]
        assert.strictEqual v = l.next().get(), arr[2]
        assert.strictEqual v, 3
        assert.strictEqual l.next().get(), arr[3]
        assert.strictEqual l.currentNode(), l.end().currentNode()
        assert.strictEqual l.prev().get(), arr[2]
        assert.strictEqual l.prev().get(), arr[1]
        assert.strictEqual l.prev().get(), arr[0]
        assert.strictEqual l.currentNode(), l.begin().currentNode()
        l = List.fromArray []
        assert.instanceOf l, List
        assert.lengthOf l, 0

    it 'destroy', ->
      l = new List()
      l.pushBack 1
      assert.lengthOf l, 1
      assert.equal l._f, l._b
      assert.equal l._f.v, 1
      f = l._f
      assert.isNull l.destructor()
      assert.isNull l._f
      assert.isNull l._b
      assert.isNull f.n
      assert.isNull f.p
      assert.isNull f.v
      assert.lengthOf l, 0

      l = new List()
      l.pushBack 1
      l.pushBack 2
      assert.lengthOf l, 2
      assert.notEqual l._f, l._b
      assert.equal l._f.v, 1
      assert.equal l._b.v, 2
      f = l._f
      b = l._b
      assert.isNull l.destructor()
      assert.isNull l._f
      assert.isNull l._b
      assert.lengthOf l, 0
      assert.isNull f.n
      assert.isNull f.p
      assert.isNull f.v
      assert.isNull b.n
      assert.isNull b.p
      assert.isNull b.v
