# Build and release aem-helloworld. Run inside the maven:3.9.11-eclipse-temurin-11 Docker image
# (Java 11), with make installed, except release-test, which starts that image itself.
SHELL := /bin/bash
MVN ?= mvn -B -ntp

ci: clean deps lint install package

clean:
	mvn clean

deps:
	mvn dependency:resolve

lint:
	echo "TODO"

install:
	mvn install

package:
	mvn package

# Release with maven-release-plugin. First moves the CHANGELOG.md `## [Unreleased]` entries under
# `## [<version>] - <today>` and commits that, then commits the release version, tags it
# aem-helloworld-<version> and commits the next -SNAPSHOT version. Nothing is pushed; review,
# then run `git push --follow-tags`. Needs a clean working tree and entries under [Unreleased].
#   release-patch: 0.0.3-SNAPSHOT -> 0.0.3, next 0.0.4-SNAPSHOT
#   release-minor: 0.0.3-SNAPSHOT -> 0.1.0, next 0.1.1-SNAPSHOT
#   release-major: 0.0.3-SNAPSHOT -> 1.0.0, next 1.0.1-SNAPSHOT
define release
	set -euo pipefail; \
	export GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0=safe.directory GIT_CONFIG_VALUE_0=$(CURDIR); \
	git diff --quiet && git diff --cached --quiet \
	  || { echo "Commit or stash your changes before releasing"; exit 1; }; \
	awk '/^## \[Unreleased\]$$/ { found = 1; next } /^## / { found = 0 } found && /^- / { n++ } \
	  END { exit n ? 0 : 1 }' CHANGELOG.md \
	  || { echo "CHANGELOG.md has no entries under ## [Unreleased]"; exit 1; }; \
	current=$$($(MVN) -q help:evaluate -Dexpression=project.version -DforceStdout); \
	IFS=. read -r major minor patch <<< "$${current%-SNAPSHOT}"; \
	case "$(1)" in \
	  major) release="$$((major + 1)).0.0" ;; \
	  minor) release="$$major.$$((minor + 1)).0" ;; \
	  patch) release="$$major.$$minor.$$patch" ;; \
	esac; \
	IFS=. read -r major minor patch <<< "$$release"; \
	next="$$major.$$minor.$$((patch + 1))-SNAPSHOT"; \
	echo "Releasing $$current as $$release, next development version $$next"; \
	awk -v heading="## [$$release] - $$(date +%Y-%m-%d)" \
	  '{ print } /^## \[Unreleased\]$$/ && !done { print ""; print heading; done = 1 }' \
	  CHANGELOG.md > CHANGELOG.md.tmp && mv CHANGELOG.md.tmp CHANGELOG.md; \
	git commit -q -m "Update CHANGELOG for $$release" CHANGELOG.md; \
	$(MVN) release:prepare -DreleaseVersion="$$release" -DdevelopmentVersion="$$next" \
	  -DpushChanges=false; \
	$(MVN) release:clean
endef

# Release test, run on your machine (not in a container): starts RELEASE_IMAGE in Docker and uploads
# the committed HEAD to Maven Central at a test version, VERSION or by default the current version
# without -SNAPSHOT plus -rc.0 (0.0.3-SNAPSHOT -> 0.0.3-rc.0). The repository is mounted read-only and
# built from a copy, and the Maven repository is cached in the M2_VOLUME Docker volume. The deployment
# is never published (-DautoPublish=false): check it reaches VALIDATED, then drop it with
# release-drop or in the Central Portal. Passes MAVEN_GPG_KEY, MAVEN_GPG_PASSPHRASE,
# MAVEN_CENTRAL_USERNAME and MAVEN_CENTRAL_PASSWORD from your environment to the container.
RELEASE_IMAGE ?= maven:3.9.11-eclipse-temurin-11
M2_VOLUME ?= aem-helloworld-m2

release-test:
	@docker run --rm -v "$(CURDIR)":/workspace:ro -v $(M2_VOLUME):/root/.m2 -w /workspace \
	  -e GIT_CONFIG_COUNT=1 -e GIT_CONFIG_KEY_0=safe.directory -e GIT_CONFIG_VALUE_0=/workspace \
	  -e VERSION="$(VERSION)" \
	  -e MAVEN_GPG_KEY -e MAVEN_GPG_PASSPHRASE -e MAVEN_CENTRAL_USERNAME -e MAVEN_CENTRAL_PASSWORD \
	  $(RELEASE_IMAGE) bash -c '\
	    set -euo pipefail; \
	    work=$$(mktemp -d); git archive HEAD | tar -x -C "$$work"; cd "$$work"; \
	    current=$$($(MVN) -q help:evaluate -Dexpression=project.version -DforceStdout); \
	    version="$${VERSION:-$${current%-SNAPSHOT}-rc.0}"; \
	    echo "Uploading HEAD to Maven Central as $$version (not published; drop it when done)"; \
	    $(MVN) -q versions:set -DnewVersion="$$version" -DgenerateBackupPoms=false; \
	    $(MVN) -Prelease deploy -DskipTests -Dgpg.signer=bc -DautoPublish=false'

# Central Portal deployments (`mvn -Prelease deploy` prints the deployment ID). Uses the user token in
# MAVEN_CENTRAL_USERNAME and MAVEN_CENTRAL_PASSWORD; the Authorization header is passed to curl on
# stdin so the token is not visible in the process list.
#   release-status: show a deployment's state (e.g. VALIDATED, PUBLISHED, FAILED) and any errors
#   release-drop:   drop (delete) a deployment that has not been published
define central_api
	set -euo pipefail; \
	test -n "$(DEPLOYMENT_ID)" || { echo "Set DEPLOYMENT_ID, e.g. make $@ DEPLOYMENT_ID=<id>"; exit 1; }; \
	test -n "$${MAVEN_CENTRAL_USERNAME:-}" && test -n "$${MAVEN_CENTRAL_PASSWORD:-}" \
	  || { echo "Set MAVEN_CENTRAL_USERNAME and MAVEN_CENTRAL_PASSWORD"; exit 1; }; \
	token=$$(printf '%s:%s' "$$MAVEN_CENTRAL_USERNAME" "$$MAVEN_CENTRAL_PASSWORD" | base64 | tr -d '\n'); \
	printf 'Authorization: Bearer %s\n' "$$token" \
	  | curl -sS --fail-with-body -X $(1) -H @- -w '\nHTTP %{http_code}\n' \
	      "https://central.sonatype.com/api/v1/publisher/$(2)"
endef

release-status:
	@$(call central_api,POST,status?id=$(DEPLOYMENT_ID))

release-drop:
	@$(call central_api,DELETE,deployment/$(DEPLOYMENT_ID))

release-major:
	@$(call release,major)

release-minor:
	@$(call release,minor)

release-patch:
	@$(call release,patch)


.PHONY: ci clean deps lint install package release-test release-status release-drop release-major release-minor release-patch
