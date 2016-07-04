# File of classes CSEvent and abstract CSEmitter

{CSObject} = require './object.coffee'

# only internal usage class for list (array) of
# regular handlers and one shot handlers.
# @nodoc
# coffeelint: disable=camel_case_classes
class __DedicatedArray
  # @property {Number} Length of handler array
  l: 0
  # @property {Number}  Count of one shots
  c: 0
  # @property {Array<Function>} Handlers list, redefined by constructor
  h: new Array(8)
  # @property {Array<Function>} One shot list, redefined by constructor
  o: new Array(8)

  # Alloc memory, `length` is required
  constructor: (length) ->
    @h = new Array(length)
    @o = new Array(length)

# Class `CSEvent` is object to throw when event call.
class CSEvent extends CSObject
  # @property {String} name of a event
  name: ''
  # @property {Number} timestamp in milliseconds
  ts: 0
  # @property {*} optional parameter
  value: null
  # @property {CSEmitter} link to object, when fire event
  target: null

  # Create event with name `name` by object `target` with
  # optionally any data `value`
  # @param {String} name is name of event
  # @param {CSEmitter} target is link to CSEmitter child object
  # @param {*} value data for transmit to event handler
  constructor: (name, target, value) ->
    if arguments.length < 1
      throw new TypeError 'No arguments'
    if typeof name isnt 'string'
      throw new TypeError "`name` must be a string"
    unless target?
      throw new TypeError "`target` is required argument"
    unless target instanceof CSEmitter
      throw new TypeError "`target` must be a instance of CSEmitter"
    @name = name
    @target = target
    @value = value if value?
    @ts = Date.now()

  # kill all links
  # @return {null}
  destructor: ->
    @value = null
    @target = null
    null

# It's can be run by node v0.10.x => Map maybe not exists
# But if exists, use it! Map quickly than object as dictionary

if typeof Map is 'function' and typeof Map::clear is 'function'
  # abstract class CSEmitter for child class
  class CSEmitter extends CSObject
    # @property {Map} private property for all handlers by name
    # @private
    _map: new Map()

    # Init map by array of emit names
    # @param {Array<String>} list is array of natural events
    # @throw {TypeError} if call from `new`
    # @abstract
    constructor: (list) ->
      if @constructor is CSEmitter
        throw new TypeError "CSEmitter is abstract"
      @_map = new Map()
      unless list?
        return
      for name in list
        @_map.set name, new __DedicatedArray(8)
      return

    # destructor clear all handlers, and clean map and links
    # @return {null}
    destructor: ->
      m = @_map.values()
      v = m.next()
      while not v.done
        pot = v.value
        pot.h = null
        pot.o = null
        v = m.next()
      @_map.clear()
      @_map = null
      null

    # Add event listener `handler` by `name` event.
    #
    # @param {String} name name of a event handle that
    # @param {Function} handler function, call when fired event
    # @callback {CSEvent} call with CSEvent object
    # @throw {Error} if no arguments
    # @throw {TypeError} if `name` not a String or `handler` not a Function
    # @throw {TypeError} if `handler` not passed
    # @return {CSEmitter} `this`
    on: (name, handler) ->
      if (al = arguments.length) is 0
        throw new Error "no arguments: `name`, `handler`"
      if typeof name isnt 'string'
        throw new TypeError "argument `name` is not a String"
      if al is 1
        throw new TypeError "no arguments: `handler`"
      if typeof handler isnt 'function'
        throw new TypeError "argument `handler` is not a callback Function"
      pot = @_map.get name
      unless pot?
        pot = new __DedicatedArray(8)
        @_map.set name, pot
      pot.h[pot.l++] = handler
      @

    # Remove listener `handler` for event `name` by this object.
    # If `handler` not passed, remove all handlers by `name` event type.
    # Return `null` if handler not found.
    # @param {String} name string, name of disable events
    # @param {Function} handler function, if pass argument, clear only `handler`
    # @throw {Error} if no arguments
    # @throw {TypeError} if `name` not a String or `handler` not a Function
    # @throw {Error} if `name` is unknown type event
    # @return {CSEmitter|null} `this` or `handler` not found indicator
    off: (name, handler) ->
      if arguments.length is 0
        throw new Error "no arguments: `name` [, `handler`]"
      if typeof name isnt 'string'
        throw new TypeError "argument `name` is not a String"
      pot = @_map.get name
      unless pot?
        throw new Error "unregistered `name` of event"
      if handler? and typeof handler isnt "function"
        throw new TypeError 'argument `handler` is not a callback Function'
      handlers = pot.h
      {l} = pot
      unless handler?
        i = 0
        while i < l
          handlers[i++] = null
        pot.l = 0
        return @

      handleIndex = handlers.indexOf handler
      if handleIndex is -1
        return null
      i = handleIndex + 1
      while i < l
        handlers[i-1] = handlers[i]
        i++
      pot.l--
      @

    # Same as the `on`, but handler call only one and before regular handlers
    # @param {String} `name` string
    # @param {Function} handler listener
    # @throw {Error} if no arguments
    # @throw {TypeError} if `name` not a String or `handler` not a Function
    # @throw {TypeError} if `handler` not pass
    # @return {CSEmitter} `this`
    once: (name, handler) ->
      if (al = arguments.length) is 0
        throw new Error "no arguments: `name`, `handler`"
      if typeof name isnt 'string'
        throw new TypeError "argument `name` is not a String"
      if al is 1
        throw new TypeError "no arguments: `handler`"
      if typeof handler isnt 'function'
        throw new TypeError "argument `handler` is not a callback Function"
      pot = @_map.get name
      unless pot?
        pot = new __DedicatedArray(8)
        @_map.set name, pot
      pot.o[pot.c++] = handler
      @

    # Emit event by name or by event.
    # if `nameOrEvent` is string than CSEvent create by func without value
    # @param {String|CSEvent} nameOrEvent type event or event (CSEvent)
    # @abstract
    # @throw {Error} if call without realisation
    # @throw {TypeError} if `nameOrEvent` unknown type
    # @throw {Error} if try call unknown name of event
    # @return {Object<__DedicatedArray, CSEvent>} for internal usage
    emit: (nameOrEvent) ->
      if @emit is CSEmitter::emit
        throw new Error "`emit` is abstract method"
      if typeof nameOrEvent is 'string'
        name = nameOrEvent
        evt = null
      else  if nameOrEvent instanceof CSEvent
        {name} = nameOrEvent
        evt = nameOrEvent
      else
        throw new TypeError 'unknown type of emit'
      pot = @_map.get name
      unless pot?
        throw new Error 'emit unregistered event `name`'
      if evt is null
        evt = new CSEvent nameOrEvent, @
      return {pot, evt}

