#!/bin/bash

###################################################
#
# Small script to command line manage LaTeX
#
###################################################
# (c) Matthias Nott, SAP. Licensed under WTFPL.
###################################################

###################################################
#
# Configuration
#

#
# Your work environment
#
# Current Target

INPUT="Content/Research Proposal"

# Other Variables
INCLUDE=include.md
MOC="- -.md"
DEST=Output
FILE=document
PARSER=parser.pl

#
# LaTeX
#
TEXBIN=/Library/TeX/texbin/latex
BIBFILE=Bibliography.bib

#
# Some more internal variables. We mention
# LOGLEVEL here as you could set that on
# the environment.
#
if [[ -z $LOGLEVEL ]]; then export LOGLEVEL=INFO; fi

#
###################################################



###################################################
#
# Some more internal variables
#

#
# Save the current directory
#
export ROOT=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
export MAKE="$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" && pwd)/$(basename -- "${BASH_SOURCE[0]}")"
export DEST="${ROOT}/${DEST}"
export INPUT="${ROOT}/${INPUT}"

#
###################################################



###################################################
#
# LaTeX intermediate files for cleanup
#
tex_files=(
  "*.4ct"
  "*.4tc"
  "*.acn"
  "*.acr"
  "*.alg"
  "*.aux"
  "*.bbl"
  "*.bcf"
  "*.blg"
  "*.css"
  "*.dvi"
  "*.ent"
  "*.fdb_latexmk"
  "*.fls"
  "*.glg"
  "*.glo"
  "*.gls"
  "*.htm*"
  "*.idv"
  "*.idx"
  "*.ilg"
  "*.ind"
  "*.ist"
  "*.lbx"
  "*.lg"
  "*.loe"
  "*.lof"
  "*.log"
  "*.lot"
  "*.md"
  "*.mw"
  "*.odt"
  "*.out"
  "*.png"
  "*.run*.xml"
  "*.slg"
  "*.svg"
  "*.syg"
  "*.syi"
  "*.tmp"
  "*.toc"
  "*.xref"
  "env.tex"
  "wc.tex"
  "zzdocument.ps"
)
#
###################################################


###################################################
#
# Shared Functions
#
###################################################


pause(){
  read -p "Press [Enter] key to continue..." fackEnterKey
}


#
# read -i does not exist on Bash 3 on MacOS
#
function readinput() {
  printf "$3[$5] "
  read vmname && [ -n "$vmname" ] || vmname=$5
}


###################################################
#
# The Logging System. Copied shamelessly from
#
# http://github.com/fredpalmer/log4bash
#
# I've added error precedence so that we can
# have actual error loglevels.
#

# This should probably be the right way - didn't have time to experiment though
# declare -r INTERACTIVE_MODE="$([ tty --silent ] && echo on || echo off)"
declare -r INTERACTIVE_MODE=$([ "$(uname)" == "Darwin" ] && echo "on" || echo "off")

# Begin Logging Section
if [[ "${INTERACTIVE_MODE}" == "off" ]]
then
    # Then we don't care about log colors
    declare -r LOG_DEFAULT_COLOR=""
    declare -r LOG_ERROR_COLOR=""
    declare -r LOG_INFO_COLOR=""
    declare -r LOG_SUCCESS_COLOR=""
    declare -r LOG_WARN_COLOR=""
    declare -r LOG_DEBUG_COLOR=""
else
    declare -r LOG_DEFAULT_COLOR="\033[0m"
    declare -r LOG_ERROR_COLOR="\033[1;31m"
    declare -r LOG_INFO_COLOR="\033[1m"
    declare -r LOG_SUCCESS_COLOR="\033[1;32m"
    declare -r LOG_WARN_COLOR="\033[1;33m"
    declare -r LOG_DEBUG_COLOR="\033[1;34m"
fi


