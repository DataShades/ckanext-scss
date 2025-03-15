from __future__ import annotations

from pathlib import Path
from typing import Any, Callable
import shutil
import pytest
from playwright.sync_api import Page

from .conftest import UserFactory, SysadminFactory


@pytest.mark.usefixtures("clean_db", "clean_index")
@pytest.mark.playwright()
class TestPageStyles:
    def test_page_styles(
        self,
        page: Page,
        user_factory: Callable[..., dict[str, Any]],
        dataset_factory: Callable[..., dict[str, Any]],
        resource_factory: Callable[..., dict[str, Any]],
        organization_factory: Callable[..., dict[str, Any]],
        group_factory: Callable[..., dict[str, Any]],
    ):
        """
        Test the page styles by taking screenshots of the pages.
        """
        self._prepare_test_data(
            user_factory,
            dataset_factory,
            resource_factory,
            organization_factory,
            group_factory,
        )
        page.set_viewport_size({"width": 1920, "height": 1080})

        for identity in ["anonymous", "user", "sysadmin"]:
            self._init_screenshot_dir(identity)

            page.set_extra_http_headers(
                {"Authorization": self._get_identity_token(identity)}
            )

            for name, url in self.test_pages:
                page.goto(url)

                self._make_screenshot(page, name)

    def _prepare_test_data(
        self,
        user_factory: Callable[..., dict[str, Any]],
        dataset_factory: Callable[..., dict[str, Any]],
        resource_factory: Callable[..., dict[str, Any]],
        organization_factory: Callable[..., dict[str, Any]],
        group_factory: Callable[..., dict[str, Any]],
    ):
        """
        Prepare the test data.

        Args:
            user_factory: The factory to create a user.
            dataset_factory: The factory to create a dataset.
            resource_factory: The factory to create a resource.
            organization_factory: The factory to create an organization.
            group_factory: The factory to create a group.
        """
        self.user = user_factory()
        self.dataset = dataset_factory()
        self.resource = resource_factory(package_id=self.dataset["id"])
        self.organization = organization_factory()
        self.group = group_factory()

        self.test_pages = self._get_test_pages()

    def _init_screenshot_dir(self, identity: str):
        """
        Initialize the screenshot directory and delete all existing screenshots.

        Args:
            identity: The identity to initialize the screenshot directory for.
        """
        main_dir = Path("screenshots")
        main_dir.mkdir(exist_ok=True)

        self.screenshot_dir = main_dir / identity
        self.screenshot_dir.mkdir(exist_ok=True)

        for file in self.screenshot_dir.iterdir():
            file.unlink()

    def _get_test_pages(self) -> list[tuple[str, str]]:
        """
        Get the list of test pages.

        Returns:
            A list of tuples, each containing a name and a URL.
        """
        pkg_name = self.dataset["name"]
        res_id = self.resource["id"]
        username = self.user["name"]

        return [
            # OTHER PAGES
            ("about", "/about"),
            ("home", "/"),
            # AUTH PAGES
            ("user_login", "/user/login"),
            ("user_register", "/user/register"),
            ("user_reset", "/user/reset"),
            # ORGANIZATION PAGES
            ("organization_list", "/organization"),
            ("organization_read", f"/organization/{self.organization['name']}"),
            # GROUP PAGES
            ("group_list", "/group"),
            ("group_read", f"/group/{self.group['name']}"),
            # USER PAGES
            ("user_list", "/user"),
            ("user_read", f"/user/{username}"),
            ("user_edit", f"/user/edit/{username}"),
            ("user_api_tokens", f"/user/{username}/api-tokens"),
            # DATASET PAGES
            ("search", "/dataset"),
            ("dataset_read", f"/dataset/{pkg_name}"),
            ("dataset_groups", f"/dataset/groups/{pkg_name}"),
            (
                "resource_read",
                f"/dataset/{pkg_name}/resource/{res_id}",
            ),
            # DASHBOARD PAGES
            ("dashboard_datasets", "/dashboard/datasets"),
            ("dashboard_organizations", "/dashboard/organizations"),
            ("dashboard_groups", "/dashboard/groups"),
            # SYSADMIN PAGES
            ("ckan_admin", "/ckan-admin"),
            ("ckan_admin_config", "/ckan-admin/config"),
            ("ckan_admin_trash", "/ckan-admin/trash"),
        ]

    def _make_screenshot(self, page: Page, name: str):
        """
        Make a screenshot of the page.

        Args:
            page: Playwright page object.
            name: The name of the page we want to screenshot.
        """
        page.screenshot(
            path=self.screenshot_dir / f"snapshot-{name}.png",
            full_page=True,  # Captures the full scrollable page
            type="png",  # PNG format for best quality (no compression artifacts)
            scale="device",  # Uses the device scale factor for better resolution
        )

    def _get_identity_token(self, identity: str) -> str:
        """
        Get the identity token.

        Args:
            identity: The identity to get the token for.

        Returns:
            The token for the identity.
        """
        if identity == "user":
            return UserFactory()["token"]
        elif identity == "sysadmin":
            return SysadminFactory()["token"]

        return ""
