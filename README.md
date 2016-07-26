# @phasor/array
[![Build Status](https://travis-ci.org/elidoran/node-phasor-array.svg?branch=master)](https://travis-ci.org/elidoran/node-phasor-array)
[![Dependency Status](https://gemnasium.com/elidoran/node-phasor-array.png)](https://gemnasium.com/elidoran/node-phasor-array)
[![npm version](https://badge.fury.io/js/%40phasor%2Farray.svg)](http://badge.fury.io/js/%40phasor%2Farray)

Lightweight ordered function execution; phases.

Add "phases" and add functions to the phases and they will be executed in order.

The main concept is functions can be ordered in groups, phases, without needing to be ordered *within* each phase.

For example, a client router may want phases:

1. Analyze Location - look at new location and do some work analyzing it
2. Exiting Location - consider whether location can be or should be exited
3. Entering Location - what to do when entering a new location (route)
4. Before Actions - preparation for Actions
5. Actions - location specific actions
6. After Actions - cleanup or other after effects

This allows expanding third party modules by adding your own phases and functions to a `phasor` they made.

## Install

    $ npm install @phasor/array --save


## API

### phasor.add(object)

#### Add a Phase

```javascript

// specify the phase via the `id` property.
// with no `before` or `after` property the phase will
// be added last
phasor.add({ id: 'some phase name' })

// add the phase *before* another phase by specifying the `before`
phasor.add({ id: 'diff phase name', before: 'other phase' })

// add the phase *after* another phase by specifying the `after`
phasor.add({ id: 'third phase name', after: 'other phase' })

// NOTE: if you specify both before and after the before will be ignored
```

#### Add a Function to a Phase

```javascript
var fn = function() {} # some function

// specify the phase via the `id` property.
// specify the function via the `fn` property
phasor.add({ id: 'phase name', fn:fn })
```


### phasor.run(object)

Executes the functions for each phase in order.

The specified object is provided to each function as both the argument and the *this* context.

Note:

1. The `this` in each function is the object passed to `phasor.run(object)`.
2. A function can stop the execution by returning `false`.
3. When adding a function to a phase it becomes the first function in that phase. This allows a newly added function the chance to prevent previously added functions from running, or, altering the inputs they receive.


```javascript
var fn = function(context) {
  if (this.someValue) { // same as context.someValue
    // set a new value into the context for future functions
    this.newValue = 'blah'
  } else {
    // false causes the run() to stop
    return false
  }
}

var context = { someValue:'value' }
phasor.run(context)
```


## Future

I can think of several other implementation styles for the `phasor` idea. I made the `@phasor` scope so those implementations can be grouped together. Please let me know if you have an idea for an implementation or you'd like to add your module to the `@phasor` scope.

For example, a phasor could be implemented with `async` utilities, or, `chain-builder` (I made chain-builder...). These could provide some more advanced features for execution.

## MIT License
