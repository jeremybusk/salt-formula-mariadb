include:
{%- if pillar.mariadb.get('server', None) %}
- mariadb.server
{%- endif %}
