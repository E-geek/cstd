{Node} = require './node.coffee'
{Container} = require './container.coffee'

nn = new Node null
nn.n = nn

# Класс очередь. Сущности кладём в конец, а забираем элементы с начала.
class Queue extends Container
  # @property {Node} начало очереди для взятия O(1)
  _f: nn
  # @property {Node} конец очереди для добавления O(1)
  _b: nn
  # @property {number} длина очереди
  length: -1

  # Конструктор очереди просто собирает её, не принимая аргументов
  # @throw {TypeError} если переданы аргументы
  constructor: ->
    if arguments.length isnt 0
      throw new TypeError "Queue constructor haven't arguments"
    @_f = new Node null
    @_b = @_f
    @length = 0

  # Добавление _одного_ элемента `some` в очередь (возвращает очередь)
  # @param {*} some добавляемая в конец сущность
  # @throw {TypeError} если аргумент не один
  # @return {Queue} `this`
  push: (some) ->
    if arguments.length > 1
      throw new TypeError "one push, one element"
    if arguments.length is 0
      throw new TypeError "push without value"
    if @length++ isnt 0
      n = new Node some
      @_b.n = n
      @_b = n
    else
      @_f.v = some
    @

  # Получение и изъятие первого элемента из очереди, не принимает аргументов
  # @throw {Error} если список пуст
  # @throw {TypeError} если переданы аргументы
  # @return {*} значение взятое с самого начала
  pop: ->
    if @length is 0
      throw new Error "queue is empty"
    if arguments.length isnt 0
      throw new TypeError "pop haven't arguments"
    l = @length--
    node = @_f
    some = node.v
    if l isnt 1
      @_f = node.n
      node.destructor()
    else
      node.v = null
    some

  # Добавляет подряд переданные элементы в очередь, принимая только
  # набор аргументов. Массив переданный внутрь будет расценен
  # самостоятельной сущностью.
  # @param {*...} args... аргументы для добавления по очереди
  # @throw {TypeError} если не переданы значения
  # @return {Queue} `this`
  add: (first, list...) ->
    if arguments.length is 0
      throw new TypeError "add without value"
    p = @_b
    if @length is 0
      @_f.v = first
      @length = 1
    else
      p = (p.n = new Node first)
      @length++
    for item in list
      p = p.n = new Node item
    @_b = p
    @length += list.length
    @

  # Очищает очередь ото всех узлов. И не принимает аргументов
  # @throw {TypeError} если переданы аргументы
  # @return {Queue} `this`
  clear: ->
    if arguments.length isnt 0
      throw new TypeError "clear haven't arguments"
    len = @length
    if len is 0
      return null
    p = @_f
    i = 0
    while i++ < len
      n = p.n
      p.destructor()
      p = n
    @_b = @_f = new Node null
    @length = 0
    @

  # Разрушает очередь, очищая её и все ссылки внутри неё
  # @return {null}
  destructor: ->
    p = @_f
    len = @length
    i = 0
    while i++ < len # Можно вызывать pop() но так на две строки больше, но яснее
      n = p.n
      p.destructor()
      p = n
    @_f = null
    @_b = null
    @length = 0
    return null

  # Создаёт очередь с объектами из массива, но ругается если что не так
  # @throw {Error} если аргумент не 1
  # @throw {TypeError} если аргумент не представляет собой массив
  # @return {Queue} новая очередь
  @fromArray = (array) ->
    l = arguments.length
    if l is 0
      throw new Error "no arguments"
    if l isnt 1
      throw new Error "tooo much arguments"
    if not (array instanceof Array)
      throw new TypeError "argument is not array"
    queue = new Queue()
    len = array.length
    if len is 0
      return queue
    i = 1
    queue.length = len
    queue._f.v = array[0]
    n = queue._f
    while i < len
      n = n.n = new Node array[i]
      i++
    queue._b = n
    queue

# Возвращаем очередь
module.exports = { Queue }