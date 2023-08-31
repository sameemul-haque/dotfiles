#! /usr/bin/env bash

set -Eeo pipefail

readonly REPO_DIR="$(dirname "$(readlink -m "${0}")")"

MY_USERNAME="${SUDO_USER:-$(logname 2> /dev/null || echo "${USER}")}"
MY_HOME=$(getent passwd "${MY_USERNAME}" | cut -d: -f6)

THEME_NAME="WhiteSur"

edit_firefox="false"

FIREFOX_SRC_DIR="${REPO_DIR}/src"
FIREFOX_DIR_HOME="${MY_HOME}/.mozilla/firefox"
FIREFOX_THEME_DIR="${MY_HOME}/.mozilla/firefox/firefox-themes"
FIREFOX_FLATPAK_DIR_HOME="${MY_HOME}/.var/app/org.mozilla.firefox/.mozilla/firefox"
FIREFOX_FLATPAK_THEME_DIR="${MY_HOME}/.var/app/org.mozilla.firefox/.mozilla/firefox/firefox-themes"
FIREFOX_SNAP_DIR_HOME="${MY_HOME}/snap/firefox/common/.mozilla/firefox"
FIREFOX_SNAP_THEME_DIR="${MY_HOME}/snap/firefox/common/.mozilla/firefox/firefox-themes"

export c_default="\033[0m"
export c_blue="\033[1;34m"
export c_magenta="\033[1;35m"
export c_cyan="\033[1;36m"
export c_green="\033[1;32m"
export c_red="\033[1;31m"
export c_yellow="\033[1;33m"

prompt() {
  case "${1}" in
    "-s")
      echo -e "  ${c_green}${2}${c_default}" ;;    # print success message
    "-e")
      echo -e "  ${c_red}${2}${c_default}" ;;      # print error message
    "-w")
      echo -e "  ${c_yellow}${2}${c_default}" ;;   # print warning message
    "-i")
      echo -e "  ${c_cyan}${2}${c_default}" ;;     # print info message
  esac
}

has_command() {
  command -v "$1" &> /dev/null
}

has_flatpak_app() {
  flatpak list --columns=application | grep "${1}" &> /dev/null || return 1
}

has_snap_app() {
  snap list "${1}" &> /dev/null || return 1
}

udoify_file() {
  if [[ -f "${1}" && "$(ls -ld "${1}" | awk '{print $3}')" != "${MY_USERNAME}" ]]; then
    sudo chown "${MY_USERNAME}:" "${1}"
  fi
}

helpify_title() {
  printf "${c_cyan}%s${c_blue}%s ${c_green}%s\n\n" "Usage: " "$0" "[OPTIONS...]"
  printf "${c_cyan}%s\n" "OPTIONS:"
}

helpify() {
  printf "  ${c_blue}%s ${c_green}%s\n ${c_magenta}%s. ${c_cyan}%s\n\n${c_default}" "${1}" "${2}" "${3}" "${4}"
}

usage() {
  helpify_title
  helpify "-m, --monterey"          ""                                   "Install 'Monterey' theme for Firefox and connect it to the current Firefox profiles"                        ""
  helpify "-a, --alt"               ""                                   "Install 'Monterey' theme alt version for Firefox and connect it to the current Firefox profiles"            ""
  helpify "-e, --edit"              ""                                   "Edit '${THEME_NAME}' theme for Firefox settings and also connect the theme to the current Firefox profiles" ""
  helpify "-r, --remove, --revert"  ""                                   "Remove themes, do the opposite things of install and connect"                                               ""
  helpify "-h, --help"              ""                                   "Show this help"                                                                                             ""
}

