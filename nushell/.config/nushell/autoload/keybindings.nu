$env.config.keybindings = [
        {
                name: job_to_foreground
                modifier: control
                keycode: char_z
                mode: [emacs, vi_insert, vi_normal]
                event: {
                        send: executehostcommand,
                        cmd: "job unfreeze"
                }
        }
        {
                name: fuzzy_history
                modifier: control
                keycode: char_r
                mode: [emacs, vi_normal, vi_insert]
                event: [
                        {
                                send: executehostcommand
                                cmd: "commandline edit --replace (
                                history
                                | reverse
                                | group-by command
                                | values
                                | each { $in.0 }
                                | each { $\"($in.index + 1)     ($in.command)\" }
                                | str join (char -i 0)
                                | fzf
                                --read0
                                --layout reverse
                                --query (commandline)
                                --scheme history
                                --preview-window hidden
                                --bind='ctrl-y:execute-silent(echo -n {2..} | wl-copy)+abort'
                                --header 'Press CTRL-Y to copy command into clipboard'
                                | decode utf-8
                                | str trim
                                | str replace -r '^\\d+\\s{5}' ''
                                )"
                        }
                ]
        }
]