#
# Log level ranking
#
loglevels() {
    if [[ ${LOGLEVEL} == "SUCCESS" ]]; then lvl=1;
  elif [[ ${LOGLEVEL} == "ERROR"   ]]; then lvl=2;
  elif [[ ${LOGLEVEL} == "WARN"    ]]; then lvl=3;
  elif [[ ${LOGLEVEL} == "INFO"    ]]; then lvl=4;
  elif [[ ${LOGLEVEL} == "DEBUG"   ]]; then lvl=5;
  else lvl=4;
  fi;
}
loglevels;


#
# Default log function: add any of the keywords
# in front of the log message, or nothing for info
# level.
#
log() {
    if [[ $1 == "DEBUG"   && $lvl >  4 ]]; then shift; log_debug   "$@";
  elif [[ $1 == "INFO"    && $lvl >  3 ]]; then shift; log_info    "$@";
  elif [[ $1 == "WARN"    && $lvl >  2 ]]; then shift; log_warn    "$@";
  elif [[ $1 == "ERROR"   && $lvl >  1 ]]; then shift; log_error   "$@";
  elif [[ $1 == "SUCCESS" && $lvl > -1 ]]; then shift; log_success "$@";
  elif [[ $lvl > 3 && $1 != "DEBUG" && $1 != "INFO" && $0 != "WARN" && $0 != "ERROR" && $0 != "SUCCESS" ]]; then
    log_info "$@";
  fi
}
_log() { log "$@"; }


#
# Print the actual log message
#
log_msg() {
    local log_text="$1"
    local log_level="$2"
    local log_color="$3"

    [[ -z ${log_level} ]] && log_level="INFO";
    [[ -z ${log_color} ]] && log_color="${LOG_INFO_COLOR}";

    printf "${log_color}[$(date +"%Y-%m-%d %H:%M:%S %Z")] "
    printf "[%-8s] ${log_text} ${LOG_DEFAULT_COLOR}\n" ${log_level};
    return 0;
}


log_speak()     {
    if [[ ! ${LOGVOICE} == "true" ]]; then return; fi;
    if type -P say >/dev/null
    then
        local easier_to_say="$1";
        case "${easier_to_say}" in
            studionowdev*)
                easier_to_say="studio now dev ${easier_to_say#studionowdev}";
                ;;
            studionow*)
                easier_to_say="studio now ${easier_to_say#studionow}";
                ;;
        esac
        say "${easier_to_say}";
    fi
    return 0;
}


log_success()  { if [[ $lvl > -1 ]]; then log_msg "$1" "SUCCESS" "${LOG_SUCCESS_COLOR}"; fi; }
log_error()    { if [[ $lvl >  1 ]]; then log_msg "$1" "ERROR"   "${LOG_ERROR_COLOR}"; log_speak "$1"; fi; }
log_warn()     { if [[ $lvl >  2 ]]; then log_msg "$1" "WARNING" "${LOG_WARN_COLOR}"; fi; }
log_info()     { if [[ $lvl >  3 ]]; then log_msg "$1" "INFO"    "${LOG_INFO_COLOR}"; fi; }
log_debug()    { if [[ $lvl >  4 ]]; then log_msg "$1" "DEBUG"   "${LOG_DEBUG_COLOR}"; fi; }
log_captains() {
    if type -P figlet >/dev/null;
    then
        figlet -f computer -w 120 "$1";
    else
        log "$1";
    fi

    log_speak "$1";

    return 0;
}

#
# End Logging Section
###################################################



###################################################
#
# Some Variables for Colors
#

RED='\033[0;41;30m'
BLU='\033[0;34m'
GRE='\033[0;32m'
STD='\033[0;0;39m'

#
###################################################



#################################################
#
# Set Verbosity
#
#################################################

_verbose() {
  log DEBUG "+ Setting Verbose Mode"
  export VERBOSE=verbose
}

_unverbose() {
  log DEBUG "+ Unsetting Verbose Mode"
  unset VERBOSE
}

