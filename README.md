# Hodpodge Application Launcher for KDE6

## Features

- configuration options:
    - the launcher can start with favorites, places or one of the existing categories
    - user icon size
    - grids icons size
    - lists icons size
    - separator lines width
    - separator lines color
    - toolbar action buttons can be all moved to the overflow menu, in addition to the former power/session/power+session options

## TODO

May take quite a while.

- [x] Fix 'All Applications' binding loop bug (grid icon size seems undefined).
- [x] Make horizontal line separator in the sidebar use settings.
- [x] Add separator between Power and Session buttons.
- [x] Fix compactRepresentation height when placed on vertical panel.
- [x] Add configuration for avatar (user icon) size.
- [ ] Remove the caret-down from the launcher icon configuration control.
- [x] Add 'Start in:' setting (Favorites/All Applications/Deveopment/Education/...)
- [ ] Add UI and row count configuration for recent apps
- [ ] Add `highlightNewlyInstalledApps` setting (see [rootmodel.h](https://invent.kde.org/plasma/plasma-workspace/-/blob/master/applets/kicker/rootmodel.h))
- [ ] Place and order individually footer buttons in or out of overflow (drag-and-drop).
- [ ] Modify it to be more like in Windows 10:
    - left column with buttons
    - middle pane with application list group either alphabetically or by categories
    - right pane with tiles

### TEST

```sh
plasmoidviewer --help
plasmoidviewer --version
plasmoidviewer --size 960x720 --location bottomedge --formfactor horizontal --applet .
plasmoidviewer --size 960x720 --location leftedge --formfactor vertical --applet .
```