# Абстрактный класс для множества контейнеров, основывается на
# узлах `Node` и имеет ссылки с начального приватного элемента `_f`
# до следующего при их наличии.
{CSObject} = require './object.coffee'
{Node} = require './node.coffee'

rev = @
# Контейнер, сущность для групировки, доступа и
# обработки других сущностей.
# @abstract
# @class Container
class Container extends CSObject
  # @property {Node} _f head of container or tail
  # @private
  _f: new Node null
  # for non-init object is -1
  # @property {Number} length count of items
  # @read-only
  length: -1

  # Создаёт контейнер, инициализирует все свойства
  # @throw {TypeError} если пытаются создать объект абстрктного класса
  constructor: ->
    if @constructor is Container
      throw new TypeError "'Container' is abstract"
    @_f = new Node null
    @length = 0
    super

  ###
  Копирует объект с сохранением всех ссылок и значений в узлах
  @param {Boolean} arrayStrategy использовать прикопировании
    создание массива и передачу его в функцию `fromArray` `[default = no]`.
    По идее параметр `arrayStrategy` для внутреннего пользования,
    но как знать, может кому поможет...
  @throw {typeError} если аргументов > 1 или если это не булево значение
  @return {extends Container} унаследованные от контейнера классы в
    которых вызван метод
  ###
  copy: (arrayStrategy) ->
    if arguments.length is 0
      arrayStrategy = no
    else if arguments.length > 1
      throw new TypeError "copy have one optional argument"
    if typeof arrayStrategy isnt "boolean"
      throw new TypeError "flag `arrayStrategy` should be boolean"
    container = new @constructor()
    return container if @length is 0
    if arrayStrategy
      return @constructor.fromArray @values()
    # end arrayStrategy
    container._f.v = @_f.v
    point = @_f.n
    prevTarget = container._f
    while point isnt null
      prevTarget = prevTarget.n = new Node point.v
      point = point.n
    if @_b?
      container._b = prevTarget
    container.length = @length
    container

  # возвращает значения в узлах контейнера в виде массива начиная с начала
  # контейнера
  # @throw {TypeError} если переданы аргументы
  # @return {Array<*>} массив значений узлов
  values: ->
    if arguments.length > 0
      throw new TypeError "values haven't arguments"
    len = @length
    res = new Array(len)
    point = @_f
    i = 0
    while i < len
      res[i++] = point.v
      point = point.n
    point = null
    res

  # Определяет, находится ли сущность `some` хотя бы в одном из узлов.
  # Сложность О(n)
  # @param {*} some искомая сущность
  # @throw {TypeError} если аргументов не 1
  # @return {Boolean} есть ли значение в хотя бы одном из узлов
  has: (some) ->
    if arguments.length isnt 1
      throw new TypeError "has should have one argument"
    point = @_f
    while point isnt null
      return true if point.v is some
      point = point.n
    false

  # Создаёт строчное предтсавления контейнера. Между элементами расставляет
  # -> для односвязанных списков и <-> для двусвязанных.
  # @return {String} проекция контейнера на строку
  toString: ->
    if @length is 0
      return ''
    out = ''
    point = @_f
    while point isnt null
      value = undefined
      switch typeof v = point.v
        when 'number'
          value = v.toString()
        when 'boolean'
          value = if v then 'true' else 'false'
        when 'string'
          value = "\"#{v}\""
        when 'undefined'
          # impossible but ok
          value = 'undefined'
        when 'function'
          value = '`function`'
        when 'object'
          if v?
            value = v.toString()
          else
            value = 'null'
      ### istanbul ignore if ###
      if (not value?) and typeof v is 'symbol'
        value = "`#{v.toString}`"
      # end switch
      if point.n?
        if point.n.p?
          arrow = '<->'
        else
          arrow = '->'
      else
        arrow = ''
      out += value + arrow
      point = point.n
    return out

  # Преобразует контейнер в объектное представление, которое можно
  # конвертировать в JSON-строку
  # @throw {TypeError} если есть аргументы
  # @return {Object< type:String, data:Array<*> >}
  # имя контейнера в `type` и в `data` значения в виде массива
  toJSON: ->
    if arguments.length > 0
      throw new TypeError "toJSON haven't arguments"
    type: @constructor.name
    data: @values()

  # Разрушает контейнер: требует определение в каждом классе своё
  # @abstarct
  # @throw {TypeError} если не определен метод в потомке
  # @return {null}
  destructor: ->
    if arguments.length > 0
      throw new TypeError "destructor haven't arguments"
    super
    @length = -1
    @_f = null

  # Создаёт контейнер из массива. Абстрактный класс, который должны
  # определить потомки для создания контейнера, принимает на вход
  # только 1 аргумент -- массив значений `array`
  # @param {Array} array массив значений узлов
  # @abstarct
  # @throw {Error} если не перекрыт потомком или аргументов не 1
  # @throw {TypeError} если аргумент не массив
  # @return {extends Container} контейнер-потомок
  @fromArray: abstract (array) ->
    if arguments.length isnt 1
      throw new Error "fromArray should have one argument"
    unless array instanceof Array
      throw new TypeError "fromArray work with array only"
    return if @fromArray isnt Container.fromArray
    throw new Error "Extended static abstract method not defined"

  # Проверяет является ли `object` контейнером
  # @param {*} object проверяемая сущность
  # @throw {Error} если аргументов не 1
  # @return {Boolean} является или нет
  @isContainer: (object) ->
    if arguments.length isnt 1
      throw new Error "isContainer should have one argument"
    object instanceof Container

  # Создаёт контейнер на основе JSON-объекта `data` и не отбрасывает
  # ошибок, если `quiet` выставлно в `yes`
  # @param {Object} data объект для строительства
  # @param {Boolean} quiet возвращать ли ошибки вметсо их отбрсывания
  # @throw {Error} если аргументов не 1 и не 2
  # @throw {TypeError} если `data` не объект и/или quiet не булево
  # @throw {TypeError} если нарушен формат `data`
  # @throw {Error} если метод `fromArray` не определён в потомке
  # @throw {TypeError} если имя потомка и имя в `data` не совпали
  # @return {extend Container|Error|TypeError} сооружение или ошибку,
  #   при включенном `quiet` и возникновении ошибки
  @fromJSON: (data, quiet = no) ->
    unless 1 <= arguments.length <= 2
      throw new Error "fromJSON should have one or two args"
    if (typeof data isnt 'object') or (not data?)
      e = new TypeError "`data` is not a object"
      return e if quiet
      throw e
    if typeof quiet isnt 'boolean'
      throw new TypeError "flag `quiet` must be a boolean"
    if (not data.type?) or (not data.data?)
      e = new TypeError "format `data` is incorrect"
      return e if quiet
      throw e
    unless data.data instanceof Array
      e = new Error "format `data` is incorrect: data is not a array"
      return e if quiet
      throw e
    keys = Object.keys data
    if keys.length > 2
      e = new Error "format `data` is incorrect: another keys have"
      return e if quiet
      throw e

    if @fromArray is Container.fromArray
      e = new Error "type is abstract type"
      return e if quiet
      throw e

    if @name isnt data.type
      e = new TypeError "type and class name is not conform"
      return e if quiet
      throw  e
    @fromArray data.data

Container = abstract Container
# Экспортируем контейнер наружу в общей манере экспорта
module.exports = { Container }