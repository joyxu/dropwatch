REL_VERSION:=1.0
REL_RELEASE:=2
ROOT_DIR=$(shell pwd)

rel-upload: release
	scp $(ROOT_DIR)/stage/dropwatch-$(REL_VERSION).tbz2 fedorahosted.org:dropwatch

release: tarball 

tarball:
	mkdir -p stage 
	ln -s $(ROOT_DIR) stage/dropwatch-$(REL_VERSION)
	tar jchf $(ROOT_DIR)/stage/dropwatch-$(REL_VERSION).tbz2 --exclude \.git --exclude stage -C stage dropwatch-$(REL_VERSION)/
	mv $(ROOT_DIR)/stage/*.tbz2 $(ROOT_DIR)
	rm -rf stage

srpm: tarball
	$(shell sed -e"s/MAKEFILE_VERSION/$(REL_VERSION)/" -e"s/MAKEFILE_RELEASE/$(REL_RELEASE)/" ./spec/dropwatch.spec > ./dropwatch.spec)
	rpmbuild --define "_sourcedir $(ROOT_DIR)" --define "_srcrpmdir $(ROOT_DIR)" -bs $(ROOT_DIR)/dropwatch.spec

rpm: srpm
	mkdir -p BUILD
	mkdir -p RPMS
	rpmbuild --define "_sourcedir $(ROOT_DIR)" --define "_builddir $(ROOT_DIR)/BUILD" --define "_rpmdir $(ROOT_DIR)/RPMS" -bb $(ROOT_DIR)/dropwatch.spec
	rm -rf BUILD

clean:
	rm -f $(ROOT_DIR)/dropwatch*.tbz2 $(ROOT_DIR)/*.rpm $(ROOT_DIR)/*.spec
	rm -rf BUILD
	rm -rf RPMS
	rm -rf stage

build:
	make -C src all 

build_clean:
	make -c src clean