_debug() {
  log SUCCESS "+ Setting Debug Mode"
  export LOGLEVEL=DEBUG
  loglevels
}

_undebug() {
  log SUCCESS "Unsetting Debug Mode"
  export LOGLEVEL=INFO
  loglevels
}



#################################################
#
# Initial Things we mostly always want to do.
#
#################################################

_check() {
  #
  # Check for maximum level of recursion
  #
  export MAKELEVEL=$((MAKELEVEL + 1))
  if [[ $MAKELEVEL -gt  20 ]]; then
    log ERROR "! Maximum recursion level reached. Aborting."
    exit 1
  else
    log DEBUG "+ Recursion level: $MAKELEVEL"
  fi

  #
  # Report Paths
  #
  log DEBUG "+ Output: ${DEST}"
  # log DEBUG "+ Script: ${MAKE}"
  # log DEBUG "+ Root  : ${ROOT}"

  #
  # Make sure the destination directory exists
  #
  if [[ ! -d "${DEST}" ]]; then mkdir -p "${DEST}"; fi

  #
  # Change into destination directory
  #
  cd "${DEST}"

  #
  # Make sure there's a file wc.tex in the destination directory
  #
  if [[ ! -f "${DEST}/wc.tex" ]]; then touch "${DEST}/wc.tex"; fi
}



###################################################
#
# Extract Files, parse, and run Pandoc
#
###################################################

