_installer_version = v0.0.33
_version ?= $(_installer_version)

develop =
local =
pyright_compatible = 1

root_dir = ..
index ?= pypi

alternative ?= remote
remote-ckan ?= https://github.com/ckan/ckan.git tag $(ckan_tag)
upgrade_requirements ?= 1

vpath ckanext-% $(root_dir)
vpath ckan $(root_dir)

define pip-file
$(if $(pyright_compatible),SETUPTOOLS_ENABLE_FEATURES="legacy-editable" )pip install $(if $(2),-U )-r "$(1)"$(if $(local), --no-index -f "$(root_dir)/$(index)");
endef

define self-install
$(if $(pyright_compatible),SETUPTOOLS_ENABLE_FEATURES="legacy-editable" )pip install -e'.$(if $(1),[$(1)])' $(if $(local), --no-index -f "$(root_dir)/$(index)");
endef

define resolve-package-extras
$(package_extras-$(alternative)-$(1))
endef

define deps-install
for f in requirements.txt pip-requirements.txt; do \
	if [ -f "$$f" ]; then $(call pip-file,$$f,$(upgrade_requirements)) fi; \
done;
endef

define dev-install
if [ "$(develop)" != "" ] && [ -f "dev-requirements.txt" ]; then \
	$(call pip-file,dev-requirements.txt) \
fi;
endef

define	ensure-ckan
@if [ ! -d "$(root_dir)/ckan" ]; then \
	echo "CKAN is not available at $(root_dir)/ckan"; \
	exit 0; \
fi;
endef

define checkout-branch
git checkout -B $(1) origin/$(1); \
git reset --hard origin/$(1);
endef

define checkout-tag
git checkout $(1);
endef

define checkout-commit
git checkout $(1);
endef

define checkout-target
$(call checkout-$(2),$(1))
endef

define download-packages
pip download . -d "$(root_dir)/$(index)"; \
for f in requirements.txt pip-requirements.txt dev-requirements.txt; do \
	if [ -f "$$f" ]; then pip download -r "$$f" -d "$(root_dir)/$(index)"; fi; \
done;
endef

define resolve-remote
$(or $($(alternative)-$(1)),$(remote-$(1)),$(call ckan-maintained-remote,$(1)))
endef

define ckan-maintained-remote
https://github.com/ckan/ckanext-$(1).git branch master
endef

info:
	@echo CKAN dependencies installer
	@echo
	@echo Usage:
	@echo -e '\tmake [target]'
	@echo TLDR\;
	@echo -e '\tmake prepare'
	@echo -e '\tmake full-upgrade'
	@echo
	@echo Targets:
	@echo -e '\tversion - check if current version of installer is correct'
	@echo
	@echo -e '\tlist - list all dependencies'
	@echo
	@echo -e '\tckanext-NAME - clone the extension if missing and checkout to the required state'
	@echo -e '\tckanext - perform ckanext-NAME for every single dependency'
	@echo
	@echo -e '\tsync-NAME - clone, update origin, reset changes and checkout the extension'
	@echo -e '\tsync - perform sync-NAME for every single dependency'
	@echo
	@echo -e '\tinstall-NAME - install the extension and its pip-requirements'
	@echo -e '\tinstall - perform install-NAME for every single dependency'
	@echo
	@echo -e '\tckan-check - verify CKAN version'
	@echo -e '\tcheck-NAME - check whether the extension is in required state'
	@echo -e '\tcheck - perform check-NAME for every single dependency and do `ckan-check`'
	@echo
	@echo -e '\tckan - clone CKAN repository'
	@echo -e '\tckan-sync - set CKAN to the expected tag'
	@echo -e '\tckan-install - install CKAN with its requirements'
	@echo
	@echo -e '\tself-install - install current extension and its requirements'
	@echo
	@echo -e '\tfull-upgrade - synchronize and install everything(it is just a combination of `sync ckan-sync install ckan-install self-install`)'
	@echo
	@echo -e '\tlocal-index - download all the requirements. This allows you to install the project with `local=1` flag even without internet access'
	@echo
	@echo 'Flags:'
	@echo -e '\tsync*:'
	@echo -e '\t\talternative=<prefix> - try using `<prefix>-<ext>` definition of extensions before falling back to `remote-<ext>`'
	@echo
	@echo -e '\tinstall*:'
	@echo -e '\t\tdevelop=1 - install dev-requirements if present'
	@echo -e '\t\tlocal=1   - use local packages instead of PyPI(you need to build it first via `make local-index`)'
	@echo
	@echo -e '\tinstall*, local-index:'
	@echo -e "\t\tindex=pypi - path to local package index(relative to $$(realpath $(root_dir))). By default: $(index)"
	@echo

version:
ifeq (master,$(_version))
	@echo You are using master branch of deps-installer.
	@echo 'Run `make prepare` in order to check/pull latest version'
else
ifneq ($(_installer_version),$(_version))
	@echo You are using incorrect version of installer: $(_version) instead of $(_installer_version)
	@echo 'Run `make prepare` in order to fix this problem'
else
	@echo Your version of installer is up-to-date
endif
endif

list:
	@echo $(ext_list)

.SECONDEXPANSION:

