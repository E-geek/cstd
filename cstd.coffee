'use strict'
e = null
### istanbul ignore if ###
if !('.coffee' of require.extensions)
  require 'coffee-script/register'

{ CSObject }  = require './lib/object.coffee'
{ CSError }   = require './lib/error.coffee'
{ CSDate }    = require './lib/date.coffee'
{ Stack }     = require './lib/stack.coffee'
{ Deque }     = require './lib/deque.coffee'
{ Queue }     = require './lib/queue.coffee'
{ Node }      = require './lib/node.coffee'
{ List }      = require './lib/list.coffee'

{ CircularList }        = require './lib/circular_list.coffee'
{ CSEmitter, CSEvent }  = require './lib/emitter.coffee'

{ BaseCache, LRUCache } = require './lib/cache.coffee'

module.exports = e = {
  CSObject, CSError, CSDate
  Stack, Deque, Queue, Node
  List, CircularList
  CSEmitter, CSEvent
  BaseCache, LRUCache
}

global.cstd = e