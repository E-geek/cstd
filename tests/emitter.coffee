{assert} = require 'chai'
{CSObject} = require '../lib/object.coffee'
{CSEmitter, CSEvent} = require '../lib/emitter.coffee'

describe 'CSEmitter', ->
  describe 'With map', ->
    if typeof Map isnt 'function'
      return
    describe 'structure', ->
      it 'class', ->
        assert.ok CSEmitter
        assert.isFunction CSEmitter
        assert.isTrue CSEmitter.isAbstract
      it 'proto', ->
        assert.isFunction CSEmitter::destructor
        assert.lengthOf CSEmitter::destructor, 0
        assert.isFunction CSEmitter::on
        assert.lengthOf CSEmitter::on, 2
        assert.isFunction CSEmitter::once
        assert.lengthOf CSEmitter::once, 2
        assert.isFunction CSEmitter::off
        assert.lengthOf CSEmitter::off, 2
        assert.isFunction CSEmitter::emit
        assert.lengthOf CSEmitter::emit, 1
        assert.isTrue CSEmitter::emit.isAbstract
        # Maybe incorrect test protected/private members?
        assert.ok CSEmitter::_map
        if typeof Map is 'function'
          assert.instanceOf CSEmitter::_map, Map
        else
          assert.isObject CSEmitter::_map

    describe 'behavior', ->
      describe 'errors', ->
        it 'abstract', ->
          fn = ->
            new CSEmitter()
          assert.throws fn, TypeError, 'CSEmitter is abstract'
        it 'emit', ->
          class EmitterChildWithoutEmit extends CSEmitter
          class EmitterChild extends CSEmitter
            emit: -> super
          fn2 = ->
            ec = new EmitterChildWithoutEmit(['now'])
            ec.emit 'now'
          assert.throws fn2, Error, '`emit` is abstract method'
          fn3 = ->
            ec = new EmitterChild([])
            ec.emit 'now'
          assert.throws fn3, Error, 'emit unregistered event `name`'
          fn4 = ->
            ec = new EmitterChild(['now'])
            ec.emit 342
          assert.throws fn4, TypeError, 'unknown type of emit'
          fn5 = ->
            ec = new EmitterChild(['now'])
            ec.emit {}
          assert.throws fn5, TypeError, 'unknown type of emit'

        it 'on', ->
          class EmitterChild extends CSEmitter
            emit: -> super
          fn = ->
            ec = new EmitterChild()
            ec.on()
          assert.throws fn, Error, 'no arguments: `name`, `handler`'
          fn2 = ->
            ec = new EmitterChild()
            ec.on('name')
          assert.throws fn2, TypeError, 'no arguments: `handler`'
          fn3 = ->
            ec = new EmitterChild()
            ec.on 11
          assert.throws fn3, TypeError, 'argument `name` is not a String'
          fn4 = ->
            ec = new EmitterChild()
            ec.on 'name', {}
          assert.throws fn4, TypeError, 'argument `handler` is not a callback Function'

        it 'once', ->
          class EmitterChild extends CSEmitter
            emit: -> super
          fn = ->
            ec = new EmitterChild()
            ec.once()
          assert.throws fn, Error, 'no arguments: `name`, `handler`'
          fn2 = ->
            ec = new EmitterChild()
            ec.once('name')
          assert.throws fn2, TypeError, 'no arguments: `handler`'
          fn3 = ->
            ec = new EmitterChild()
            ec.once 11
          assert.throws fn3, TypeError, 'argument `name` is not a String'
          fn4 = ->
            ec = new EmitterChild()
            ec.once 'name', {}
          assert.throws fn4, TypeError, 'argument `handler` is not a callback Function'

        it 'off', ->
          class EmitterChild extends CSEmitter
            emit: -> super
          ec = new EmitterChild('one')
          ec.on 'one', ->
          fn = ->
            ec.off()
          assert.throws fn, Error, 'no arguments: `name` [, `handler`]'
          fn2 = ->
            ec.off(21)
          assert.throws fn2, TypeError, 'argument `name` is not a String'
          fn3 = ->
            ec.off('name')
          assert.throws fn3, Error, 'unregistered `name` of event'
          fn3 = ->
            ec.off 'one', {}
          assert.throws fn3, TypeError, 'argument `handler` is not a callback Function'

          assert.isNull ec.off('one', ->), '`off` for unregistered handler is soft error, return null'

      describe 'correct', ->
        EmitterSimpleAsync = undefined
        esa = undefined
        before ->
          EmitterSimpleAsync = class EmitterSimpleAsync extends CSEmitter
            emit: (nameOrEvent) ->
              {pot, evt} = super nameOrEvent
              {l,c,h,o} = pot
              if c > 0
                i = 0
                while i < c
                  fn = o[i]
                  do (fn)-> process.nextTick -> fn(evt); return
                  o[i] = null
                  i++
                pot.c = 0
              i = 0
              while i < l
                fn = h[i]
                do (fn)-> process.nextTick -> fn(evt); return
                i++
              @
          esa = new EmitterSimpleAsync ['nya', 'error']

        it 'on nya', (done) ->
          r = esa.on 'nya', (e) ->
            assert.instanceOf e, CSEvent
            assert.equal e.name, 'nya'
            assert.equal e.target, esa
            assert.equal e.value, null
            done()
          assert.equal r, esa

          esa.emit 'nya'

        it 'on error', (done) ->
          err = new Error('aaaaa')
          r = esa.on 'error', (e) ->
            assert.instanceOf e, CSEvent
            assert.equal e.name, 'error'
            assert.equal e.target, esa
            assert.equal e.value, err
            done()
          assert.equal r, esa

          esa.emit new CSEvent 'error', esa, err

        it 'once any', (done) ->
          counterOnce = 0
          counterOn = 0
          r = esa.once 'any', (e) ->
            assert.equal counterOnce, 0
            counterOnce++
            assert.equal e.name, 'any'
            assert.equal e.target, esa
            assert.equal e.value, null
          assert.equal r, esa

          r = esa.on 'any', (e) ->
            assert.equal e.name, 'any'
            assert.equal counterOnce, 2
            assert.isTrue 0 <= counterOn <= 1
            if counterOn is 1
              done()
            counterOn++
            return
          assert.equal r, esa

          assert.equal esa, esa.once 'any', ->
            counterOnce++
            return

          esa.emit 'any'
          esa.emit 'any'

        it 'off pull', (done) ->
          counter = 0
          r = esa.on 'pull', fn = ->
            if counter is 0
              counter = 1
              return
            throw new Error 'call not must be'
          esa.on 'pull', ->
            counter++
            if counter is 3
              done()
            return
          assert.equal r, esa

          esa.emit 'pull'
          r = esa.off 'pull', fn
          assert.equal r, esa
          esa.emit 'pull'

        it 'off', (done) ->
          counter = 0
          r = esa.on 'tom', ->
            if counter > 1
              throw new Error 'call not must be'
            counter++
          assert.equal r, esa
          r = esa.on 'tom', ->
            if counter > 1
              throw new Error 'call not must be'
            counter++
          assert.equal r, esa

          assert.isNull esa.off 'tom', ->

          esa.emit 'tom'
          r = esa.off 'tom'
          assert.equal r, esa
          esa.emit 'tom'

          esa.once 'end', ->
            assert.equal counter, 2
            done()
          esa.emit 'end'

      it 'destroy', ->
        class EmitterSimpleAsync extends CSEmitter
        esa = new EmitterSimpleAsync(['no', 'yes', 'true'])
        assert.ok esa._map
        assert.instanceOf esa._map, Map
        assert.isNull esa.destructor()
        assert.isNull esa._map
  describe 'without Map', ->
    if typeof Map is 'function'
      clear = Map::clear
      before ->
        Map::clear = null
        delete require.cache[require.resolve('../lib/emitter.coffee')]
        {CSEmitter, CSEvent} = require '../lib/emitter.coffee'
        return
      after ->
        Map::clear = clear
        delete require.cache[require.resolve('../lib/emitter.coffee')]
        {CSEmitter, CSEvent} = require '../lib/emitter.coffee'
        return
    describe 'structure', ->
      it 'class', ->
        assert.ok CSEmitter
        assert.isFunction CSEmitter
        assert.isTrue CSEmitter.isAbstract
      it 'proto', ->
        assert.isFunction CSEmitter::destructor
        assert.lengthOf CSEmitter::destructor, 0
        assert.isFunction CSEmitter::on
        assert.lengthOf CSEmitter::on, 2
        assert.isFunction CSEmitter::once
        assert.lengthOf CSEmitter::once, 2
        assert.isFunction CSEmitter::off
        assert.lengthOf CSEmitter::off, 2
        assert.isFunction CSEmitter::emit
        assert.lengthOf CSEmitter::emit, 1
        assert.isTrue CSEmitter::emit.isAbstract
        # Maybe incorrect test protected/private members?
        assert.ok CSEmitter::_map
        assert.isObject CSEmitter::_map

    describe 'behavior', ->
      describe 'errors', ->
        it 'abstract', ->
          fn = ->
            new CSEmitter()
          assert.throws fn, TypeError, 'CSEmitter is abstract'
        it 'emit', ->
          class EmitterChildWithoutEmit extends CSEmitter
          class EmitterChild extends CSEmitter
            emit: -> super
          fn2 = ->
            ec = new EmitterChildWithoutEmit(['now'])
            ec.emit 'now'
          assert.throws fn2, Error, '`emit` is abstract method'
          fn3 = ->
            ec = new EmitterChild([])
            ec.emit 'now'
          assert.throws fn3, Error, 'emit unregistered event `name`'
          fn4 = ->
            ec = new EmitterChild(['now'])
            ec.emit 342
          assert.throws fn4, TypeError, 'unknown type of emit'
          fn5 = ->
            ec = new EmitterChild(['now'])
            ec.emit {}
          assert.throws fn5, TypeError, 'unknown type of emit'

        it 'on', ->
          class EmitterChild extends CSEmitter
            emit: -> super
          fn = ->
            ec = new EmitterChild()
            ec.on()
          assert.throws fn, Error, 'no arguments: `name`, `handler`'
          fn2 = ->
            ec = new EmitterChild()
            ec.on('name')
          assert.throws fn2, TypeError, 'no arguments: `handler`'
          fn3 = ->
            ec = new EmitterChild()
            ec.on 11
          assert.throws fn3, TypeError, 'argument `name` is not a String'
          fn4 = ->
            ec = new EmitterChild()
            ec.on 'name', {}
          assert.throws fn4, TypeError, 'argument `handler` is not a callback Function'

        it 'once', ->
          class EmitterChild extends CSEmitter
            emit: -> super
          fn = ->
            ec = new EmitterChild()
            ec.once()
          assert.throws fn, Error, 'no arguments: `name`, `handler`'
          fn2 = ->
            ec = new EmitterChild()
            ec.once('name')
          assert.throws fn2, TypeError, 'no arguments: `handler`'
          fn3 = ->
            ec = new EmitterChild()
            ec.once 11
          assert.throws fn3, TypeError, 'argument `name` is not a String'
          fn4 = ->
            ec = new EmitterChild()
            ec.once 'name', {}
          assert.throws fn4, TypeError, 'argument `handler` is not a callback Function'

        it 'off', ->
          class EmitterChild extends CSEmitter
            emit: -> super
          ec = new EmitterChild('one')
          ec.on 'one', ->
          fn = ->
            ec.off()
          assert.throws fn, Error, 'no arguments: `name` [, `handler`]'
          fn2 = ->
            ec.off(21)
          assert.throws fn2, TypeError, 'argument `name` is not a String'
          fn3 = ->
            ec.off('name')
          assert.throws fn3, Error, 'unregistered `name` of event'
          fn3 = ->
            ec.off 'one', {}
          assert.throws fn3, TypeError, 'argument `handler` is not a callback Function'

          assert.isNull ec.off('one', ->), '`off` for unregistered handler is soft error, return null'

      describe 'correct', ->
        EmitterSimpleAsync = undefined
        esa = undefined
        before ->
          EmitterSimpleAsync = class EmitterSimpleAsync extends CSEmitter
            emit: (nameOrEvent) ->
              {pot, evt} = super nameOrEvent
              {l,c,h,o} = pot
              if c > 0
                i = 0
                while i < c
                  fn = o[i]
                  do (fn)-> process.nextTick -> fn(evt); return
                  o[i] = null
                  i++
                pot.c = 0
              i = 0
              while i < l
                fn = h[i]
                do (fn)-> process.nextTick -> fn(evt); return
                i++
              @
          esa = new EmitterSimpleAsync ['nya', 'error']

        it 'on nya', (done) ->
          r = esa.on 'nya', (e) ->
            assert.instanceOf e, CSEvent
            assert.equal e.name, 'nya'
            assert.equal e.target, esa
            assert.equal e.value, null
            done()
          assert.equal r, esa

          esa.emit 'nya'

        it 'on error', (done) ->
          err = new Error('aaaaa')
          r = esa.on 'error', (e) ->
            assert.instanceOf e, CSEvent
            assert.equal e.name, 'error'
            assert.equal e.target, esa
            assert.equal e.value, err
            done()
          assert.equal r, esa

          esa.emit new CSEvent 'error', esa, err

        it 'once any', (done) ->
          counterOnce = 0
          counterOn = 0
          r = esa.once 'any', (e) ->
            assert.equal counterOnce, 0
            counterOnce++
            assert.equal e.name, 'any'
            assert.equal e.target, esa
            assert.equal e.value, null
          assert.equal r, esa

          r = esa.on 'any', (e) ->
            assert.equal e.name, 'any'
            assert.equal counterOnce, 2
            assert.isTrue 0 <= counterOn <= 1
            if counterOn is 1
              done()
            counterOn++
            return
          assert.equal r, esa

          assert.equal esa, esa.once 'any', ->
            counterOnce++
            return

          esa.emit 'any'
          esa.emit 'any'

        it 'off pull', (done) ->
          counter = 0
          r = esa.on 'pull', fn = ->
            if counter is 0
              counter = 1
              return
            throw new Error 'call not must be'
          esa.on 'pull', ->
            counter++
            if counter is 3
              done()
            return
          assert.equal r, esa

          esa.emit 'pull'
          r = esa.off 'pull', fn
          assert.equal r, esa
          esa.emit 'pull'

        it 'off', (done) ->
          counter = 0
          r = esa.on 'tom', ->
            if counter > 1
              throw new Error 'call not must be'
            counter++
          assert.equal r, esa
          r = esa.on 'tom', ->
            if counter > 1
              throw new Error 'call not must be'
            counter++
          assert.equal r, esa

          assert.isNull esa.off 'tom', ->

          esa.emit 'tom'
          r = esa.off 'tom'
          assert.equal r, esa
          esa.emit 'tom'

          esa.once 'end', ->
            assert.equal counter, 2
            done()
          esa.emit 'end'

      it 'destroy', ->
        class EmitterSimpleAsync extends CSEmitter
        esa = new EmitterSimpleAsync(['no', 'yes', 'true'])
        assert.ok esa._map
        assert.isObject esa._map
        assert.isNull esa.destructor()
        assert.isNull esa._map

