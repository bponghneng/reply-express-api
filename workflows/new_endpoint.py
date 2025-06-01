from pathlib import Path
from aider.coders import Coder
from aider.models import Model
from aider.io import InputOutput
import sys


def new_endpoint(spec_file_name: str):
    """
    Create a new endpoint based on the given spec file.

    Args:
        spec_file_name (str): Name of the spec file to generate the endpoint from.
    """

    pyproject_path = Path.cwd() / "pyproject.toml"
    if not pyproject_path.exists():
        raise FileNotFoundError(
            "pyproject.toml not found in current directory - move to the root of the project"
        )

    # Read the spec from 'spec-template.md'
    spec_path = Path.cwd() / "specs" / spec_file_name
    if not spec_path.exists():
        raise FileNotFoundError(
            f"{spec_file_name} not found in current directory - please make sure it exists"
        )
    with open(spec_path, "r") as spec_file:
        spec_prompt = spec_file.read()

    # Setup BIG THREE: context, prompt, and model

    # Files to be edited
    context_editable = [
        "lib/reply_express/accounts/aggregates/user.ex",
        "lib/reply_express/accounts/users_context.ex",
        "lib/reply_express/accounts/user_tokens_context.ex",
        "lib/reply_express_web/router.ex",
    ]

    # Files that are read-only references
    context_read_only = [
        "lib/reply_express/accounts/commands/generate_password_reset_token.ex",
        "lib/reply_express/accounts/commands/register_user.ex",
        "lib/reply_express/accounts/events/password_reset_token_generated.ex",
        "lib/reply_express_web/controllers/api/v1/users/reset_password_controller.ex",
        "mix.exs",
    ]

    # Define the prompt for the AI model
    prompt = spec_prompt

    # Initialize the AI model
    model = Model(
        "claude-3-7-sonnet-latest",
        editor_model="gpt-4.1",
        editor_edit_format="diff",
    )

    # Initialize the AI Coding Assistant
    coder = Coder.create(
        main_model=model,
        edit_format="architect",
        io=InputOutput(yes=True),
        fnames=context_editable,
        read_only_fnames=context_read_only,
        auto_commits=True,
        suggest_shell_commands=False,
    )

    # Run the code modification
    coder.run(prompt)


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python new_endpoint.py '<spec-file-name>'")
        sys.exit(1)

    spec_file_name = sys.argv[1]
    new_endpoint(spec_file_name)
