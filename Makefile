###############################################################################
#                             requirements: start                             #
###############################################################################
ckan_tag = ckan-2.11.2

ext_list =

###############################################################################
#                              requirements: end                              #
###############################################################################

_version = master

-include deps.mk

prepare:
	curl -O https://raw.githubusercontent.com/DataShades/ckan-deps-installer/$(_version)/deps.mk


test-config ?= test_config/test.ini
test-server:  ## start server for frontend testing
	yes | ckan -c  $(test-config) db clean
	ckan -c $(test-config) search-index clear
	ckan -c $(test-config) db upgrade
	ckan -c $(test-config) run -t

test-frontend:  ## run e2e tests
	pytest --ckan-ini=$(test-config) -m playwright
