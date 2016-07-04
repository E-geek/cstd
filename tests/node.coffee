{assert} = require 'chai'
{Node} = require '../lib/node.coffee'
{CSObject} = require '../lib/object.coffee'

describe 'Node', ->
  it 'structure', ->
    assert.ok Node
    assert.isFunction Node, 'constructor'
    assert.isFunction Node::destructor, 'destructor defined'
    assert.lengthOf Node::destructor, 0
    assert.isFunction Node::remove, 'remove node defined'
    assert.lengthOf Node::remove, 0
    assert.isNull Node::n, 'next node is null'
    assert.isNull Node::p, 'prev node is null'
    assert.isNull Node::v, 'value is null'

  describe 'behavior', ->
    it 'inheritance', ->
      assert.instanceOf new Node(null), CSObject, 'node is instance of CSObject'

    describe 'error', ->
      it 'If not set value', ->
        fn = -> new Node()
        assert.throws fn, TypeError, "Incorrect situation: value of node not set"
      it 'If next or prev not null and not nodes', ->
        fn = -> new Node null, 1
        fn2 = -> new Node null, new Node(null), 2
        fn3 = -> new Node null, null, 3
        assert.throws fn, TypeError, "next node can be Node or NULL"
        assert.throws fn2, TypeError, "prev node can be Node or NULL"
        assert.throws fn3, TypeError, "prev node can be Node or NULL"

    describe 'correct', ->
      it 'empty create/remove/destructor', ->
        o = {}
        node = new Node o
        assert.instanceOf node, Node, 'object correct Node'
        assert.instanceOf node, CSObject, 'object correct CSObject'
        assert.isNull node.n, 'next not set'
        assert.isNull node.p, 'prev not set'
        assert.strictEqual node.v, o, 'value correct'

        assert.strictEqual node.remove(), node, 'remove return this'
        assert.isNull node.n, 'next not change'
        assert.isNull node.p, 'prev not change'
        assert.strictEqual node.v, o, 'value correct'

        assert.isNull node.destructor(), 'destructor return NULL'
        assert.isNull node.n, 'next not change'
        assert.isNull node.p, 'prev not change'
        assert.isNull node.v, 'value removed'
        return

      it 'list-emulate create/remove/destructor', ->
        prev = new Node 0
        next = new Node 2
        node = new Node 1, next, prev
        assert.equal node.p, prev, 'prev set'
        assert.equal node.n, next, 'next set'
        assert.equal node.v, 1, 'value correct'
        assert.equal node.p.v, 0, 'value prev correct'
        assert.equal node.n.v, 2, 'value next correct'
        assert.isNull prev.n, 'next not set'
        assert.isNull prev.p, 'prev not set'
        assert.isNull next.n, 'next not set'
        assert.isNull next.p, 'prev not set'
        next.p = node
        prev.n = node
        assert.equal node.remove(), node, 'call remove'
        assert.equal node.v, 1, 'value not change'
        assert.equal next.p, prev, 'next node look at prev'
        assert.equal prev.n, next, 'prev node look at next'
        assert.isNull node.p
        assert.isNull node.n
        assert.equal next.remove(), next, 'remove next'
        assert.equal next.v, 2
        assert.isNull next.n
        assert.isNull next.p
        assert.isNull prev.n
        assert.isNull prev.p
        assert.equal prev.remove(), prev, 'no exception'
        assert.equal prev.v, 0
        assert.isNull node.destructor()
        assert.isNull prev.destructor()
        assert.isNull next.destructor()
        assert.isNull node.v
        assert.isNull prev.v
        assert.isNull next.v
        return # it


