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

.PHONY: ci clean deps lint install package
