{% from "postfix/map.jinja" import postfix with context %}

include:
  - postfix.install

# manage /etc/aliases if data found in pillar
{% if 'aliases' in postfix %}
ensure_{{postfix.aliases_file}}:
  file.managed:
    - source: salt://{{slspath}}/files/alias.jinja
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - require:
      - pkg: postfix

ensure_newaliases:
  cmd.wait:
    - name: newaliases
    - cwd: /
    - watch:
      - file: {{postfix.aliases_file}}
{% endif %}
