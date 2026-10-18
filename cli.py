import os
from pathlib import Path

import click

ACTIONS = click.Choice(["show", "hide", "toggle"])
# Avoid IPC method names that conflict with QuickShell's own subcommands.
ACTION_QUICKSHELL = {"show": "setShown", "hide": "setHidden", "toggle": "toggle"}


def control(entry: str, *arguments: str) -> None:
    config_home = Path(os.environ.get("XDG_CONFIG_HOME") or Path.home() / ".config")
    config_dir = Path(os.environ.get("FOYER_CONFIG_DIR") or config_home / "foyer")
    args = [
        "quickshell",
        "-p",
        str(config_dir / f"{entry}.qml"),
        *arguments,
    ]
    try:
        os.execvp("quickshell", args)
    except OSError as error:
        raise click.ClickException(str(error)) from error


@click.group()
def cli() -> None:
    """Control Foyer."""


@cli.command()
@click.argument("action", type=ACTIONS)
def bar(action: str) -> None:
    """Show, hide, or toggle the bar."""
    control("bar", "ipc", "call", "bar", ACTION_QUICKSHELL[action])


@cli.command()
@click.argument("action", type=ACTIONS)
def launcher(action: str) -> None:
    """Show, hide, or toggle the application launcher."""
    control("app_launcher", "ipc", "call", "app-launcher", ACTION_QUICKSHELL[action])


@cli.command()
@click.argument("action", type=ACTIONS)
def notifications(action: str) -> None:
    """Show, hide, or toggle the notification center."""
    methods = {
        "show": "setNotificationCenterOpen",
        "hide": "setNotificationCenterClosed",
        "toggle": "toggleNotificationCenter",
    }
    control("bar", "ipc", "call", "notifications", methods[action])


@cli.command()
def lock() -> None:
    """Lock the session until authenticated."""
    control("lock_screen", "--no-duplicate")


if __name__ == "__main__":
    cli(prog_name="foyer")
