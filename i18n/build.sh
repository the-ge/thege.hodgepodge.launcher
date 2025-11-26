#!/bin/bash
# Version: 23
# https://techbase.kde.org/Development/Tutorials/Localization/i18n_Build_Systems
# https://techbase.kde.org/Development/Tutorials/Localization/i18n_Build_Systems/Outside_KDE_repositories
# https://invent.kde.org/sysadmin/l10n-scripty/-/blob/master/extract-messages.sh


set -eEu
# shellcheck source=/media/sync/var/linux/bin/xtra/.env-checks
. .events


help()
{
    cat << HELP

build  --  build translations for this plasmoid

USAGE:
    build TARGET [--restart]

ARGUMENTS
    TARGET      Allowed targets are 'po' or 'mo'
    --restart   Restarts plasmashell (only with 'mo' argument)

EXAMPLES:
    build po
    build mo
    build mo --restart

HELP
}

say()
{
    # https://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux
    # https://stackoverflow.com/questions/911168/how-can-i-detect-if-my-shell-script-is-running-through-a-pipe
    # \033[1m   bold
    # \033[94m  lightblue
    # \033[90m  lightgray
    # \033[92m  lightgreen
    # \033[91m  lightred
    # \033[33m  orange
    # \033[31m  red
    # \033[93m  yellow
    local text color level indent=' ' gray='\033[90m' reset='\033[0m'
    level="$1"
    text="$2"
    color="$3"
    prefix="${4:-}"
    [ -n "$prefix" ] && prefix="[$prefix]"
    prefix="$( printf '%-8s' "$prefix" )"
    if [ ! -t 1 ]; then # check if output is not a TTY (https://unix.stackexchange.com/questions/401934/how-do-i-check-whether-my-shell-is-running-in-a-terminal#answer-401938)
        color=''
        reset=''
    fi

    for (( i = 0; i < level; i++ )); do indent+='    '; done

    echo -e "${gray}${prefix}${reset}${indent}${color}${text//$'\n'/$'\n'$prefix$indent}${reset}"
}

# args: 1 - indent level, 2 - text, 3 - prefix
hint()  { say "$1" "$2" '\033[90m' "${3:-}"; } # light gray

warn()  { say "$1" "$2" '\033[33m' "${3:-}"; } # orange

panic() { say "$1" "Error: $2. Aborting..." '\033[31m' "${3:-}"; exit 1; } # red

shout() { say "$1" "$2" '\033[92m' "${3:-}"; } # light green

bold()  { say "$1" "$2" '\033[1m' "${3:-}";  } # bold

check-gettext-command()
{
    local command="$1"

    if [ -z "$( which "$command" )" ]; then
        warn 0 "$command command not found. Need to install gettext." $LINENO
        hint 0 "Running $( bold 'sudo apt install gettext' )..." $LINENO
        sudo apt install gettext
        shout 0 "...done installing gettext." $LINENO
    else
        hint 0 "gettext is installed." $LINENO
    fi
}

extract-strings()
{
    local workPath="$1" appId="$2" issuesUrl="$3" potFile="$4" listFile="$5" appRoot=".."

    find "$appRoot" -name '*.cpp' -o -name '*.h' -o -name '*.c' -o -name '*.qml' -o -name '*.js' | sort > "$listFile"

    # See Ki18n's extract-messages.sh for a full example:
    # https://invent.kde.org/sysadmin/l10n-scripty/-/blob/master/extract-messages.sh#L25
    # The -kN_ and -kaliasLocale keywords are mentioned in the Outside_KDE_repositories wiki.
    # We don't need -kN_ since we don't use intltool-extract but might as well keep it.
    # I have no idea what -kaliasLocale is used for. Googling aliasLocale found only listed kde1 code.
    # We don't need to parse -ki18nd since that'll extract messages from other domains.
    xgettext \
        --package-name="$appId" \
        --msgid-bugs-address="$issuesUrl" \
        --directory="$appRoot" \
        --directory="$workPath" \
        --files-from=infiles.list \
        --from-code=UTF-8 \
        --width=400 \
        --add-location=file \
        --c++ \
        --kde \
        -ci18n \
        -ki18n:1 -ki18nc:1c,2 -ki18np:1,2 -ki18ncp:1c,2,3 \
        -kki18n:1 -kki18nc:1c,2 -kki18np:1,2 -kki18ncp:1c,2,3 \
        -ktr2i18n:1 -kI18N_NOOP:1  -kI18N_NOOP2:1c,2 \
        -kN_:1 \
        -kaliasLocale \
        --output="$potFile" \
    || panic 0 "xgettext error" $LINENO
}

update-template()
{
    local workPot="$1" tmpPot="$2"

    if [ -f "$workPot" ]; then
        local nowDate oldDate changes
        nowDate="$( grep "POT-Creation-Date:" "$tmpPot" | sed 's/.\{3\}$//' )"
        oldDate="$( grep "POT-Creation-Date:" "$workPot" | sed 's/.\{3\}$//' )"

        sed -i 's/'"$nowDate"'/'"$oldDate"'/' "$tmpPot"

        # HACK diff returns exit code 1 when finds any difference. The ` || true` part mitigates that.
        changes="$( diff "$workPot" "$tmpPot" )" || true
        if [ -n "$changes" ]; then
            sed -i 's/'"$oldDate"'/'"$nowDate"'/' "$tmpPot"
            mv "$tmpPot" "$workPot"
            addedKeys="$( echo "$changes" | grep "> msgid" | cut -c 9- | sort )"
            removedKeys="$( echo "$changes" | grep "< msgid" | cut -c 9- | sort )"
            if [ -n "$addedKeys" ]; then
                shout 1 "Added translation strings from code:" $LINENO
                shout 2 "$addedKeys"
            elif [ -n "$removedKeys" ]; then
                shout 1 "Removed translation strings from code:" $LINENO
                shout 2 "$removedKeys"
            fi
        else
            rm "$tmpPot"
            hint 1 "No changes in '$workPot', removed '$tmpPot'." $LINENO
        fi
    else
        # template.pot didn't already exist
        mv "$tmpPot" "$workPot"
        hint 1 "No '$workPot', renamed '$tmpPot' to '$workPot'." $LINENO
    fi
}

