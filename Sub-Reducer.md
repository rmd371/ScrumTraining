# Organizing Reducer Logic with Sub-Reducers

Are you tired of having reducer logic with multiple spread operations?  Are you tired of having huge unreadable reducers that cover multiple levels of state?  If so, dividing up reducer logic into sub-reducers might be just the thing your code needs.  

Let's imagine a health care application for quickly entering templated impressions for a patient that has a redux state that looks like the following...  

```js
{
    impressions: [
        { impressionId: 1, templateText: 'Compared to previous study from [[MOD]], patient shows [[MOD]] improvement' },
        { impressionId: 2, templateText: '[[MOD]] lung capacity' },
        ...
    ],
    prevImpressions: [],
    prevStudies: [],
    reportStatus: 'Open',
    numStatusChanges: 3
}
```

And we we're given a reducer that looks like this...

```js
const reportingReducer(state, action) => {
    switch(action.type) {
        CASE SET_IMPRESSIONS:
            return { ...state, impressions: action.impressions };
        CASE CLEAR_IMPRESSIONS:
            return { ...state, impressions: action.impressions };
        CASE SET_PREV_STUDIES:
            return { ...state, prevStudies: action.studies };
        CASE CLEAR_PREV_STUDIES:
            return { ...state, prevStudies: [] };
        CASE SET_PREV_IMPRESSIONS:
            return { ...state, prevImpressions: action.impressions };
        CASE CLEAR_PREV_IMPRESSIONS:
            return { ...state, prevImpressions: [] };
        CASE COMPLETE_REPORT:
            return { ...state, reportStatus: 'Complete', numStatusChanges: state.numStatusChanges + 1 }
        CASE CANCEL_REPORT:
            return { ...state, reportStatus: 'Canceled', numStatusChanges: state.numStatusChanges + 1 }
        CASE REOPEN_REPORT:
            return { ...state, reportStatus: 'Open', numStatusChanges: state.numStatusChanges + 1 }
        default:
            return state;
    }
};
```

Even with the simplest of operations our reducer is starting to grow in size.  The next requirement is a context menu that allows users to do the following operations on the impressions list...

* Move to top
* Move to bottom
* Remove
* Move Up
* Move Down
* Duplicate

I could add all these additional actions to the main reducer.  I'll try adding a few with help from the ramda `without` function...

```js
CASE MOVE_SELECTED_IMPRESSIONS_TO_TOP: {
    return { 
        ...state, 
        impressions: [...action.impressions, ...without(action.impressions, state.impressions)] 
    };
}
CASE MOVE_SELECTED_IMPRESSIONS_TO_BOTTOM: {
    return { 
        ...state, 
        impressions: [...without(action.impressions, state.impressions), ...action.impressions] 
    };
}
CASE REMOVE_SELECTED_IMPRESSIONS: {
    return { 
        ...state, 
        impressions: without(action.impressions, state.impressions) 
    };
}
```

You'll notice that multiple levels of spread operations are required for some of the context menu actions and it only gets worse with deeper nesting.  Could we make this task easier?  What if we had a magical sub-reducer for handling all impressions list operations that only had to return the impressions slice of state?  Something like...

```js
CASE MOVE_SELECTED_IMPRESSIONS_TO_TOP: 
    return [...action.impressions, ...without(action.impressions, state)];
CASE MOVE_SELECTED_IMPRESSIONS_TO_BOTTOM: 
    return [...without(action.impressions, state), ...action.impressions];
CASE REMOVE_SELECTED_IMPRESSIONS: 
    return without(action.impressions, state);
```

Now I only have one level of spread operations which is much easier to read and type without errors.  As a side benefit, the complexity of the main reducer would be decreased by removing the context menu cases.  Below is the full sub-reducer...

```js
// (action, impression[]) => impression[]
const impressionsReducer = (action, state) => {
    switch(action.type) {
        CASE MOVE_SELECTED_IMPRESSIONS_TO_TOP: 
            return [...action.impressions, ...without(action.impressions, state)];
        CASE MOVE_SELECTED_IMPRESSIONS_TO_BOTTOM: 
            return [...without(action.impressions, state), ...action.impressions];
        CASE REMOVE_SELECTED_IMPRESSIONS: 
            return without(action.impressions, state);
        default:
            return state;
    }
}
```

How can we make this hypothetical sub-reducer a reality?  By adding the following line to our main reducer...

```js
const reportingReducer(initState, action) => {
    const state = { ...initState, impressions: impressionsReducer(action, initState.impressions) }

    switch(action.type) {
        CASE ADD_SELECTED_IMPRESSION:
        ...
    }
};
```

Notice that two things changed...
1) The parameter state was changed to initState since our sub-reducer needs to be able to make changes to state
2) We added a line to first call our sub-reducer to update only the impressions slice of state before the main reducer updates any part of state.

If you only have one sub-reducer in the main reducer, the code above might be a pretty good implementation.  However, multiple sub-reducers start to get a bit ugly...

```js
const reportingReducer(initState, action) => {
    const state1 = { ...initState, impressions: impressionsReducer(action, initState.impressions) }
    const state2 = { ...state1, prevStudies: prevStudiesReducer(action, state1.prevStudies) }
    const state = { ...state2, prevImpressions: prevImpressionsReducer(action, state2.prevImpressions) }

    switch(action.type) {
        CASE ADD_SELECTED_IMPRESSION:
        ...
    }
};
```

Trying to come up with names for the intermediate variables state1 and state2 and remembering to use the correct one is error prone and tedious.  I prefer the following tweaks (using lenses (add link to lens tutorial?) and the ramda's lensProp, over & pipe) to make this read better...

```js
const reportingReducer(initState, action) => {
    const state = pipe(
        over(lensProp('impressions'), impressionsReducer(action)),
        over(lensProp('prevStudies'), prevStudiesReducer(action)),
        over(lensProp('prevImpressions'), prevImpressionsReducer(action)),
    )(initState);

    switch(action.type) {
        CASE ADD_SELECTED_IMPRESSION:
        ...
    }
};
```

NOTE: To make this work, we have to make one tweak to our sub-reducer signatures to allow for partial application of its parameters...

```js
// (action, impression[]) => impression[]
const impressionsReducer = (action, state) => {
```    

becomes...

```js
// action => impression[] => impression[]
const impressionsReducer = action => state => {
```    

If your reducers are becoming hard to read because of too many cases with too many spread operations to update nested properties, try adding some sub-reducers.

Next I'll be trying to update a single deeply nested property.  Each impression in our original structure has a modifier array.  Each modifier object has a value property we need to update.  How many sub-reducers will we have to create to update one property?  Can lenses help with this problem too?  That's for next time.
