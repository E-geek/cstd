###*
 * Самая простая часть:
###

{CSObject} = require './object.coffee'

# Узел. По умолчанию готов к двусвязности
# В `destructor` записан метод для удаления ссылок
class Node extends CSObject
  # @property {*} Хранимое значение
  v: null
  # @property {Node|null} Следущий узел
  n: null
  # @property {Node|null} Предыдущий узел
  p: null

  ###*
    Обязательно передать значение `@v`, помещаемое в узел,
    Далееможно передать следущий элемент `n` и предыдущий `p`
    @overload constructor (v)
      without links
      @param {*} v value for save in node
      @throw {TypeError} if `v` is undefined
    @overload constructor (v, n)
      with next link only
      @param {*} v value for save in node
      @param {Node} n link to next node or null
      @throw {TypeError} if `v` is undefined
      @throw {TypeError} if `n` is not node
    @overload constructor (v, n, p)
      with prev link only
      @param {*} v value for save in node
      @param {null} n no link
      @param {Node} p link to prev node or null
      @throw {TypeError} if `v` is undefined
      @throw {TypeError} if `n` is not null
      @throw {TypeError} if `p` is not node
    @overload constructor (v, n, p)
      with next and prev link
      @param {*} v value for save in node
      @param {Node} n link to next node or null
      @param {Node} p link to prev node or null
      @throw {TypeError} if `v` is undefined
      @throw {TypeError} if `n` is not node and not null
      @throw {TypeError} if `p` is not node and not null
  ###
  constructor: (v, n, p) ->
    if typeof v is 'undefined'
      throw new TypeError "Incorrect situation: value of node not set"
    @v = v
    if n?
      unless n instanceof Node
        throw new TypeError "next node can be Node or NULL"
      @n = n
    if p?
      unless p instanceof Node
        throw new TypeError "prev node can be Node or NULL"
      @p = p


  # Удаление атома, отвязывание от списка, значение сохраняется
  # @return {Node} this
  remove: ->
    if @n isnt null
      @n.p = @p
    if @p isnt null
      @p.n = @n
    @p = null
    @n = null
    return @

  # Очистка атома, в std все классы обязаны иметь destructor
  # @return {null}
  destructor: ->
    @n = null
    @p = null
    @v = null
    return null

# Лакальное правлио: экспортируется всегда объект.
# Название класса одноимённо со свойством
module.exports = { Node }