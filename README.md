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


## Credits

Photos by Hitoshi Suzuki, Joshua Rodriguez, Roman Kraft and Nathan Dumlao used under the [Unsplash Licence](https://unsplash.com/license).
