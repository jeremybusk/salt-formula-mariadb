{%- from "mariadb/map.jinja" import server with context %}

{%- if server.admin is defined %}

mariadb_debconf:
  debconf.set:
  - name: mariadb-server
  - data:
      'mariadb-server/root_password': {'type':'string','value':'{{ server.admin.password }}'}
      'mariadb-server/root_password_again': {'type':'string','value':'{{ server.admin.password }}'}
  - require:
    - pkg: mariadb_packages

{%- endif %}

mariadb_packages:
  pkg.installed:
  - names: {{ server.pkgs }}

mariadb_config:
  file.managed:
  - name: {{ server.config }}
  - source: salt://mariadb/conf/my.cnf.{{ grains.os_family }}
  - mode: 644
  - template: jinja
  - require:
    - pkg: mariadb_packages

mariadb_service:
  service.running:
  - name: {{ server.service }}
  - enable: true
  - watch:
    - file: mariadb_config
