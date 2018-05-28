{%- from "mariadb/map.jinja" import server, mariadb_connection_args with context %}

{%- if server.enabled %}

include:
- mariadb.common

{%- if server.ssl.enabled %}

/etc/mysql/server-cert.pem:
  file.managed:
  {%- if server.ssl.cert is defined %}
  - contents_pillar: mariadb:server:ssl:cert
  {%- else %}
  - source: salt://pki/{{ server.ssl.authority }}/certs/{{ server.ssl.certificate }}.cert.pem
  {%- endif %}
  - require:
    - pkg: mariadb_packages
  - watch_in:
    - service: mariadb_service

/etc/mysql/server-key.pem:
  file.managed:
  {%- if server.ssl.key is defined %}
  - contents_pillar: mariadb:server:ssl:key
  {%- else %}
  - source: salt://pki/{{ server.ssl.authority }}/certs/{{ server.ssl.certificate }}.key.pem
  {%- endif %}
  - require:
    - pkg: mariadb_packages
  - watch_in:
    - service: mariadb_service

{%- if server.replication.role in ['slave', 'both'] %}

/etc/mysql/client-cert.pem:
  file.managed:
  {%- if server.ssl.client_cert is defined %}
  - contents_pillar: mariadb:server:ssl:client_cert
  {%- else %}
  - source: salt://pki/{{ server.ssl.authority }}/certs/{{ server.ssl.client_certificate }}.cert.pem
  {%- endif %}
  - require:
    - pkg: mariadb_packages
  - watch_in:
    - service: mariadb_service

/etc/mysql/client-key.pem:
  file.managed:
  {%- if server.ssl.client_key is defined %}
  - contents_pillar: mariadb:server:ssl:client_key
  {%- else %}
  - source: salt://pki/{{ server.ssl.authority }}/certs/{{ server.ssl.client_certificate }}.key.pem
  {%- endif %}
  - require:
    - pkg: mariadb_packages
  - watch_in:
    - service: mariadb_service

{%- endif %}

/etc/mysql/cacert.pem:
  file.managed:
  {%- if server.ssl.cacert is defined %}
  - contents_pillar: mariadb:server:ssl:cacert
  {%- else %}
  - source: salt://pki/{{ server.ssl.authority }}/{{ server.ssl.authority }}-chain.cert.pem
  {%- endif %}
  - require:
    - pkg: mariadb_packages
  - watch_in:
    - service: mariadb_service

{%- endif %}


{%- if server.replication.role in ['master', 'both'] %}

{{ server.replication.user }}:
  mysql_user.present:
  - host: '%'
  - password: {{ server.replication.password }}
  - connection_user: {{ mariadb_connection_args.user }}
  - connection_pass: {{ mariadb_connection_args.password }}
  - connection_charset: {{ mariadb_connection_args.charset }}
  - watch:
    - service: mariadb_service

{{ server.replication.user }}_replication_grants:
  mysql_grants.present:
  - grant: replication slave
  - database: '*.*'
  - user: {{ server.replication.user }}
  - host: '%'
  - connection_user: {{ mariadb_connection_args.user }}
  - connection_pass: {{ mariadb_connection_args.password }}
  - connection_charset: {{ mariadb_connection_args.charset }}
  - watch:
    - service: mariadb_service

{%- endif %}

{%- if server.replication.role in ['slave', 'both'] %}

{%- if not salt['mysql.get_slave_status'] is defined %}

{%- include "mariadb/server/_connect_replication_slave.sls" %}

{%- elif salt['mysql.get_slave_status']() == [] %}

{%- include "mariadb/server/_connect_replication_slave.sls" %}

{%- else %}

{%- if salt['mysql.get_slave_status']().get('Slave_SQL_Running', 'No') == 'Yes' and salt['mysql.get_slave_status']().get('Slave_IO_Running', 'No') == 'Yes' %}

{%- else %}

{%- include "mariadb/server/_connect_replication_slave.sls" %}

{%- endif %}

{%- endif %}

{%- endif %}

{%- endif %}
