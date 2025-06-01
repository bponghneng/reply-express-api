from pathlib import Path
from aider.coders import Coder
from aider.models import Model
from aider.io import InputOutput
import sys


def workflow_template(description: str):
    """
    Create a new <thing> based on the given description.

    Args:
        description (str): Description of the new <thing> to generate.
    """

    pyproject_path = Path.cwd() / "pyproject.toml"
    if not pyproject_path.exists():
        raise FileNotFoundError(
            "pyproject.toml not found in current directory - move to the root of the project"
        )

    # Read the spec from 'spec-template.md'
    spec_path = Path.cwd() / "specs" / "spec-template.md"
    if not spec_path.exists():
        raise FileNotFoundError(
            "spec-template.md not found in current directory - please make sure it exists"
        )
    with open(spec_path, "r") as spec_file:
        spec_content = spec_file.read()

    # Include the description in the spec prompt
    spec_prompt = spec_content.replace("<description>", description)

    # Setup BIG THREE: context, prompt, and model

    # Files to be edited
    context_editable = []

    # Files that are read-only references
    context_read_only = []

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
        auto_commits=False,
        suggest_shell_commands=False,
    )

    # Run the code modification
    coder.run(prompt)


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python workflow_template.py '<description>'")
        sys.exit(1)

    description = sys.argv[1]
    workflow_template(description)
