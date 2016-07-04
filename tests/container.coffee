{assert} = require 'chai'
{Container} = require '../lib/container.coffee'
{CSObject} = require '../lib/object.coffee'
{Node} = require '../lib/node.coffee'

describe 'Container', ->
  describe 'structure', ->
    it 'class', ->
      assert.ok Container
      assert.isFunction Container
      assert.lengthOf Container, 0
      assert.isFunction Container.isContainer
      assert.lengthOf Container.isContainer, 1
      assert.isFunction Container.fromJSON
      assert.lengthOf Container.fromJSON, 2, 'data[, quiet]'

    it 'proto', ->
      assert.strictEqual Container::length, -1
      assert.instanceOf Container::_f, Node
      assert.isFunction Container::destructor
      assert.lengthOf Container::destructor, 0
      assert.isFunction Container::copy
      assert.lengthOf Container::copy, 1
      assert.isFunction Container::values
      assert.lengthOf Container::values, 0
      assert.isFunction Container::has
      assert.lengthOf Container::has, 1, 'who'
      assert.isFunction Container::toString
      assert.lengthOf Container::toString, 0
      assert.isFunction Container::toJSON
      assert.lengthOf Container::toJSON, 0

    it 'is abstract', ->
      fn = ->
        new Container()
      assert.throws fn, TypeError, '\'Container\' is abstract'

      # check correct
      class CC extends Container
        _f: new Node null
        constructor: ->
          super
        @fromArray: () ->
          new CC()

      cc = new CC()
      r = cc.copy()
      assert.instanceOf r, Container
      r = cc.values()
      assert.isArray r
      r = cc.has 'a'
      assert.isBoolean r
      r = cc.toString()
      assert.isString r
      r = cc.toJSON()
      assert.isObject r


  describe 'behavior', ->

    describe 'errors', ->
      it 'copy', ->
        class CC extends Container
        f = ->
          c = new CC()
          c.copy null
        assert.throws f, TypeError, 'flag `arrayStrategy` should be boolean'
        f = ->
          c = new CC()
          c.copy yes, 2
        assert.throws f, TypeError, 'copy have one optional argument'

      it 'values', ->
        class CC extends Container
        f = ->
          c = new CC()
          c.values null
        assert.throws f, TypeError, 'values haven\'t arguments'
        f = ->
          c = new CC()
          c.values 1, 2
        assert.throws f, TypeError, 'values haven\'t arguments'

      it 'has', ->
        class CC extends Container
        f = ->
          c = new CC()
          c.has()
        assert.throws f, TypeError, 'has should have one argument'
        f = ->
          c = new CC()
          c.has(1, 2)
        assert.throws f, TypeError, 'has should have one argument'

      it 'toJSON', ->
        class CC extends Container
        f = ->
          c = new CC()
          c.toJSON null
        assert.throws f, TypeError, 'toJSON haven\'t arguments'
        f = ->
          c = new CC()
          c.toJSON 1, 2
        assert.throws f, TypeError, 'toJSON haven\'t arguments'

      it 'destructor', ->
        class CC extends Container
        f = ->
          c = new CC()
          c.destructor null
        assert.throws f, TypeError, 'destructor haven\'t arguments'
        f = ->
          c = new CC()
          c.destructor 1, 2
        assert.throws f, TypeError, 'destructor haven\'t arguments'

      it '@fromArray', ->
        class CC extends Container
        f = ->
          Container.fromArray []
        assert.throws f, Error, "Extended static abstract method not defined"
        f = ->
          CC.fromArray()
        assert.throws f, Error, 'fromArray should have one argument'
        f = ->
          CC.fromArray 1, 2
        assert.throws f, Error, 'fromArray should have one argument'
        f = ->
          CC.fromArray [], 2
        assert.throws f, Error, 'fromArray should have one argument'
        f = ->
          CC.fromArray 3
        assert.throws f, TypeError, 'fromArray work with array only'

      it '@isContainer', ->
        f = ->
          Container.isContainer()
        assert.throws f, Error, 'isContainer should have one argument'
        f = ->
          Container.isContainer(1, 2)
        assert.throws f, Error, 'isContainer should have one argument'

      it '@fromJSON', ->
        class CC extends Container
          @fromArray: -> super

        f = ->
          Container.fromJSON()
        assert.throws f, Error, 'fromJSON should have one or two args'
        f = ->
          Container.fromJSON({}, yes, 3)
        assert.throws f, Error, 'fromJSON should have one or two args'
        f = ->
          Container.fromJSON '{a,b,c}'
        assert.throws f, TypeError, '`data` is not a object'
        e = Container.fromJSON null, yes
        assert.instanceOf e, TypeError
        assert.equal e.message, '`data` is not a object'

        f = ->
          Container.fromJSON {}, 1
        assert.throws f, TypeError, 'flag `quiet` must be a boolean'
        f = ->
          Container.fromJSON {}
        assert.throws f, TypeError, 'format `data` is incorrect'
        e = Container.fromJSON {}, yes
        assert.instanceOf e, TypeError
        assert.equal e.message, 'format `data` is incorrect'

        f = ->
          Container.fromJSON {type: 'CC', data: 'a'}
        assert.throws f, Error, 'format `data` is incorrect: data is not a array'
        e = Container.fromJSON {type: 'CC', data: 'a'}, yes
        assert.instanceOf e, Error
        assert.equal e.message, 'format `data` is incorrect: data is not a array'

        if typeof Object.keys isnt 'function'
          throw new ReferenceError '
            node is too old: required >= 0.5.1
            or polyfill for Object.keys, but versions < 0.6.0 is unstable, you can read
            https://raw.githubusercontent.com/nodejs/node-v0.x-archive/master/ChangeLog'
        f = ->
          Container.fromJSON {type: 'CC', data: [], other: 0}
        assert.throws f, Error, 'format `data` is incorrect: another keys have'
        e = Container.fromJSON {type: 'CC', data: [], other: 0}, yes
        assert.instanceOf e, Error
        assert.equal e.message, 'format `data` is incorrect: another keys have'

        f = ->
          Container.fromJSON {type: 'Container', data: []}
        assert.throws f, Error, 'type is abstract type'
        e = Container.fromJSON {type: 'Container', data: []}, yes
        assert.instanceOf e, Error
        assert.equal e.message, 'type is abstract type'

        f = ->
          CC.fromJSON {type: 'Lepra', data: []}
        assert.throws f, TypeError, 'type and class name is not conform'
        e = CC.fromJSON {type: 'Lepra', data: []}, yes
        assert.instanceOf e, TypeError
        assert.equal e.message, 'type and class name is not conform'

    describe 'correct', ->
      class CC extends Container
        @fromArray: (array) ->
          super(array) # check
          c = new CC()
          if array.length is 0
            return c
          point = c._f
          len = c.length = array.length
          point.v = array[0]
          i = 1
          while i < len
            point = point.n = new Node array[i++]
          c

      it 'prepare check', ->
        cc = new CC()
        assert.ok cc._f
        assert.lengthOf cc, 0

        cc = CC.fromArray []
        assert.instanceOf cc, CC
        assert.instanceOf cc, Container
        assert.ok cc._f
        assert.isNull cc._f.v
        assert.lengthOf cc, 0

        cc = CC.fromArray [1]
        assert.instanceOf cc, CC
        assert.instanceOf cc, Container
        assert.ok cc._f
        assert.equal cc._f.v, 1
        assert.isNull cc._f.n
        assert.lengthOf cc, 1

        cc = CC.fromArray [1,2,3]
        assert.instanceOf cc, CC
        assert.instanceOf cc, Container
        assert.ok cc._f
        assert.equal cc._f.v, 1
        assert.equal cc._f.n.v, 2
        assert.equal cc._f.n.n.v, 3
        assert.isNull cc._f.n.n.n
        assert.lengthOf cc, 3


      it 'new', ->
        cc = new CC()
        assert.instanceOf cc, CC
        assert.instanceOf cc, Container
        assert.instanceOf cc, CSObject

      it 'copy', ->
        cc = CC.fromArray [1, 2, 3]
        cc2 = cc.copy()
        assert.notEqual cc, cc2
        assert.instanceOf cc2, CC
        assert.instanceOf cc2, Container
        assert.equal cc._f.v, cc2._f.v
        assert.equal cc._f.n.v, cc2._f.n.v
        assert.equal cc._f.n.n.v, cc2._f.n.n.v
        assert.equal cc.length, cc2.length

        cc2 = cc.copy yes
        assert.notEqual cc, cc2
        assert.instanceOf cc2, CC
        assert.instanceOf cc2, Container
        assert.equal cc._f.v, cc2._f.v
        assert.equal cc._f.n.v, cc2._f.n.v
        assert.equal cc._f.n.n.v, cc2._f.n.n.v
        assert.equal cc.length, cc2.length

      it 'values', ->
        cc = CC.fromArray [1]
        values = cc.values()
        assert.isArray values
        assert.lengthOf values, 1
        assert.equal values[0], 1
        b = {a:0}
        realValues = [1,2,3, b]
        cc = CC.fromArray realValues
        values = cc.values()
        assert.isArray values
        assert.lengthOf values, 4
        assert.equal values[0], 1
        assert.equal values[1], 2
        assert.equal values[2], 3
        assert.equal values[3], b
        values[3].a = 1
        assert.strictEqual cc._f.n.n.n.v.a, 1

      it 'has', ->
        b = {}
        cc = CC.fromArray [1,2,3,b]
        assert.isTrue cc.has 1
        assert.isTrue cc.has 2
        assert.isTrue cc.has 3
        assert.isTrue cc.has b
        assert.isFalse cc.has null
        assert.isFalse cc.has false
        assert.isFalse cc.has true
        assert.isFalse cc.has '1'

      it 'toString', ->
        b =
          toString: -> 'abra'
        f = {a: 1} # '[object Object]'
        cc0 = new CC()
        assert.strictEqual cc0.toString(), ''

        cc = CC.fromArray [1, '2', null, 'undefined', b, f, true]
        cc._f.n.n.n.n.n.n.n = new Node(null)
        cc._f.n.n.n.n.n.n.n.v = undefined
        cc._f.n.n.n.n.n.n.n.n = new Node ->
        str = cc.toString()
        assert.equal str,
          '1->"2"->null->"undefined"->abra->\
[object Object]->true->undefined->`function`'

        next = cc._f.n
        point = cc._f
        while next isnt null
          next.p = point
          point = next
          next = next.n
        point.p.p.v = false
        str = cc.toString()
        assert.equal str,
          '1<->"2"<->null<->"undefined"<->abra<->\
[object Object]<->false<->undefined<->`function`'

      it 'toJSON', ->
        cc = CC.fromArray [1,2,3]
        data = cc.toJSON()
        assert.isString data.type
        assert.equal data.type, 'CC'
        assert.isArray data.data
        assert.lengthOf data.data, 3


      it '@isContainer', ->
        cc = new CC()
        assert.isTrue CC.isContainer cc
        assert.isFalse CC.isContainer null
        assert.isFalse CC.isContainer []
        assert.isFalse CC.isContainer {}

      it '@fromJSON', ->
        cc = CC.fromJSON
          type: 'CC'
          data: [1,2,3]
        assert.instanceOf cc, CC
        assert.equal cc._f.v, 1
        assert.equal cc._f.n.v, 2
        assert.equal cc._f.n.n.v, 3
        cc2 = CC.fromJSON cc.toJSON()
        assert.lengthOf cc2, 3
        assert.equal cc2._f.v, 1
        assert.equal cc2._f.n.v, 2
        assert.equal cc2._f.n.n.v, 3

      it 'destroy', ->
        cc = CC.fromArray []
        cc.destructor()
        assert.lengthOf cc, -1
        assert.isNull cc._f