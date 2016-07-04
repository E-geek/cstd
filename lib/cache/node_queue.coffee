{Node} = require '../node.coffee'
{CSObject} = require '../object.coffee'

nn = new Node null
nn.n = nn

# fast-forced class of Queue for caches
# В основном для внутреннего использования: нет проверок на аргументы
# и есть функции смещения узлов к началу или к концу, при чём
# причастность узлов не проверяется.
# Так же начало и конец очереди публичные свойства
class NodeQueue extends CSObject
  # @property {Node} верх стопки для взятия O(1)
  front: nn
  # @property {Node} конец очереди для добавления O(1)
  back: nn
  # @property {number} длина очереди
  length: 0

  # Конструктор очереди просто собирает её, не принимая аргументов
  # Работает без проверок
  constructor: ->
    @front = new Node null
    @back = @front

  # Добавление _одного_ элемента `some` в очередь (возвращает очередь).
  # Работает без проверок
  # @param {*} some добавляемая в конец сущность
  # @return {NodeQueue} `this`
  push: (some) ->
    if @length++ isnt 0
      b = @back
      @back = (b.n = new Node some, null, b)
    else
      @front.v = some
    @

  # Получение и изъятие первого элемента из очереди, не принимает аргументов
  # @return {*} значение взятое с самого начала
  pop: ->
    l = @length--
    node = @front
    some = node.v
    if l isnt 1
      @front = node.n
      node.destructor()
      @front.p = null
    else
      node.v = null
    some

  # Перемещает элемент к началу очереди, если кто-то, допустим, заждался
  # @param {Node} node узел из очереди. ,
  #   Если он не из очереди, то поведение не предопределено
  # @return {NodeQueue} `this`
  rise: (node) ->
    if @length < 2
      return @
    if node is @front
      return @
    if node is @back
      back = node.p
      back.n = null
      @back = back
      if back.p is null
        back.p = node
    else
      back = node.p
      next = node.n
      back.n = next
      next.p = back
    node.p = null
    @front.p = node
    node.n = @front
    @front = node
    @

  # Перемещает элемент к концу очереди, если кто-то, допустим,
  # хорошо держится
  # @param {Node} node узел из очереди. ,
  #   Если он не из очереди, то поведение не предопределено
  # @return {NodeQueue} `this`
  drop: (node) ->
    if @length < 2
      return @
    if node is @back
      return @
    if node is @front
      next = node.n
      next.p = null
      @front = next
      if next.n is null
        next.n = node
    else
      back = node.p
      next = node.n
      back.n = next
      next.p = back
    node.n = null
    @back.n = node
    node.p = @back
    @back = node
    @

  # Отвязывает узел от очереди грамотно, не уничтожая сам узел,
  # а только очищая ссылки на соседние узлы
  # @param {Node} node узел из списка, который удаляем
  # @return {NodeQueue} `this`
  remove: (node) ->
    if @length is 1
      @length = 0
      @back = @front = new Node null
      return @
    @length--
    if node is @back
      back = node.p
      back.n = null
      @back = back
    else if node is @front
      next = node.n
      next.p = null
      @front = next
    else
      back = node.p
      next = node.n
      back.n = next
      next.p = back
    node.n = null
    node.p = null
    @

  # Очищает очередь ото всех узлов. И не принимает аргументов
  # @return {NodeQueue} `this`
  clear: ->
    len = @length
    if len is 0
      return null
    p = @front
    i = 0
    while i++ < len
      n = p.n
      p.destructor()
      p = n
    @back = @front = new Node null
    @length = 0
    @

  # Разрушает очередь, очищая её и все ссылки внутри неё
  # @return {null}
  destructor: ->
    len = @length
    @length = -1
    if len is 0
      @back = @front = null
      return null
    p = @front
    i = 0
    while i++ < len
      n = p.n
      p.destructor()
      p = n
    @back = @front = null
    null

# Возвращаем упрощённую очередь узлов
module.exports = { NodeQueue }