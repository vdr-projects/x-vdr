#!/bin/bash
# file-browser.sh - Version 0.0.2
# A small file-browser for the vdr-osdserver

if [ "$*" != "0" ] && [ -x "$*" ] && [ -d "$*" ]; then
    directory=$(echo "$*" | sed s?//?/?g)
else
    directory="/"
fi
exit_cmd=
svdrpsend="svdrpsend.pl"

mkfifo --mode=700 /tmp/pipe-in$$ /tmp/pipe-out$$
exec 3<> /tmp/pipe-in$$
exec 4<> /tmp/pipe-out$$
rm /tmp/pipe-in$$ /tmp/pipe-out$$

{ netcat localhost 2010 ; echo 499 disconnected ; } <&3 >&4 &
pid=$!


function error() {
    SendCmd Quit

    exec 3>&-
    exec 4>&-

    kill $pid

    exit 1
}

function ReadReply() {
    reply2xx=()
    reply3xx=()
    reply4xx=()

    while read -r code line <&4 ; do
        echo "< $code $line"
        case $code in
            2*)     IFS=$' \t\n\r' reply2xx=($code "$line")
                    ;;
            3*)     IFS=$' \t\n\r' reply3xx=($code $line)
                    ;;
            4*)     IFS=$' \t\n\r' reply4xx=($code "$line")
                    ;;
        esac
        [ -n "${reply2xx[0]}" ] && break;
    done

    [ -n "${reply4xx[0]}" ] && return 1
    return 0
}

function SendCmd() {
    echo "> $*"
    echo "$*" >&3

    ReadReply
}

function FileBrowser() {
    n=1  # counter reset
    # menu
    SendCmd "menu=NewMenu \"File-Browser: $directory\"" || return 1
    if [ "$directory" != "/" ] ; then
        SendCmd "opt${n}=menu.AddOsdItem \".\"" || return 1
        ((n=n+1))
        SendCmd "opt${n}=menu.AddOsdItem \"..\"" || return 1
        ((n=n+1))
    fi
    files=$(ls -I $(basename $0) -B "$directory")
    if [ -n "$files" ] ; then
        for i in $files ; do
            SendCmd "opt$n=menu.AddOsdItem \"$i\"" || return 1
            ((n=n+1))
        done
    fi

    SendCmd 'menu.Show' || return 1
    SendCmd 'menu.EnableEvent keyOk close' || return 1
    SendCmd 'menu.SleepEvent' || return 1

    # reply
    if [ "${reply3xx[0]}" != "300" ] ; then return 1 ; fi

    if [ "${reply3xx[2]}" == "close" ] ; then
        if [ "$directory" != "/" ] ; then
            exit_cmd="$0 \"$(dirname "$directory")\""
        else
            SendCmd 'Message "Closing File-Browser ..."' || return 1
        fi

        SendCmd 'menu.SendState osEnd' || return 1
        return 0
    fi

    if [ "${reply3xx[2]}" != "keyOk" ] ; then return 1 ; fi

    SendCmd 'menu.GetCurrent' || return 1
    if [ "${reply3xx[0]}" != "302" ] ; then return 1 ; fi

    # options
    n=1
    if [ "$directory" != "/" ] ; then
        if [ "${reply3xx[2]}" == "opt${n}" ] ; then
            exit_cmd="$0 /"
            SendCmd 'menu.SendState osEnd' || return 1
            return 0
        fi
        ((n=n+1))

        if [ "${reply3xx[2]}" == "opt${n}" ] ; then
            exit_cmd="$0 \"$(dirname "$directory")\""
            SendCmd 'menu.SendState osEnd' || return 1
            return 0
        fi
        ((n=n+1))
    fi

    if [ -n "$files" ] ; then
        for i in $files ; do
            if [ "${reply3xx[2]}" == "opt${n}" ] ; then
                if [ -d "${directory}/${i}" ] ; then
                    exit_cmd="$0 \"${directory}/${i}\""
                    break
                elif [ -f "${directory}/${i}" ] && [ -x "${directory}/${i}" ] ; then
                    SendCmd "Message \"Executing $i ...\""
                    exit_cmd="${directory}/${i}"
                    break
                elif [ -f "${directory}/${i}" ] && [ -r "${directory}/${i}" ] ; then
                    SendCmd "Message \"Not supported: $i\""
#                    exit_cmd="${directory}/${i}"
                    break
                else
                    SendCmd "Message \"Not supported: $i\""
                    break
                fi
            else
                ((n=n+1))
            fi
        done
    fi

    SendCmd 'menu.SendState osEnd' || return 1
    return 0
}


ReadReply
SendCmd 'Version 0' || error

FileBrowser || error

SendCmd Quit

exec 3>&-
exec 4>&-

eval $exit_cmd
