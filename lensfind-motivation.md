# lensFind motivation
## Prereqs
Familiarity with...
1) composing functions
2) redux
3) ramda functions
4) lenses

## Purpose
When using redux reducers state must be updated while maintaining immutability.  I found myself creating hard to understand logic in reducers that needed to update lists.  I wanted an easier way to update an item in a list.  

Our structure in state looked like the following...

```js
{
  plateTemplates: [
    {id: 1, name: 'Influenza', ...},
    {id: 2, name: 'Covid-19', ...},
    ...
  ],
  selPlateTemplate: undefined,
}
```

When the user selects a plate template to edit, the app needs to copy that template in the selectedPlateTemplate field to store temporary edits before the user is ready to save.  The reducer is notified of this task by having an action with a plate template ID (ptId) in it passed to it...

```js
// with the ramda find method...
case: PLATE_TEMPLATE_SELECTED
  return {...state, selectedPlateTemplate: find(pt => pt.id === action.ptId, state.plateTemplates)};
```

```js
//with lensFind...
//outside reducer
const plateTemplatesLens = lensProp('plateTemplates');
const stateToSelPtLens = ptId => compose(plateTemplateLens, lensFind(pt => pt.id === ptId)); 

// inside reducer
case: PLATE_TEMPLATE_SELECTED
  return {...state, selectedPlateTemplate: get(stateToSelPtLens(action.ptId), state)};
```

Okay, I probably haven't conviced you yet since lensFind requires some extra lens setup code.  Now let's look at what happens when the user want to save their changes back to the main list...

```js
//with plain.js...
case: PLATE_TEMPLATE_SAVE
  return {...state, plateTemplates: state.plateTemplates.map(pt => pt.ptId === action.id ? action.pt : pt)};
```

```js
//with lensFind (reusing stateToSelPtLens from above)...	
case: PLATE_TEMPLATE_SAVE
  return set(stateToSelPtLens(action.id), action.pt, state);
```

Now I hope I'm starting to convince you.  Below are the benefits I see...
1) Reuse of the predicate from the getter `pt => pt.id === ptId` rather than duplicating it
2) One less branching operation since there is no need for a ternary operation `? action.id : pt`
3) No need use property `plateTemplates` (much less specifying it twice)
4) Using `lensFind` simply reads better.

Additionally, I was working with plate templates that contained a series of plates which in turn contained a series of spots on the plate.  The users wanted a screen where all plates/spots in the template could be edited.  The additional state looked like the following...

```js
{
  plates: [
    {
      plateNum: 1
      name: 'Plate One',
      spots: [
        { spotNum: 1, specimen: 'CTRL0001' },
        { spotNum: 2, specimen: 'CTRL0002' },
        { spotNum: 3, specimen: 'SPEC1234' },
        ...
        { spotNum: 96, specimen: 'SPEC9876' },
      ]
    },
    {
      plateNum: 2
      name: 'Plate Two',
      spots: [...]
    },
  ]
}
```

I'll assume we have a reducer that has it's slice of state beginning at the `selectedPlateTemplate` property (see how to do this [here](http://www.google.com)).  Upon the user updating a plate name on the plate with a new specimen, I would do something like the following in my reducer...

```js
//with map...
case: PLATE_NAME_UPDATE
  return {
    ...state,
    plates: state.plates.map(p => p.plateNum === action.plateNum ? { ...p, name: action.plateName } : p);
  }
```

```js
//with lensFind we could create the following reusable lenses (using the ramda lensProp, compose, and set functions)...	
const platesLens = lensProp('plates');
const stateToPlateLens = plateNum => compose(platesLens, lensFind(p => p.plateNum === plateNum));
const stateToPlateNameLens = plateNum => compose(stateToPlateLens(plateNum), lensProp('name'));

case: PLATE_NAME_UPDATE
  return set(stateToPlateNameLens(action.plateNum), action.plateName, state);
```

Assuming you're familar with lenses, the reducer code that makes use of `lensFind` is easier to follow.  It has no explicit speading, looping, ternary operation, or indented code blocks.  Now, let's update a spot...

```js
//with plain js...
case SPOT_SPECIMEN_UPDATE:
  return {
    ...state,
    state.plates.map(p => p.plateNum === action.plateNum
      ? {
        ...p,
        spots: p.spots.map(s => s.spotNum === action.spotNum 
          ? {
            ...s,
            specimen: action.specimen
          } 
          : s)
      } 
      : p)
  }
```
```js
//with lensFind we could create the following reusable lenses (using the ramda lensProp, compose, and set functions)...	
const spotsLens = lensProp('spots');
const stateToSpotLens = (plateNum, spotNum) => compose(stateToPlateLens(plateNum), spotsLens, lensFind(s => s.spotNum === spotNum));
const stateToSpotSpecimen = (plateNum, spotNum) => compose(stateToSpotLens(plateNum, spotNum), lensProp('specimen'));

// inside reducer
case SPOT_SPECIMEN_UPDATE:
  return set(stateToSpotSpecimen(action.plateNum, action.spotNum), action.specimen, state);
```

I think I got the plain js above correct, but that amount of mapping, spreading, ternary logic, and indentation is hard to read and easy to mess up. The lensFind solution just continues to repeat the same patterns and the reducer code is very readable.

In conclusion, the `lensFind` function builds on top of ramda lenses to give us lots of little reusable parts that hopefully make our code easier to read, more difficult to make mistakes in, and easier to test. 
