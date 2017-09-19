# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "postfix/map.jinja" import postfix with context -%}

include:
  - postfix.install
  - postfix.config

# manage various mappings
{% for mapping, data in postfix.mapping.items() -%}
  {% set map_type = '' -%}
  {% set file_param = salt['pillar.get']('postfix:config:' ~ mapping) -%}
  {% if ':' in file_param -%}
    {% set map_type,file_path = file_param.split(':') -%}
  {% endif %}
postfix_{{mapping}}:
  file.managed:
    - name: {{ file_path }}
    - source: salt://{{slspath}}/files/mapping.jinja
    - user: root
    - group: root
    {% if mapping.endswith('_sasl_password_maps') -%}
    - mode: 600
    {% else -%}
    - mode: {{postfix.file_mode}}
    {% endif -%}
    - template: jinja
    - context:
        data: {{data|json()}}
    - require:
      - pkg: postfix
  {% if map_type in postfix.postmap_types %}
postmap_{{mapping}}:
  cmd.wait:
    - name: {{postfix.postmap}} {{file_param}}
    - cwd: /
    - watch:
      - file: {{file_path}}
    - watch_in:
      - service: postfix
    - require:
      - sls: postfix.config
  {% endif -%}
{% endfor -%}
