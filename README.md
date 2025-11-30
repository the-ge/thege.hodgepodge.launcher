# Hodpodge Application Launcher for KDE6

## FEATURES

- configuration options:
    - the launcher can start with favorites, places or one of the existing categories
    - user avatar size
    - grids icons size
    - lists icons size
    - separator lines width
    - separator lines color
    - toolbar action buttons can be all moved to the overflow menu, in addition to the former power/session/power+session options

## TRANSLATE

1. Translate in the "<your language>.po" file.
2. Install `gettext`.
3. Compile the translation:
    ```sh
    cd ../../     # go outside of the plasmoid root
    ./build.sh mo # to compile the translations
    ```
4. Test your translation:
    ```sh
    cd ./thege.hodgepodge.launcher # go to the metadata.json location
    kpackagetool6 --type Plasma/Applet --upgrade .
    systemctl --user restart plasma-plasmashell.service
    ```

## TEST

1. Using `plasmoidviewer`:
    ```sh
    plasmoidviewer --size 960x720 --location bottomedge --formfactor horizontal --applet .
    plasmoidviewer --size 960x720 --location leftedge --formfactor vertical --applet .
    plasmoidviewer --help
    ```

2. Installing on your system:

    2.1. Launch the install utility from the utilities folder:
    ```sh
    cd path/to/the/package/root # where this README is
    ./bin/plasmoid-install
    ```

    2.2. Right-click on the taskbar and choose 'Add or Manage Widgets', then drag and drop this widget to the taskbar.

## UTILITIES

### Plasmoid

- `plasmoid-install`
- `plasmoid-upgrade`
- `plasmoid-uninstall`

### Internationalisation

- `i18n-extract`
- `i18n-new`
- `i18n-compile`
- `i18n-status`

### Restart plasmashell

```sh
systemctl --user restart plasma-plasmashell.service
```

or

```sh
killall plasmashell && kstart plasmashell
```

## TODO

May take quite a while.

- [x] Fix 'All Applications' binding loop bug (grid icon size seems undefined).
- [x] Make horizontal line separator in the sidebar use settings.
- [x] Add separator between Power and Session buttons.
- [x] Fix compactRepresentation height when placed on vertical panel.
- [x] Add configuration for the user avatar size.
- [ ] Test if adding (again) the i18nContext to the singleton helps with the 'Applications' and 'Places' translations. If not, get them from KDE Kicker.
- [ ] Add utility to pack the plasmoid for KDE Store
    - check if KDE Store accepts .plasmoid files
    - compile translations
    - zip: cd src; zip contents/, translate/, metadata.json
    - change extension to plasmoid
    - zip the plasmoid - name uses version from metadata.json
- [ ] Add `--check-punctuation` option for `i18n-status`, to make the punctuation check opt-in.
- [ ] Remove the caret-down from the launcher icon configuration control.
- [x] Add 'Start in:' setting (Favorites/All Applications/Deveopment/Education/...)
- [ ] Add UI and row count configuration for recent apps
- [ ] Add `highlightNewlyInstalledApps` setting (see [rootmodel.h](https://invent.kde.org/plasma/plasma-workspace/-/blob/master/applets/kicker/rootmodel.h))
- [ ] Place and order individually footer buttons in or out of overflow (drag-and-drop).
- [ ] Modify it to be more like in Windows 10:
    - left column with buttons
    - middle pane with application list group either alphabetically or by categories
    - right pane with tiles
