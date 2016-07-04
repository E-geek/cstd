{assert} = require 'chai'

describe 'cstd.js', ->
  { CSObject, CSError, CSDate, Stack, Deque, Queue, Node,
  CSEmitter, CSEvent, List, CircularList, BaseCache, LRUCache } = {}
  before ->
    { CSObject, CSError, CSDate, Stack, Deque, Queue, Node,
    CSEmitter, CSEvent, List, CircularList,
    BaseCache, LRUCache } = require '../cstd.js'
  it 'all', ->
    assert.ok CSObject
    assert.ok CSError
    assert.ok CSDate
    assert.ok Stack
    assert.ok Deque
    assert.ok Queue
    assert.ok Node
    assert.ok CSEmitter
    assert.ok CSEvent
    assert.ok BaseCache
    assert.ok LRUCache
  it 'CSObject', ->
    e = require '../lib/object.coffee'
    assert.equal e.CSObject, CSObject
  it 'CSError', ->
    e = require '../lib/error.coffee'
    assert.equal e.CSError, CSError
  it 'CSDate', ->
    e = require '../lib/date.coffee'
    assert.equal e.CSDate, CSDate
  it 'Stack', ->
    e = require '../lib/stack.coffee'
    assert.equal e.Stack, Stack
  it 'Deque', ->
    e = require '../lib/deque.coffee'
    assert.equal e.Deque, Deque
  it 'Queue', ->
    e = require '../lib/queue.coffee'
    assert.equal e.Queue, Queue
  it 'Node', ->
    e = require '../lib/node.coffee'
    assert.equal e.Node, Node
  it 'CSEmitter, CSEvent', ->
    e = require '../lib/emitter.coffee'
    assert.equal e.CSEvent, CSEvent
    assert.equal e.CSEmitter, CSEmitter
  it 'List', ->
    e = require '../lib/list.coffee'
    assert.equal e.List, List
  it 'CircularList', ->
    e = require '../lib/circular_list.coffee'
    assert.equal e.CircularList, CircularList
  it 'BaseCache', ->
    e = require '../lib/cache/base.coffee'
    assert.equal e.BaseCache, BaseCache
  it 'LRUCache', ->
    e = require '../lib/cache/lru.coffee'
    assert.equal e.LRUCache, LRUCache

describe 'cstd.coffee', ->
  { CSObject, CSError, CSDate, Stack, Deque, Queue, Node,
  CSEmitter, CSEvent, List, CircularList, BaseCache, LRUCache } = {}
  before ->
    { CSObject, CSError, CSDate, Stack, Deque, Queue, Node,
    CSEmitter, CSEvent, List, CircularList,
    BaseCache, LRUCache } = require '../cstd.coffee'
  it 'all', ->
    assert.ok CSObject
    assert.ok CSError
    assert.ok CSDate
    assert.ok Stack
    assert.ok Deque
    assert.ok Queue
    assert.ok Node
    assert.ok CSEmitter
    assert.ok CSEvent
    assert.ok BaseCache
    assert.ok LRUCache
  it 'CSObject', ->
    e = require '../lib/object.coffee'
    assert.equal e.CSObject, CSObject
  it 'CSError', ->
    e = require '../lib/error.coffee'
    assert.equal e.CSError, CSError
  it 'CSDate', ->
    e = require '../lib/date.coffee'
    assert.equal e.CSDate, CSDate
  it 'Stack', ->
    e = require '../lib/stack.coffee'
    assert.equal e.Stack, Stack
  it 'Deque', ->
    e = require '../lib/deque.coffee'
    assert.equal e.Deque, Deque
  it 'Queue', ->
    e = require '../lib/queue.coffee'
    assert.equal e.Queue, Queue
  it 'Node', ->
    e = require '../lib/node.coffee'
    assert.equal e.Node, Node
  it 'CSEmitter, CSEvent', ->
    e = require '../lib/emitter.coffee'
    assert.equal e.CSEvent, CSEvent
    assert.equal e.CSEmitter, CSEmitter
  it 'List', ->
    e = require '../lib/list.coffee'
    assert.equal e.List, List
  it 'CircularList', ->
    e = require '../lib/circular_list.coffee'
    assert.equal e.CircularList, CircularList
  it 'BaseCache', ->
    e = require '../lib/cache/base.coffee'
    assert.equal e.BaseCache, BaseCache
  it 'LRUCache', ->
    e = require '../lib/cache/lru.coffee'
    assert.equal e.LRUCache, LRUCache