install ckanext sync check local-index: $(ext_list:%=$$@-%)
ckanext-% check-% sync-% install-% local-index-% %.tar: ext_path=$(root_dir)/ckanext-$*
ckanext-% check-% sync-% install-%: type = $(word 2, $(call resolve-remote,$*))
ckanext-% check-% sync-% install-%: remote = $(firstword $(call resolve-remote,$*))
ckanext-% check-% sync-% install-%: target = $(word 3, $(call resolve-remote,$*))
install-%: package_extras = $(call resolve-package-extras,$*)
archive: $(ext_list:%=%.tar)

install-ckan:
	$(error Use 'ckan-install' rule if you need to install CKAN core)

ckanext-%:
	@echo [Clone $* into $(ext_path)]
	git clone $(remote) $(ext_path);
	cd $(ext_path); \
	$(call checkout-target,$(target),$(type))

sync-%: ckanext-%
	@echo [Synchronize $*];
	cd $(ext_path); \
	git remote set-url origin $(remote); \
	git fetch origin --tags;
	cd $(ext_path); \
	git reset --hard; \
	$(call checkout-target,$(target),$(type)) \
	git clean -df;

ckan: ckan_path=$(root_dir)/ckan

ckan ckan-sync: type = $(word 2, $(call resolve-remote,ckan))
ckan ckan-sync: remote = $(firstword $(call resolve-remote,ckan))
ckan ckan-sync ckan-check: target = $(lastword $(call resolve-remote,ckan))
ckan:
	@echo [Clone ckan into $(ckan_path)]
	git clone $(remote) $(ckan_path);

ckan-sync: ckan
	$(call ensure-ckan)
	cd $(root_dir)/ckan; \
	git remote set-url origin $(remote); \
	git fetch origin --tags;
	cd $(root_dir)/ckan; \
	git reset --hard; \
	$(call checkout-target,$(target),$(type)) \
	git clean -df;

ckan-install:
	$(call ensure-ckan)
	cd $(root_dir)/ckan; \
	$(call self-install) \
	$(call deps-install) \
	$(call dev-install)

self-install:
	$(call self-install) \
	$(call deps-install) \
	$(call dev-install)

install-%: ckanext-%
	cd $(ext_path); \
	$(call self-install,$(package_extras)) \
	$(call deps-install) \
	$(call dev-install)

check: ckan-check
check-%:
	@if [ ! -d "$(ext_path)" ]; then \
		echo $(ext_path) does not exist; \
		exit 0; \
	fi; \
	cd "$(ext_path)"; \
	remote_url=$$(git remote get-url origin); \
	if [ "$$remote_url" != "$(remote)" ]; then \
		echo $* remote is different from $(remote): $$remote_url; \
		exit 0; \
	fi; \
	if [ "$(type)" = "branch" ]; then \
		branch=$$(git rev-parse --abbrev-ref HEAD); \
		if [ "$$branch" != "$(target)" ]; then \
			echo $* branch is different from $(target): $$branch; \
			exit 0; \
		fi; \
		git fetch origin --tags; \
		if [ "$$(git log ..origin/$$branch)" != "" ]; then \
			echo $* remote has extra commits; \
			exit 0; \
		fi; \
	elif [ "$(type)" = "commit" ] || [ "$(type)" = "tag" ]; then \
		expected=$$(git rev-list -n1 $(target)); \
		current=$$(git rev-list -n1 HEAD); \
		if [ "$$current" != "$$expected" ]; then \
			if [ "$(type)" = "tag" ]; then\
				echo "$* commit is different from $(target)($$expected): $$current"; \
			else \
				echo "$* commit is different from $(target): $$current"; \
			fi; \
			exit 0; \
		fi; \
	fi; \
	echo $* is up-to-date;

ckan-check:
	$(call ensure-ckan)
	@cd $(root_dir)/ckan; \
	current_tag=$$(git describe --tags); \
	if [ "$$current_tag" != "$(target)" ]; then \
		echo "CKAN is using wrong tag: $$current_tag. Expected: $(target)"; \
		exit 0; \
	else \
		echo "CKAN is using correct tag: $$current_tag"; \
	fi;

full-upgrade: ckan-sync sync ckan-install install self-install

local-index:
	$(call ensure-ckan)
	cd $(root_dir)/ckan; \
	pip download wheel setuptools -d "$(root_dir)/$(index)"; \
	$(call download-packages)
	$(call download-packages)

local-index-%:
	cd $(ext_path); \
	$(call download-packages)

%.tar:
	tar cvf $(root_dir)/$@ --exclude-vcs $(ext_path)

archive:
	tar cvf $(root_dir)/src.tar --exclude-vcs $(root_dir)/ckan;
	for ext in $(ext_list); do \
		tar Af $(root_dir)/src.tar --exclude-vcs "$(root_dir)/$$ext.tar"; \
		rm -f $(root_dir)/$$ext.tar; \
	done;
	self=$$(basename $$PWD); \
	tar cvf "$(root_dir)/$$self.tar" "$(root_dir)/$$self/deps.mk" --exclude-vcs "$(root_dir)/$$self"; \
	tar Af $(root_dir)/src.tar "$(root_dir)/$$self.tar"; \
	rm -f "$(root_dir)/$$self.tar"

	tar cvf "$(root_dir)/$(index).tar" "$(root_dir)/$(index)"; \
	tar Af $(root_dir)/src.tar "$(root_dir)/$(index).tar"; \
	rm -f "$(root_dir)/$(index).tar"

	gzip < "$(root_dir)/src.tar" > "$(root_dir)/src.tar.gz"
	rm -f "$(root_dir)/src.tar"
