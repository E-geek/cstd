# Класс от которого можно наследовать ошибки и иметь свойства,
# как в обычном `Error`.
class CSError extends Error
  # Регулярка для очистки стектрейса,
  # если это строка, от первой строчки
  __stackRegExpr = /^.+?\n/

  # Очистка стектрейса в виде строки
  # от двух первых строчек
  __doubleExclude = /^(.+?\n){2}/

  # @property {String} название ошибки
  name: 'CSError'

  # @property {Array<String>} стопка вызовов
  stack: []

  # Создаёт ошибку (можно её и не отбрасывать, а передавать, например)
  # @param {String|Number|undefined} message текст сообщения об ошибке
  # @throw {TypeError} если `message` ненадлежащего формата
  # @throw {TypeError} если тип стека Error очень неподдерживаемого формата
  constructor: (message) ->
    switch typeof message
      when 'string'
        @message = message
      when 'undefined'
        @message = ''
      when 'number'
        @message = message.toString()
      else
        throw new TypeError "Message must be string, or number, or can be unset"
    super
    stack = (new Error()).stack
    switch typeof stack
      when 'string'
        if @constructor is CSError
          @stack = stack
          .replace __stackRegExpr, ''
          .split '\n'
        else
          @stack = stack
          .replace __doubleExclude, ''
          .split '\n'
      when 'object'
        if typeof stack.slice isnt 'function'
          stack = [stack...]
        if @constructor is CSError
          @stack = stack.slice 1
        else
          @stack = stack.slice 2
      when 'undefined' then @stack = []
      else throw new TypeError "Unexpected type of stack trace"

module.exports = { CSError }

