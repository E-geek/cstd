# Тут создаётся список на основе узлов
{Node} = require './node.coffee'
{CSObject} = require './object.coffee'

nn = new Node null
nn.n = nn

# Список на основе узлов `Node`. Есть внутренний указатель,
# который перемещается методами `#next()`, `#prev()`,
# `#begin()`, `#end()` и значение получается всегда через
# метод `#get()`.
#
# В результате вставок указатель всегда
# указывает на тот же самый элемент, а индекс указателя `#index`
# даптивно подстраивается. То же самое по возможности и при
# изъятии узла, но если изымается элемент, на котором стоит указатель,
# тогда он смещается к ближайшему узлу в сторону начала, а если
# это не возможно, то ближайшему узлу в сторону конца.
class List extends CSObject
  # @property {Node} начало очереди для взятия O(1)
  _f: nn
  # @property {Node} конец очереди для добавления O(1)
  _b: nn
  # @property {Node} Указатель на текущий элемент
  _p: nn
  # @property {Number} Индекс текущего указателя,
  # если -1, то значит список пуст
  index: -1
  # @property {Number} длина очереди
  # @read-only
  length: 0

  # Создаёт пустой список, устанавливает значения
  # @throw {TypeError} при наличии аргументов
  constructor: ->
    if arguments.length isnt 0
      throw new TypeError "List constructor haven't arguments"
    @_f = new Node null
    @_p = @_b = @_f
    @index = -1

  # Добавление _одного_ элемента в список в конец
  # @param {*} some сущность для добавления в конец
  # @throw {TypeError} если сущности нет или она не одна
  # @return {List} `this`
  pushBack: (some) ->
    if arguments.length > 1
      throw new TypeError "one pushBack, one element"
    if arguments.length is 0
      throw new TypeError "pushBack without value"
    if @length++ isnt 0
      b = @_b
      @_b = (b.n = new Node some, null, b)
    else
      @_f.v = some
      @index = 0
      @_p = @_f
    @

  # Добавление одной сущности `some` в начало списка.
  # При этом указатль остаётся на том же элементе, где и был,
  # а в случае пустого индекса указывает на новый узел.
  # Индекс же следит за указателем всегда.
  # @param {*} some сущность для вставки
  # @throw {TypeError} если сущности нет или она не одна
  # @return {List} `this`
  pushFront: (some) ->
    if arguments.length > 1
      throw new TypeError "one pushFront, one element"
    if arguments.length is 0
      throw new TypeError "pushFront without value"
    if @length++ isnt 0
      f = @_f
      @_f = (f.p = new Node some, f)
      @index++
    else
      @_f.v = some
      @index = 0
      @_p = @_f
    @

  # Взятие первого элемента из очереди. Указатель не смещается,
  # если не удалён элемент указателя. Если же удалён, то он
  # переходит на предыдущий элемент.
  # @throw {Error} если список пуст
  # @throw {TypeError} если переданы аргументы
  # @return {*} some значение первого узла
  popFront: ->
    if @length is 0
      throw new Error "list is empty"
    if arguments.length isnt 0
      throw new TypeError "popFront haven't arguments"
    l = @length--
    node = @_f
    some = node.v
    if l isnt 1
      if @_p is @_f
        @_p = @_f = node.n
      else
        @_f = node.n
        @index--
      node.destructor()
      @_f.p = null
    else
      @index = -1
      @_p = node
      node.v = null
    some

  # Изымает и возвращает последнее значение.
  # @throw {Error} если список пуст
  # @throw {TypeError} если переданы аргументы
  # @return {*} some значение последнего узла
  popBack: ->
    if @length is 0
      throw new Error "list is empty"
    if arguments.length isnt 0
      throw new TypeError "popBack haven't arguments"
    l = @length--
    node = @_b
    some = node.v
    if l isnt 1
      if @_p is @_b
        @_p = @_b = node.p
        @index--
      else
        @_b = node.p
      node.destructor()
      @_b.n = null
    else
      @index = -1
      @_p = node
      node.v = null
    some

  # Присоединяет сущность `some` после указателя.
  # @param {*} some вставляемое значение
  # @throw {TypeError} если нет сущности или она не одна
  # @return {List} `this`
  append: (some) ->
    if arguments.length > 1
      throw new TypeError "more than one append"
    if arguments.length is 0
      throw new TypeError "append nothing"
    if @length++ isnt 0
      n = @_p.n
      if n isnt null
        n.p = @_p.n = new Node some, n, @_p
      else
        @_b = @_p.n = new Node some, null, @_p
    else
      @index = 0
      @_p = @_b = @_f
      @_f.v = some
    @

  # Присоединяет сущность `some` перед указателем.
  # @param {*} some вставляемое значение
  # @throw {TypeError} если нет сущности или она не одна
  # @return {List} `this`
  prepend: (some) ->
    if arguments.length > 1
      throw new TypeError "more than one prepend"
    if arguments.length is 0
      throw new TypeError "prepend nothing"
    if @length++ isnt 0
      p = @_p.p
      if p isnt null
        p.n = @_p.p = new Node some, @_p, p
      else
        @_f = @_p.p = new Node some, @_p, null
      @index++
    else
      @index = 0
      @_p = @_b = @_f
      @_f.v = some
    @

  # Присоединяет сущности `some` в самый конец списка
  # @param {*...} some... добавляемые значения подряд через зяпятую
  # @throw {TypeError} если нет ни одной сущности
  # @return {List} `this`
  add: (first, list...) ->
    if arguments.length is 0
      throw new TypeError "add without value"
    p = @_b
    if @length is 0
      @_f.v = first
      @length = 1
      @index = 0
    else
      p = (p.n = new Node first, null, p)
      @length++
    for item in list
      p = p.n = new Node item, null, p
    @_b = p
    @length += list.length
    @

  # Перемещает указатель на `step` шагов относительно текущего положения.
  # Если `step` < 0 тогда двигаемся к началу, а иначе к концу списка.
  #
  # *Если шаги выходят за рамки, то возвращается null.*
  # @param {Number} step на сколько шагов идём и в какую сторону
  # @throw {Error} если не указан `step` или аргументов больше 1
  # @throw {TypeError} если шаги указаны не числом
  # @return {List|null} `this` или признак выхода за границы
  go: (step) ->
    if arguments.length is 0
      throw new Error "`step` is required"
    if typeof step isnt 'number'
      throw new TypeError "`step` must be a Number"
    if arguments.length > 1
      throw new Error "too many arguments"
    unless 0 <= @index + step <= @length - 1
      return null
    return @ if step is 0
    currentIndex = 0
    currentPointer = @_p
    @index += step
    if step > 0
      while currentIndex++ < step
        currentPointer = currentPointer.n
    else
      while currentIndex-- > step
        currentPointer = currentPointer.p
    @_p = currentPointer
    @

  # То же, что и `#go(1)`
  # @throw {Error} если переданы аргументы
  # @return {List|null} `this` или признак, что указатель уже в конце
  next: ->
    if arguments.length > 0
      throw new Error "next haven't arguments"
    if @index is @length - 1
      return null
    @_p = @_p.n
    @index++
    @

  # То же, что и `#go(-1)`
  # @throw {Error} если переданы аргументы
  # @return {List|null} `this` или признак, что указатель уже в начале
  prev: ->
    if arguments.length > 0
      throw new Error "prev haven't arguments"
    if @index <= 0
      return null
    @_p = @_p.p
    @index--
    @

  # Перемещает указатель на самый _первый_ узел
  # @throw {Error} если переданы аргументы
  # @return {List|null} `this` или признак пустого списка
  begin: ->
    if arguments.length > 0
      throw new Error "begin haven't arguments"
    return null if @length is 0
    @_p = @_f
    @index = 0
    @

  # Перемещает указатель на самый _последний_ узел
  # @throw {Error} если переданы аргументы
  # @return {List|null} `this` или признак пустого списка
  end: ->
    if arguments.length > 0
      throw new Error "end haven't arguments"
    return null if @length is 0
    @_p = @_b
    @index = @length - 1
    @

  # Возвращает значение первого узла без смещения указателя
  # и без изменений списка.
  # @throw {Error} если список пуст или переданы аругменты
  # @return {*} значение первого узла
  getFront: ->
    if arguments.length > 0
      throw new Error "getFront haven't arguments"
    if @length is 0
      throw new Error "list is empty"
    @_f.v

  # Возвращает значение последнего узла без смещения указателя
  # и без изменения списка.
  # @throw {Error} если список пуст или переданы аругменты
  # @return {*} значение последнего узла
  getBack: ->
    if arguments.length > 0
      throw new Error "getBack haven't arguments"
    if @length is 0
      throw new Error "list is empty"
    @_b.v

  # Возвращает значение узла "под" указателем, не меняя список
  # @throw {Error} если список пуст или переданы аругменты
  # @return {*} значение узла указателя
  get: ->
    if arguments.length > 0
      throw new Error "get haven't arguments"
    if @length is 0
      throw new Error "list is empty"
    @_p.v

  # Возвразает сам *узел* указателя
  # @throw {Error} если список пуст или переданы аругменты
  # @return {*} узел указателя
  currentNode: ->
    if arguments.length > 0
      throw new Error "currentNode haven't arguments"
    if @length is 0
      throw new Error "list is empty"
    @_p

  # Переставляет местами _значения_ узлов
  # (след./пред. относительно указателя). Если `rev` не равен `true`,
  # томеняемся со следующим узлом от указателя, иначе -- с прудыдущим.
  # @throw {Error} если в списке менее 2-ух элементов
  # @throw {Error} если пытаемся махнуться со слледующим в конце
  # @throw {Error} если пытаемся махнуться с предыдущим в начале
  # @return {List} `this`
  swap: (rev) ->
    if @length < 2
      throw new Error "for swap require 2 nodes minimum"
    rev = no if rev isnt yes
    unless rev
      if @_p.n is null
        throw new Error "it is last element, swap impossible"
      v = @_p.n.v
      @_p.n.v = @_p.v
      @_p.v = v
      v = null
      return @
    if @index is 0
      throw new Error "it is first element, reverse swap impossible"
    v = @_p.p.v
    @_p.p.v = @_p.v
    @_p.v = v
    v = null
    return @

  # Устанавливает значение указателя на `some`
  # @throw {Error} если список пуст или аргументов не 1
  # @return {List} `this`
  set: (some) ->
    if (l = arguments.length) is 0
      throw new Error "can't set nothing to value"
    if @length is 0
      throw new Error "can't set to empty list"
    if l > 1
      throw new Error "too many arguments"
    @_p.v = some
    @

  # Удаляет элемент или несколько из списка, начиная
  # с позиции `start` и до позиции `end` (от начала),
  # если `returnNodes` равна `true`, то удалённые узлы
  # вернутся в виде массива из метода.
  # Если `end` не установлено, то удаляется только элемент
  # с индексом `start`
  # @overload erase(start, end, returnNodes)
  #   Удаление диапазона от `start` до `end` включительно
  #   @param {Number} start начальная позиция для удаления
  #   @param {Number} end последняя позиция
  #   @param {Boolean} returnNodes возвращать ли узлы [default = no]
  #   @throw {RangeError} если `start` < 0 или `end` >= `#length`
  #   @throw {RangeError} если `start` > `end`
  #   @throw {TypeError} если аргументов многовато
  #   @throw {TypeError} если типы аргументов не правильные
  #   @return {List|Array<Node>} `this` или массив удалённых узлов,
  #     если `returnNodes` равен `yes`
  # @overload erase(start, returnNodes)
  #   Удаление диапазона от `start` до `end` включительно
  #   @param {Number} start начальная позиция для удаления
  #   @param {Boolean} returnNodes возвращать ли узлы [default = no]
  #   @throw {RangeError} если `start` < 0
  #   @throw {TypeError} если аргументов многовато
  #   @throw {TypeError} если типы аргументов не правильные
  #   @return {List|Array<Node>} `this` или массив удалённых узлов,
  #     если `returnNodes` равен `yes`
  erase: (start, end, returnNodes) ->
    l = arguments.length
    listLength = @length
    dual = no
    switch l
      when 0
        start = @index
      when 1
        if typeof start is 'boolean'
          start = @index
          returnNodes = start
      when 2
        if typeof end is 'boolean'
          returnNodes = end
          end = start
        else
          dual = yes
          returnNodes = yes
      when 3
        dual = yes
    returnNodes ?= yes

    if typeof start isnt 'number' and typeof start isnt 'boolean'
      throw new TypeError "`start` must be a number or boolean"
    if l is 2 and typeof end isnt 'number' and typeof start isnt 'boolean'
      throw new TypeError "`end` must be a number or boolean"
    if l is 3
      if typeof end isnt 'number'
        throw new TypeError "`end` must be a number"
      if typeof returnNodes isnt 'boolean'
        throw new TypeError "`returnNodes` must be a boolean"
    if l > 3
      throw new Error "too many arguments"
    if listLength is 0
      throw new RangeError "list is empty"
    if start < 0
      throw new RangeError "`start` less than 0"
    if start >= listLength
      throw new RangeError "`start` more than last index"

    if typeof end is 'number'
      if end < 1
        end = listLength + end - 1
      if end < start
        throw new RangeError "`end` less than index of `start`"
      if end >= listLength
        throw new RangeError "`end` more than last index"
    else

    i = @index
    @length-- unless dual
    if start is i # если на том. на котором стоим,то
      n = @_p
      if i > 0 # при возможности сдивгаемся назад
        @index--
        @_p = n.p
        n.p.n = n.n # отвязываем
        if i < listLength - 1 # если i не последний
          n.n.p = n.p # выставляем следущему элементу указатель на пред.
        else
          @_b = @_p # иначе переустанавливаем оконечный указатель
      else if listLength > 1 # если бежать некуда, прорываемся
        p = @_p = @_f = n.n
        p.p = null
      else
        @index--
    else # здусь мы ищем ближайшее расстояние до искомого индекса
      @index-- if start < i
      dp = Math.abs start - i
      ds = start
      de = listLength - start - 1
      if dp <= ds and dp <= de # если ближе всех к поинтеру
        d = dp # расстояние (количество движений в сторону)
        n = @_p
        if start > i # нужно направление
          while d-- isnt 0
            n = n.n
        else
          while d-- isnt 0
            n = n.p
      else if ds <= dp and ds <= de # к началу
        d = start
        n = @_f
        while d-- isnt 0
          n = n.n
      else # к концу
        d = listLength - start - 1
        n = @_b
        while d-- isnt 0
          n = n.p

    if dual
      dp = end - start + 1
      @length -= dp
      res = new Array(dp)
      k = 1
      res[0] = n
      e = n
      position = start
      while position++ < end
        e = e.n
        res[k++] = e
      if start <= i <= end # ?[start]..[i]..[end]?
        i = start - 1
        if i < 0 # [start]..[i]..[end]?
          if end < listLength - 1 # [start]..[i]..[end]..
            i = start
            @_p = e.n
          else # [start]..[i]..[end]
            @_f = null
        else # ..[start]..[i]..[end]?
          @_p = n.p
        @index = i
      else if i > end
        @index -= dp - 1
    else
      e = n

    if n.p?
      n.p.n = e.n
    else
      @_f = e.n
    if e.n?
      e.n.p = n.p
    else
      @_b = n.p

    if @_f is null
      @_f = @_b = @_p = new Node null
    n.n = n.p = null

    if returnNodes
      if dual
        i = res.length
        while i-- > 0
          res[i].p = res[i].n = null
        return res
      return n
    @

  # Очистка всего списка. Если список пуст уже, то вернётся `null`
  # @throw {TypeError} если переданы аргументы
  # @return {List|null} `this` или признак пустого списка
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
    @_p = @_b = @_f = new Node null
    @length = 0
    @index = -1
    @

  # Удаляет все ссылки и очищает список, разрушая все узлы
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

  # Создаёт список на основе массива с указателем на первом элементе
  # @param {Array<*>} array массив сущностей
  # @throw {Error} если аргументов нет или больше одного
  # @throw {TypeError} если `array` не массив
  # @return {List}
  @fromArray = (array) ->
    l = arguments.length
    if l is 0
      throw new Error "no arguments"
    if l isnt 1
      throw new Error "too much arguments"
    if not (array instanceof Array)
      throw new TypeError "argument is not array"
    list = new List()
    len = array.length
    if len is 0
      return list
    i = 1
    list.length = len
    list._f.v = array[0]
    n = list._f
    while i < len
      n = n.n = new Node array[i], null, n
      i++
    list._b = n
    list.index = 0
    list


module.exports = { List }
