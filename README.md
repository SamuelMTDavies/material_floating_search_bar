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
  material_floating_search_bar: ^0.1.0
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