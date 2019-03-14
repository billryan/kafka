all: jar dockerbuild

jar:
	./gradlew clean releaseTarGz

dockerbuild:
	make -C docker
