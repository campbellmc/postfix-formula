{% from "postfix/map.jinja" import postfix with context %}

include:
  - postfix.install
  - postfix.config
  - postfix.aliases
  - postfix.mapped
  - postfix.service
