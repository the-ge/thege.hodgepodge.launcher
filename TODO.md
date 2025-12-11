# :construction: Hodpodge Launcher TODO

May take quite a while. Also some todos may not make it to code.

*Some of the following items are bugfixes for issues solved before creating this repository.*

1. **Issues**

    - [ ] Remove the caret-down from the launcher icon configuration control.

2. **Features**

    - [ ] Add `highlightNewlyInstalledApps` setting (see [rootmodel.h](https://invent.kde.org/plasma/plasma-workspace/-/blob/master/applets/kicker/rootmodel.h))
    - [ ] Highlight recently installed applications.
    - [ ] Move 'Recently Used Applications' and 'Most Used Applications' out of 'Places'
    - [ ] Add count configuration for 'Recently Used Applications' and 'Most Used Applications'
    - [ ] Place and order individually footer buttons in or out of overflow (drag-and-drop).
    - [ ] Remove implicit categories (shortcuts and about) or - at least - change their icons (needs C++ plugin).
    - [ ] Modify it to be more like in Windows 10:
        - left column with buttons
        - middle pane with application list group either alphabetically or by categories
        - right pane with tiles

3. **Utilities**

    - [ ] Add `--check-punctuation` option for `i18n-status`, to make the punctuation check opt-in.

4. **Repository**

    - [ ] ~~Add contributor column to the translations table.~~ **If translations are added by PRs, their authors become contributors automatically. Put on hold until a need appears.**
