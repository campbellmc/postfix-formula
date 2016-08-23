{% from "postfix/map.jinja" import postfix with context %}

include:
  - postfix.install
  - postfix.aliases
  - postfix.mapped
  - postfix.config
  - postfix.service
