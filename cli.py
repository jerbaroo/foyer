import os
from pathlib import Path
import shutil
import subprocess
import tempfile

import click

ACTIONS = click.Choice(["show", "hide", "toggle"])
# Avoid IPC method names that conflict with QuickShell's own subcommands.
ACTION_QUICKSHELL = {"show": "setShown", "hide": "setHidden", "toggle": "toggle"}


def command(entry: str, *arguments: str) -> list[str]:
    config_home = Path(os.environ.get("XDG_CONFIG_HOME") or Path.home() / ".config")
    config_dir = Path(os.environ.get("FOYER_CONFIG_DIR") or config_home / "foyer")
    return [
        "quickshell",
        "-p",
        str(config_dir / f"{entry}.qml"),
        *arguments,
    ]


def control(entry: str, *arguments: str) -> None:
    try:
        os.execvp("quickshell", command(entry, *arguments))
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


@cli.command()
def text() -> None:
    """Show plain text from standard input in the running text viewer."""
    if click.get_text_stream("stdin").isatty():
        raise click.UsageError("Pipe text to this command or redirect a file into it.")
    try:
        with tempfile.NamedTemporaryFile(prefix="foyer-text-") as source:
            shutil.copyfileobj(click.get_binary_stream("stdin"), source)
            source.flush()
            result = subprocess.run(
                command("text", "ipc", "call", "text", "setShown", source.name),
                stdin=subprocess.DEVNULL,
            )
    except OSError as error:
        raise click.ClickException(str(error)) from error
    raise click.exceptions.Exit(
        result.returncode if result.returncode >= 0 else 128 - result.returncode
    )


if __name__ == "__main__":
    cli(prog_name="foyer")
