# Hodpodge Application Launcher for KDE6

## SCREENSHOTS

![Default settings (48px grid) vs my settings(64px grid)](https://github.com/user-attachments/assets/de2351db-83d2-4f83-921d-cc540fe5149e)

![Default settings (32px list)](https://github.com/user-attachments/assets/e502e142-23f6-47ef-a158-93ac6c0da52f)

![Grid variants: 128px vs 16px](https://github.com/user-attachments/assets/ba353256-bd98-44ca-91b1-b64f9a899515)

![List variants: 1280px vs 16px](https://github.com/user-attachments/assets/862ebf2d-f8b2-4728-a8b3-7e5df32d8471)

![Configuration options](https://github.com/user-attachments/assets/b0b7d127-5288-4701-af9c-708ac8bb2105)

## INSTALLATION

> [!NOTE]
> Only the KDE Store package contains compiled translations, so it should be a bit faster, at least in theory. Of course, one could compile the translations (see step 4 in [HOW TO TRANSLATE](#how-to-translate)) before installing from GitHub).

### 1. Using [pling-store](https://www.opendesktop.org/p/1175480/) or [ocs-url](https://www.opendesktop.org/p/1136805/)

Go to the KDE Store (https://store.kde.org/p/2330881) and click on `Install`.

### 2. Manually, using the plasmoid from the KDE Store

1. Go to the KDE Store (https://store.kde.org/p/2330881) and click on `Download`.
2. Right-click on the taskbar and choose `Add or Manage Widgets`.
3. Click on the `Get New` button and choose 'Install Widget From Local File'
4. Navigate to the folder where is the plasmoid and choose it.
5. You may need to exit the KDE widget interface and re-enter to be able to see the new plasmoid. If so, right-click again on the taskbar and choose `Add or Manage Widgets`.
5. Click on the plasmoid in the widget list, then drag and drop this widget to the taskbar.

### 3. Manually, cloning the GitHub repository

1. Get the files from the GitHub repository page (https://github.com/the-ge/thege.hodgepodge.launcher):
    - Go to the GitHub repository page and click `Code` > `Download ZIP`, then extract it to your system.
    - or clone the repository.
2. Go to the extracted files root (where README.md is) and open a terminal, then run the plasmoid install utility:
```sh
./bin/plasmoid-install
```
3. Right-click on the taskbar and choose `Add or Manage Widgets`.
4. Click on the plasmoid in the widget list, then drag and drop this widget to the taskbar.

## FEATURES

### New configuration options:

- the launcher can start with favorites, places or one of the existing categories
- user avatar size
- grids icons size
- lists icons size
- separator lines width
- separator lines color
- toolbar action buttons can be all moved to the overflow menu, in addition to the former power/session/power+session options

## TRANSLATION STATUS
            

| Locale | ¹Translatable | Translated | ²Translated Ratio |
| :---   |          ---: |       ---: |              ---: |
| nl     | ✅         78 |         78 | ✅        100.00% |
| ro     | ✅         78 |         78 | ✅        100.00% |

*¹ The language file translatable string count is checked to be the same as in the template.*

*² The language file translated string ratio is checked to be 100%.*

> [!TIP]
> See more details at [i18n-status.md](i18n-status.md).

## HOW TO TRANSLATE

### 1. Extract translatable strings from the plasmoid code:

```sh
./bin/i18n-extract
```

> [!NOTE]
> `./bin/i18n-extract` will attempt to install gettext if not already installed.

### 2. Create your language catalog file, if it does not already exist:
```sh
./bin/i18n-new <LANGUAGE_CODE> # <LANGUAGE_CODE> i.e. de, en_UK
```

### 3. Translate the strings in the `/src/translate/<LANGUAGE_CODE>.po` file.

### 4. Compile the translation:
```sh
./bin/i18n-compile
```

### 5. Test your translation

#### 5.1 Check that your system has the locale for the language you're translating:

```sh
locale --all
```

#### 5.2 Rebuild translations and install/upgrade the plasmoid:

```sh

# if this plasmoid is not already installed
./bin/i18n-extract && ./bin/i18n-compile && ./bin/plasmoid-install

# if this plasmoid is already installed
# ./bin/plasmoid-upgrade will also restart plasmashell
./bin/i18n-extract && ./bin/i18n-compile && ./bin/plasmoid-upgrade
 
```

> [!NOTE]
> `./bin/plasmoid-upgrade` will also restart plasmashell

## TESTING

1. Using `plasmoidviewer`:
    ```sh
    plasmoidviewer --size 960x720 --location bottomedge --formfactor horizontal --applet .
    plasmoidviewer --size 960x720 --location leftedge --formfactor vertical --applet .
    plasmoidviewer --help
    ```

    If you are testing translations, add the locale of your translation, i.e.

    ```sh
    LC_ALL=ro_RO.utf8 plasmoidviewer --size 960x720 --applet .
    ```

2. Installing on your system from the cloned repository (see INSTALLATION, [method #3](#3-manually-cloning-the-github-repository)).

3. View the plasmashell system logs:
    ```sh
    journalctl -f /usr/bin/plasmashell
    ```

## UTILITIES (in the `/bin/` folder)

### Plasmoid

- `plasmoid-install`

- `plasmoid-upgrade` (also restarts `plasmashell`)

- `plasmoid-uninstall`

- `plasmoid-generate` (generates a .plasmoid package versioned by `/src/metadata.json`)

### Internationalisation

- `i18n-test`: displays a concise translations status (it is meant for use in a GitHub action, though it only works locally for now).

- `i18n-status`: displays translations status, alog with some tests' results.

- `i18n-extract`: extracts translatable strings from code and existing i18n catalogs into a new `template.pot` i18n template file.

- `i18n-new`: generates a new i18n catalog (.po) file; takes a language code argument, i.e.
    ```sh
    ./bin/i18n-new de
    ```

    or

    ```sh
    ./bin/i18n-new en_UK
    ```

- `i18n-compile`: compiles existing i18n catalog (.po) files to machine object (.mo) files, i.e. `/src/translate/nl.po` to `/src/contents/locale/nl/LC_MESSAGES/plasma_applet_thege.hodgepodge.launcher.mo`.

### Restart plasmashell

```sh
systemctl --user restart plasma-plasmashell.service
```

or

```sh
killall plasmashell && kstart plasmashell
```

## :construction: TODO

May take quite a while. Also some todos may not make it to code.

*Some of the following items are bugfixes for issues solved before creating this repository.*

- [x] Fix 'All Applications' binding loop bug (grid icon size seems undefined).
- [x] Make horizontal line separator in the sidebar use settings.
- [x] Add separator between Power and Session buttons.
- [x] Fix compactRepresentation height when placed on vertical panel.
- [x] Add configuration for the user avatar size.
- [x] Add 'Start in:' setting (Favorites/All Applications/Deveopment/Education/...)
- [x] Test if adding (again) the i18nContext to the singleton helps with the 'Applications' and 'Places' translations. **Nope, not working.** ~~If not, get them from KDE Kicker.~~ **On second thought, I don't like the idea.**
- [ ] ~~Add contributor column to the translations table.~~ **If translations are added by PRs, their authors become contributors automatically. Put on hold until a need appears.**
- [x] Add proper credits.
- [x] Add explanations to the README utilities section.
- [x] Add utility to pack the plasmoid for KDE Store
    - [x] check if KDE Store accepts .plasmoid files **- it does**
    - [x] ~~compile translations~~ **- this step will remain outside ot this utility**
    - [x] zip: cd src; zip `contents/`, `translate/`, `metadata.json`
    - [x] change extension to plasmoid **- uses version from metadata.json**
    - [x] ~~zip the plasmoid - name uses version from metadata.json~~ **- KDE Store accepts .plasmoid uploads, so no need to zip it again**
- [ ] Add `--check-punctuation` option for `i18n-status`, to make the punctuation check opt-in.
- [ ] Remove the caret-down from the launcher icon configuration control.
- [ ] Add UI and row count configuration for recent apps
- [ ] Add `highlightNewlyInstalledApps` setting (see [rootmodel.h](https://invent.kde.org/plasma/plasma-workspace/-/blob/master/applets/kicker/rootmodel.h))
- [ ] Place and order individually footer buttons in or out of overflow (drag-and-drop).
- [ ] Modify it to be more like in Windows 10:
    - left column with buttons
    - middle pane with application list group either alphabetically or by categories
    - right pane with tiles

## CREDITS

Thanks to the following individuals/teams for their work that helped me understand things related to this plasmoid or code things into this plasmoid.

- [Chris Holland](https://github.com/Zren):
    - [Tiled Menu](https://github.com/Zren/plasma-applet-tiledmenu) (or [on KDE Store](https://store.kde.org/p/2142716/)) - my favorite launcher, whose issues with KDE 6 prompted me to make my own.
    - [Plasma Widget tutorial](https://develop.kde.org/docs/plasma/widget/) (and its [old version](https://zren.github.io/kde/docs/widget/))
    - [Plasma Widget Library](https://github.com/Zren/plasma-applet-lib)
    - [Zren's Plasma Widgets](https://github.com/Zren/plasma-applets)

- [Jin Liu](https://github.com/jinliu):
    - [Kickon](https://github.com/jinliu/plasma-applet-kickon) (or [on KDE Store](https://store.kde.org/p/2286877))

- [Claudio Catterina](https://github.com/ccatterina):
    - [PlasMusic Toolbar](https://github.com/ccatterina/plasmusic-toolbar): not directly related, but it gave me ideas about internationalization and GitHub repository presentation.

- [KDE team](https://kde.org/):
    - [Plasma Framework](https://invent.kde.org/plasma/libplasma)
    - [Kickoff](https://invent.kde.org/plasma/plasma-desktop/-/tree/master/applets/kickoff)
    - [Kicker](https://invent.kde.org/plasma/plasma-desktop/-/tree/master/applets/kickerf)
    - [KDE Developer Documentation](https://develop.kde.org/docs/)
    - [KDE API Reference](https://api.kde.org/index.html) (especially [Kirigami](https://api.kde.org/kirigami-index.html))
    - [Plasma 6 Wiki](https://community.kde.org/Plasma/Plasma_6)

- [Qt team](https://www.qt.io/)
    - [Qt QML Documentation](https://doc.qt.io/qt-6/qtqml-index.html)
    - [Qt Quick Controls Documentation](https://doc.qt.io/qt-6/qtquickcontrols-index.html)
    - [Qt Learning Hub](https://www.qt.io/qt-learning-hub)
    - [Qt Blog](https://www.qt.io/blog)
