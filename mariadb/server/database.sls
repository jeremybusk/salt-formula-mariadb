{%- from "mariadb/map.jinja" import server, mariadb_connection_args with context %}

{%- if not grains.get('noservices', False) %}
{%- for database_name, database in server.get('database', {}).items() %}

mariadb_database_{{ database_name }}:
  mysql_database.present:
  - name: {{ database_name }}
  - character_set: {{ database.get('encoding', 'utf8') }}
  - connection_user: {{ mariadb_connection_args.user }}
  - connection_pass: {{ mariadb_connection_args.password }}
  - connection_charset: {{ mariadb_connection_args.charset }}

{%- for user in database.users %}

mariadb_user_{{ user.name }}_{{ database_name }}_{{ user.host }}:
  mysql_user.present:
  - host: '{{ user.host }}'
  - name: '{{ user.name }}'
  {%- if user.password is defined %}
  - password: {{ user.password }}
  {%- else %}
  - allow_passwordless: true
  {%- endif %}
  - connection_user: {{ mariadb_connection_args.user }}
  - connection_pass: {{ mariadb_connection_args.password }}
  - connection_charset: {{ mariadb_connection_args.charset }}

mariadb_grants_{{ user.name }}_{{ database_name }}_{{ user.host }}:
  mysql_grants.present:
  - grant: {{ user.rights }}
  - database: '{{ database_name }}.*'
  - user: '{{ user.name }}'
  - host: '{{ user.host }}'
  - connection_user: {{ mariadb_connection_args.user }}
  - connection_pass: {{ mariadb_connection_args.password }}
  - connection_charset: {{ mariadb_connection_args.charset }}
  - require:
    - mysql_user: mariadb_user_{{ user.name }}_{{ database_name }}_{{ user.host }}
    - mysql_database: mariadb_database_{{ database_name }}

{%- endfor %}
{%- endfor %}

{%- for user in server.get('users', []) %}

mariadb_user_{{ user.name }}_{{ user.host }}:
  mysql_user.present:
  - host: '{{ user.host }}'
  - name: '{{ user.name }}'
  {%- if user.password is defined %}
  - password: {{ user.password }}
  {%- else %}
  - allow_passwordless: True
  {%- endif %}

{%- endfor %}
{%- endif %}
