[![Build Status](https://github.com/shinesolutions/aem-helloworld/workflows/CI/badge.svg)](https://github.com/shinesolutions/aem-helloworld/actions?query=workflow%3ACI)
[![Known Vulnerabilities](https://snyk.io/test/github/shinesolutions/aem-helloworld/badge.svg)](https://snyk.io/test/github/shinesolutions/aem-helloworld)

# AEM Hello World

## Content

This project is an AEM package that must be deployed on the author instance and its respective publish instances. 
 
 It will provide a single authorable page at `/content/helloworld`.

## Building

This project uses Maven for building. Common commands:

From the root directory, run ``mvn -PautoInstallPackage clean install`` to build the bundle and content package and install to a CQ instance.

From the bundle directory, run ``mvn -PautoInstallBundle clean install`` to build *just* the bundle and install to a CQ instance.

## Using with VLT

To use vlt with this project, first build and install the package to your local CQ instance as described above. Then cd to `content/src/main/content/jcr_root` and run

    vlt --credentials admin:admin checkout -f ../META-INF/vault/filter.xml --force http://localhost:4502/crx

Once the working copy is created, you can use the normal ``vlt up`` and ``vlt ci`` commands.

## Specifying CRX Host/Port

The CRX host and port can be specified on the command line with:
mvn -Dcrx.host=otherhost -Dcrx.port=5502 <goals>


## Release

Releases are published to [Maven Central](https://central.sonatype.com/namespace/com.shinesolutions)
under `com.shinesolutions:aem-helloworld`, `aem-helloworld-bundle` and `aem-helloworld-content`, and
tagged `aem-helloworld-<version>` in git. Versions follow [Semantic Versioning](https://semver.org/):
use a major release for breaking changes, minor for new features and patch for fixes.

| Target | Description |
|---|---|
| `make release-major`, `release-minor`, `release-patch` | Release the next major, minor or patch version with maven-release-plugin. Dates the `## [Unreleased]` CHANGELOG.md entries as the release, then commits and tags `aem-helloworld-<version>` locally; push with `git push --follow-tags` |
| `make release-test` | Run on your machine: in Docker (`maven:3.9.11-eclipse-temurin-11`), upload the committed `HEAD` to Maven Central as a test version (`VERSION`, default `<version>-rc.0`) that is never published, to check it validates; drop it afterwards with `release-drop` |
| `make release-status DEPLOYMENT_ID=<id>` | Show a Maven Central Portal deployment's state (e.g. `VALIDATED`, `PUBLISHED`, `FAILED`) and errors, using `MAVEN_CENTRAL_USERNAME` and `MAVEN_CENTRAL_PASSWORD` |
| `make release-drop DEPLOYMENT_ID=<id>` | Drop (delete) a Maven Central Portal deployment that has not been published |

### Requirements
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

This project builds with Java 11. Run the `make`, `mvn` and `git` commands below, except `make release-test`, in the
`maven:3.9.11-eclipse-temurin-11` Docker image, started from the directory above this repository.
It installs `make`, passes the variables through by name, your git identity for the release
commits, and marks the mounted repository as safe for git (it is owned by your user, not root):

```
$ docker run --rm -it -v "$(pwd)":/workspace -w /workspace/aem-helloworld \
    -v ~/.gitconfig:/root/.gitconfig:ro \
    -e GIT_CONFIG_COUNT=1 -e GIT_CONFIG_KEY_0=safe.directory \
    -e GIT_CONFIG_VALUE_0=/workspace/aem-helloworld \
    -e MAVEN_GPG_KEY -e MAVEN_GPG_PASSPHRASE -e MAVEN_CENTRAL_USERNAME -e MAVEN_CENTRAL_PASSWORD \
    maven:3.9.11-eclipse-temurin-11 \
    bash -c 'apt-get update -qq && apt-get install -y -qq make >/dev/null && exec bash'
```

### Steps
1. Start from an up-to-date `master` with a green CI build and a clean working tree. Check that the
   `## [Unreleased]` entries in CHANGELOG.md describe everything in this release.
2. Check signing and Maven Central validation with a test upload of `HEAD`, e.g. `0.0.3-rc.0`
   for `0.0.3-SNAPSHOT` (set another with `VERSION=<version>`). It is never published. Run it on
   your machine in this repository, not in the container, with the variables above exported; it
   starts `maven:3.9.11-eclipse-temurin-11` in Docker itself:
   ```
   $ make release-test
   ```
   The build waits until the deployment is validated and prints its ID
   (`Deployment <id> has been validated`). Drop it with `make release-drop DEPLOYMENT_ID=<id>` or
   **Drop** in the Central Portal.
3. Create the release, choosing `release-major`, `release-minor` or `release-patch`:
   ```
   $ make release-patch
   ```
   This dates the `## [Unreleased]` entries as the new version in CHANGELOG.md, commits the release
   version, tags it `aem-helloworld-<version>` and commits the next `-SNAPSHOT` version. Nothing is
   pushed. Review the result with `git log -3` and `git show aem-helloworld-<version>:CHANGELOG.md`.
4. Push the commits and the tag from your machine, outside the container, where your GitHub
   credentials are:
   ```
   $ git push --follow-tags
   ```
5. Upload the tagged version to Maven Central:
   ```
   $ git checkout aem-helloworld-<version>
   $ mvn -Prelease deploy -DskipTests -Dgpg.signer=bc
   $ git checkout master
   ```
   Maven Central validates the upload (signatures, checksums and POM) and the build waits until it
   is validated. The deployment then waits at [central.sonatype.com](https://central.sonatype.com)
   → Publishing → Deployments: click **Publish** to release it, or **Drop** to discard it without
   publishing. A published version can't be changed or removed. To publish automatically once
   validated, add `-DautoPublish=true` to `mvn`.

   Without a Central Portal login, use the user token and the deployment ID printed by `mvn deploy`:
   ```
   $ make release-status DEPLOYMENT_ID=<id>
   $ make release-drop DEPLOYMENT_ID=<id>
   ```
6. Unset the secrets when you are done:
   `unset MAVEN_GPG_KEY MAVEN_GPG_PASSPHRASE MAVEN_CENTRAL_USERNAME MAVEN_CENTRAL_PASSWORD`

## Credits

Photos by Hitoshi Suzuki, Joshua Rodriguez, Roman Kraft and Nathan Dumlao used under the [Unsplash Licence](https://unsplash.com/license).
