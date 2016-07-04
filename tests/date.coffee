# test for CSDate correct
{assert} = require 'chai'
{CSDate} = require '../lib/date.coffee'

describe 'CSDate', ->
  describe 'structure', ->
    it 'class', ->
      assert.ok CSDate
      assert.isFunction CSDate
      assert.isFunction CSDate.now
      assert.isFunction CSDate.parse
      assert.isFunction CSDate.UTC
    it 'proto', ->
      assert.isFunction CSDate::destructor
      assert.isFunction CSDate::getDate
      assert.isFunction CSDate::setDate
      assert.isFunction CSDate::getDay
      assert.isFunction CSDate::getFullYear
      assert.isFunction CSDate::setFullYear
      assert.isFunction CSDate::getHours
      assert.isFunction CSDate::setHours
      assert.isFunction CSDate::getMilliseconds
      assert.isFunction CSDate::setMilliseconds
      assert.isFunction CSDate::getMinutes
      assert.isFunction CSDate::setMinutes
      assert.isFunction CSDate::getMonth
      assert.isFunction CSDate::setMonth
      assert.isFunction CSDate::getSeconds
      assert.isFunction CSDate::setSeconds
      assert.isFunction CSDate::getTime
      assert.isFunction CSDate::setTime
      assert.isFunction CSDate::getYear
      assert.isFunction CSDate::setYear
      assert.isFunction CSDate::getTimezoneOffset
      assert.isFunction CSDate::getUTCDate
      assert.isFunction CSDate::setUTCDate
      assert.isFunction CSDate::getUTCDay
      assert.isFunction CSDate::getUTCFullYear
      assert.isFunction CSDate::setUTCFullYear
      assert.isFunction CSDate::getUTCHours
      assert.isFunction CSDate::setUTCHours
      assert.isFunction CSDate::getUTCMilliseconds
      assert.isFunction CSDate::setUTCMilliseconds
      assert.isFunction CSDate::getUTCMinutes
      assert.isFunction CSDate::setUTCMinutes
      assert.isFunction CSDate::getUTCMonth
      assert.isFunction CSDate::setUTCMonth
      assert.isFunction CSDate::getUTCSeconds
      assert.isFunction CSDate::setUTCSeconds
      assert.isFunction CSDate::toDateString
      assert.isFunction CSDate::toGMTString
      assert.isFunction CSDate::toISOString
      assert.isFunction CSDate::toJSON
      assert.isFunction CSDate::toString
      assert.isFunction CSDate::toTimeString
      assert.isFunction CSDate::toUTCString
      assert.isFunction CSDate::valueOf
      assert.isFunction CSDate::toGMTString
      assert.isFunction CSDate::toLocaleDateString
      assert.isFunction CSDate::toLocaleString
      assert.isFunction CSDate::toLocaleTimeString

  describe 'behavior', ->
    it 'error', ->
      fn = -> new CSDate {}
      assert.throws fn, TypeError, "first param is not a Number and not a Date"

    it 'new', ->
      d = new Date()
      byTime = new CSDate d.getTime()
      byDate = new CSDate d
      byMore = new CSDate 1999, 0, 15
      assert.instanceOf byTime, CSDate
      assert.instanceOf byTime, Date
      assert.instanceOf byDate, CSDate
      assert.instanceOf byDate, Date
      assert.instanceOf byMore, CSDate
      assert.instanceOf byMore, Date
      assert.equal byMore.getFullYear(), 1999
      assert.equal byMore.getMonth(), 0
      assert.equal byMore.getDate(), 15
      ds = CSDate()
      d = new CSDate()
      assert.instanceOf ds, CSDate
      assert.instanceOf ds, Date
      assert.isTrue -15 < ds.getTime() - d.getTime() < 15

    it 'extends only', ->
      class D extends CSDate
      d = new D()
      pattern = new Date(d.getTime())
      assert.ok d
      assert.instanceOf d, D
      assert.instanceOf d, CSDate
      assert.instanceOf d, Date
      assert.equal d.getTime(), pattern.getTime()
      assert.equal d.getFullYear(), pattern.getFullYear()
      assert.equal d.getHours(), pattern.getHours()
      assert.equal d.getUTCMilliseconds(), pattern.getUTCMilliseconds()
    it 'identical', ->
      methodNames = [
        'getDate', 'setDate'
        'getDay'
        'getFullYear', 'setFullYear'
        'getHours', 'setHours'
        'getMilliseconds', 'setMilliseconds'
        'getMinutes', 'setMinutes'
        'getMonth', 'setMonth'
        'getSeconds', 'setSeconds'
        'getTime', 'setTime'
        'getYear', 'setYear'
        'getTimezoneOffset'
        'getUTCDate', 'setUTCDate'
        'getUTCDay'
        'getUTCFullYear', 'setUTCFullYear'
        'getUTCHours', 'setUTCHours'
        'getUTCMilliseconds', 'setUTCMilliseconds'
        'getUTCMinutes', 'setUTCMinutes'
        'getUTCMonth', 'setUTCMonth'
        'getUTCSeconds', 'setUTCSeconds'
        'toDateString', 'toGMTString', 'toISOString'
        'toJSON', 'toString', 'toTimeString', 'toUTCString'
        'valueOf', 'toGMTString'
        'toLocaleDateString', 'toLocaleString', 'toLocaleTimeString'
      ]
      date = new Date()
      csDate = new CSDate()
      assert.isBelow csDate.getTime() - date.getTime(), 100
      csDate.setTime date.getTime()
      for method in methodNames
        if method.indexOf('set') is 0
          unless date[method]?
            console.log method + ' not exists\n'
            continue
          getMethod = method.replace /^set/, 'get'
          unless date[getMethod]?
            process.stdout.write getMethod + ' not exists\n'
            continue
          getVal = date[getMethod]()
          try
            date[method](getVal)
          catch
            process.stdout.write "#{method} not accept #{getVal}\n"
            continue
          if isNaN date[method](getVal)
            assert.isNaN csDate[method](getVal)
          else
            assert.strictEqual csDate[method](getVal), date[method](getVal)
        else
          try
            date[method]()
          catch
            process.stdout.write "#{method} not accept empty\n" + date.toJSON() + '\n'
            continue
          if isNaN date[method]()
            assert.isNaN csDate[method]()
          else
            assert.strictEqual csDate[method](), date[method]()
        if JSON.stringify(date) is 'null'
          throw new Error "method #{method}(#{getVal}) break object!"
      return

    it 'CSDate.*', ->
      assert.strictEqual Date.UTC(1999, 15), CSDate.UTC(1999, 15)
      assert.strictEqual Date.UTC(1999, 10, 15), CSDate.UTC(1999, 10, 15)
      assert.strictEqual Date.UTC(1999, 10, 15, 11),
        CSDate.UTC(1999, 10, 15, 11)
      assert.strictEqual Date.UTC(1999, 10, 15, 11, 12),
        CSDate.UTC(1999, 10, 15, 11, 12)
      assert.strictEqual Date.UTC(1999, 10, 15, 11, 12, 15),
        CSDate.UTC(1999, 10, 15, 11, 12, 15)
      assert.strictEqual Date.UTC(1999, 10, 15, 11, 12, 15, 456),
        CSDate.UTC(1999, 10, 15, 11, 12, 15, 456)

      assert.isBelow Math.abs(Date.now() - CSDate.now()), 100

      assert.equal Date.parse('10/25/2014'), CSDate.parse('10/25/2014')
      assert.equal Date.parse('2014-10-23'), CSDate.parse('2014-10-23')
      assert.equal Date.parse('Thu, 01 Jan 1970 00:00:00 GMT-0400'),
        CSDate.parse('Thu, 01 Jan 1970 00:00:00 GMT-0400')

    it 'destructor', ->
      csd = new CSDate()
      assert.ok csd.__base__
      assert.isNull csd.destructor()
      assert.isNull csd.__base__