# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-10-20
### Added
- Added Makefile targets for ci, clean, deps, build, install, release-test, publish, release-status, release-drop and release-major/minor/patch
- Added Maven Central credentials to `.mvn/settings.xml`, read from environment variables
- Added Release Major/Minor/Patch GitHub workflows, and a Publish to Maven Central workflow that runs `make publish` on a pushed release tag with the Maven Central and GPG secrets

### Changed
- Builds, publishes and releases in aem-platform-buildenv 6.3.0, with its Java 11
- Publish to Maven Central through the Central Portal (central-publishing-maven-plugin) instead of the retired OSSRH
- Maven Central deployments wait for a manual Publish or Drop in the Central Portal, use `-DautoPublish=true` to publish automatically
- Artifact signing now runs in the `release` Maven profile, replacing `sign-artifacts`, with maven-gpg-plugin 3.2.8
- Releases are now made with RTK, by `make release-major|minor|patch` or the Release Major/Minor/Patch GitHub workflows, replacing maven-release-plugin
- Development versions are now pre-release versions such as `0.0.3-pre.0` instead of `-SNAPSHOT`
- Replaced Travis CI with GitHub Actions [#8]
- Upgraded junit from 4.11 to 4.13.1 [#9]
- CI now runs `make ci` in aem-platform-buildenv 6.3.0, through cliffano/command-docker-action
- Simplify CI workflow to not use action files anymore
- Restructured README into Installation, Usage, Result Model, Error Handling, Testing and Versions History

### Fixed
- Fixed the bundle build on Java 11 by adding the `javax.annotation-api` provided dependency for `@PostConstruct`, which Java 11 no longer includes
- Fixed the bundle build on Java 11 by upgrading maven-scr-plugin from 1.20.0 to 1.26.4
- Fix metadata-lint failure on publishing by upgrading release-action to 2.1.0
- Fix metadata-lint failure on publishing via workflow runner 6.4.1

## [0.0.2] - 2019-01-21
### Added
- Added Cafe demo site with rich components [#3]
- Added Makefile for consistency and clarity for non-Java developers
- Added Snyk vulnerabilities badge

### Changed
- Renamed the content folder to helloworld
- Modified CHANGELOG to use the Keep a Changelog standard

### Fixed
- Fixed GPG build warning

## [0.0.1] - 2017-02-27
### Added
- Initial version

[#3]: https://github.com/shinesolutions/aem-helloworld/issues/3
[#8]: https://github.com/shinesolutions/aem-helloworld/issues/8
[#9]: https://github.com/shinesolutions/aem-helloworld/issues/9

[1.0.0]: https://github.com/shinesolutions/aem-helloworld/compare/aem-helloworld-0.0.2...aem-helloworld-1.0.0
[0.0.2]: https://github.com/shinesolutions/aem-helloworld/compare/aem-helloworld-0.0.1...aem-helloworld-0.0.2
[0.0.1]: https://github.com/shinesolutions/aem-helloworld/releases/tag/aem-helloworld-0.0.1
