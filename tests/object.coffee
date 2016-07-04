# test for CSObject correct
{assert} = require 'chai'
{CSObject} = require '../lib/object.coffee'

describe 'CSObject', ->
  it 'structure', ->
    assert.ok CSObject, 'exists'
    assert.isFunction CSObject, 'is constructor => function'
    assert.isFunction CSObject::destructor, 'destructor proto exists'
    assert.isTrue CSObject.isAbstract

  describe 'behavior create', ->
    it 'new from abstract', ->
      fn = ->
        obj = new CSObject()
        obj.destructor()
      assert.throws fn, TypeError, "'CSObject' is abstract"

    it 'incorrect extends without call super', ->
      fn = ->
        class Simple extends CSObject
        simple = new Simple()
        simple.destructor()
      assert.throws fn, Error, "You must define 'destructor' by class"

    it 'incorrect extends with call super', ->
      class SimpleConstructed extends CSObject
        constructor: ->
          super()
      fn = ->
        simple = new SimpleConstructed()
        simple.destructor()
      assert.throws fn, Error, "You must define 'destructor' by class"

    it 'correct extends without call super', ->
      class SimpleCorrect extends CSObject
        constructor: ->
        destructor: ->
      simple = new SimpleCorrect()
      fn = ->
        simple.destructor()
      assert.instanceOf simple, SimpleCorrect, 'simple instanceof SimpleCorrect'
      assert.instanceOf simple, CSObject, 'simple instanceof CSObject'
      assert.doesNotThrow fn, "correct destructor call"

    it 'correct extends with call super', ->
      class SimpleCorrect extends CSObject
        constructor: ->
          super()
        destructor: ->
          super()

      simple = new SimpleCorrect()
      fn = ->
        simple.destructor()
      assert.instanceOf simple, SimpleCorrect, 'simple instanceof SimpleCorrect'
      assert.instanceOf simple, CSObject, 'simple instanceof CSObject'
      assert.doesNotThrow fn, "correct destructor call"

    it 'destructor not defined', ->
      class SimpleIncorrect extends CSObject
        constructor: ->
      fn = ->
        inc = new SimpleIncorrect()
        inc.destructor()
      assert.throws fn, Error, 'Extended class destructor is not defined'



