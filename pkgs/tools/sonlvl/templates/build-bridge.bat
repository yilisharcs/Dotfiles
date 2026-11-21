@ECHO OFF
start /wait /unix @direnv@ exec . @make@ build || pause
