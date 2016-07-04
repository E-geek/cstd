{BaseCache} = require './base.coffee'
{NodeQueue} = require './node_queue.coffee'

HAVE_MAP = typeof Map is 'function'

# Реализация Least Request Cache известного, как "Вытесняющий кеш"
class LRUCache extends BaseCache

  keyRE = /string|number/

  # Создаёт кэш размера `size`
  # @param {Number} size обязателен
  constructor: (size) ->
    super(size)
    @_control = new NodeQueue()

  # Идиентичен родительскому `BaseCache::set(key, value)`
  # @param {String|Number} key
  # @param {*} value
  # @throw {Error} если не два аргумента
  # @throw {TypeError} если ключ не того типа
  # @return {LRUCache} `this`
  set: (key, value) ->
    if arguments.length isnt 2
      throw new Error "`set` have `key` and `value` arguments"
    keyType = typeof key
    if not keyRE.test keyType
      throw new TypeError "`key` must be a string or number"
    if HAVE_MAP
      unless @_data.has key # if must insert
        node = @_control
        .push key
        .back
        @_data.set key,
          node: node
          data: value
        if @length is @maxSize
          key = @_control.pop()
          @_data.delete key
        else
          @length++
      else
        scope = @_data.get key
        scope.data = value
        @_control.drop scope.node
      return @

    key = keyType[0] + key
    if typeof @_data[key] is 'undefined'
      node = @_control
      .push key
      .back
      @_data[key] =
        node: node
        data: value
      if @length is @maxSize
        key = @_control.pop()
        delete @_data[key]
      else
        @length++
    else
      scope = @_data[key]
      scope.data = value
      @_control.drop scope.node
    @

  # Идиентичен родительскому `BaseCache::get(key)`
  # @param {String|Number} key
  # @throw {Error} если аргументов нет или больше одного
  # @throw {TypeError} если `key` не вписался в типы
  # @return {*|undefined}
  get: (key) ->
    scope = super
    return undefined unless scope?
    @_control.drop scope.node
    scope.data

module.exports = { LRUCache }