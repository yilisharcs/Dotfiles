@ECHO OFF
start /wait /unix @direnv@ exec . @just@ build || pause
