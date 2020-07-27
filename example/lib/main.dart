import 'package:flutter/material.dart';
import 'package:implicitly_animated_reorderable_list/implicitly_animated_reorderable_list.dart';
import 'package:implicitly_animated_reorderable_list/transitions.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import 'package:material_floating_search_bar/material_floating_search_bar.dart';

import 'place.dart';
import 'search_model.dart';

void main() => runApp(MaterialFloatingSearchBarExample());

class MaterialFloatingSearchBarExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material Floating Search Bar Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Montserrat',
        iconTheme: const IconThemeData(
          color: Color(0xFF4d4d4d),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          elevation: 4,
        ),
      ),
      home: ChangeNotifierProvider(
        create: (_) => SearchModel(),
        child: const Home(),
      ),
    );
  }
}

class Home extends StatelessWidget {
  const Home({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      drawer: Drawer(
        child: Container(
          width: 200,
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          buildMap(),
          buildBottomNavigationBar(),
          buildFabs(),
          buildSearchBar(context),
        ],
      ),
    );
  }

  Widget buildSearchBar(BuildContext context) {
    final actions = [
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
    ];

    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Consumer<SearchModel>(
      builder: (context, model, _) {
        return FloatingSearchBar(
          hint: 'Search for a new Place...',
          transitionDuration: const Duration(milliseconds: 800),
          transitionCurve: Curves.easeInOut,
          physics: const BouncingScrollPhysics(),
          axisAlignment: isPortrait ? 0.0 : -1.0,
          openAxisAlignment: 0.0,
          maxWidth: isPortrait ? 600 : 500,
          actions: actions,
          progress: model.isLoading,
          debounceDelay: const Duration(milliseconds: 500),
          onQueryChanged: model.onQueryChanged,
          transition: CircularFloatingSearchBarTransition(),
          bodyBuilder: (context, transition) {
            return Material(
              color: Colors.white,
              elevation: 4.0,
              borderRadius: BorderRadius.circular(8),
              child: ImplicitlyAnimatedList<Place>(
                shrinkWrap: true,
                items: model.suggestions.take(6).toList(),
                physics: const NeverScrollableScrollPhysics(),
                areItemsTheSame: (a, b) => a == b,
                itemBuilder: (context, animation, place, i) {
                  return SizeFadeTransition(
                    animation: animation,
                    child: buildItem(context, place),
                  );
                },
                updateItemBuilder: (context, animation, place) {
                  return FadeTransition(
                    opacity: animation,
                    child: buildItem(context, place),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget buildItem(BuildContext context, Place place) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final model = Provider.of<SearchModel>(context, listen: false);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () {
            FloatingSearchBar.of(context).close();
            Future.delayed(
              const Duration(milliseconds: 500),
              () => model.clear(),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                SizedBox(
                  width: 36,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: model.suggestions == history
                        ? const Icon(Icons.history, key: Key('history'))
                        : const Icon(Icons.place, key: Key('place')),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      style: textTheme.subtitle1,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      place.level2Address,
                      style: textTheme.bodyText2.copyWith(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (model.suggestions.isNotEmpty && place != model.suggestions.last)
          const Divider(height: 0),
      ],
    );
  }

  Widget buildFabs() {
    return Align(
      alignment: AlignmentDirectional.bottomEnd,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(bottom: 72, end: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton(
              onPressed: () {},
              backgroundColor: Colors.white,
              child: const Icon(Icons.gps_fixed, color: Color(0xFF4d4d4d)),
            ),
            const SizedBox(height: 16),
            FloatingActionButton(
              onPressed: () {},
              backgroundColor: Colors.blue,
              child: const Icon(Icons.directions),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildBottomNavigationBar() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: BottomNavigationBar(
        currentIndex: 0,
        elevation: 16,
        showUnselectedLabels: true,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue,
        selectedFontSize: 11.5,
        unselectedFontSize: 11.5,
        unselectedItemColor: const Color(0xFF4d4d4d),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(MdiIcons.homeVariantOutline),
            title: Text('Explore'),
          ),
          BottomNavigationBarItem(
            icon: Icon(MdiIcons.homeCityOutline),
            title: Text('Commute'),
          ),
          BottomNavigationBarItem(
            icon: Icon(MdiIcons.bookmarkOutline),
            title: Text('Saved'),
          ),
          BottomNavigationBarItem(
            icon: Icon(MdiIcons.plusCircleOutline),
            title: Text('Contribute'),
          ),
          BottomNavigationBarItem(
            icon: Icon(MdiIcons.bellOutline),
            title: Text('Updates'),
          ),
        ],
      ),
    );
  }

  Widget buildMap() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 52.0),
      child: Image.asset(
        'assets/map.jpg',
        fit: BoxFit.cover,
      ),
    );
  }
}
