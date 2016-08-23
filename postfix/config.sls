{% from "postfix/map.jinja" import postfix with context -%}

include:
  - postfix.install

/etc/postfix/main.cf:
  file.managed:
    - source: salt://{{slspath}}/files/main.cf.jinja
    - user: root
    - group: root
    - mode: {{postfix.file_mode}}
    - require:
      - pkg: postfix
    - watch_in:
      - service: postfix
    - template: jinja

{% if salt['pillar.get']('postfix:manage_master_config', True) %}
/etc/postfix/master.cf:
  file.managed:
    - source: salt://{{slspath}}/files/master.cf.jinja
    - user: root
    - group: root
    - mode: {{postfix.file_mode}}
    - require:
      - pkg: postfix
    - watch_in:
      - service: postfix
    - template: jinja
{% endif %}

{%- for domain in postfix.certificates.keys() %}
postfix_{{ domain }}_ssl_certificate:
  file.managed:
    - name: /etc/postfix/ssl/{{ domain }}.crt
    - makedirs: True
    - contents_pillar: postfix:certificates:{{ domain }}:public_cert
    - watch_in:
       - service: postfix

postfix_{{ domain }}_ssl_key:
  file.managed:
    - name: /etc/postfix/ssl/{{ domain }}.key
    - mode: 600
    - makedirs: True
    - contents_pillar: postfix:certificates:{{ domain }}:private_key
    - watch_in:
       - service: postfix
{% endfor %}
