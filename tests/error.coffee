# test for CSObject correct
{assert} = require 'chai'
{CSError} = require '../lib/error.coffee'

describe 'CSError', ->
  it 'structure', ->
    assert.ok CSError
    assert.isFunction CSError
    assert.isArray CSError::stack
    assert.isString CSError::message
    assert.isString CSError::name
    assert.strictEqual CSError::name, 'CSError'
    
  describe 'behavior', ->
    describe 'normal', ->
      it 'error', ->
        errMessage = 'Message must be string, or number, or can be unset'
        fn = -> new CSError(null)
        assert.throws fn, TypeError, errMessage
        fn = -> new CSError({})
        assert.throws fn, TypeError, errMessage
        fn = -> new CSError([])
        assert.throws fn, TypeError, errMessage
        fn = -> new CSError(1234)
        assert.doesNotThrow fn, TypeError, errMessage

      it 'correct', ->
        err = new CSError()
        assert.instanceOf err, CSError
        assert.instanceOf err, Error
        assert.equal err.message, ''
        assert.isArray err.stack
        assert.isAbove err.stack.length, 1
        err = new CSError message = 'normal message'
        assert.equal err.message, message
        err = new CSError 1234
        assert.equal err.message, '1234'

      it 'correct extends', ->
        errBase = new CSError()
        class CustomError extends CSError
          constructor: -> super
        err = new CustomError()
        assert.instanceOf err, CustomError
        assert.instanceOf err, CSError
        assert.instanceOf err, Error
        assert.equal err.message, ''
        assert.isArray err.stack
        assert.lengthOf err.stack, errBase.stack.length
        err = new CustomError message = 'normal message'
        assert.equal err.message, message
        err = new CustomError 1234
        assert.equal err.message, '1234'
    describe 'stack as', ->
      error = global.Error
      after ->
        global.Error = error
        return

      it 'Array', ->
        global.Error = class Error
          stack: [1,2,3]
        err = new CSError()
        assert.lengthOf err.stack, 2
        assert.equal err.stack[0], 2
        assert.equal err.stack[1], 3

      it 'Object', ->
        global.Error = class Error
          stack:
            0: 4
            1: 5
            2: 6
            length: 3

        class CustomError2 extends CSError
          constructor: -> super

        err = new CSError()
        assert.lengthOf err.stack, 2
        assert.equal err.stack[0], 5
        assert.equal err.stack[1], 6

        err2 = new CustomError2()
        assert.lengthOf err2.stack, 1
        assert.equal err2.stack[0], 6

      it 'Undefined', ->
        global.Error = class Error
        err = new CSError()
        assert.lengthOf err.stack, 0

      it 'Other', ->
        global.Error = class Error
          stack: 12
        fn = ->
          new CSError()
        assert.throws fn, TypeError, 'Unexpected type of stack trace'

