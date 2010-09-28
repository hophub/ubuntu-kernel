# The following targets are for the maintainer only! do not run if you don't
# know what they do.

.PHONY: printenv updateconfigs printchanges insertchanges startnewrelease diffupstream help updateportsconfigs editportsconfigs

help:
	@echo "These are the targets in addition to the normal $(DEBIAN) ones:"
	@echo
	@echo "  printenv        : Print some variables used in the build"
	@echo
	@echo "  updateconfigs        : Update core arch configs"
	@echo
	@echo "  editconfigs          : Update core arch configs interractively"
	@echo "  genconfigs           : Generate core arch configs in CONFIGS/*"
	@echo
	@echo "  updateportsconfigs   : Update ports arch configs"
	@echo
	@echo "  editportsconfigs     : Update ports arch configs interactivly"
	@echo "  genportconfigs       : Generate ports arch configs in CONFIGS/*"
	@echo
	@echo "  printchanges    : Print the current changelog entries (from git)"
	@echo
	@echo "  insertchanges   : Insert current changelog entries (from git)"
	@echo
	@echo "  startnewrelease : Start a new changelog set"
	@echo
	@echo "  diffupstream    : Diff stock kernel code against upstream (git)"
	@echo
	@echo "  help            : If you are kernel hacking, you need the professional"
	@echo "                    version of this"
	@echo
	@echo "Environment variables:"
	@echo
	@echo "  NOKERNLOG       : Do not add upstream kernel commits to changelog"
	@echo "  CONCURRENCY_LEVEL=X"
	@echo "                  : Use -jX for kernel compile"
	@echo "  PRINTSHAS       : Include SHAs for commits in changelog"

printdebian:
	@echo "$(DEBIAN)"

updateconfigs:
	dh_testdir;
	$(SHELL) $(DROOT)/scripts/misc/kernelconfig oldconfig
	rm -rf build

defaultconfigs:
	dh_testdir;
	yes "" | $(SHELL) $(DROOT)/scripts/misc/kernelconfig defaultconfig
	rm -rf build

editconfigs:
	dh_testdir
	$(SHELL) $(DROOT)/scripts/misc/kernelconfig editconfig
	rm -rf build

genconfigs:
	dh_testdir
	$(SHELL) $(DROOT)/scripts/misc/kernelconfig genconfig
	rm -rf build

updateportsconfigs:
	dh_testdir;
	$(SHELL) $(DROOT)/scripts/misc/kernelconfig oldconfig ports
	rm -rf build

editportsconfigs:
	dh_testdir
	$(SHELL) $(DROOT)/scripts/misc/kernelconfig editconfig ports
	rm -rf build

genportsconfigs:
	dh_testdir
	$(SHELL) $(DROOT)/scripts/misc/kernelconfig genconfig ports
	rm -rf build

printenv:
	dh_testdir
	@echo "src package name  = $(src_pkg_name)"
	@echo "release           = $(release)"
	@echo "revisions         = $(revisions)"
	@echo "revision          = $(revision)"
	@echo "uploadnum         = $(uploadnum)"
	@echo "prev_revisions    = $(prev_revisions)"
	@echo "prev_revision     = $(prev_revision)"
	@echo "abinum            = $(abinum)"
	@echo "gitver            = $(gitver)"
	@echo "flavours          = $(flavours)"
	@echo "skipabi           = $(skipabi)"
	@echo "skipmodule        = $(skipmodule)"
	@echo "skipdbg           = $(skipdbg)"
	@echo "ubuntu_log_opts   = $(ubuntu_log_opts)"
ifneq ($(SUBLEVEL),)
	@echo "SUBLEVEL          = $(SUBLEVEL)"
endif
	@echo "CONCURRENCY_LEVEL = $(CONCURRENCY_LEVEL)"
	@echo "bin package name  = $(bin_pkg_name)"
	@echo "hdr package name  = $(hdrs_pkg_name)"
	@echo "doc package name  = $(doc_pkg_name)"
	@echo "do_doc_package            = $(do_doc_package)"
	@echo "do_doc_package_content    = $(do_doc_package_content)"
	@echo "do_source_package         = $(do_source_package)"
	@echo "do_source_package_content = $(do_source_package_content)"
	@echo "do_libc_dev_package       = $(do_libc_dev_package)"
	@echo "do_common_headers_indep   = $(do_common_headers_indep)"
	@echo "do_full_source            = $(do_full_source)"
	@echo "do_tools                  = $(do_tools)"

printchanges:
	@baseCommit=$$(git log --pretty=format:'%H %s' | \
		awk '/UBUNTU: '".*Ubuntu-$(release)-$(prev_revision)"'$$/ { print $$1; exit }'); \
		git log "$$baseCommit"..HEAD | \
		perl -w -f $(DROOT)/scripts/misc/git-ubuntu-log $(ubuntu_log_opts)

insertchanges:
	@perl -w -f $(DROOT)/scripts/misc/insert-changes.pl $(DROOT) $(DEBIAN) 

diffupstream:
	@git diff-tree -p refs/remotes/linux-2.6/master..HEAD $(shell ls | grep -vE '^(ubuntu|$(DEBIAN)|\.git.*)')

startnewrelease:
	dh_testdir
	@nextminor=$(shell expr `echo $(revision) | awk -F. '{print $$2}'` + 1); \
	now="$(shell date -R)"; \
	echo "Creating new changelog set for $(abi_release).$$nextminor..."; \
	echo -e "$(src_pkg_name) ($(abi_release).$$nextminor) UNRELEASED; urgency=low\n" > $(DEBIAN)/changelog.new; \
	echo "  CHANGELOG: Do not edit directly. Autogenerated at release." >> \
		$(DEBIAN)/changelog.new; \
	echo "  CHANGELOG: Use the printchanges target to see the curent changes." \
		>> $(DEBIAN)/changelog.new; \
	echo "  CHANGELOG: Use the insertchanges target to create the final log." \
		>> $(DEBIAN)/changelog.new; \
	echo -e "\n -- $$DEBFULLNAME <$$DEBEMAIL>  $$now\n" >> \
		$(DEBIAN)/changelog.new ; \
	cat $(DEBIAN)/changelog >> $(DEBIAN)/changelog.new; \
	mv $(DEBIAN)/changelog.new $(DEBIAN)/changelog

