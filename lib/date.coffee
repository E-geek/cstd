# Создаёт класс, не отличающийся от `Date`, но который можно свободно \
# наследовать и расширять. Сам по себе Date не является расширяемым
# (напоминает *finally*).
{CSObject} = require './object.coffee'

# Класс, который накладывается поверх `Date` повторяя его методы
# и экземпляры которого будут повторять методы экземпляров `Date`
class CSDate extends Date

  # @property {Date} хранимое оригинальное значение для работы с ним
  # @private
  __base__: null

  ###
  Конструктор создаёт экземпляр идиентично `Date` по одному из
  четырёх путей:
    1. new CSDate();
    2. new CSDate(value);
    3. new CSDate(dateString);
    4. new CSDate(year, month[, day[, hour[, minute[, second[, ms]]]]]);
  @overload constructor ()
    без аргументов, создаётся объект, хранящий значение времени создания
  @overload constructor (date)
    создаёт объект сметкойвремени, как у `date`
    @param {CSDate|Date} date
    @throw {TypeError} если `date` не дата (или потомк даты) и не число
  @overload constructor (number)
    создаёт объект, у которого количество миллисекунд равно аргументу
    @param {Number} milliseconds
    @throw {TypeError} если `date` не дата (или потомк даты) и не число
  @overload constructor (year, month, day, hour, minute, second, ms)
    создаёт объект на основе переданных соответствующих значений
    @param {Number} year год в полном формате
    @param {Number} mount месяц, [0..11]
    @param {Number} day день, начиная с 1. [default = 1]
    @param {Number} hour час [default = 0]
    @param {Number} minute минута [default = 0]
    @param {Number} second секунда [default = 0]
    @param {Number} ms милисекунда [default = 0]
    @throw {TypeError} родителя если что-то не так
  ###
  constructor: (year, month= 0, day= 1, hour= 0, minute= 0, second= 0, ms= 0) ->
    return new CSDate() unless @ instanceof CSDate
    switch arguments.length
      when 0 then @__base__ = new Date()
      when 1
        if typeof year isnt 'number' and not (year instanceof Date)
          throw new TypeError 'first param is not a Number and not a Date'
        @__base__ = new Date(year)
      else @__base__ = new Date(year, month, day, hour, minute, second, ms)

  # Удаление объекта для очистки
  # @return {null}
  destructor: ->
    @__base__ = null
    null

  # Наследует `Date.UTC` (преобразует набор аргументов год, месяц... в
  # количество миллисекунд с эпохи юникс в 0-ом часовом поясе)
  # @param {Number...} args... то же, что и в 4-ом варианте new CSDate()
  # @return {Number} миллисекунды в нулевом часовом поясе
  @UTC: (args...) ->
    return Date.UTC args...

  # Наследует `Date.parse` (разбирает строку и возвращает количество мс)
  # @param {String} dateString разбираемая строка
  # @return {Number} миллисекунды
  @parse: (dateString) ->
    return Date.parse dateString

  # Наследует `Date.now` (получает количество мс с начала эпохи
  # юникс на момент вызова)
  # @return {Number} миллисекунды
  @now: ->
    return Date.now()

  # Наследует `Date::getDate()`
  # @return {Number} число месяца
  getDate: (args...) ->
    @__base__.getDate args...

  # Наследует `Date::setDate(date)`
  # @param {Number} date день месяца
  # @return {Number} милиссекунды новой даты
  setDate: (args...) ->
    @__base__.setDate args...

  # Наследует `Date::getDay()`
  # @return {Number} днь недели
  getDay: (args...) ->
    @__base__.getDay args...

  # Наследует `Date::getFullYear()`
  # @return {Number} год от рождения Христа
  getFullYear: (args...) ->
    @__base__.getFullYear args...

  # Наследует `Date::setFullYear()`
  # @param {Number} fullYear год
  # @return {Number} милиссекунды новой даты
  setFullYear: (args...) ->
    @__base__.setFullYear args...

  # Наследует `Date::getHours()`
  # @return {Number} hours час
  getHours: (args...) ->
    @__base__.getHours args...

  # Наследует `Date::setHours(hour)`
  # @param {Number} hour час
  # @return {Number} милиссекунды новой даты
  setHours: (args...) ->
    @__base__.setHours args...

  # Наследует `Date::()getMilliseconds`
  # @return {Number}
  getMilliseconds: (args...) ->
    @__base__.getMilliseconds args...

  # Наследует `Date::setMilliseconds(ms)`
  # @param {Number} ms милисекунда
  # @return {Number} милиссекунды новой даты
  setMilliseconds: (args...) ->
    @__base__.setMilliseconds args...

  # Наследует `Date::getMinutes()`
  # @return {Number} минуты
  getMinutes: (args...) ->
    @__base__.getMinutes args...

  # Наследует `Date::setMinutes(minute)`
  # @param {Number} minute минута
  # @return {Number} милиссекунды новой даты
  setMinutes: (args...) ->
    @__base__.setMinutes args...

  # Наследует `Date::getMonth()`
  # @return {Number} номер месяца (с 0)
  getMonth: (args...) ->
    @__base__.getMonth args...

  # Наследует `Date::setMonth(month)`
  # @param {Number} month месяц
  # @return {Number} милиссекунды новой даты
  setMonth: (args...) ->
    @__base__.setMonth args...

  # Наследует `Date::getSeconds()`
  # @return {Number} секунды
  getSeconds: (args...) ->
    @__base__.getSeconds args...

  # Наследует `Date::setSeconds(second)`
  # @param {Number} second секунда
  # @return {Number} милиссекунды новой даты
  setSeconds: (args...) ->
    @__base__.setSeconds args...

  # Наследует `Date::getTime()`
  # @return {Number} миллисекунды с эпохи юникс
  getTime: (args...) ->
    @__base__.getTime args...

  # Наследует `Date::setTime(ms)`
  # @param {Number} ms миллисекунда с начала эпохи юникс
  # @return {Number} милиссекунды новой даты
  setTime: (args...) ->
    @__base__.setTime args...

  # Наследует `Date::getYear()`. Устарел
  # @return {Number} две цифры года
  # @deprecated
  getYear: (args...) ->
    @__base__.getYear args...

  # Наследует `Date::setYear(year)`. Устарел
  # @param {Number} year год
  # @return {Number} милиссекунды новой даты
  # @deprecated
  setYear: (args...) ->
    @__base__.setYear args...

  # Наследует `Date::getTimezoneOffset()`
  # @return {Number} смещение от гринвича в минутах
  getTimezoneOffset: (args...) ->
    @__base__.getTimezoneOffset args...

  # Наследует `Date::getUTCDate()`
  # @return {Number} день месяца по гринвичу
  getUTCDate: (args...) ->
    @__base__.getUTCDate args...

  # Наследует `Date::setUTCDate(date)`
  # @param {Number} date день месяца по гринвичу
  # @return {Number} милиссекунды новой даты
  setUTCDate: (args...) ->
    @__base__.setUTCDate args...

  # Наследует `Date::getUTCDay()`
  # @return {Number} день недели по гринвичу
  getUTCDay: (args...) ->
    @__base__.getUTCDay args...

  # Наследует `Date::getUTCFullYear()`
  # @return {Number} год по гринвичу
  getUTCFullYear: (args...) ->
    @__base__.getUTCFullYear args...

  # Наследует `Date::setUTCFullYear(fullYear)`
  # @param {Number} fullYear год по гринвичу
  # @return {Number} милиссекунды новой даты
  setUTCFullYear: (args...) ->
    @__base__.setUTCFullYear args...

  # Наследует `Date::getUTCHours()`
  # @return {Number} час по гринвичу
  getUTCHours: (args...) ->
    @__base__.getUTCHours args...

  # Наследует `Date::setUTCHours(hour)`
  # @param {Number} hour час по гринвичу
  # @return {Number} милиссекунды новой даты
  setUTCHours: (args...) ->
    @__base__.setUTCHours args...

  # Наследует `Date::getUTCMilliseconds()`
  # @return {Number} миллисекунды по гринвичу (будто они могут отличаться)
  getUTCMilliseconds: (args...) ->
    @__base__.getUTCMilliseconds args...

  # Наследует `Date::setUTCMilliseconds(ms)`
  # @param {Number} ms миллисекунды по гринвичу
  # @return {Number} милиссекунды новой даты
  setUTCMilliseconds: (args...) ->
    @__base__.setUTCMilliseconds args...

  # Наследует `Date::getUTCMinutes()`
  # @return {Number} минуты по гринвичу
  getUTCMinutes: (args...) ->
    @__base__.getUTCMinutes args...

  # Наследует `Date::setUTCMinutes(minute)`
  # @param {Number} minute минуты по гринвичу
  # @return {Number} милиссекунды новой даты
  setUTCMinutes: (args...) ->
    @__base__.setUTCMinutes args...

  # Наследует `Date::getUTCMonth()`
  # @return {Number} номер месяца по гринвичу (начиная с 0)
  getUTCMonth: (args...) ->
    @__base__.getUTCMonth args...

  # Наследует `Date::setUTCMonth(month)`
  # @param {Number} month номер месяца по гринвичу (начиная с 0)
  # @return {Number} милиссекунды новой даты
  setUTCMonth: (args...) ->
    @__base__.setUTCMonth args...

  # Наследует `Date::getUTCSeconds()`
  # @return {Number} секунды по гринвичу (ещё раз ха!)
  getUTCSeconds: (args...) ->
    @__base__.getUTCSeconds args...

  # Наследует `Date::setUTCSeconds(second)`
  # @param {Number} second секунды по гринвичу (ещё раз ха!)
  # @return {Number} милиссекунды новой даты
  setUTCSeconds: (args...) ->
    @__base__.setUTCSeconds args...

  # Наследует `Date::toDateString()`
  # @return {String} {День недели} {месяц} {число} {год}
  toDateString: (args...) ->
    @__base__.toDateString args...

  # Наследует `Date::toGMTString()`
  # @return {String} WWW, DD MMM YYYY HH:mm:SS GMT
  toGMTString: (args...) ->
    @__base__.toGMTString args...

  # Наследует `Date::toISOString()`
  # @return {String} YYYY-MM-DDTHH:mm:SS.sssZ
  toISOString: (args...) ->
    @__base__.toISOString args...

  # Наследует `Date::toJSON()`
  # @return {String} YYYY-MM-DDTHH:mm:SS.sssZ
  toJSON: (args...) ->
    @__base__.toJSON args...

  # Наследует `Date::toJSON()`
  # @return {String} WWW MMM DD YYYY HH:mm:SS GMTppppp (CCC)
  toString: (args...) ->
    @__base__.toString args...

  # Наследует `Date::toTimeString()`
  # @return {String} HH:mm:SS GMTppppp (CCC)
  toTimeString: (args...) ->
    @__base__.toTimeString args...

  # Наследует `Date::toUTCString()`
  # @return {String} WWW, DD MMM YYYY HH:mm:SS GMT
  toUTCString: (args...) ->
    @__base__.toUTCString args...

  # Наследует `Date::valueOf()`
  # @return {Number} миллисекунды с начала эпохи юникс
  valueOf: (args...) ->
    @__base__.valueOf args...

  # Наследует `Date::toLocaleDateString()`
  # @return {String} WWWW, MMMM DD, YYYY
  toLocaleDateString: (args...) ->
    @__base__.toLocaleDateString args...

  # Наследует `Date::toLocaleString()`
  # @return {String} WWW MMM DD YYYY HH:mm:SS GMTppppp (CCC)
  toLocaleString: (args...) ->
    @__base__.toLocaleString args...

  # Наследует `Date::toLocaleTimeString()`
  # @return {String} HH:mm:SS
  toLocaleTimeString: (args...) ->
    @__base__.toLocaleTimeString args...


module.exports = { CSDate }