update-metadata()
{
    local file="$1" id="$2" name="$3" year="$4" author="$5" email="$6" language="${7:-LANGUAGE}"

    sed -i 's/# SOME DESCRIPTIVE TITLE./'"# Translation of $name ($id) in $language"'/' "$file"
    sed -i 's/# Copyright (C) YEAR THE PACKAGE'"'"'S COPYRIGHT HOLDER/'"# Copyright (C) $year $author"'/' "$file"
    sed -i 's/# FIRST AUTHOR <EMAIL@ADDRESS>, YEAR./'"# $author <$email>, $year"'/' "$file"
    sed -i 's/"Content-Type: text\/plain; charset=CHARSET\\n"/"Content-Type: text\/plain; charset=UTF-8\\n"/' "$file"
}

update-translations()
{
    local translations="$1" template="$2" output="$3"

    msgmerge \
       --width=400 \
       --add-location=file \
       --no-fuzzy-matching \
       --quiet \
       --output-file="$output" \
       "$translations" "$template"
}

build-po ()
{
    check-gettext-command 'xgettext'

    local packageRoot="$1" i18nPath="$2" plasmoidId="$3" plasmoidName="$4" issuesUrl="$5" authorName="$6" authorEmail="$7" tmpPot workPot nowYear
    nowYear="$(date +%Y)"
    tmpPot='template.pot.tmp'
    workPot='template.pot'
    listFile="$i18nPath/infiles.list"

    hint 0 "Extracting translation strings..." $LINENO
    extract-strings "$i18nPath" "$plasmoidId" "$issuesUrl" "$tmpPot" "$listFile"
    update-metadata "$tmpPot" "$plasmoidId" "$plasmoidName" "$nowYear" "$authorName" "$authorEmail"
    update-template "$workPot" "$tmpPot"
    rm "$listFile"

    shout 0 "...done extracting translation strings." $LINENO

    hint 0 "Merging translation strings..." $LINENO
    for poFile in $( find . -name '*.po' | sort ); do
        local locale tmpfile="$poFile.tmp"
        locale="$( basename "${poFile%.*}" )"

        cp "$poFile" "$tmpfile"
        update-translations "$poFile" "$i18nPath/$workPot" "$tmpfile"
        update-metadata "$tmpfile" "$plasmoidName" "$plasmoidId" "$nowYear" "$authorName" "$authorEmail" "$locale"
        mv "$tmpfile" "$poFile"

        hint 1 "Updated $( basename "$poFile" )." $LINENO
    done
    shout 0 "...done merging translation strings." $LINENO
}

build-mo ()
{
    check-gettext-command 'msgfmt'

    local packageRoot="$1" i18nPath="$2" plasmoidId="$3"

    hint 0 "Compiling translations..." $LINENO

    for poFile in $( find . -name '*.po' | sort ); do
        local untranslated locale

        # HACK pcregrep returns exit code 1 if no match found. The ` || true` part mitigates that.
        untranslated="$( pcregrep -Mno1 'msgid "(.+?)".*\nmsgstr ""' "$poFile" )" || true
        if [ -n "$untranslated" ]; then
            warn 1 "$poFile - strings not translated:" $LINENO
            warn 2 "$untranslated"
        else
            hint 1 "$poFile - all translations done. Good job!"
        fi

        locale="$( basename "${poFile%.*}" )"

        msgfmt -o "$locale.mo" "$poFile"

        moFile="$packageRoot/contents/locale/$locale/LC_MESSAGES/$plasmoidId.mo"
        mkdir -p "$(dirname "$moFile")"
        mv "$locale.mo" "${moFile}"
    done
    shout 0 '...done compiling translations.' $LINENO
}

main()
{
    local i18nPath packageRoot plasmoidId plasmoidName appUrl issuesUrl authorName authorEmail
    i18nPath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    packageRoot=".."
    {
        read -r plasmoidId
        read -r plasmoidName
        read -r appUrl
        read -r issuesUrl
        read -r authorName
        read -r authorEmail
    } < <( jq -r '.KPlugin.Id, .KPlugin.Name, .KPlugin.Website, .KPlugin.BugReportUrl, .KPlugin.Authors[0].Name, .KPlugin.Authors[0].Email' "$i18nPath/../metadata.json" )
    [ -z "$plasmoidId" ] && panic 0 "couldn't read plasmoidId" $LINENO
    [ -n "$issuesUrl" ] || issuesUrl="$appUrl"

    case "$1" in
        -h|--help)
            help
            ;;

        'po')

            build-po "$packageRoot" "$i18nPath" "$plasmoidId" "$plasmoidName" "$issuesUrl" "$authorName" "$authorEmail"
            ;;

        'mo')
            build-mo "$packageRoot" "$i18nPath" "$plasmoidId" "$plasmoidName" "$issuesUrl" "$authorName" "$authorEmail"

            if [ "${2:-}" = "--restart" ]; then
                hint 0 'Restarting plasmashell...' $LINENO
                killall plasmashell && kstart plasmashell
                shout 0 "...done restarting plasmashell" $LINENO
            else
                warn 0 "[!] (Re)install the plasmoid and restart plasmashell to test translations." $LINENO
            fi
            ;;

         *) logErrorAndExit "Unsupported option: $1"; help;;
    esac
}

main "$@"