# Map not defined, use object as dictionary
else
  # @nodoc
  class CSEmitterOld extends CSObject

    _map: {}

    constructor: (list) ->
      if @constructor is CSEmitterOld
        throw new TypeError "CSEmitter is abstract"
      @_map = {}
      unless list?
        return
      @_map = {}
      for name in list
        @_map[name] = new __DedicatedArray(8)

    destructor: ->
      m = @_map
      for item, pot of m
        pot.h = null
        pot.o = null
      m = null
      @_map = null
      null

    on: (name, handler) ->
      if (al = arguments.length) is 0
        throw new Error "no arguments: `name`, `handler`"
      if typeof name isnt 'string'
        throw new TypeError "argument `name` is not a String"
      if al is 1
        throw new TypeError "no arguments: `handler`"
      if typeof handler isnt 'function'
        throw new TypeError "argument `handler` is not a callback Function"
      pot = @_map[name]
      unless pot?
        pot = new __DedicatedArray(8)
        @_map[name] = pot
      pot.h[pot.l++] = handler
      @

    off: (name, handler) ->
      if arguments.length is 0
        throw new Error "no arguments: `name` [, `handler`]"
      if typeof name isnt 'string'
        throw new TypeError "argument `name` is not a String"
      pot = @_map[name]
      unless pot?
        throw new Error "unregistered `name` of event"
      if handler? and typeof handler isnt "function"
        throw new TypeError 'argument `handler` is not a callback Function'
      handlers = pot.h
      {l} = pot
      unless handler?
        i = 0
        while i < l
          handlers[i++] = null
        pot.l = 0
        return @

      handleIndex = handlers.indexOf handler
      if handleIndex is -1
        return null
      i = handleIndex + 1
      while i < l
        handlers[i-1] = handlers[i]
        i++
      pot.l--
      @

    once: (name, handler) ->
      if (al = arguments.length) is 0
        throw new Error "no arguments: `name`, `handler`"
      if typeof name isnt 'string'
        throw new TypeError "argument `name` is not a String"
      if al is 1
        throw new TypeError "no arguments: `handler`"
      if typeof handler isnt 'function'
        throw new TypeError "argument `handler` is not a callback Function"
      pot = @_map[name]
      unless pot?
        pot = new __DedicatedArray(8)
        @_map[name] = pot
      pot.o[pot.c++] = handler
      @

    emit: (nameOrEvent) ->
      if @emit is CSEmitter::emit
        throw new Error "`emit` is abstract method"
      if typeof nameOrEvent is 'string'
        name = nameOrEvent
        evt = null
      else  if nameOrEvent instanceof CSEvent
        name = nameOrEvent.name
        evt = nameOrEvent
      else
        throw new TypeError 'unknown type of emit'
      pot = @_map[name]
      unless pot?
        throw new Error 'emit unregistered event `name`'
      if evt is null
        evt = new CSEvent nameOrEvent, @
      return {pot, evt}

# set abstract property
CSEmitter = abstract if CSEmitterOld? then CSEmitterOld else CSEmitter
CSEmitter::emit = abstract CSEmitter::emit

module.exports = { CSEmitter, CSEvent }