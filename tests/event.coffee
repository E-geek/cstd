{assert} = require 'chai'
{CSObject} = require '../lib/object.coffee'
{CSEmitter, CSEvent} = require '../lib/emitter.coffee'

describe 'CSEvent', ->
  describe 'structure', ->
    it 'class', ->
      assert.ok CSEvent
    it 'proto', ->
      assert.ok CSEvent
      assert.isFunction CSEvent::constructor
      assert.lengthOf CSEvent::constructor, 3
      assert.isFunction CSEvent::destructor
      assert.lengthOf CSEvent::destructor, 0
      assert.typeOf CSEvent::name, 'string'
      assert.typeOf CSEvent::ts, 'number'
      assert.isNull CSEvent::value
      assert.isNull CSEvent::target
  describe 'behavior', ->
    it 'errors', ->
      fn = ->
        new CSEvent()
      assert.throws fn, TypeError, 'No arguments'
      fn = ->
        new CSEvent 12
      assert.throws fn, TypeError, '`name` must be a string'
      fn = ->
        new CSEvent {}
      assert.throws fn, TypeError, '`name` must be a string'
      fn = ->
        new CSEvent 'correct'
      assert.throws fn, TypeError, '`target` is required argument'
      fn = ->
        new CSEvent 'correct', {}
      assert.throws fn, TypeError, '`target` must be a instance of CSEmitter'
    it 'correct', ->
      class TestEmitter extends CSEmitter

      target = new TestEmitter(['fire'])
      someData =
        any: 'object'
      e1 = new CSEvent 'fire', target
      e2 = new CSEvent 'fire', target, someData
      time = Date.now()

      assert.instanceOf e1, CSEvent
      assert.instanceOf e1, CSObject
      assert.instanceOf e2, CSEvent

      assert.equal e1.target, target
      assert.equal e2.target, target

      assert.isNull e1.value
      assert.equal e2.value, someData

      assert.isBelow time - e1.ts, 100
      assert.isBelow time - e2.ts, 100

    it 'destroy', ->
      class TestEmitter extends CSEmitter

      target = new TestEmitter(['fire'])
      someData =
        any: 'object'
      e1 = new CSEvent 'fire', target
      e2 = new CSEvent 'fire', target, someData

      e1.destructor()
      e2.destructor()

      assert.isNull e1.value
      assert.isNull e1.target
      assert.isNull e2.value
      assert.isNull e2.target


