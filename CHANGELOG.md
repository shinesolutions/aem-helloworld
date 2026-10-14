# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Added Makefile targets for release-test, release-status, release-drop and release-major/minor/patch, run in the maven:3.9.11-eclipse-temurin-11 Docker image (Java 11)
- Added Maven Central credentials to `.mvn/settings.xml`, read from environment variables

### Changed
- Publish to Maven Central through the Central Portal (central-publishing-maven-plugin) instead of the retired OSSRH
- Maven Central deployments wait for a manual Publish or Drop in the Central Portal, use `-DautoPublish=true` to publish automatically
- Artifact signing now runs in the `release` Maven profile, replacing `sign-artifacts`, with maven-gpg-plugin 3.2.8

### Fixed
- Fixed the bundle build on Java 11 by adding the `javax.annotation-api` provided dependency for `@PostConstruct`, which Java 11 no longer includes
- Fixed the bundle build on Java 11 by upgrading maven-scr-plugin from 1.20.0 to 1.26.4

## [0.0.1] - 2017-02-27

### Added
- Initial version
