from __future__ import annotations

from typing import Any

import pytest
import factory
from faker import Faker
from playwright.sync_api import expect
from pytest_factoryboy import register

from ckan.tests import factories

expect.set_options(timeout=1000)
fake = Faker()


@pytest.fixture()
def browser_context_args(
    browser_context_args: dict[str, Any], ckan_config: dict[str, Any]
):
    """Modify playwright's standard configuration of browser's context."""
    browser_context_args["base_url"] = ckan_config["ckan.site_url"]
    return browser_context_args


@register(_name="resource")
class ResourceFactory(factories.Resource):
    package_id = factory.LazyFunction(lambda: DatasetFactory()["id"])


@register(_name="dataset")
class DatasetFactory(factories.Dataset):
    owner_org = factory.LazyAttribute(lambda _: factories.Organization()["id"])


@register(_name="organization")
class OrganizationFactory(factories.Organization):
    image_url = factory.LazyFunction(lambda: fake.image_url(width=100, height=100))


@register(_name="group")
class GroupFactory(factories.Group):
    image_url = factory.LazyFunction(lambda: fake.image_url(width=100, height=100))


@register(_name="user")
class UserFactory(factories.UserWithToken):
    image_url = factory.LazyFunction(lambda: fake.image_url(width=100, height=100))


@register(_name="sysadmin")
class SysadminFactory(factories.SysadminWithToken):
    pass
