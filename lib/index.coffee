
# make available as 'PhasorArray' and as 'default' for ES6 module import
# examples:
#   import PhasorArray from '@phasor/array';
#   import {PhasorArray} from '@phasor/array';
# for CoffeeScript:
#   {PhasorArray} = require '@phasor/array'

exports.default = exports.PhasorArray = class PhasorArray

  constructor: ->

    # store all actions into a single array, in order, ready for execution
    @_phaseActions = []

    # track how many each phase has so we know where they are in the array
    @_phaseCounts = {}

    # track the phase IDs and their order
    @_phases = []

  # add a new phase before/after another phase, or at the end.
  # add an action to a phase, goes before other actions in the phase.
  add: (arg0, arg1) ->

    # # DETERMINE ARGS

    # either it's an `options` object with the `id` property,
    # or, it's a string argument which is the `id`
    phaseId = arg0.id ? arg0

    # either it's the second argument, or, it's `fn` property on options arg
    fn = arg1 ? arg0.fn

    # before/after must be specified in an options object as arg0
    otherId = arg0.after ? arg0.before

    # if after then we the phase on the other side of the specified phase
    after = arg0.after


    # # FIND INDICES
    # remember phase's index
    phaseIndex  = -1

    # remember the other phase's index
    otherIndex = -1

    # remember where to put the action
    actionIndex = 0

    # accumulate phase action counts until we find the phase, or, we've checked
    # all of them. remember both the phaseIndex and the actionIndex
    for phase,index in @_phases when phaseIndex is -1
      if phase is otherId then otherIndex = index
      if phase is phaseId then phaseIndex = index
      else actionIndex += @_phaseCounts[phase]


    # # ADD MISSING PHASE
    # if the phase didn't exist, add it
    if phaseIndex is -1

      # then, we put the phase where the other ref'd phase is
      # if the phase didn't exist then we'd have found the otherId's index,
      # if it existed.
      phaseIndex = otherIndex

      # so, if we have an index to target...
      if phaseIndex > -1

        # increment if we want it 'after' it, `before` or no setting then leave it
        if after
          phaseIndex++

        # if we're adding an action now too, then actionIndex must be recalculated
        if fn?
          actionIndex = 0
          for phase,index in @_phases when index < phaseIndex
            actionIndex += @_phaseCounts[phase]

      # else, we didn't find it (maybe otherId was null), so add to the end
      # actionIndex will be at the end in this case so it's correct
      else
        phaseIndex = @_phases.length

      # put its id into phases where it belongs
      @_phases.splice phaseIndex, 0, phaseId

      # start its count at zero
      @_phaseCounts[phaseId] = 0


    # # ADD FN
    # if there's a `fn` then set it into the array for its phase
    if fn?

      # splice in the function at the index
      @_phaseActions.splice actionIndex, 0, fn

      # and increment the phase's count
      @_phaseCounts[phaseId]++

    return

  run: (context = {}) ->
    for fn in @_phaseActions
      # context is both an arg and the `this`
      result = fn.call context, context
      if result is false then break # must be an explicit false

    return context
