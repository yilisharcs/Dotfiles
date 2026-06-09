@ECHO OFF
start /wait /unix @direnv@ exec . /bin/sh -c "exec @blastem@ \"$(winepath -u \"$1\")\"" -- %1
