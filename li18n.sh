#!/bin/sh

PRO=together

lupdate -no-obsolete -recursive src/ main.cpp qml/js/*.js qml/${PRO} qml/${PRO}/component -ts i18n/${PRO}.zh_CN.ts
