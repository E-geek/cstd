# File of a base class for all subclasses

# method for create abstract class
# @example
#   NewClass = abstract class NewClass
#
# @param  {*} ctor any object for convert to abstract
# @return  {ctor} from input
abstract = (ctor) ->
  Object.defineProperty ctor, 'isAbstract',
    enumerable: false
    writable: false
    value: true
  ctor

global.abstract = abstract

# Simple abstract class for all classes.
#
# `destructor` is abstract method, must be defined by extended classes
# @abstract
# @class CSObject
class CSObject

  # Constructor of all classes by lib.
  # Can be call for check defined destructor.
  #
  # @abstract
  # @throw {TypeError} if call `new CSObject()`
  # @throw {Error} if `destructor` is not defined by child class
  constructor: ->
    if @constructor is CSObject
      throw new TypeError "'CSObject' is abstract"
    if @destructor is CSObject::destructor
      throw new Error "You must define 'destructor' by class"

  # Destructor is method for clear object. Must be override
  # @abstract
  # @throw {Error} if not defined by child class
  destructor: ->
    if @destructor is CSObject::destructor
      throw new Error 'Extended class destructor is not defined'
    return null

CSObject = abstract CSObject

module.exports = { CSObject }