# Material Floating Search Bar

A Flutter implementation of an expandable floating search bar, also known as persistent search, similar to the ones used extensively by Google in their own apps.

<p>
  <img width="216px" alt="CircularFloatingSearchBarTransition" src="https://raw.githubusercontent.com/bnxm/material_floating_search_bar/master/assets/circular_example.gif"/>

  <img width="216px" alt="ExpandingFloatingSearchBarTransition" src="https://raw.githubusercontent.com/bnxm/material_floating_search_bar/master/assets/expanding_example.gif"/>

  <img width="216px" alt="SlideFadeFloatingSearchBarTransition" src="https://raw.githubusercontent.com/bnxm/material_floating_search_bar/master/assets/slide_fade_example.gif"/>
</p>

Click [here](https://github.com/bnxm/material_floating_search_bar/blob/master/example/lib/main.dart) to view the full example.

## Installing

Add it to your `pubspec.yaml` file:
```yaml
dependencies:
  material_floating_search_bar: ^0.1.3
```
Install packages from the command line
```
flutter packages get
```

If you like this package, consider supporting it by giving it a star on [GitHub](https://github.com/bnxm/material_floating_search_bar) and a like on [pub.dev](https://pub.dev/packages/material_floating_search_bar) :heart:

## Usage

A `FloatingSearchBar` should be placed above your main content in your widget tree and be allowed to fill all the available space.

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    // This is handled by the search bar itself.
    resizeToAvoidBottomInset: false,
    body: Stack(
      fit: StackFit.expand,
      children: [
        buildMap(),
        buildBottomNavigationBar(),
        buildFloatingSearchBar(),
      ],
    ),
  );
}

