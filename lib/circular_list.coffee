{Node} = require './node.coffee'
{CSObject} = require './object.coffee'

nn = new Node parseInt {}
nn.p = nn.n = nn

# Описывает циклический список, в котором нет начала или конца,
# есть только текущий указатель.
class CircularList extends CSObject
  # @property {Node} указатель на текущий узел
  # @private
  _p: nn

  # @property {Number} длина списка
  # @read-only
  length: 0

  # Конструктор циклического списка создаёт первый узел без значения,
  # и замыкает его указатели на самого себя.
  # @throw {TypeError} если в конструктор пытаются передать аргументы
  constructor: ->
    if arguments.length isnt 0
      throw new TypeError "CircularList constructor haven't arguments"
    @_p = new Node null
    @_p.p = @_p.n = @_p

  ###
  Присоединяет элемент следом за указателем, т.е.
  значение становится доступным при вызове `.next().get()`.
  @param {*} some сущность для присоединения
  @throw {TypeError} если аргументов более одного, т.к. есть `add`
  @throw {TypeError} если нет аргументов
  @return {CircularList} `this`
  ###
  append: (some) ->
    if arguments.length > 1
      throw new TypeError "more than one append"
    if arguments.length is 0
      throw new TypeError "append nothing"
    if @length++ isnt 0
      n = @_p.n
      n.p = @_p.n = new Node some, n, @_p
    else
      @_p.v = some
    @

  ###
  Присоединяет элемент перед текущим, т.е. значение становится
  достыпным при вызове `.prev().get()`
  @param {*} some сущность для присоединения
  @throw {TypeError} если аргументов более одного
  @throw {TypeError} если нет аргументов
  @return {CircularList} `this`
  ###
  prepend: (some) ->
    if arguments.length > 1
      throw new TypeError "more than one prepend"
    if arguments.length is 0
      throw new TypeError "prepend nothing"
    if @length++ isnt 0
      p = @_p.p
      p.n = @_p.p = new Node some, @_p, p
    else
      @_p.v = some
    @

  ###
  Присоединяет список аргументов после текущего. Замечу,
  что принимает на вход множество аргументов, а не массив аргументов.
  @param {*} arguments... сущности для присоединения
  @throw {TypeError} если аргументов нет
  @return {CircularList} `this`
  ###
  add: (first, list...) ->
    if arguments.length is 0
      throw new TypeError "add without value"
    end = @_p
    start = end.p
    if @length is 0
      @_p.v = first
      @length = 1
      activeNode = null
    else
      activeNode = new Node first, null, start
      @length++
    # link one node
    if list.length is 0
      if activeNode isnt null
        activeNode.n = end
        activeNode.p = start
        end.p = start.n = activeNode
      return @

    if @length is 1
      i = 1
      activeNode = new Node list[0], null, start
      firstNode = activeNode
    else
      i = 0
      firstNode = activeNode
    len = list.length
    while i < len
      activeNode = (activeNode.n = new Node list[i], null, activeNode)
      i++

    start.n = firstNode
    end.p = activeNode
    activeNode.n = end

    @length += list.length
    @

  ###
  Позволяет перейти по списку вперёд или назад на `step` шагов.
  Чтобы не кружить по списку, количесво шагов будет оптимизированно.
  @param {Number} step количество шагов: если > 0, то вперёд, иначе -- назад
  @throw {Error} если `step` не передан
  @throw {TypeError} если `step` не число
  @throw {Error} если аргументов больше 1
  @return {CircularList} `this`
  ###
  go: (step) ->
    if arguments.length is 0
      throw new Error "`step` is required"
    if typeof step isnt 'number'
      throw new TypeError "`step` must be a Number"
    if arguments.length > 1
      throw new Error "too many arguments"
    listLength = @length
    if listLength is 0
      return null
    return @ if step is 0
    index = 0
    pointer = @_p
    step = step % listLength
    if step > 0
      while index++ < step
        pointer = pointer.n
    else
      while index-- > step
        pointer = pointer.p
    @_p = pointer
    @

  # Перейти к следующему узлу в списке
  # @throw {Error} если переданы аргументы
  # @return {CircularList} `this`
  next: ->
    if arguments.length > 0
      throw new Error "next haven't arguments"
    if @length is 0
      return null
    @_p = @_p.n
    @

  # Перейти к предыдущему элементу
  # @throw {Error} если переданы аргументы
  # @return {CircularList} `this`
  prev: ->
    if arguments.length > 0
      throw new Error "prev haven't arguments"
    if @length is 0
      return null
    @_p = @_p.p
    @

  # Получить значение текущего элемента
  # @throw {Error} если переданы аргументы
  # @return {CircularList} `this`
  get: ->
    if arguments.length > 0
      throw new Error "get haven't arguments"
    if @length is 0
      throw new Error "circular list is empty"
    @_p.v

  # Получить текущий узел
  # @throw {Error} если переданы аргументы
  # @return {CircularList} `this`
  currentNode: ->
    if arguments.length > 0
      throw new Error "currentNode haven't arguments"
    if @length is 0
      throw new Error "circular list is empty"
    @_p

  # Установить значение текущего элемента
  # @param {*} some новое значение
  # @throw {Error} Если агрументов не 1
  # @throw {Error} Если список пуст.
  # @return {CircularList} `this`
  set: (some) ->
    if (l = arguments.length) is 0
      throw new Error "can't set nothing to value"
    if @length is 0
      throw new Error "can't set to empty circular list"
    if l > 1
      throw new Error "too many arguments"
    @_p.v = some
    @

  # Очистить список от текущего значения и вернуть его,
  # если `returnNodes` == true
  # @param {Boolean} returnNodes возвращать ли удалённый узел
  # @throw {Error} если аргументов > 1
  # @throw {RangeError} если список пуст
  # @throw {TypeError} если returnNodes не булево
  # @return {CircularList|Node} `this`|элемент
  erase: (returnNodes = yes) ->
    if arguments.length > 1
      throw new Error "too many arguments"
    listLength = @length
    if listLength is 0
      throw new RangeError "circular list is empty"
    if typeof returnNodes isnt 'boolean'
      throw new TypeError "`returnNodes` must be a boolean"
    n = @_p
    @length--
    if listLength is 1
      @_p = new Node null
      @_p.p = @_p.n = @_p
      if returnNodes
        return n
      return @
    pointer = @_p = n.n
    pointer.p = n.p
    n.p.n = pointer
    n.n = n.p = null
    if returnNodes
      return n
    n = null
    return @

  # Очистить список ото всех значений
  # @throw {TypeError} если переданы аргументы
  # @return {CircularList} `this`
  clear: ->
    if arguments.length isnt 0
      throw new TypeError "clear haven't arguments"
    len = @length
    if len is 0
      return null
    p = @_p
    i = 0
    while i++ < len
      n = p.n
      p.destructor()
      p = n
    @_p = new Node null
    @_p.p = @_p.n = @_p
    @length = 0
    @

  # Удалить список и очистить все линки
  # @return {null}
  destructor: ->
    p = @_p
    len = @length
    i = 0
    while i++ < len # Можно вызывать pop() но так на две строки больше, но яснее
      n = p.n
      p.destructor()
      p = n
    p = null
    @_p = null
    @length = -1
    return null

  # Создать список из массива `array` с указателем на первый элемент массива
  # @param {Array<*>} array массив из которых создаём список
  # @throw {Error} если аргументов не 1
  # @throw {TypeError} если `array` не массив
  # @return {CircularList} circularList
  @fromArray = (array) ->
    l = arguments.length
    if l is 0
      throw new Error "no arguments"
    if l isnt 1
      throw new Error "too much arguments"
    if not (array instanceof Array)
      throw new TypeError "argument is not array"
    list = new CircularList()
    len = array.length
    if len is 0
      return list
    i = 1
    list.length = len
    pointer = list._p
    pointer.v = array[0]
    n = pointer
    while i < len
      n = n.n = new Node array[i], pointer, n
      i++
    pointer.p = n
    list

module.exports = { CircularList }