_parse () {
  log DEBUG "> parse"

  if [[ "${PARSED}" == "parsed" ]]; then
    log DEBUG "+ No parsing needed."
    log DEBUG "< parse"
    return
  fi

  #
  # If the destination directory is missing, we might
  # just have cloned from github.
  #
  if [[ ! -d "${DEST}" ]]; then
    mkdir "${DEST}"
  fi

  #
  # Remove the target file for pandoc
  #
  if [[ -f "${DEST}/${FILE}.md" ]]; then
    rm "${DEST}/${FILE}.md"
  fi

  #
  # Re-link the fig directory for graphics
  #
  if [[ -d "${INPUT}/fig" ]]; then
    if [[ -e "${DEST}/fig" || -L "${DEST}/fig" ]]; then
      rm -rf "${DEST}/fig"
    fi
    ln -s "${INPUT}/fig" "${DEST}"
  fi

  #
  # Re-link the Templates
  #
  if [[ -d "${ROOT}/templates" ]]; then
    if [[ ! -e "${DEST}/templates" && ! -L "${DEST}/templates" ]]; then
      ln -s "${ROOT}/templates" "${DEST}/templates"
    fi
  fi

  #
  # Re-link the Bibliography
  #
  if [[ -f "${ROOT}/${BIBFILE}" ]]; then
    if [[ ! -e "${DEST}/${BIBFILE}" && ! -L "${DEST}/${BIBFILE}" ]]; then
      ln -s "${ROOT}/${BIBFILE}" "${DEST}/${BIBFILE}"
    fi
  fi


  #
  # Copy the template content
  #
  # When doing so, remove all ```
  # which allow us to edit the file
  # nicely in Obsidian
  #
  if [[ -f "${INPUT}/template.md" ]]; then
    cat "${INPUT}/template.md" | grep -v \`\`\` >"${DEST}/${FILE}.md"
  fi

  #
  # Run our parser
  #
  while read i; do
    find "${INPUT}/$i" -type f -name "*md" ! -name "$MOC" 2>/dev/null |
      sort |
      tr \\n \\0 |
      xargs -0 -n1 -I % echo '%';

    find "${INPUT}/$i" -type f -name "*md" ! -name "$MOC" 2>/dev/null |
      sort |
      tr \\n \\0 |
      xargs -0 -n1 -I % cat '%' |
      perl -e 'while(<>) { print; }; print "\n\n";' |
      perl "${ROOT}/templates/${PARSER}" >>"${DEST}/${FILE}.md";
  done < "${INPUT}/${INCLUDE}"

  #
  # Run Pandoc
  #
  pandoc "${DEST}/${FILE}.md" -s -o "${DEST}/${FILE}.tex" --template "${DEST}/templates/template.tex"

  export PARSED=parsed

  log DEBUG "< parse"
}


###################################################
#
# LaTeX Run
#
###################################################


#
# Default Run
#
_run() {
  export PARSED=""
  _parse
  _pdflatex
}


#
# Create and open PDF
#
_pdf () {
  log DEBUG "> pdf"
  _run

  if [[ -f "${ROOT}/${FILE}.pdf" ]]; then
    open "${ROOT}/${FILE}.pdf"
  else
    log ERROR "! Could not create ${ROOT}/${FILE}.pdf"
  fi

  log DEBUG "< pdf"
}


#
# Just update the PDF
#
_pdflatex () {
  log DEBUG "> pdflatex"
  _check

  log INFO "+ Running pdflatex..."
  if [[ "$VERBOSE" == "verbose" ]] ; then
    yes x | pdflatex -shell-escape -enable-write18 -synctex=1 "${FILE}.tex";
  else
    yes x | pdflatex -shell-escape -enable-write18 -synctex=1 -interaction=batchmode "${FILE}.tex" >/dev/null 2>&1;
  fi;
  remake=0;

  if grep -Fq "No file ${FILE}.acr"  "${DEST}/${FILE}.log"; then "${MAKE}" $VERBOSE acronyms; remake=1; fi;
  if grep -Fq "No file ${FILE}.gls"  "${DEST}/${FILE}.log"; then "${MAKE}" $VERBOSE glossary; remake=1; fi;
  if grep -Fq "No file ${FILE}.syi"  "${DEST}/${FILE}.log"; then "${MAKE}" $VERBOSE symbols;  remake=1; fi;
  if grep -Fq "No file ${FILE}.ind"  "${DEST}/${FILE}.log"; then "${MAKE}" $VERBOSE index;    remake=1; fi;
  if grep -Fq "Please (re)run Biber" "${DEST}/${FILE}.log"; then "${MAKE}" $VERBOSE biber;    remake=1; fi;
  if grep -Fq "Please rerun LaTeX"   "${DEST}/${FILE}.log"; then remake=1; fi;
  if [[ "$remake" == "1" ]] ; then "${MAKE}" $VERBOSE pdflatex; fi;

  if [ -f "${DEST}/${FILE}.pdf" ]; then mv "${DEST}/${FILE}.pdf" "$ROOT/" >/dev/null 2>&1; fi;

  # Commenting out the following two lines until we've got synctex working with Obisidan
  # if [ -f ${DEST}/${FILE}.synctex.gz ]; then mv ${DEST}/${FILE}.synctex.gz "$ROOT/" >/dev/null 2>&1; fi;
  # if [ -f ${DEST}/${FILE}.log ];        then mv ${DEST}/${FILE}.log        "$ROOT/" >/dev/null 2>&1; fi;

  log DEBUG "< pdflatex"
}



#################################################
#
# Run htlatex
#
#################################################


#
# Create and open HTML
#
_html () {
  log DEBUG "> html"
  _parse
  _htlatex

  if [[ -f "${DEST}/${FILE}.html" ]]; then
    open "${DEST}/${FILE}.html"
  else
    log ERROR "! Could not create ${DEST}/${FILE}.html"
  fi

  log DEBUG "< html"
}


#
# Just update the HTML
#
_htlatex () {
  log DEBUG "> htlatex $VERBOSE"
  _check

  cp -a "${DEST}/${FILE}.tex" "${DEST}/${FILE}.sav.tex"

  cat "${DEST}/${FILE}.sav.tex" | perl -0777 -pe 's/\\begin{exhibit}.*?$(.*?)\\end{exhibit}/\1/gms' >"${DEST}/${FILE}.tex"

  log INFO "+ Running htlatex..."
  if [[ "$VERBOSE" == "verbose" ]] ; then
    yes x | htlatex "${FILE}.tex" #"templates/cfg/myconfig.cfg" "" "" "-interaction=batchmode";
  else
    yes x | htlatex "${FILE}.tex" >/dev/null 2>&1; #"templates/cfg/myconfig.cfg" "" "" "-interaction=batchmode" >/dev/null 2>&1;
  fi;
  remake=0;

  mv "${FILE}.sav.tex" "${FILE}.tex"

  if grep -Fq "No file ${FILE}.acr"  "$DEST/${FILE}.log"; then "${MAKE}" $VERBOSE acronyms; remake=1; log INFO "+ Needed to make Acronyms."; fi;
  if grep -Fq "No file ${FILE}.gls"  "$DEST/${FILE}.log"; then "${MAKE}" $VERBOSE glossary; remake=1; log INFO "+ Needed to make Glossary."; fi;
  if grep -Fq "No file ${FILE}.syi"  "$DEST/${FILE}.log"; then "${MAKE}" $VERBOSE symbols;  remake=1; log INFO "+ Needed to make Symbols. "; fi;
  if grep -Fq "No file ${FILE}.ind"  "$DEST/${FILE}.log"; then "${MAKE}" $VERBOSE index;    remake=1; log INFO "+ Needed to make Index.   "; fi;
  if grep -Fq "Please (re)run Biber" "$DEST/${FILE}.log"; then "${MAKE}" $VERBOSE biber;    remake=1; log INFO "+ Needed to make Biber.   "; fi;
  if grep -Fq "Please rerun LaTeX"   "$DEST/${FILE}.log"; then remake=1; fi;
  if [[ "$remake" == "1" ]] ;        then "${MAKE}" $VERBOSE pdflatex; fi;
  if [[ -f "$DEST/${FILE}.pdf" ]];   then mv "${DEST}/${FILE}.pdf" "${ROOT}" >/dev/null 2>&1; fi;

  # Commenting out the following two lines until we've got synctex working with Obisidan
  # if [ -f ${DEST}/${FILE}.synctex.gz ]; then mv ${DEST}/${FILE}.synctex.gz "$ROOT/" >/dev/null 2>&1; fi;

  log DEBUG "< htlatex"
}



#################################################
#
# Run Submit: Basically, run all.
#
#################################################

_submit () {
  log DEBUG "> submit $VERBOSE"
  _check
  _clean
  _wc
  _pdf
  _html
  log DEBUG "< submit"
}



#################################################
#
# Run Makeindex
#
#################################################

_makeindex () {
  log DEBUG "> makeindex"
  _check

  if [ ! -f "${FILE}.ist" ]; then
    "${MAKE}" $VERBOSE pdflatex;
  fi;
  if [ -f "${FILE}.${INDEXFILE}" ] ; then
    if [ "$VERBOSE" == "verbose" ] ; then
      if [ "${INDEXFILE}" == "idx" ] ; then
        makeindex "${FILE}.idx";
      fi;
      makeindex -s "${FILE}.ist" -t "${FILE}.${LOGFILE}" -o "${FILE}.${OUTFILE}" "${FILE}.${INDEXFILE}";
      exit
      if [ "${INDEXFILE}" == "idx" ] ; then
        makeindex "${FILE}.idx";
      fi;
    else
      if [ "${INDEXFILE}" == "idx" ] ; then
        makeindex "${FILE}.idx" >/dev/null 2>&1;
      fi;
      makeindex -s "${FILE}.ist" -t "${FILE}.${LOGFILE}" -o "${FILE}.${OUTFILE}" "${FILE}.${INDEXFILE}" >/dev/null 2>&1;
      if [ "${INDEXFILE}" == "idx" ] ; then
        makeindex "${FILE}.idx" >/dev/null 2>&1;
      fi;
    fi;
  fi;

  log DEBUG "< makeindex"
}


#
# Sort Acronyms
#
_acronyms () {
  log DEBUG "> acronyms"
  _check

  LOGFILE=alg OUTFILE=acr INDEXFILE=acn INDEX=acronyms _makeindex

  log DEBUG "< acronyms"
}


#
# Sort Glossary
#
_glossary () {
  log DEBUG "> glossary"
  _check

  LOGFILE=glg OUTFILE=gls INDEXFILE=glo INDEX=glossary _makeindex

  log DEBUG "< glossary"
}


#
# Sort Symbols
#
_symbols () {
  log DEBUG "> symbols"
  _check

  LOGFILE=slg OUTFILE=syi INDEXFILE=syg INDEX=symbols _makeindex

  log DEBUG "< symbols"
}


#
# Sort Index
#
_index () {
  log DEBUG "> index"
  _check

  LOGFILE=ilg OUTFILE=ind INDEXFILE=idx INDEX=index _makeindex

  log DEBUG "< index"
}



#################################################
#
# Run Biber
#
#################################################

_biber () {
  log DEBUG "> biber"
  _check

  if [ ! -f "$DEST/${FILE}.log" ]; then
    "${MAKE}" $VERBOSE pdflatex;
  fi;

  log INFO "+ Running biber..."
  if [ "$VERBOSE" == "verbose" ] ; then
    biber --output_directory="${DEST}" ${FILE};
  else \
    biber --output_directory="${DEST}" ${FILE} >/dev/null 2>&1;
  fi;

  #
  # Sometines a document.blg gets generated, so we move it away
  #
  #if [ -f "${FILE}.blg" -a "${DEST}" == "Output" ]; then mv "${FILE}.blg" Output/ >/dev/null 2>&1; fi;

  #
  # Conditionally remake indices
  #
  if grep -Fq "pdfTeX warning (dest): name{acn:" "$DEST/${FILE}.log"; then "${MAKE}" $VERBOSE acronyms; fi;
  if grep -Fq "pdfTeX warning (dest): name{glo:" "$DEST/${FILE}.log"; then "${MAKE}" $VERBOSE glossary; fi;
  if grep -Fq "pdfTeX warning (dest): name{syg:" "$DEST/${FILE}.log"; then "${MAKE}" $VERBOSE symbols;  fi;
  if grep -Fq "pdfTeX warning (dest): name{idx:" "$DEST/${FILE}.log"; then "${MAKE}" $VERBOSE index;    fi;

  log DEBUG "< biber"
}



#################################################
#
# Count Words
#
#################################################

_wc () {
  log DEBUG "> wc"
  _check
  _parse

  if [ -s "${DEST}/wc.tex" ] ; then
    if [ "$(cat "$DEST/wc.tex")" != "." ] ; then
      words=`cat "$DEST/wc.tex"`
      log SUCCESS "The document contains ${words} words."
      return;
    fi;
  fi;
  log INFO "+ Running htlatex..."

  "${MAKE}" $VERBOSE htlatex;

  if [ "$VERBOSE" == "verbose" ] ; then
    cat "${FILE}.html" | perl -p -e 'BEGIN{undef$/};s%<!-- COUNT -->%##COUNT##%sg'| perl -p -e 'BEGIN{undef$/};s%<!-- /COUNT -->%##/COUNT##%sg' | html2text | perl -0777 -ne 'print "$1\n" while /##COUNT##(.*?)##\/COUNT##/gs' | perl -p -e 'BEGIN{undef$/};s%##COUNT##%%sg' | perl -p -e 'BEGIN{undef$/};s%##/COUNT##%%sg' | perl -p -e "s%#{1,} %%gm"| perl -p -e "s%\* %%gm" | perl -p -e "s%\\[\\[.*?\\)%%gm";
  fi;
  cat   "${FILE}.html" | perl -p -e 'BEGIN{undef$/};s%<!-- COUNT -->%##COUNT##%sg'| perl -p -e 'BEGIN{undef$/};s%<!-- /COUNT -->%##/COUNT##%sg' | html2text | perl -0777 -ne 'print "$1\n" while /##COUNT##(.*?)##\/COUNT##/gs' | perl -p -e 'BEGIN{undef$/};s%##COUNT##%%sg' | perl -p -e 'BEGIN{undef$/};s%##/COUNT##%%sg' | perl -p -e "s%#{1,} %%gm"| perl -p -e "s%\* %%gm" | perl -p -e "s%\\[\\[.*?\\)%%gm" >"${DEST}/wc.log";
  cat   "${FILE}.html" | perl -p -e 'BEGIN{undef$/};s%<!-- COUNT -->%##COUNT##%sg'| perl -p -e 'BEGIN{undef$/};s%<!-- /COUNT -->%##/COUNT##%sg' | html2text | perl -0777 -ne 'print "$1\n" while /##COUNT##(.*?)##\/COUNT##/gs' | perl -p -e 'BEGIN{undef$/};s%##COUNT##%%sg' | perl -p -e 'BEGIN{undef$/};s%##/COUNT##%%sg' | perl -p -e "s%#{1,} %%gm"| perl -p -e "s%\* %%gm" | perl -p -e "s%\\[\\[.*?\\)%%gm" | wc -w | sed 's/ //g' >"${DEST}/wc.tex";
  words=`cat "$DEST/wc.tex"`
  log SUCCESS "+ The document contains ${words} words."

  log DEBUG "< wc"
}



#################################################
#
# Create Maps of Contents
#
#################################################


__moc () {
  DIR=$1
  MOC=$2

  cd "$DIR";

  if [[ -f "$MOC" ]]; then
    rm -- "$MOC"
  fi

  find . -type f -name "*md" ! -name "$MOC" 2>/dev/null |
    sort |
    sed 's|^./||' |
    tr \\n \\0 |
    xargs -0 -n1 -I % echo "![[%]]" >>"$MOC";
}
typeset -fx __moc

_moc () {
  while read i; do
    find "${INPUT}/$i" -type d 2>/dev/null |
    tr \\n \\0 |
    xargs -0 -n1 -I % bash -c "__moc \"%\" \"${MOC}\";"
  done < "${INPUT}/${INCLUDE}"

  while read i; do
    find "${INPUT}/$i" -type f -name "*md" 2>/dev/null |
      sed "s#${INPUT}/##g" |
      sort |
      tr \\n \\0 |
      xargs -0 -n1 -I % perl -e 'my $f="%"; print "[[$f]]\n"; print "![[$f]]\n";' >>"${INPUT}/${MOC}"
  #   sed "s#\(.*\)#![[\1]]#g" >>"${INPUT}/${MOC}"
  done < "${INPUT}/${INCLUDE}"

  log INFO "+ MOCs created."
}

_unmoc () {
  find "${INPUT}/" -name "${MOC}" -type f 2>/dev/null |
    tr \\n \\0 |
    xargs -0 rm -f;
  log INFO "+ MOCs removed."
}



#################################################
#
# Remove all temporary tex-files
#
#################################################

_clean () {
  log DEBUG "> clean"
  _check

  #
  # Remove all files matching pattern in tex-files
  #
  for i in ${tex_files[*]}; do
     find . -type f -name "$i" 2>/dev/null |
       sed 's|^./||' |
       tr \\n \\0 |
       xargs -0 -n1 -I % rm -f "%";
   # for f in `find "${ROOT}" -name "$i" -type f|grep -v .git|grep -v .png`; do
   #   echo rm -f "$f";
   # done;
  done

  #
  # Re-link the Bibliography file
  #
  if [[ -e "${ROOT}/${BIBFILE}" ]]; then
    if [[ -e "${DEST}/${BIBFILE}" || -L "${DEST}/${BIBFILE}" ]]; then
      rm -f "${DEST}/${BIBFILE}"
    fi
    ln -s "${ROOT}/${BIBFILE}" "${DEST}"
  fi

  #
  # Re-link the fig directory for graphics
  #
  if [[ -d "${INPUT}/fig" ]]; then
    if [[ -e "${DEST}/fig" || -L "${DEST}/fig" ]]; then
      rm -rf "${DEST}/fig"
    fi
    ln -s "${INPUT}/fig" "${DEST}"
  fi

  #
  # Re-link the templates directory for graphics
  #
  if [[ -d "${ROOT}/templates" ]]; then
    if [[ -e "${DEST}/templates" || -L "${DEST}/templates" ]]; then
      rm -rf "${DEST}/templates"
    fi
    ln -s "${ROOT}/templates" "${DEST}"
  fi

  #
  # Create the file document.ent which seems to be needed.
  #
  touch "${DEST}/${FILE}.ent";

  #
  # Unset PARSED
  #
  unset PARSED

  log DEBUG "< clean"
}



###################################################
#
# Main Menu
#
###################################################

show_menus() {
    clear
    echo -e "-------------------------------------------"
    echo -e "       ${BLU}L a T e X      C O N T R O L${STD}"
    echo -e "-------------------------------------------"
    echo ""

    echo -e "${GRE}Compose${STD}"
    echo ""
    echo -e "${GRE}[run]${STD}    Run LaTeX, update PDF"
    echo -e "${GRE}[submit]${STD} Run Submission Target"
    echo ""

    echo -e "${GRE}[pdf]${STD}    Run LaTeX,   open PDF"
    echo -e "${GRE}[html]${STD}   Run htLaTeX, open HTML"
    echo ""
    echo -e "${GRE}[p]${STD}      Run parser only"
    echo ""
    echo -e "${GRE}[moc]${STD}    Create MOCs"
    echo -e "${GRE}[unmoc]${STD}  Remove MOCs"
    echo ""
    echo -e "${GRE}[wc]${STD}     Word Count"
    echo -e "${GRE}[c]${STD}      Clean Auxiliary files"
    echo ""
    echo -e "${GRE}[d]${STD}      Set/Unset Debug   Mode"
    echo -e "${GRE}[v]${STD}      Set/Unset Verbose Mode"
    echo ""

    echo ""
}

read_options(){
    trap 'echo "";exit 0' SIGINT
    local choice
    #read -p "${BLU}Enter${STD} to run, choice or q to exit: " choice
    read -p "$(echo -e ${GRE}"[Enter] "$STD) to run, choice or q to exit: " choice
    case $choice in
        "")       _run;pause;;
        pdf)      _pdf;pause;;
        run)      _pdflatex;pause;;
        pdflatex) _pdflatex;pause;;
        html)     _html;pause;;
        htlatex)  _htlatex;pause;;
        submit)   _submit;pause;;
        p)        export PARSED="";_parse;pause;;
        moc)      _moc;pause;;
        unmoc)    _unmoc;pause;;
        wc)       _wc;pause;;
        c)        _clean;pause;;
        v)        if [[ ${VERBOSE} == "verbose" ]]; then
                    _unverbose;
                    _undebug;
                  else
                    _debug;
                    _verbose;
                  fi;
                  pause;;
        d)        if [[ ${LOGLEVEL} != "DEBUG" ]]; then
                    _debug;
                  else
                    _undebug;
                  fi;
                  pause;;
        q|x) exit 0;;
        *) echo -e "${RED}Error...${STD} [${choice}]" && sleep 1
    esac
}



###################################################
# Trap CTRL+C, CTRL+Z and quit singles
###################################################

trap '' SIGINT SIGQUIT SIGTSTP



###################################################
# Main Loop
###################################################

if [[ "$#" -gt 0 ]]; then
  for var in "$@"
  do
    if [[ $(type -t _$var) == function && _$var != "" ]]; then
      _$var;
    else
      log ERROR "$var is not a known command."
    fi
  done
else
  while true
  do
      show_menus
      read_options
  done
fi


