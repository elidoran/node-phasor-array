assert = require 'assert'
{PhasorArray} = require '../../lib'

phasor = new PhasorArray

describe 'test phasor array', ->

  it 'adding phases', ->

    phases = [ 'first', 'second', 'third']
    phasor.add id:id for id in phases

    assert.equal phasor._phaseActions.length, 0, 'shouldnt have any actions'
    assert.equal phasor._phases.length, 3, 'should have the three phases'

    for phase,index in phases
      assert.equal phasor._phases[index], phase, "phase [#{phase}] should be at #{index}"
      assert.equal phasor._phaseCounts[phase], 0, "phase [#{phase}] should have a count of zero"

  it 'adding phase actions', ->

    fn0 = ->
    fn1 = ->
    fn2 = ->
    fn3 = ->
    fn4 = ->
    fn5 = ->
    fn6 = ->
    fn7 = ->
    fn8 = ->
    fn9 = ->

    fn0.displayName = 'fn0'
    fn1.displayName = 'fn1'
    fn2.displayName = 'fn2'
    fn3.displayName = 'fn3'
    fn4.displayName = 'fn4'
    fn5.displayName = 'fn5'
    fn6.displayName = 'fn6'
    fn7.displayName = 'fn7'
    fn8.displayName = 'fn8'
    fn9.displayName = 'fn9'

    phasor.add id:'first', fn:fn1
    assert.equal phasor._phaseActions[0], fn1
    assert.equal phasor._phaseCounts['first'], 1

    phasor.add id:'second', fn:fn3
    assert.equal phasor._phaseActions[1], fn3
    assert.equal phasor._phaseCounts['second'], 1

    phasor.add id:'third', fn:fn6
    assert.equal phasor._phaseActions[2], fn6
    assert.equal phasor._phaseCounts['third'], 1

    phasor.add id:'second', fn:fn2
    assert.equal phasor._phaseActions[1], fn2
    assert.equal phasor._phaseCounts['second'], 2

    phasor.add id:'third', fn:fn5
    assert.equal phasor._phaseActions[3], fn5
    assert.equal phasor._phaseCounts['third'], 2

    phasor.add id:'first', fn:fn0
    assert.equal phasor._phaseActions[0], fn0
    assert.equal phasor._phaseCounts['first'], 2

    phasor.add id:'third', fn:fn4
    assert.equal phasor._phaseActions[4], fn4
    assert.equal phasor._phaseCounts['third'], 3

    phasor.add id:'sixth', fn:fn9
    assert.equal phasor._phases.length, 4, 'should have 4 phases now'
    assert.equal phasor._phaseActions.length, 8, 'should have 8 actions now'
    assert.equal phasor._phaseActions[7], fn9
    assert.equal phasor._phaseCounts['sixth'], 1

    phasor.add id:'fourth', fn:fn7, after:'third'
    assert.equal phasor._phases.length, 5, 'should have 5 phases now'
    assert.equal phasor._phaseActions.length, 9, 'should have 9 actions now'
    assert.equal phasor._phaseActions[7], fn7
    assert.equal phasor._phaseCounts['fourth'], 1

    phasor.add id:'fifth', fn:fn8, before:'sixth'
    assert.equal phasor._phases.length, 6, 'should have 6 phases now'
    assert.equal phasor._phaseActions.length, 10, 'should have 10 actions now'
    assert.equal phasor._phaseActions[8], fn8
    assert.equal phasor._phaseCounts['fifth'], 1


  it 'run()', ->

    # make a function to track its execution count
    fn = ->
      this.count ?= 0
      this.count++
      # also count with something other than context, just in case
      fn.count++
    fn.count = 0

    # replace each action with our counter function
    phasor._phaseActions[index] = fn for each,index in phasor._phaseActions

    # run without a context
    result = phasor.run()

    assert.equal fn.count, phasor._phaseActions.length, 'should run once for each one'
    assert.equal result.count, phasor._phaseActions.length, 'should count via context as well'

    # reset for the next test
    fn.count = 0

  it 'run(context)', ->

    # ensure our counter is reset
    fn = phasor._phaseActions[0]
    fn.count = 0

    # run WITH a context. start at 10 so we can see it uses what it's given
    result = phasor.run count:10

    assert.equal fn.count, phasor._phaseActions.length, 'should run once for each one'
    assert.equal result.count, (phasor._phaseActions.length + 10), 'should count via context as well (from 10)'

    # reset for the next test
    fn.count = 0

  it 'stops running when false is returned', ->

    # ensure our counter is reset
    fn = phasor._phaseActions[0]
    fn.count = 0

    # return false at that action
    phasor._phaseActions[2] = -> false

    # run with a context so we can see we don't get the false back
    result = phasor.run context:true

    assert.equal fn.count, 2, 'should stop after second'
    assert.equal result.context, true, 'should return the context, not `false`'
    assert.equal result.count, 2, 'should stop after second'

  it 'ignores repeated add of same phase ID', ->

    phaseCount = phasor._phases.length

    same = 'same'
    phasor.add id:same
    phasor.add id:same
    phasor.add id:same

    assert.equal phasor._phases.length, (phaseCount + 1), 'should have only one more phase'

    count = 0
    count++ for phase in phasor._phases when phase is same

    assert.equal count, 1, 'should only be a single instance of the `same` phase'
