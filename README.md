# Hodpodge Application Launcher for KDE6

## INSTALLATION

### 1. Using [pling-store](https://www.opendesktop.org/p/1175480/) or [ocs-url](https://www.opendesktop.org/p/1136805/)

Go to the KDE Store (https://store.kde.org/p/2330881) and click on `Install`.

### 2. Manually, using the zip from the KDE Store (https://store.kde.org/p/2330881)

1. Go to the KDE Store (https://store.kde.org/p/2330881) and click on `Download`.
2. Extract the archive content.
3. Drag and drop the archive on the desktop and choose `Install` from the menu that appeared.

### 3. Manually, cloning the GitHub repository

1. Get the files from the GitHub repository page (https://github.com/the-ge/thege.hodgepodge.launcher):
    - Go to the GitHub repository page and click `Code` > `Download ZIP`, then extract it to your system.
    - or clone the repository.

2. Go to the extracted files root (where README.md is) and open a terminal, then run the plasmoid install utility:
```sh
./bin/plasmoid-install
```

3. Right-click on the taskbar and choose 'Add or Manage Widgets', then drag and drop this widget to the taskbar.

## FEATURES

### New configuration options:

- the launcher can start with favorites, places or one of the existing categories
- user avatar size
- grids icons size
- lists icons size
- separator lines width
- separator lines color
- toolbar action buttons can be all moved to the overflow menu, in addition to the former power/session/power+session options

## TRANSLATE

1. Extraxt translatable strings from the plasmoid code:
```sh
./bin/i18n-extract
```
    Note: the utility will attempt to install gettext if not already installed.

2. Create your language catalog file, if it does not already exist:
```sh
./bin/i18n-new <LANGUAGE_CODE> # <LANGUAGE_CODE> i.e. de, en_UK
```

3. Translate the strings in the `/src/translate/<LANGUAGE_CODE>.po` file.

4. Compile the translation:
```sh
./bin/i18n-compile
```

5. Test your translation using the methods in the next chapter.

## TEST

1. Using `plasmoidviewer`:
    ```sh
    plasmoidviewer --size 960x720 --location bottomedge --formfactor horizontal --applet .
    plasmoidviewer --size 960x720 --location leftedge --formfactor vertical --applet .
    plasmoidviewer --help
    ```

2. Installing on your system (see INSTALLATION, [method #3](#3-manually-cloning-the-github-repository)).

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
- [x] Add 'Start in:' setting (Favorites/All Applications/Deveopment/Education/...)
- [ ] Test if adding (again) the i18nContext to the singleton helps with the 'Applications' and 'Places' translations. If not, get them from KDE Kicker.
- [ ] Add contributor column to the translations table.
- [ ] Add utility to pack the plasmoid for KDE Store
    - check if KDE Store accepts .plasmoid files
    - compile translations
    - zip: cd src; zip contents/, translate/, metadata.json
    - change extension to plasmoid
    - zip the plasmoid - name uses version from metadata.json
- [ ] Add `--check-punctuation` option for `i18n-status`, to make the punctuation check opt-in.
- [ ] Remove the caret-down from the launcher icon configuration control.
- [ ] Add UI and row count configuration for recent apps
- [ ] Add `highlightNewlyInstalledApps` setting (see [rootmodel.h](https://invent.kde.org/plasma/plasma-workspace/-/blob/master/applets/kicker/rootmodel.h))
- [ ] Place and order individually footer buttons in or out of overflow (drag-and-drop).
- [ ] Modify it to be more like in Windows 10:
    - left column with buttons
    - middle pane with application list group either alphabetically or by categories
    - right pane with tiles

## CONTRIBUTORS

- Heimen Stoffels (https://github.com/Vistaus): NL translation

## CREDITS

TODO: add
- KDE team (Plasma Framework, Kickoff, what else?)
- Chris Holland (Tiled Menu, tutorials)
- Jin Liu (Kickon, i18n)
- Claudio Catterina (PlasMusic Toolbar, i18n, repository presentation)