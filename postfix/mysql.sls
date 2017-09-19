# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "postfix/map.jinja" import postfix with context %}

mysql:
  pkg.installed:
    - name: {{ postfix.mysql_pkg }}
    - watch_in:
      - service: postfix
