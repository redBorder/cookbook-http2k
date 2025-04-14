cookbook-http2k CHANGELOG
===============

## 1.3.0

  - David Vanhoucke
    - [650bd05] update broker to work with sync network

## 1.2.0

  - Miguel Negrón
    - [d65ba78] Merge pull request #25 from redBorder/bugfix/#19144_missing_nginx_confd_files
  - David Vanhoucke
    - [3e63d53] remove files if service disabled
  - Miguel Negron
    - [fcf0ac6] Add balancing

## 1.1.2

  - Miguel Negrón
    - [0d2e5a9] Fix spec file

## 1.1.1

  - Miguel Negrón
    - [f93e8a3] Add pre and postun to clean the cookbook

## 1.1.0

  - Miguel Negrón
    - [2c472e6] Merge pull request #21 from redBorder/bugfix/#13550_restrain_user_permissions
  - Miguel Negrón
    - [98474ee] Merge branch 'development' into bugfix/#13550_restrain_user_permissions
  - Luis Blanco
    - [c0e0f7f] nologin permission to user

## 1.0.11

  - Miguel Alvarez
    - [34f8422] Fix ssl certs

## 1.0.10

  - Miguel Negrón
    - [43bc053] fix lint
    - [9172f1f] lint resources
    - [77d6cf6] lint recipes
    - [69a4cd8] lint providers
    - [20ee94f] lint libraries
    - [4380d03] lint attrbiutes
    - [2a90359] Update README.md
    - [436663c] Update rpm.yml
    - [a022625] Update metadata.rb

## 1.0.9

  - nilsver
    - [76f7879] refactor code
    - [6fba6dd] deleted a space
    - [d2b1234] added sensor_name enrichment
    - [0d30370] add enrichment ips
    - [0e99ae6] add enrichment proxy

0.0.7
-----
- [cjmateos]
  - Update version to 0.0.7

0.0.6
-----
- [cjmateos]
  - f742226 add consul registering support
  - 9b94053 Fix config temaplate
  - 67b7803 Update config template
  - 397dea3 update provider and resource
  - 551b83b Delete unused attributes
  - ceac5fa Delete thrash files
  - 50fa6ce update metadata and changelog
- [arodriguez]
  - 7bebe8a Add readme in cookbook installation
  - 1854607 Add makefile to root
  - 776c314 Add makefile and spec to generate rpm
  - ba5b3c2 Move coobook to resources folder
- [ejimenez]
  - a4d25d1 updated changelog for version 0.0.6
  - 19b1e32 Restart service when the config file is changed
  - 684b45f Add domain to config template

0.0.5
-----
- [cjmateos]
 - c0d9cfe Protection against nil values in organizations and proxy_nodes
 - c7671d6 Enable package installation
 - 058548e Send port var to http2k_config.json

0.0.4
-----
- [ejimenez]
 - verbose mode in errors
 - Add cookbook property to templates resources
 - Fix wrong iteration logic on config.json template

0.0.3
-----
- [ejimenez] - Fixed typo in resource definition

0.0.2
-----
- [ejimenez] - Added logic

0.0.1
-----
- [ejimenez] - Skel creation