install_firefox_theme() {
  if has_snap_app firefox; then
    local TARGET_DIR="${FIREFOX_SNAP_THEME_DIR}"
  elif has_flatpak_app org.mozilla.firefox; then
    local TARGET_DIR="${FIREFOX_FLATPAK_THEME_DIR}"
  else
    local TARGET_DIR="${FIREFOX_THEME_DIR}"
  fi

  local name=${1}

  mkdir -p                                                                                    "${TARGET_DIR}"
  cp -rf "${FIREFOX_SRC_DIR}/${name}"                                                         "${TARGET_DIR}"
  [[ -f "${TARGET_DIR}"/customChrome.css ]] && mv "${TARGET_DIR}"/customChrome.css "${TARGET_DIR}"/customChrome.css.bak
  cp -rf "${FIREFOX_SRC_DIR}"/customChrome.css                                                "${TARGET_DIR}"
  cp -rf "${FIREFOX_SRC_DIR}"/common/{icons,titlebuttons,pages}                               "${TARGET_DIR}/${name}"
  cp -rf "${FIREFOX_SRC_DIR}"/common/*.css                                                    "${TARGET_DIR}/${name}"
  cp -rf "${FIREFOX_SRC_DIR}"/common/parts/*.css                                              "${TARGET_DIR}/${name}"/parts
  [[ -f "${TARGET_DIR}"/userChrome.css ]] && mv "${TARGET_DIR}"/userChrome.css "${TARGET_DIR}"/userChrome.css.bak
  cp -rf "${FIREFOX_SRC_DIR}"/userChrome-"${name}".css                                        "${TARGET_DIR}"/userChrome.css
  [[ -f "${TARGET_DIR}"/userContent.css ]] && mv "${TARGET_DIR}"/userContent.css "${TARGET_DIR}"/userContent.css.bak
  cp -rf "${FIREFOX_SRC_DIR}"/userContent-"${name}".css                                       "${TARGET_DIR}"/userContent.css

  if [[ "${alt}" == 'true' && "${name}" == 'Monterey' ]]; then
    cp -rf "${FIREFOX_SRC_DIR}"/userChrome-Monterey-alt.css                                   "${TARGET_DIR}"/userChrome.css
    cp -rf "${FIREFOX_SRC_DIR}"/WhiteSur/parts/headerbar-urlbar.css                           "${TARGET_DIR}"/Monterey/parts/headerbar-urlbar-alt.css
  fi

  config_firefox
}

config_firefox() {
  if has_snap_app firefox; then
    local TARGET_DIR="${FIREFOX_SNAP_THEME_DIR}"
    local FIREFOX_DIR="${FIREFOX_SNAP_DIR_HOME}"
  elif has_flatpak_app org.mozilla.firefox; then
    local TARGET_DIR="${FIREFOX_FLATPAK_THEME_DIR}"
    local FIREFOX_DIR="${FIREFOX_FLATPAK_DIR_HOME}"
  else
    local TARGET_DIR="${FIREFOX_THEME_DIR}"
    local FIREFOX_DIR="${FIREFOX_DIR_HOME}"
  fi

  killall "firefox" "firefox-bin" &> /dev/null || true

  for d in "${FIREFOX_DIR}/"*"default"*; do
    if [[ -f "${d}/prefs.js" ]]; then
      rm -rf                                                                                  "${d}/chrome"
      ln -sf "${TARGET_DIR}"                                                                  "${d}/chrome"
      udoify_file                                                                             "${d}/prefs.js"
      echo "user_pref(\"toolkit.legacyUserProfileCustomizations.stylesheets\", true);" >>     "${d}/prefs.js"
      echo "user_pref(\"browser.tabs.drawInTitlebar\", true);" >>                             "${d}/prefs.js"
      echo "user_pref(\"browser.uidensity\", 0);" >>                                          "${d}/prefs.js"
      echo "user_pref(\"layers.acceleration.force-enabled\", true);" >>                       "${d}/prefs.js"
      echo "user_pref(\"mozilla.widget.use-argb-visuals\", true);" >>                         "${d}/prefs.js"
    fi
  done
}

edit_firefox_theme_prefs() {
  if has_snap_app firefox; then
    local TARGET_DIR="${FIREFOX_SNAP_THEME_DIR}"
  elif has_flatpak_app org.mozilla.firefox; then
    local TARGET_DIR="${FIREFOX_FLATPAK_THEME_DIR}"
  else
    local TARGET_DIR="${FIREFOX_THEME_DIR}"
  fi

  install_firefox_theme ; config_firefox
  ${EDITOR:-nano}                                                                            "${TARGET_DIR}/userChrome.css"
  ${EDITOR:-nano}                                                                            "${TARGET_DIR}/customChrome.css"
}

remove_firefox_theme() {
  #rm -rf "${FIREFOX_DIR_HOME}/"*"default"*"/chrome"
  rm -rf "${FIREFOX_THEME_DIR}/${THEME_NAME}"
  [[ -f "${FIREFOX_THEME_DIR}"/customChrome.css ]] && rm -rf "${FIREFOX_THEME_DIR}"/customChrome.css
  [[ -f "${FIREFOX_THEME_DIR}"/userChrome.css ]] && rm -rf "${FIREFOX_THEME_DIR}"/userChrome.css
  #rm -rf "${FIREFOX_FLATPAK_DIR_HOME}/"*"default"*"/chrome"
  rm -rf "${FIREFOX_FLATPAK_THEME_DIR}/${THEME_NAME}"
  [[ -f "${FIREFOX_FLATPAK_THEME_DIR}"/customChrome.css ]] && rm -rf "${FIREFOX_FLATPAK_THEME_DIR}"/customChrome.css
  [[ -f "${FIREFOX_FLATPAK_THEME_DIR}"/userChrome.css ]] && rm -rf "${FIREFOX_FLATPAK_THEME_DIR}"/userChrome.css
  #rm -rf "${FIREFOX_SNAP_DIR_HOME}/"*"default"*"/chrome"
  rm -rf "${FIREFOX_SNAP_THEME_DIR}/${THEME_NAME}"
  [[ -f "${FIREFOX_SNAP_THEME_DIR}"/customChrome.css ]] && rm -rf "${FIREFOX_SNAP_THEME_DIR}"/customChrome.css
  [[ -f "${FIREFOX_SNAP_THEME_DIR}"/userChrome.css ]] && rm -rf "${FIREFOX_SNAP_THEME_DIR}"/userChrome.css
}

echo

while [[ $# -gt 0 ]]; do
  case "${1}" in
    -m|--monterey)
      monterey="true"
      THEME_NAME="Monterey"
      shift ;;
    -a|--alt)
      alt="true"
      monterey="true"
      THEME_NAME="Monterey"
      shift ;;
    -r|--remove|--revert)
      uninstall='true'; shift ;;
    -h|--help)
      echo; usage; echo
      exit 0 ;;
    -e|--edit)
      edit_firefox='true'

      if ! has_command firefox && ! has_flatpak_app org.mozilla.firefox && ! has_snap_app firefox; then
        prompt -e "'${1}' ERROR: There's no Firefox installed in your system"
      elif [[ ! -d "${FIREFOX_DIR_HOME}" && ! -d "${FIREFOX_FLATPAK_DIR_HOME}" && ! -d "${FIREFOX_SNAP_DIR_HOME}" ]]; then
        prompt -e "'${1}' ERROR: Firefox is installed but not yet initialized."
        prompt -w "'${1}': Don't forget to close it after you run/initialize it"
      elif pidof "firefox" &> /dev/null || pidof "firefox-bin" &> /dev/null; then
        prompt -e "'${1}' ERROR: Firefox is running, please close it"
      fi; shift ;;
    *)
      prompt -e "ERROR: Unrecognized tweak option '${1}'."
      shift ;;
  esac
done

if [[ "${uninstall}" == 'true' ]]; then
    prompt -i "Removing '${THEME_NAME}' Firefox theme...\n"
    remove_firefox_theme
    prompt -s "Done! '${THEME_NAME}' Firefox theme has been removed."
else
    prompt -i "Installing '${THEME_NAME}' Firefox theme...\n"
    install_firefox_theme "${name:-${THEME_NAME}}"
    prompt -s "Done! '${THEME_NAME}' Firefox theme has been installed.\n"

    if [[ "${edit_firefox}" == 'true' ]]; then
      prompt -i "Editing '${THEME_NAME}' Firefox theme preferences...\n"
      edit_firefox_theme_prefs
      prompt -s "Done! '${THEME_NAME}' Firefox theme preferences has been edited.\n"
    fi

    prompt -w "FIREFOX: Please go to [Firefox menu] > [Customize...], and customize your Firefox to make it work. Move your 'new tab' button to the titlebar instead of tab-switcher.\n"
    prompt -i "FIREFOX: Anyways, you can also edit 'userChrome.css' and 'customChrome.css' later in your Firefox profile directory.\n"
fi
