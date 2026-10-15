[![Build Status](https://github.com/shinesolutions/aem-helloworld/workflows/CI/badge.svg)](https://github.com/shinesolutions/aem-helloworld/actions?query=workflow%3ACI)
[![Known Vulnerabilities](https://snyk.io/test/github/shinesolutions/aem-helloworld/badge.svg)](https://snyk.io/test/github/shinesolutions/aem-helloworld)

# AEM Hello World

AEM Hello World is an AEM package that must be deployed on the author instance and its respective publish instances.
It provides a small authorable Cafe site at `/content/helloworld`.

Learn more about AEM Hello World:

* [Installation](#installation)
* [Usage](#usage)
* [Result Model](#result-model)
* [Error Handling](#error-handling)
* [Testing](#testing)
* [Versions History](#versions-history)

## Installation

### Requirements

This project requires Java 11 and Apache Maven. Run the build `make` targets inside the
`maven:3.9.11-eclipse-temurin-11` Docker image, started from the directory above this repository,
with `make` installed. It marks the mounted repository as safe for git (it is owned by your user, not
root):

```
$ docker run --rm -it -v "$(pwd)":/workspace -w /workspace/aem-helloworld \
    -v aem-helloworld-m2:/root/.m2 \
    -e GIT_CONFIG_COUNT=1 -e GIT_CONFIG_KEY_0=safe.directory \
    -e GIT_CONFIG_VALUE_0=/workspace/aem-helloworld \
    maven:3.9.11-eclipse-temurin-11 \
    bash -c 'apt-get update -qq && apt-get install -y -qq make >/dev/null && exec bash'
```

### Download

Releases are published to [Maven Central](https://central.sonatype.com/namespace/com.shinesolutions)
under `com.shinesolutions:aem-helloworld-content` (the content package) and
`com.shinesolutions:aem-helloworld-bundle` (the OSGi bundle).

### Build from source

| Target | Description |
|---|---|
| `make deps` | Download all dependencies |
| `make build` | Build the bundle and the content package |
| `make install` | Build and install the artifacts into the local Maven repository |

```
$ make build
```

This creates the bundle `bundle/target/aem-helloworld-bundle-<version>.jar` and the content package
`content/target/aem-helloworld-content-<version>.zip`, which embeds the bundle.

## Usage

### Install to AEM

Install the content package on the author instance and its publish instances, either by uploading
`aem-helloworld-content-<version>.zip` with CRX Package Manager, or with Maven from the root directory:

| Command | Description |
|---|---|
| `mvn -PautoInstallPackage clean install` | Build the bundle and content package and install the package to the author instance |
| `mvn -PautoInstallPackagePublish clean install` | Build and install the content package to the publish instance |
| `mvn -PautoInstallBundle clean install` (from the `bundle` directory) | Build *just* the bundle and install it to the author instance |

### Specifying CRX Host/Port

The CRX host, port and credentials default to `localhost:4502` with `admin`/`admin` for author and
`localhost:4503` for publish. Override them on the command line:

```
$ mvn -Dcrx.host=otherhost -Dcrx.port=5502 -Dcrx.username=admin -Dcrx.password=admin <goals>
$ mvn -Dpublish.crx.host=otherhost -Dpublish.crx.port=5503 <goals>
```

### Using with VLT

To use vlt with this project, first build and install the package to your local CQ instance as described above. Then cd to `content/src/main/content/jcr_root` and run

    vlt --credentials admin:admin checkout -f ../META-INF/vault/filter.xml --force http://localhost:4502/crx

Once the working copy is created, you can use the normal ``vlt up`` and ``vlt ci`` commands.

## Result Model

Installing the content package creates these paths, as defined in its
[filter.xml](content/src/main/content/META-INF/vault/filter.xml):

| Path | Content |
|---|---|
| `/apps/helloworld` | Page components (`cafe-basepage`, `navigation`, `footer`), content components (`hero`, `textimage`, `reservation`, `gmaps`), the Blank Page and Landing Page templates, and the bundle in `/apps/helloworld/install` |
| `/etc/clientlibs/helloworld` | Client libraries |
| `/etc/designs/helloworld` | Design |
| `/content/helloworld` | The "My Cafe Project" site, with `welcome` and `reservation` pages |

The bundle (`com.shinesolutions.aem-helloworld`) provides the `Navigation`, `Footer` and `HeroImage`
Sling Models in `com.shinesolutions.models`.

Photos by Hitoshi Suzuki, Joshua Rodriguez, Roman Kraft and Nathan Dumlao used under the [Unsplash Licence](https://unsplash.com/license).

## Error Handling

The `autoInstall*` profiles fail the Maven build when AEM rejects the package or bundle
(content-package-maven-plugin runs with `failOnError`). Most likely causes are:

* AEM is not running or not reachable at the CRX host and port
* Invalid CRX credentials
* The bundle doesn't start in AEM: check its state in the OSGi console at `/system/console/bundles`

## Testing

The project has no automated tests. `make ci` cleans, downloads dependencies, then builds and installs
the bundle and content package into the local Maven repository, as a build check:

```
$ make ci
```

To test the package itself, install it to a local AEM instance (see [Install to AEM](#install-to-aem))
and open `/content/helloworld/welcome.html` on author and publish.

## Versions History

Changes in each version are described in [CHANGELOG.md](CHANGELOG.md).

Releases are published to [Maven Central](https://central.sonatype.com/namespace/com.shinesolutions)
under `com.shinesolutions:aem-helloworld`, `aem-helloworld-bundle` and `aem-helloworld-content`, and
tagged `aem-helloworld-<version>` in git. Versions follow [Semantic Versioning](https://semver.org/):
use a major release for breaking changes, minor for new features and patch for fixes.
Between releases, the `pom.xml` files hold the next pre-release version, e.g. `0.0.3-pre.0`.

Versions are managed with [RTK](https://github.com/cliffano/rtk), configured in `.rtk.json`: it sets
the release version in the `pom.xml` files and CHANGELOG.md, commits and tags it
`aem-helloworld-<version>`, then commits the next pre-release version.

### Release targets

| Target | Description |
|---|---|
| `make release-test RELEASE_TEST_VERSION=<x.y.z-rc.n>` | Run on your machine: in `maven:3.9.11-eclipse-temurin-11` (Docker), sign `HEAD` and upload it to the Maven Central Portal as a pre-release test version without publishing it, then print the deployment ID for `release-status` and `release-drop`. Only pre-release versions are accepted (default: current release version with `-rc.0`) |
| `make release-status DEPLOYMENT_ID=<id>` | Show a Maven Central Portal deployment's state (e.g. `VALIDATED`, `PUBLISHED`, `FAILED`) and errors, using `MAVEN_CENTRAL_USERNAME` and `MAVEN_CENTRAL_PASSWORD` |
| `make release-drop DEPLOYMENT_ID=<id>` | Drop (delete) a Maven Central Portal deployment that has not been published |
| `make publish` | Sign the checked-out version and upload it to the Maven Central Portal, then wait until it is validated. Run by the **Publish to Maven Central** workflow on a pushed `aem-helloworld-<version>` tag |
| `make release-major`, `release-minor`, `release-patch` | Release the next major, minor or patch version with RTK. Dates the `## [Unreleased]` CHANGELOG.md entries as the release, then commits and tags `aem-helloworld-<version>` locally; push with `git push --follow-tags` |

### Release requirements
- A GPG key for signing, with its public key on a keyserver such as `keyserver.ubuntu.com`
  (Maven Central verifies signatures against it)
- A Maven Central Portal user token for the `com.shinesolutions` namespace
- Both are read from environment variables only, never from files. Enter them in your shell, so
  the values stay hidden and out of your shell history:

  ```
  # GPG private key: run this, paste the whole key including the
  # -----BEGIN/END PGP PRIVATE KEY BLOCK----- lines, press Enter, then Ctrl-D
  $ stty -echo; MAVEN_GPG_KEY="$(cat)"; stty echo; export MAVEN_GPG_KEY

  # GPG passphrase and Central Portal user token: type or paste each value, then press Enter
  $ read -rs MAVEN_GPG_PASSPHRASE; export MAVEN_GPG_PASSPHRASE
  $ read -rs MAVEN_CENTRAL_USERNAME; export MAVEN_CENTRAL_USERNAME
  $ read -rs MAVEN_CENTRAL_PASSWORD; export MAVEN_CENTRAL_PASSWORD
  ```

  Check the key arrived complete without printing it: `printf '%s\n' "$MAVEN_GPG_KEY" | head -1` and
  `| tail -1` should show the BEGIN and END lines.

`make release-test` runs on your machine and starts the Java 11 image itself. Run `make publish` in
the `maven:3.9.11-eclipse-temurin-11` container from [Requirements](#requirements), with the
variables passed through (`-e MAVEN_GPG_KEY -e MAVEN_GPG_PASSPHRASE -e MAVEN_CENTRAL_USERNAME
-e MAVEN_CENTRAL_PASSWORD`).

The other release targets run no Java. Run them in aem-platform-buildenv, which has RTK, started from
the directory above this repository. It passes the variables through by name, your git identity for
the release commits, and marks the mounted repository as safe for git (it is owned by your user, not
root):

```
$ docker run --rm -it -v "$(pwd)":/workspace -w /workspace/aem-helloworld \
    -v ~/.gitconfig:/root/.gitconfig:ro \
    -e GIT_CONFIG_COUNT=1 -e GIT_CONFIG_KEY_0=safe.directory \
    -e GIT_CONFIG_VALUE_0=/workspace/aem-helloworld \
    -e MAVEN_CENTRAL_USERNAME -e MAVEN_CENTRAL_PASSWORD \
    shinesolutions/aem-platform-buildenv:6.2.1 bash
```

### Release steps
1. Start from an up-to-date `master` with a green CI build and a clean working tree. Check that the
   `## [Unreleased]` entries in CHANGELOG.md describe everything in this release.
2. Check signing and Maven Central validation with a test upload of `HEAD`, from this repository on
   your machine:
   ```
   $ make release-test
   ```
   Then drop the test deployment with `make release-drop DEPLOYMENT_ID=<id>` in aem-platform-buildenv,
   or **Drop** in the Central Portal.
3. Create the release, either:
   - In GitHub Actions, run the **Release Major**, **Release Minor** or **Release Patch** workflow.
     It runs RTK and pushes the commits and the tag. Then `git pull --tags` to fetch them.
   - Or locally in aem-platform-buildenv, choosing `release-major`, `release-minor` or `release-patch`:
     ```
     $ make release-patch
     ```
     This dates the `## [Unreleased]` entries as the new version in CHANGELOG.md, commits the release
     version, tags it `aem-helloworld-<version>` and commits the next pre-release version. Nothing
     is pushed. Review the result with `git log -3` and `git show aem-helloworld-<version>:CHANGELOG.md`.
4. If you released locally, push the commits and the tag from your machine, outside the container,
   where your GitHub credentials are:
   ```
   $ git push --follow-tags
   ```
5. Upload the tagged version to Maven Central. The pushed tag triggers the **Publish to Maven
   Central** workflow, which runs `make publish` in `maven:3.9.11-eclipse-temurin-11` with the
   `SHINEOPENSOURCE_MAVEN_CENTRAL_USERNAME`, `SHINEOPENSOURCE_MAVEN_CENTRAL_PASSWORD`,
   `SHINEOPENSOURCE_MAVEN_GPG_KEY` and `SHINEOPENSOURCE_MAVEN_GPG_PASSPHRASE` GitHub secrets. To
   upload it yourself instead, in the Java 11 container:
   ```
   $ git checkout aem-helloworld-<version>
   $ make publish
   $ git checkout master
   ```
   Maven Central validates the upload (signatures, checksums and POM) and the build waits until it
   is validated. The deployment then waits at [central.sonatype.com](https://central.sonatype.com)
   → Publishing → Deployments: click **Publish** to release it, or **Drop** to discard it without
   publishing. A published version can't be changed or removed. To publish automatically once
   validated, run `make publish MVN="mvn -B -ntp -DautoPublish=true"`.

   Without a Central Portal login, use the user token and the deployment ID printed by `make publish`,
   in aem-platform-buildenv:
   ```
   $ make release-status DEPLOYMENT_ID=<id>
   $ make release-drop DEPLOYMENT_ID=<id>
   ```
6. Unset the secrets when you are done:
   `unset MAVEN_GPG_KEY MAVEN_GPG_PASSPHRASE MAVEN_CENTRAL_USERNAME MAVEN_CENTRAL_PASSWORD`
