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

  service.running:
    - enable: {{ salt['pillar.get']('postfix:enable_service', True) }}
    - require:
      - pkg: postfix
    - watch:
      - pkg: postfix

# manage various mappings
{% for mapping, data in salt['pillar.get']('postfix:mapping', {}).items() %}
  {%- set need_postmap = False %}
  {%- set file_path = salt['pillar.get']('postfix:config:' ~ mapping) %}
  {%- if ':' in file_path %}
    {%- set file_path = file_path.split(':')[1] %}
    {%- set need_postmap = True %}
  {%- endif %}
postfix_{{ mapping }}:
  file.managed:
    - name: {{ file_path }}
    - source: salt://{{slspath}}/files/mapping.j2
    - user: root
    - group: root
    {%- if mapping.endswith('_sasl_password_maps') %}
    - mode: 600
    {%- else %}
    - mode: 644
    {%- endif %}
    - template: jinja
    - context:
        data: {{ data|json() }}
    - require:
      - pkg: postfix
  {%- if need_postmap %}
  cmd.wait:
    - name: /usr/sbin/postmap {{ file_path }}
    - cwd: /
    - watch:
      - file: {{ file_path }}
    - watch_in:
      - service: postfix
  {%- endif %}
{% endfor %}
