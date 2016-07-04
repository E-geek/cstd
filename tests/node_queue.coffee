{assert} = require 'chai'
{NodeQueue} = require '../lib/cache/node_queue.coffee'
{CSObject} = require '../lib/object.coffee'
{Node} = require '../lib/node.coffee'

describe 'NodeQueue', ->
  describe 'structure', ->
    it 'class', ->
      assert.ok NodeQueue
      assert.isFunction NodeQueue

    it 'proto', ->
      assert.instanceOf NodeQueue::back, Node
      assert.isFunction NodeQueue::rise
      assert.lengthOf NodeQueue::rise, 1
      assert.isFunction NodeQueue::drop
      assert.lengthOf NodeQueue::drop, 1
      assert.isFunction NodeQueue::remove
      assert.lengthOf NodeQueue::remove, 1
      assert.isFunction NodeQueue::destructor
      assert.lengthOf NodeQueue::destructor, 0
      assert.isNumber NodeQueue::length
      assert.isFunction NodeQueue::push
      assert.lengthOf NodeQueue::push, 1
      assert.isFunction NodeQueue::pop
      assert.lengthOf NodeQueue::pop, 0
      assert.isFunction NodeQueue::clear
      assert.lengthOf NodeQueue::clear, 0
      # protected elements
      assert.ok NodeQueue::front
      assert.instanceOf NodeQueue::front, Node

  describe 'behavior', ->
    describe 'correct', ->
      it 'push', ->
        q = new NodeQueue()
        assert.instanceOf q, NodeQueue
        assert.instanceOf q, CSObject
        assert.lengthOf q, 0
        q.push 1
        assert.lengthOf q, 1

      it 'pop', ->
        q = new NodeQueue()
        obj = {}
        q.push obj
        assert.equal q.pop(), obj
        assert.lengthOf q, 0

      it 'rise', ->
        q = new NodeQueue()
        q.push 1
        q.push 2
        assert.equal q, q.rise q.back
        assert.equal q.back.v, 1
        assert.equal q.back.p.v, 2
        assert.equal q.back.p.n, q.back
        assert.isNull q.back.n
        assert.isNull q.back.p.p
        assert.lengthOf q, 2

        assert.equal q, q.rise q.back
        assert.equal q.back.v, 2
        assert.equal q.back.p.v, 1
        q.push 3
        q.push 4
        q.rise q.back.p
        q.rise q.back.p.p
        q.rise q.back
        assert.equal q.back.v, 2
        assert.equal q.back.p.v, 3
        assert.equal q.back.p.p.v, 1
        assert.equal q.back.p.p.p.v, 4
        q.rise q.back.p.p.p # first => nothing
        assert.equal q.back.v, 2
        assert.equal q.back.p.v, 3
        assert.equal q.back.p.p.v, 1
        assert.equal q.back.p.p.p.v, 4
        q.destructor()

        q = new NodeQueue()
        q.push 1
        front = q.front
        assert.equal q, q.rise q.front
        assert.lengthOf q, 1
        assert.equal front, q.front
        assert.equal front, q.back
        q.destructor()

      it 'drop', ->
        q = new NodeQueue()
        q.push 1
        q.push 2
        assert.equal q, q.drop q.front
        assert.equal q.front.v, 2
        assert.equal q.front.n.v, 1
        assert.equal q.front.n.p, q.front
        assert.isNull q.front.p
        assert.isNull q.front.n.n
        assert.lengthOf q, 2

        assert.equal q, q.drop q.front
        assert.equal q.front.v, 1
        assert.equal q.front.n.v, 2
        q.push 3
        q.push 4
        q.drop q.front.n
        q.drop q.front.n.n
        q.drop q.front
        assert.equal q.front.v, 3
        assert.equal q.front.n.v, 2
        assert.equal q.front.n.n.v, 4
        assert.equal q.front.n.n.n.v, 1
        q.drop q.front.n.n.n # first => nothing
        assert.equal q.front.v, 3
        assert.equal q.front.n.v, 2
        assert.equal q.front.n.n.v, 4
        assert.equal q.front.n.n.n.v, 1

      it 'remove', ->
        q = new NodeQueue()
        q.push 1
        q.push 2
        q.push 3
        n0 = q.front
        n1 = q.front.n
        n2 = q.front.n.n
        assert.equal n0.v, 1
        assert.equal n1.v, 2
        assert.equal n2.v, 3
        assert.equal q, q.remove n1
        assert.isNull n1.p
        assert.isNull n1.n
        assert.lengthOf q, 2
        assert.equal n0.n, n2
        assert.equal n0, n2.p
        q.push 4
        assert.lengthOf q, 3
        n4 = q.back
        assert.equal n2.n, n4
        assert.equal q, q.remove n4
        assert.lengthOf q, 2
        assert.isNull n2.n
        assert.isNull n4.p
        assert.isNull n4.n
        assert.equal q, q.remove n0
        assert.equal q.front, q.back
        assert.equal q.front, n2
        assert.lengthOf q, 1
        assert.isNull n2.p
        assert.isNull n0.p
        assert.isNull n0.n
        assert.equal q, q.remove n2
        assert.equal q.front, q.back
        assert.notEqual q.front, n2
        assert.isNull n2.p
        assert.isNull n2.n
        q.destructor()

      it 'clear', ->
        q = new NodeQueue()
        q.push 1
        q.push 2
        q.push 3
        assert.lengthOf q, 3
        assert.equal q.clear(), q
        assert.lengthOf q, 0
        assert.isNull q.clear(), 'return null if try clear empty list'
        assert.lengthOf q, 0
        q.push 1
        assert.lengthOf q, 1
        q.push 2
        q.push 3
        assert.lengthOf q, 3
        assert.equal q.pop(), 1
        assert.equal q.pop(), 2
        assert.equal q.pop(), 3
        assert.lengthOf q, 0

    it 'destroy', ->
      q = new NodeQueue()
      q.push 1
      assert.lengthOf q, 1
      assert.equal q.front, q.back
      assert.equal q.front.v, 1
      f = q.front
      assert.isNull q.destructor()
      assert.isNull q.front
      assert.isNull q.back
      assert.isNull f.n
      assert.isNull f.p
      assert.isNull f.v
      assert.lengthOf q, -1

      q = new NodeQueue()
      q.push 1
      q.push 2
      assert.lengthOf q, 2
      assert.notEqual q.front, q.back
      assert.equal q.front.v, 1
      assert.equal q.back.v, 2
      f = q.front
      b = q.back
      assert.isNull q.destructor()
      assert.isNull q.front
      assert.isNull q.back
      assert.lengthOf q, -1
      assert.isNull f.n
      assert.isNull f.p
      assert.isNull f.v
      assert.isNull b.n
      assert.isNull b.p
      assert.isNull b.v

      q = new NodeQueue()
      assert.isNull q.destructor()
      assert.isNull q.front
      assert.isNull q.back
      assert.lengthOf q, -1

