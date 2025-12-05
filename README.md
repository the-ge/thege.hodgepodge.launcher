# Hodpodge Application Launcher for KDE6

## SCREENSHOTS

![Default settings (48px grid) vs my settings(64px grid)](https://github.com/user-attachments/assets/de2351db-83d2-4f83-921d-cc540fe5149e)

![Default settings (32px list)](https://github.com/user-attachments/assets/e502e142-23f6-47ef-a158-93ac6c0da52f)

![Grid variants: 128px vs 16px](https://github.com/user-attachments/assets/ba353256-bd98-44ca-91b1-b64f9a899515)

![List variants: 1280px vs 16px](https://github.com/user-attachments/assets/862ebf2d-f8b2-4728-a8b3-7e5df32d8471)

![Configuration options](https://github.com/user-attachments/assets/b0b7d127-5288-4701-af9c-708ac8bb2105)

## INSTALLATION

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

> [!NOTE]
> Only the KDE Store package contains compiled translations, so it should be a bit faster, at least in theory. Of course, one could compile the translations (see step 4 in [HOW TO TRANSLATE](#how-to-translate)) before installing from GitHub).

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
> Note: the utility will attempt to install gettext if not already installed.

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

#### 5.1 Test your translation using `plasmoidviewer` in your translation's locale, i.e.

> [!NOTE]
> The configuration translations will not available when testing using this method.

```sh
LC_ALL=en_UK.utf8 plasmoidviewer --applet .
```

```sh
LC_ALL=ro_RO.utf8 plasmoidviewer --applet .
```

#### 5.2 Test your translation by installing on your system (having set the right locale) from the cloned repository (see INSTALLATION, [method #3](#3-manually-cloning-the-github-repository)).

## TEST

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

## :construction: TODO

May take quite a while.

- [x] Fix 'All Applications' binding loop bug (grid icon size seems undefined).
- [x] Make horizontal line separator in the sidebar use settings.
- [x] Add separator between Power and Session buttons.
- [x] Fix compactRepresentation height when placed on vertical panel.
- [x] Add configuration for the user avatar size.
- [x] Add 'Start in:' setting (Favorites/All Applications/Deveopment/Education/...)
- [ ] Test if adding (again) the i18nContext to the singleton helps with the 'Applications' and 'Places' translations. If not, get them from KDE Kicker.
- [ ] Add contributor column to the translations table.
- [ ] Add proper credits.
- [ ] Add explanations to the README utilities section.
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

## CREDITS

- KDE team (Plasma Framework, Kickoff, what else?)
- Chris Holland (Tiled Menu, tutorials)
- Jin Liu (Kickon, i18n)
- Claudio Catterina (PlasMusic Toolbar, i18n, repository presentation)
