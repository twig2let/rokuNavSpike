# Coding guide

## Main views

### BaseView

This is the base view responsible for mixing in functions for focus management, keyhandling and providing the main framework. It light enough for use as a component; but not recommended for use in rowlists/grids/other aggregate views which are expected to have a large amount of items.

This view is itended to be extended by Components, which in turn are aggregates of views; but not whole screens.


#### BaseView fields

 - `isInitialized` - indicates if `initialize` has yet been called
 - `isShown`, true if the view is on screen
 - `name`, useful for logging

#### BaseView methods

 - `initialize` - must be called to start the view machinery

#### BaseView abstract methods

You can override these methods to safely drive your application behaviour

- `_applyStyle(styles, localizations, assets)` - will be called when the view is initialized, so it can apply required styles, etc
- `_initialize(args)` - called when the view has been initialized
- `_onFirstShow` - called the first time a view is shown
- `_onShow` - called when a view is shown - note a view cannot be shown if it is not initialized. This method will be called immediately for a visible view, when `initialize` is invoked
- `_onHide` - called when a view is hidden
 
In addition you can override the methods in KeyMixin:

 -  `_isAnyKeyPressLocked()` - returns true if any keypress is locked - defualt impl is to return the value of `m.isKeyPressLocked`
 -  `_isCapturingAnyKeyPress(key)`, return true if the key `key` is captured

Override the following, to return true, if the applicable key is captured

 -  `_onKeyPressDown()`
 -  `_onKeyPressUp()`
 -  `_onKeyPressLeft()`
 -  `_onKeyPressRight()`
 -  `_onKeyPressBack()`
 -  `_onKeyPressOption()`
 -  `_onKeyPressOK()`

Also, BaseView allows entry points for overriding abstract methods from `FocusMixin`

 - `_onGainedFocus(isSelfFocused)`
 - `_onLostFocus()`

### BaseScreen

Extends Baseview and adds additional awareness for selections, loading state, if the user is reloading, and contains utility and application level functions. Application functions proxy main application activity such as playing a video, or showing a screen.

#### BaseScreen fields

 - `content` the content that this screen loaded
 - `selection` selection object for the currently selected content
 - `isLoading`
 - `isUserChangePending`
 - `NavController` - reference to the `NavController` this screen belongs to - this is the navController that will be used for `push`, `pop`, and `resetNavController`

#### BaseScreen functions

 - `getTopScreen` - can be used to ask this screen what it consider's it's top view. Useful if the screen in turn composes other screens (e.g. via nested NavControllers)
 - `push` - pushes passed in screen to the navController
 - `pop` - pops the current navController screen
 - `resetNavController` - resets the navController - passing in a screen or index, will reset to that screen, or back to that index
 - other utility functions implemented for your app
 
#### BaseScreen abstract functions

BaseScreen provides the same lifecycle methods as Baseview; but also provides

 - `_getTopScreen ` - tempalte method used by `getTopScreen`
 - `_baseScreenOnShow` - special hook used to overcome needing more `onShow` overrides (SceneGraph has a limit to super method calls)
 - `_onUserChange` - called when the user changes, so the view can update itself with the latest data

 
### BaseAggregateView

A special BaseScreen subclass, which manages showing, or hiding views. The `currentView` property informs which view is currently active (i.e. the selected tab, or current view on top of a NavController)

Only one screen is ever visible at a time. A screen's lifecycle methods for focus and visibility will all be managed and can be relied upon for ascertaining the proper state of the screen.


### TabController

BaseAggregateView subclass which allows you to swtich various views. The tabController will display a screen which corresponds to the currently selected item. The screen is created lazily, unless it was specified using `addExistingView`

#### TabController fields

 - `menuItems` array of items, which are used to create child screens. The menuItem must have an id, which matches the view passed in with `addExistingView`, or have it's screenType set to the valid type of a `BaseScreen` subclass
 - `currentItem` _readOnly_ the currently selected menuItem

#### TabController functions

 - `addExistingView` - will register the passed in view to be displayed when a menu item with the same id is set as the `currentItem` 
 - `getViewForMenuItemContent`
 - `changeCurrentItem` - will set the `currentItem`


### NavController

NavController controls a stack of views stacked one up on the other. When a BaseScreen is added to a NavController it's `navController` field is set to the navController. In addition the lifecycle methods `onAddedToAggregateView` and `onRemovedFromAggregateView` are invoked in accordance with `pop`, `push` and `reset`

#### NavController fields

 - `numberOfViews` _readonly_ number of Views on the stack 
 - `isLastViewPopped` _readonly_ true, if the last view is popped, can be observed
 - `isAutoFocusEnabled` if true then pushed views receive focus

### NavController functions

 - `push` - pushes the passed in view onto the stack, and initializes it
 - `pop` - pops current view from the stack
 - `reset` - resets the stack
 - `resetToIndex` - resests the stack to the desired index

## Component Lifecycle

To make develpoment easier, and remove boilerplate, a lifecycle is provided, so that all views and screens can override a few methods to get accurate access to their perceived state on screen. the lifecycle methods are invokved as follows:

 - `_initialize` - invoked once
 - `_onFirstShow` - onvoked once
 - `_onShow` - can be invoked multiple times
 - `_onHide` - can be invoked multiple times
 - `_onUserChange` - can be invoked multiple times