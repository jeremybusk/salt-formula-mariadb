include:
{%- if pillar.get('mariadb', {}).get('server', None) %}
- mariadb.server
{%- endif %}
