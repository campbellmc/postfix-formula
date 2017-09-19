# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "postfix/map.jinja" import postfix with context %}

/etc/postfix:
  file.directory:
    - user: root
    - group: root
    - dir_mode: {{postfix.dir_mode}}
    - file_mode: 
    - makedirs: True

postfix:
  pkg.installed:
    - name: {{ postfix.package }}
    - watch_in:
      - service: postfix
