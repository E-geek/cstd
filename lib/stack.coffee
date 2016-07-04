{Node} = require './node.coffee'
{Container} = require './container.coffee'

nn = new Node null
nn.n = nn

# Класс стопка. Кладём элемент последним, а забираем первым.
class Stack extends Container
  # @property {Node} верх стопки для взятия O(1)
  _f: nn

  # Конструктор стопки просто собирает её, не принимая аргументов
  # @throw {TypeError} если переданы аргументы
  constructor: ->
    if arguments.length isnt 0
      throw new TypeError "Stack constructor haven't arguments"
    @_f = new Node null
    @length = 0

  # Добавление _одного_ элемента `some` в стопку (возвращает стопку)
  # @param {*} some добавляемая в конец сущность
  # @throw {TypeError} если аргумент не один
  # @return {Stack} `this`
  push: (some) ->
    if arguments.length > 1
      throw new TypeError "one push, one element"
    if arguments.length is 0
      throw new TypeError "push without value"
    if @length++ isnt 0
      @_f = new Node some, @_f, null
    else
      @_f.v = some
    @

  # Получение и изъятие последнего элемента из стопки, не принимает аргументов
  # @throw {Error} если список пуст
  # @throw {TypeError} если переданы аргументы
  # @return {*} значение взятое с самого начала
  pop: ->
    if @length is 0
      throw new Error "stack is empty"
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

  # Добавляет подряд переданные элементы в стопку, принимая только
  # набор аргументов. Массив переданный внутрь будет расценен
  # самостоятельной сущностью.
  # @param {*...} args... аргументы для добавления в стопку
  # @throw {TypeError} если не переданы значения
  # @return {Stack} `this`
  add: (first, list...) ->
    if arguments.length is 0
      throw new TypeError "add without value"
    p = @_f
    if @length is 0
      @_f.v = first
      @length = 1
    else
      p = new Node first, p, null
      @length++
    for item in list
      p = new Node item, p, null
    @_f = p
    @length += list.length
    @

  # Очищает стопку ото всех узлов. И не принимает аргументов
  # @throw {TypeError} если переданы аргументы
  # @return {Stack} `this`
  clear: ->
    if arguments.length isnt 0
      throw new TypeError "clear haven't arguments"
    len = @length
    if len is 0
      return null
    t = @_f
    i = 0
    while i++ < len
      p = t.n
      t.destructor()
      t = p
    @_f = new Node null
    @length = 0
    @

  # Получает все значения в стопке начиная с первого (нижнего)
  # @override Container::values
  # @throw {TypeError} если переданы аргументы
  # @return {Array<*>} значения
  values: ->
    if arguments.length > 0
      throw new TypeError "values haven't arguments"
    len = @length
    res = new Array(len)
    point = @_f
    i = len - 1
    while i >= 0
      res[i--] = point.v
      point = point.n
    point = null
    res

  # Разрушает список, очищая его и все ссылки внутри него
  # @return {null}
  destructor: ->
    len = @length
    if len is 0
      @_f.destructor()
    t = @_f
    i = 0
    while i++ < len
      p = t.n
      t.destructor()
      t = p
    @_f = null
    @length = -1
    return null

  # Создаёт стопку с объектами из массива, но ругается если что не так
  # @throw {Error} если аргумент не 1
  # @throw {TypeError} если аргумент не представляет собой массив
  # @return {Stack} новый список
  @fromArray = (array) ->
    l = arguments.length
    if l is 0
      throw new Error "no arguments"
    if l isnt 1
      throw new Error "tooo much arguments"
    if not (array instanceof Array)
      throw new TypeError "argument is not array"
    stack = new Stack()
    len = array.length
    if len is 0
      return stack
    i = 1
    stack.length = len
    t = stack._f
    t.v = array[0]
    while i < len
      t = new Node array[i], t, null
      i++
    stack._f = t
    stack

# Возвращаем список
module.exports = { Stack }