Widget buildFloatingSearchBar() {
  final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

  return FloatingSearchBar(
    hint: 'Search...',
    scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
    transitionDuration: const Duration(milliseconds: 800),
    transitionCurve: Curves.easeInOut,
    physics: const BouncingScrollPhysics(),
    axisAlignment: isPortrait ? 0.0 : -1.0,
    openAxisAlignment: 0.0,
    maxWidth: isPortrait ? 600 : 500,
    debounceDelay: const Duration(milliseconds: 500),
    onQueryChanged: (query) {
      // Call your model, bloc, controller here.
    },
    // Specify a custom transition to be used for
    // animating between opened and closed stated.
    transition: CircularFloatingSearchBarTransition(),
    actions: [
      FloatingSearchBarAction(
        showIfOpened: false,
        child: CircularButton(
          icon: const Icon(Icons.place),
          onPressed: () {},
        ),
      ),
      FloatingSearchBarAction.searchToClear(
        showIfClosed: false,
      ),
    ],
    bodyBuilder: (context, transition) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Material(
          color: Colors.white,
          elevation: 4.0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: Colors.accents.map((color) {
              return Container(height: 112, color: color);
            }).toList(),
          ),
        ),
      );
    },
  );
}
```

#### Usage with `Scrollables`

By default, the `Widget` returned by the `builder` is not allowed to have an unbounded (infinite) height. This is necessary in order for the search bar to be able to dismiss itself, when the user taps below the area of the child. (For example, when you have a list of items but there are not enough items to fill the whole screen, as shown in the gifs above, the user would expect to be able to close the search bar when tapping below the last item in the list).

Therefore, `shrinkWrap` should be set to `true` on all `Scrollables` and `physics` to `NeverScrollableScrollPhysics`. On `Columns`, the `mainAxisSize` should be set to `MainAxisSize.min`. 

If you don't want this behavior, you can set the `isScrollControlled` flag to `true`. Then you are allowed to use expanding `Widgets` such as `Scrollables` with the caveat that the search bar may not be able to detect taps on the backdrop area.

### Customizations

There are many customization options:

| Field                       | Description             |
| --------------------------- | ----------------------- |
| `body`                      | The widget displayed below the `FloatingSearchBar`. <br><br> This is useful, if the `FloatingSearchBar` should react to scroll events (i.e. hide from view when a `Scrollable` is being scrolled down and show it again when scrolled up).
| `accentColor`               | The color used for elements such as the progress indicator. <br><br> Defaults to the themes accent color if not specified. 
| `backgroundColor`           | The color of the card. <br><br> If not specified, defaults to `theme.cardColor`.
| `shadowColor`               | The color of the shadow drawn when `elevation > 0`. <br><br> If not specified, defaults to `Colors.black54`.
| `iconColor`                 | When specified, overrides the themes icon color for this `FloatingSearchBar`, for example to easily adjust the icon color for all `actions` and `startActions`.
| `backdropColor`             | The color that fills the available space when the `FloatingSearchBar` is opened. <br><br> Typically a black-ish color. <br><br> If not specified, defaults to `Colors.black26`.
| `margins`                   | The insets from the edges of its parent. <br><br> This can be used to position the `FloatingSearchBar`. <br><br> If not specifed, the `FloatingSearchBar` will try to position itself at the top offsetted by `MediaQuery.of(context).viewPadding.top` to avoid the status bar.
| `padding`                   | The padding of the card. <br><br> Only the horizontal values will be honored.
| `insets`                    | The padding between `startActions`, the input field and `actions` respectively. <br><br> Only the horizontal values will be honored.
| `height`                    | The height of the card. <br><br> If not specified, defaults to `48.0` pixels.
| `elevation`                 | The elevation of the card. 
| `maxWidth`                  | The max width of the `FloatingSearchBar`. <br><br> By default the `FloatingSearchBar` will expand to fill all the available width. <br><br> This value can be set to avoid this.
| `openMaxWidth`              | The max width of the `FloatingSearchBar` when opened. <br><br> This can be used, when the max width when opened should be different from the one specified by `maxWidth`. <br><br> When not specified, will use the value of `maxWidth`.
| `axisAlignment`             | How the `FloatingSearchBar` should be aligned when the available width is bigger than the width specified by `maxWidth`. <br><br> When not specified, defaults to `0.0` which centers the `FloatingSearchBar`.
| `openAxisAlignment`         | How the `FloatingSearchBar` should be aligned when the available width is bigger than the width specified by `openMaxWidth`. <br><br> When not specified, will use the value of `axisAlignment`.
| `border`                    | The border of the card.
| `borderRadius`              | The `BorderRadius` of the card. <br><br> When not specified, defaults to `BorderRadius.circular(4)`.
| `hintStyle`                 | The `TextStyle` for the hint in the `TextField`.
| `queryStyle`                | The `TextStyle` for the input in the `TextField`.
| `clearQueryOnClose`         | Whether the current query should be cleared when the `FloatingSearchBar` was closed. <br><br> When not specifed, defaults to `true`.
| `showDrawerHamburger`       | Whether a hamburger menu should be shown when there is a `Scaffold` with a `Drawer` in the widget tree.
| `closeOnBackdropTap`        | Whether the `FloatingSearchBar` should be closed when the backdrop was tapped. <br><br> When not specified, defaults to `true`.
| `progress`                  | The progress of the `LinearProgressIndicator` inside the card. <br><br> When set to a `double` between `0..1`, will show show a determined `LinearProgressIndicator`. <br><br> When set to `true`, the `FloatingSearchBar` will show an indetermined `LinearProgressIndicator`. <br><br> When `null` or `false`, will hide the `LinearProgressIndicator`.
| `transitionDuration`       |  The duration of the animation between opened and closed state.
| `transitionCurve`          |  The curve for the animation between opened and closed state.
| `debounceDelay`            |  The delay between the time the user stopped typing and the invocation of the `onQueryChanged` callback. <br><br> This is useful for example if you want to avoid doing expensive tasks, such as making a network call, for every single character.
| `title`                    | A widget that is shown in place of the `TextField` when the `FloatingSearchBar` is closed.
| `hint`                    | The text value of the hint of the `TextField`.
| `actions`                  | A list of widgets displayed in a row after the `TextField`. <br><br> Consider using `FloatingSearchBarActions` for more advanced actions that can interact with the `FloatingSearchBar`. <br><br> In LTR languages, they will be displayed to the left of the `TextField`.
| `startActions`             | A list of widgets displayed in a row before the `TextField`. <br><br> Consider using `FloatingSearchBarActions` for more advanced actions that can interact with the `FloatingSearchBar`. <br><br> In LTR languages, they will be displayed to the right of the `TextField`. 
| `onQueryChanged`   | A callback that gets invoked when the input of the query inside the `TextField` changed.
| `onSubmitted`   | A callback that gets invoked when the user submitted their query (e.g. hit the search button).
| `onFocusChanged`            | A callback that gets invoked when the `FloatingSearchBar` receives or looses focus.
| `transition`                | The transition to be used for animating between closed and opened state. See below for a list of all available transitions.
| `builder`                   | The builder for the body of this `FloatingSearchBar`. <br><br> Usually, a list of items. Note that unless `isScrollControlled` is set to `true`, the body of a `FloatingSearchBar` must not have an unbounded height meaning that `shrinkWrap` should be set to `true` on all `Scrollables`.
| `controller`                | The controller for this `FloatingSearchBar` which can be used to programatically open, close, show or hide the `FloatingSearchBar`.
| `isScrollControlled` | Whether the body of this `FloatingSearchBar` is using its own `Scrollable`. <br><br> This will allow the body of the `FloatingSearchBar` to have an unbounded height. <br><br> Note that when set to `true`, the `FloatingSearchBar` won't be able to dismiss itself when tapped below the height of child inside the `Scrollable`, when the child is smaller than the avaialble height.

### Transitions

As of now there are three types of transitions that are exemplified above:

| Transition                             | Description                           |
| -------------------------------------- | ------------------------------------- |
| `CircularFloatingSearchBarTransition`  | Clips its child in an expanding circle.
| `ExpandingFloatingSearchBarTransition` | Fills all the available space with the background of the `FloatingSearchBar`. Similar to the ones used in many Google apps like Gmail.
| `SlideFadeFloatingSearchBarTransition` | Vertically slides and fades its child.

You can also easily create you own custom transition by extending `FloatingSearchBarTransition`.

