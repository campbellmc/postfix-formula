{% from "postfix/map.jinja" import postfix with context -%}

include:
  - postfix.install

# manage various mappings
{% for mapping, data in postfix.mapping.items() -%}
  {% set map_type = '' -%}
  {% set file_path = salt['pillar.get']('postfix:config:' ~ mapping) -%}
  {% if ':' in file_path -%}
    {% set file_path = file_path.split(':')[1] -%}
    {% set map_type = file_path.split(':')[0] -%}
  {% endif -%}
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
        data: {{ data|json() }}
    - require:
      - pkg: postfix
  {% if map_type in postfix.postmap_types -%}
postmap_{{mapping}}:
  cmd.wait:
    - name: {{postfix.postmap}} {{map_type}} {{file_path}}
    - cwd: /
    - watch:
      - file: {{file_path}}
    - watch_in:
      - service: postfix
  {% endif -%}
{% endfor -%}
