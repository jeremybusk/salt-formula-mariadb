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

{%- endif %}
