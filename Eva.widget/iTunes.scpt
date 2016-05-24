global tname, aname, alname, ttrack, trate, coverTarget, coverData, coverURL

set {player, status} to my check()

try
    if player is not false and status is not false then
        if player is equal to "Spotify" then
            tell application "Spotify"
                set coverURL to artwork url of current track
                if status is "playing" or status is "paused" then
                    set {tname, aname, alname, ttrack, trate, tduration} to {name, artist, album, track number, popularity, duration} of current track
                    return tname & "~" & aname & "~" & alname & "~" & tduration & "~" & ttrack & "~" & trate & "~" & coverURL
                else
                    return " ~ ~ ~ 0 ~ 0 ~ 0"
                end if
            end tell
        else if player is equal to "iTunes" then
            tell application "iTunes"
                set coverTarget to open for access (text 1 thru -12 of (path to me as text) & "album.jpg" as text) with write permission
                set coverData to data of artwork 1 of current track
                write coverData to coverTarget
                close access coverTarget
                if status is "playing" or status is "paused" then
                    set {tname, aname, alname, ttrack, trate, tduration} to {name, artist, album, track number, rating, duration} of current track
                    return tname & "~" & aname & "~" & alname & "~" & tduration & "~" & ttrack & "~" & trate
                else
                    return " ~ ~ ~ 0 ~ 0 ~ 0"
                end if
            end tell
        else
            return " ~ ~ ~ 0 ~ 0 ~ 0"
        end if
    end if
    return " ~ ~ ~ 0 ~ 0 ~ 0"
on error e
    return " ~ ~ ~ 0 ~ 0 ~ 0"
end try

on check()
    tell application "System Events" to set state to (name of processes) contains "Spotify"
    if state is true then
        using terms from application "Spotify"
            tell application "Spotify" to if player state is playing then return {"Spotify", "playing"}
            tell application "Spotify" to if player state is paused then return {"Spotify", "paused"}
            tell application "Spotify" to if player state is stopped then return {"Spotify", "stopped"}
        end using terms from
    end if
    tell application "System Events" to set state to (name of processes) contains "iTunes"
    if state is true then
        using terms from application "iTunes"
            tell application "iTunes" to if player state is playing then return {"iTunes", "playing"}
            tell application "iTunes" to if player state is paused then return {"iTunes", "paused"}
            tell application "iTunes" to if player state is stopped then return {"iTunes", "stopped"}
        end using terms from
    end if
    return {false, false}
end check
