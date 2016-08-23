{% from "postfix/map.jinja" import postfix with context %}

include:
  - postfix.install

postfix_service:
  service.running:
    - name: {{postfix.service}}
    - enable: {{ salt['pillar.get']('postfix:enable_service', True) }}
    - require:
      - pkg: postfix
    - watch:
      - pkg: postfix
