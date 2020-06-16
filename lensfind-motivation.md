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
  templates: [
    {id: 1, name: 'Influenza', ...},
    {id: 2, name: 'Covid-19', ...},
    ...
  ],
  selTemplate: undefined,
}
```

When the user selects a template to edit, the app needs to copy that template in the `selTemplate` field to store temporary edits before the user is ready to save.  The reducer is notified of this task by having an action with a template ID passed to it...

`action = { type: 'TEMPLATE_SELECTED', id: 2 }`

```js
// with the ramda find method...
case TEMPLATE_SELECTED:
  return {...state, selTemplate: find(t => t.id === action.id, state.templates)};
```

```js
//with lensFind...
//outside reducer (using ramda compose & lensProp)
const templatesLens = lensProp('templates');
const stateToTemplateLens = id => compose(templatesLens, lensFind(t => t.id === id)); 

// inside reducer (using the ramda get function)
case TEMPLATE_SELECTED:
  return {...state, selTemplate: get(stateToTemplateLens(action.id), state)};
```

Okay, I probably haven't conviced you yet since lensFind requires some extra lens setup code.  Note that the "outside reducer" code can go at the top of the reducer file or in a separate file that could be shared with selectors.  Now let's look at what happens when the user want to save their changes back to the main list...

`action = { type: 'TEMPLATE_SAVE' }`

```js
//with plain.js...
case TEMPLATE_SAVE:
  return {...state, templates: state.templates.map(t => t.id === state.selTemplate.id ? state.selTemplate : t)};
```

```js
//with lensFind (reusing stateToTemplateLens from above with the ramda set function)...	
case PLATE_TEMPLATE_SAVE:
  return set(stateToTemplateLens(state.selTemplate.id), state.selTemplate, state);
```

Now I hope I'm starting to convince you.  Below are the benefits I see...
1) Reuse of the predicate from the getter `t => t.id === id` rather than duplicating it
2) One less branching operation since there is no need for a ternary operation `? state.selTemplate : t`
3) No need use property `templates` (much less specifying it twice)
4) Using `lensFind` simply reads better.

To add another requirement, I was working with templates that contained a series of plates which in turn contained a series of spots on the plate.  The users wanted a screen where all plates/spots in the template could be edited.  The additional state looked like the following...

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

Upon the user updating a plate name, I would do something like the following in my reducer...

`action = { type: 'PLATE_NAME_UPDATE', plateNum: 2, plateName: 'new name' }`

```js
//with map...
case: PLATE_NAME_UPDATE:
  return {
    ...state,
    plates: state.plates.map(p => p.plateNum === action.plateNum ? { ...p, name: action.plateName } : p);
  }
```

```js
//with lensFind...	
const platesLens = lensProp('plates');
const stateToPlateLens = plateNum => compose(platesLens, lensFind(p => p.plateNum === plateNum));
const stateToPlateNameLens = plateNum => compose(stateToPlateLens(plateNum), lensProp('name'));

case: PLATE_NAME_UPDATE:
  return set(stateToPlateNameLens(action.plateNum), action.plateName, state);
```

Assuming you're familar with lenses, the reducer code that makes use of `lensFind` is easier to follow.  It has no explicit speading, looping, ternary operation, or indented code blocks.  Now, let's update a spot...

`action = { type: 'SPOT_SPECIMEN_UPDATE', plateNum: 1, spotNum: 96, specimen: 'SPEC7891'}`

```js
//with map...
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
//with lensFind...	
const spotsLens = lensProp('spots');
const stateToSpotLens = (plateNum, spotNum) => compose(stateToPlateLens(plateNum), spotsLens, lensFind(s => s.spotNum === spotNum));
const stateToSpotSpecimen = (plateNum, spotNum) => compose(stateToSpotLens(plateNum, spotNum), lensProp('specimen'));

// inside reducer
case SPOT_SPECIMEN_UPDATE:
  return set(stateToSpotSpecimen(action.plateNum, action.spotNum), action.specimen, state);
```

I think I got the "with map" version above correct, but that amount of mapping, spreading, ternary logic, and indentation is hard to read and easy to mess up. The lensFind solution just continues to repeat the same patterns and the reducer code remains very readable.

In conclusion, the `lensFind` function builds on top of ramda lenses to give us lots of little reusable parts that hopefully make our code easier to read, more difficult to make mistakes in, and easier to test. 
