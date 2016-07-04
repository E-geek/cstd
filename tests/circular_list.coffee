{assert} = require 'chai'
{CircularList} = require '../lib/circular_list.coffee'
{CSObject} = require '../lib/object.coffee'
{Node} = require '../lib/node.coffee'

describe 'CircularList', ->
  describe 'structure', ->
    it 'class', ->
      assert.ok CircularList
      assert.isFunction CircularList
      assert.isFunction CircularList.fromArray
      assert.lengthOf CircularList.fromArray, 1

    it 'proto', ->
      assert.isFunction CircularList::destructor
      assert.lengthOf CircularList::destructor, 0
      assert.isNumber CircularList::length
      assert.equal CircularList::length, 0

      assert.isFunction CircularList::append
      assert.lengthOf CircularList::append, 1
      assert.isFunction CircularList::prepend
      assert.lengthOf CircularList::prepend, 1
      assert.isFunction CircularList::add
      assert.lengthOf CircularList::add, 0, 'dynamic arguments circular list'

      assert.isFunction CircularList::go, 'move pointer to `n` steps'
      assert.lengthOf CircularList::go, 1
      assert.isFunction CircularList::next, 'move pointer to next step'
      assert.lengthOf CircularList::next, 0
      assert.isFunction CircularList::prev, 'move pointer to prev step'
      assert.lengthOf CircularList::prev, 0

      assert.isFunction CircularList::currentNode, 'return current node'
      assert.lengthOf CircularList::currentNode, 0
      assert.isFunction CircularList::get, 'return current value'
      assert.lengthOf CircularList::get, 0
      assert.isFunction CircularList::set, 'set value for current pointer.
          circularList.set("some") is circularList.currentNode().v = "some" '
      assert.lengthOf CircularList::set, 1

      assert.isFunction CircularList::erase
      assert.lengthOf CircularList::erase, 1, '[returnNode = yes]'
      assert.isFunction CircularList::clear
      assert.lengthOf CircularList::clear, 0

      # protected elements
      assert.ok CircularList::_p
      assert.instanceOf CircularList::_p, Node

  describe 'behavior', ->
    describe 'errors', ->
      it 'new', ->
        fn = ->
          new CircularList 12
        assert.throws fn, TypeError, 'CircularList constructor haven\'t arguments'

      it 'append/prepend', ->
        fn = ->
          cl = new CircularList
          cl.append 1, 2
        assert.throws fn, TypeError, 'more than one append'
        fn2 = ->
          cl = new CircularList
          cl.prepend 1, 2
        assert.throws fn2, TypeError, 'more than one prepend'
        fn = ->
          cl = new CircularList
          cl.append()
        assert.throws fn, TypeError, 'append nothing'
        fn2 = ->
          cl = new CircularList
          cl.prepend()
        assert.throws fn2, TypeError, 'prepend nothing'

      it 'add', ->
        fn7 = ->
          cl = new CircularList()
          cl.add()
        assert.throws fn7, TypeError, 'add without value'

      it 'go', ->
        fn = ->
          cl = new CircularList
          cl.go()
        assert.throws fn, Error, '`step` is required'
        fn = ->
          cl = new CircularList
          cl.go('+1')
        assert.throws fn, TypeError, '`step` must be a Number'
        fn = ->
          cl = new CircularList
          cl.go(1, 2)
        assert.throws fn, Error, 'too many arguments'

      it 'next/prev', ->
        fn = ->
          cl = new CircularList
          cl.next null
        assert.throws fn, Error, 'next haven\'t arguments'
        fn = ->
          cl = new CircularList
          cl.prev '-2'
        assert.throws fn, Error, 'prev haven\'t arguments'

      it 'currentNode/get', ->
        fn = ->
          cl = new CircularList
          cl.currentNode null
        assert.throws fn, Error, 'currentNode haven\'t arguments'
        fn = ->
          cl = new CircularList
          cl.currentNode()
        assert.throws fn, Error, 'circular list is empty'
        fn = ->
          cl = new CircularList
          cl.get '-2'
        assert.throws fn, Error, 'get haven\'t arguments'
        fn = ->
          cl = new CircularList
          cl.get()
        assert.throws fn, Error, 'circular list is empty'

      it 'set', ->
        fn = ->
          cl = new CircularList
          cl.set()
        assert.throws fn, Error, 'can\'t set nothing to value'
        fn = ->
          cl = new CircularList
          cl.set(1)
        assert.throws fn, Error, 'can\'t set to empty circular list'
        fn = ->
          cl = new CircularList
          cl.append 0
          .set(1, 2)
        assert.throws fn, Error, 'too many arguments'

      it 'erase', ->
        fn = ->
          cl = new CircularList()
          cl.erase()
        assert.throws fn, RangeError, 'circular list is empty'
        fn = ->
          cl = new CircularList()
          cl.erase 0
        assert.throws fn, RangeError, 'circular list is empty'
        fn = ->
          cl = new CircularList
          cl.erase(4, no)
        assert.throws fn, Error, 'too many arguments'
        fn = ->
          cl = new CircularList()
          cl.add 0
          cl.erase 0
        assert.throws fn, TypeError, '`returnNodes` must be a boolean'
        fn = ->
          cl = new CircularList()
          cl.add 0
          cl.erase {}
        assert.throws fn, TypeError, '`returnNodes` must be a boolean'

      it 'clear', ->
        fn5 = ->
          cl = new CircularList()
          cl.clear 1
        assert.throws fn5, TypeError, 'clear haven\'t arguments'

      it ':fromArray', ->
        fn8 = ->
          CircularList.fromArray()
        assert.throws fn8, Error, 'no arguments'
        fn9 = ->
          CircularList.fromArray 'ast'
        assert.throws fn9, TypeError, 'argument is not array'
        fn10 = ->
          CircularList.fromArray {}
        assert.throws fn10, TypeError, 'argument is not array'
        fn11 = ->
          CircularList.fromArray [], []
        assert.throws fn11, Error, 'too much arguments'

    describe 'correct', ->
      it 'new', ->
        cl = new CircularList()
        assert.instanceOf cl, CircularList
        assert.instanceOf cl, CSObject
        assert.instanceOf cl._p, Node
        assert.isNotNaN cl._p.v
        assert.equal cl._p.n, cl._p
        assert.equal cl._p.p, cl._p
        assert.lengthOf cl, 0

      it 'add', ->
        cl = new CircularList()
        cl.append 1
        assert.equal cl, cl.add 2, 3, obj = {}
        assert.lengthOf cl, 4
        assert.equal cl.get(), 1
        assert.equal cl.next().get(), 2
        assert.equal cl.next().get(), 3
        assert.equal cl.next().get(), obj
        assert.equal cl.next().get(), 1
        assert.equal cl.prev().get(), obj
        assert.equal cl.prev().get(), 3
        assert.equal cl.prev().get(), 2
        assert.equal cl.prev().get(), 1
        cl = new CircularList()
        assert.equal cl, cl.append 1
        assert.lengthOf cl, 1
        assert.strictEqual cl.get(), 1
        cl.add 2
        cl.prepend 3
        assert.equal cl.next().get(), 2
        assert.equal cl.next().get(), 3
        assert.equal cl.next().get(), 1


      it 'get', ->
        cl = new CircularList()
        assert.equal cl, cl.add 1, 2, 3, 4
        assert.equal cl.get(), 1
        assert.lengthOf cl, 4
        assert.equal cl, cl.prepend 0
        assert.lengthOf cl, 5
        assert.equal cl.get(), 1
        assert.equal cl.prev().get(), 0
        assert.equal cl, cl.erase no
        assert.equal cl.get(), 1, 'erase current element => go next'

      it 'next', ->
        cl = new CircularList()
        assert.isNull cl.next()
        assert.equal cl, cl.add 1,2,3,4
        assert.equal cl, cl.next()
        assert.equal cl.get(), 2
        assert.equal cl, cl.next()
        assert.equal cl.get(), 3
        assert.equal cl.next().get(), 4
        assert.equal cl.next().get(), 1

      it 'prev', ->
        cl = new CircularList()
        assert.isNull cl.prev()
        cl.prepend 4
        cl.prepend 3
        cl.prepend 2
        cl.prepend 1
        assert.equal cl.get(), 4
        assert.equal cl, cl.prev()
        assert.equal cl.get(), 1
        assert.equal cl, cl.prev()
        assert.equal cl.get(), 2
        assert.equal cl.prev().get(), 3
        assert.equal cl.prev().get(), 4, 'cycled'

        assert.equal cl.next().get(), 3
        assert.equal cl.next().get(), 2
        assert.equal cl.next().get(), 1
        assert.equal cl.next().get(), 4

      it 'append', ->
        cl = new CircularList()
        assert.equal cl, cl.append(1)
        assert.lengthOf cl, 1
        assert.equal cl.get(), 1
        assert.equal cl, cl.append(2)
        assert.lengthOf cl, 2
        assert.equal cl.get(), 1
        assert.equal cl, cl.append(3)
        assert.lengthOf cl, 3
        assert.equal cl.get(), 1
        assert.equal cl.next().get(), 3
        assert.equal cl.next().get(), 2
        assert.equal cl.next().get(), 1
        assert.equal cl.prev().get(), 2
        assert.equal cl.prev().get(), 3
        assert.equal cl.prev().get(), 1

      it 'prepend', ->
        cl = new CircularList()
        assert.equal cl, cl.prepend(1)
        assert.lengthOf cl, 1
        assert.equal cl.get(), 1
        assert.equal cl, cl.prepend(2)
        assert.lengthOf cl, 2
        assert.equal cl.get(), 1
        assert.equal cl, cl.prepend(3)
        assert.lengthOf cl, 3
        assert.equal cl.get(), 1
        assert.equal cl.prev().get(), 3
        assert.equal cl.prev().get(), 2
        assert.equal cl.prev().get(), 1
        assert.equal cl.next().get(), 2
        assert.equal cl.next().get(), 3
        assert.equal cl.next().get(), 1

      it 'go', ->
        cl = new CircularList()
        assert.isNull cl.go(0)
        assert.isNull cl.go(1)
        assert.isNull cl.go(-1)
        cl.add 1,2,3,4
        assert.equal cl.get(), 1
        assert.equal cl, cl.go(2)
        assert.equal cl.get(), 3
        assert.equal cl, cl.go(-1)
        assert.equal cl.get(), 2
        assert.equal cl, cl.go(2)
        assert.equal cl.get(), 4
        assert.equal cl, cl.go(-3)
        assert.equal cl.get(), 1
        assert.equal cl, cl.go(4)
        assert.equal cl.get(), 1
        assert.equal cl, cl.go(0)
        assert.equal cl.get(), 1
        assert.equal cl, cl.go(-1)
        assert.equal cl.get(), 4
        assert.equal cl, cl.go(9), 'double cycle'
        assert.equal cl.get(), 1


      it 'currentNode', ->
        cl = new CircularList()
        o1 = {}
        o2 = {}
        o3 = {}
        cl.add o2
        .prepend o1
        .append o3
        assert.equal cl.get(), o2
        node = cl.currentNode()
        assert.instanceOf node, Node
        assert.equal node.v, o2
        assert.equal node.p.v, o1
        assert.equal node.n.v, o3

      it 'set', ->
        cl = new CircularList()
        cl.add 1,2,3,4
        assert.equal cl, cl.set 'saitama'
        assert.equal cl.get(), 'saitama'
        assert.equal cl.next().get(), 2
        assert.equal cl, cl.set 'naomi'
        assert.equal cl.get(), 'naomi'
        cl.prev()
        assert.equal cl.get(), 'saitama'
        assert.equal cl.next().get(), 'naomi'
        assert.equal cl.next().get(), 3
        assert.equal cl.next().get(), 4

      it 'erase', ->
        cl = new CircularList()
        cl.add 1,2,3,4
        tn = cl.next().currentNode()
        n = cl.erase()
        assert.equal n, tn
        assert.isNull n.n
        assert.isNull n.p
        assert.equal n.v, 2
        assert.lengthOf cl, 3
        assert.equal cl.get(), 3
        assert.equal cl.next().get(), 4
        assert.equal cl.next().get(), 1
        assert.equal cl.next().get(), 3
        assert.equal cl.prev().get(), 1
        assert.equal cl.prev().get(), 4
        assert.equal cl.prev().get(), 3
        assert.equal cl.prev().get(), 1
        # remove under-self
        cl.append(2).next()
        assert.equal cl.get(), 2
        assert.equal cl, cl.erase no
        assert.lengthOf cl, 3
        assert.equal cl.get(), 3
        assert.equal cl.next().get(), 4
        assert.equal cl.next().get(), 1
        assert.equal cl.next().get(), 3
        assert.equal cl.prev().get(), 1
        assert.equal cl.prev().get(), 4
        assert.equal cl.prev().get(), 3
        assert.equal cl.prev().get(), 1

        assert.equal cl, cl.clear().add 1
        assert.lengthOf cl, 1
        assert.equal cl, cl.erase(no)
        assert.lengthOf cl, 0

        cl.append(1)
        #np = cl._p
        n = cl.erase yes
        assert.instanceOf n, Node
        assert.equal n.v, 1
        #assert.equal n, np
        assert.lengthOf cl, 0

      it 'clear', ->
        cl = new CircularList()
        assert.equal cl, cl.add 1, 2, 3
        assert.lengthOf cl, 3
        assert.equal cl.clear(), cl
        assert.lengthOf cl, 0
        assert.isNull cl.clear(), 'return null if try clear empty circular list'
        assert.lengthOf cl, 0
        assert.equal cl, cl.prepend 1
        assert.lengthOf cl, 1
        assert.equal cl, cl.add 2, 3
        assert.lengthOf cl, 3
        assert.equal cl.get(), 1
        assert.equal cl.next().get(), 2
        assert.equal cl.next().get(), 3
        assert.equal cl.next().get(), 1
        assert.equal cl.next().get(), 2
        assert.equal cl.clear(), cl
        assert.lengthOf cl, 0
        
      it 'fromArray', ->
        arr = [true, 'nya', 3, {}]
        cl = CircularList.fromArray arr
        assert.instanceOf cl, CircularList
        assert.lengthOf cl, 4
        assert.strictEqual v = cl.get(), arr[0]
        assert.strictEqual v, true
        assert.strictEqual cl.next().get(), arr[1]
        assert.strictEqual v = cl.next().get(), arr[2]
        assert.strictEqual v, 3
        assert.strictEqual cl.next().get(), arr[3]
        assert.strictEqual cl.next().get(), arr[0]
        assert.strictEqual cl.prev().get(), arr[3]
        assert.strictEqual cl.prev().get(), arr[2]
        assert.strictEqual cl.prev().get(), arr[1]
        assert.strictEqual cl.prev().get(), arr[0]
        assert.strictEqual cl.prev().get(), arr[3]

        cl = CircularList.fromArray []
        assert.instanceOf cl, CircularList
        assert.lengthOf cl, 0

    it 'destroy', ->
      cl = new CircularList()
      cl.append 1
      assert.lengthOf cl, 1
      assert.equal cl._p.v, 1
      f = cl.currentNode()
      assert.equal f.v, 1
      assert.instanceOf f, Node
      assert.isNull cl.destructor()
      assert.lengthOf cl, -1
      assert.isNull cl._p
      assert.isNull f.n
      assert.isNull f.p
      assert.isNull f.v
      assert.lengthOf cl, -1

      cl = new CircularList()
      cl.append 1
      cl.append 2
      assert.lengthOf cl, 2
      assert.equal cl._p.v, 1
      assert.equal cl._p.n.v, 2
      f = cl.currentNode()
      b = cl.next().currentNode()
      assert.isNull cl.destructor()
      assert.isNull cl._p
      assert.lengthOf cl, -1
      assert.isNull f.n
      assert.isNull f.p
      assert.isNull f.v
      assert.isNull b.n
      assert.isNull b.p
      assert.isNull b.v
