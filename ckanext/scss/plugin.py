import ckan.plugins as plugins
import ckan.plugins.toolkit as toolkit


class ScssPlugin(plugins.SingletonPlugin):
    plugins.implements(plugins.IConfigurer)


    # IConfigurer

    def update_config(self, config_):
        toolkit.add_public_directory(config_, "public")
        toolkit.add_resource("assets", "scss")
