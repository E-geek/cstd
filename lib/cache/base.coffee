{CSObject} = require '../object.coffee'
{Queue} = require '../queue.coffee'

# Detect exists Map native class
HAVE_MAP = typeof Map is 'function'

# Базовый аппарат кеша, определяет примитивную реализацию
# и набор необходимых методов. Абстрактный.
class BaseCache extends CSObject
  # @property {Map|Object} data is map for 'key': value
  # @private
  _data: null
  # @property {Map|Object} control list
  # @private
  _control: null
  # @property {Number} количество элементов в кэше
  # @read-only
  length: -1
  # @property {Number} максимальное количество элементов в кэше
  maxSize: -1

  # Создаёт кэш на `size` элементов
  # @abstract
  # @param {Number} size не обязателен в принципе,
  #   определяет значение `#maxSize` если оно не установлено
  # @throw {TypeError} если строится абстрактный класс
  # @throw {TypeError} если `size` передан, но не число
  # @throw {RangeError} если `size` меньше 1
  constructor: (size) ->
    if @constructor is BaseCache
      throw new TypeError "`BaseCache` is abstract"
    if typeof size isnt 'undefined'
      if typeof size isnt 'number'
        throw new TypeError "`size` should be a number"
      if size < 1
        throw new RangeError "`size` less than 1"
    @_data ?= if HAVE_MAP then new Map() else {}
    @_control ?= new Queue
    @maxSize = size if size? and @maxSize is -1
    @length = 0 if @length is -1

  # Полчаем элемент по ключу `key` или undefined
  # @param {String|Number} key ключ хранимого в кеше значения
  # @throw {Error} если аргументов нет или больше одного
  # @throw {TypeError} если `key` не вписался в типы
  # @return {*|undefined} значение из кеша или что такового нет
  get: (key) ->
    if arguments.length isnt 1
      throw new Error "`get` have `key` argument"
    keyType = typeof key
    ### memo:
    string
    number
    object
    symbol
    boolean
    function
    undefined
    ###
    if not (keyType[5] is 'g' or keyType[5] is 'r')
      throw new TypeError "`key` must be a string or number"
    if HAVE_MAP
      return @_data.get key
    return @_data[keyType[0] + key]

  # Помещает или обновляет значение `value` в кэше по ключу `key`
  # @param {String|Number} key ключ
  # @param {*} value не стоит передавать undefined
  # @throw {Error} если не два аргумента
  # @throw {TypeError} если ключ не того типа
  # @return {BaseCache} `this`
  set: (key, value) ->
    if arguments.length isnt 2
      throw new Error "`set` have `key` and `value` arguments"
    keyType = typeof key
    if not (keyType[5] is 'g' or keyType[5] is 'r')
      throw new TypeError "`key` must be a string or number"
    if HAVE_MAP
      unless @_data.has key
        @_data.set key, value
        @_control.push key
        if @length is @maxSize
          key = @_control.pop()
          @_data.delete key
        else
          @length++
      else
        @_data.set key, value
      return @
    key = keyType[0] + key
    if typeof @_data[key] is 'undefined'
      @_data[key] = value
      @_control.push key
      if @length is @maxSize
        key = @_control.pop()
        delete @_data[key]
      else
        @length++
    else
      @_data[key] = value
    @

  # Очистить кэш
  # @throw {Error} если переданы аргументы
  # @return {BaseCache} `this`
  clear: ->
    if arguments.length isnt 0
      throw new Error "`clear` have not arguments"
    if HAVE_MAP
      @_data.clear()
    else
      @_data = {}
    @_control.clear()
    @length = 0
    @

  # Очищает кэш и удаляет все связки
  # @return {null}
  destructor: ->
    @clear()
    @length = -1
    @maxSize = -1
    @_data = null
    @_control = null
    null

BaseCache = abstract BaseCache
module.exports = { BaseCache }
