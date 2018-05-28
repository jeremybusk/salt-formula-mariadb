{%- if pillar.mariadb is defined %}
include:
  {%- if pillar.mariadb.server is defined %}
  - mariadb.server
  {%- endif %}
{%- endif %}
