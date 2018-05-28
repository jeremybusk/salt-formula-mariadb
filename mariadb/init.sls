include:
{%- if pillar.mariadb.server is defined %}
- mariadb.server
{%- endif %}
