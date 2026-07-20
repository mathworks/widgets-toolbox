# Repository Guidelines

## Project Structure & Module Organization

- 'deploy' for files needed to package it as a .mltbx
- 'release' for released versions
- 'resources' for MATLAB project files
- `test/` for automated tests
- `widgets/+wt` for source code
- 'widgets/doc' for user-facing documentation
- 'widgets/examples' for user-facing demo examples
- 'widgets/resources' for app designer json metadata to add widgets to the component library
- 'widgets/icons' for static icon files
- `widgets/templates` for user-facing app templates


## Build, Test, and Development Commands

- 'deploy/wtPackageRelease.m' is used to generate a release

## Widgets Architecture

- Reuse existing widget base classes where appropriate.
- Prefer composition over duplicating widget functionality.
- Follow existing event and listener patterns used throughout the toolbox.
- Maintain App Designer compatibility
- Reuse existing base classes
- Preserve API compatibility
- New widgets should include:
  - automated tests
  - documentation
  - example code
  - component library metadata when applicable

## Coding Style & Naming Conventions
Use consistent formatting from the start:

- Indent with 4 spaces unless the chosen language community strongly expects otherwise
- Prefer `snake_case` for files, `PascalCase` for types/classes
- Prefer `camelCase` for local variables
- Prefer `camelCase` for function and method names
- Use the modern arguments block instead of nargin
- Prefer clear and maintainable code.
- Use vectorization when it improves performance without harming readability.
- Check for equivalent toolbox functions before writing custom signal processing logic
- Add comments to explain intent and non-obvious logic.
- Avoid comments that merely restate the code.
- For conditional statements, have a line break then a comment before to explain what the conditional is doing.
- Prefer object-oriented MATLAB
- Use class-based unit tests
- Use MATLAB Code Analyzer recommendations
- Generate help text for all functions and headers for all files
- Avoid toolbox dependencies unless requested
- Ensure every code file header has a "Copyright Y The MathWorks, Inc." or "Copyright X-Y The MathWorks, Inc.", where Y is the current year if any edits were made.

If you add a formatter or linter, commit its config with the code that introduces it.

Before modifying code:

1. Review existing implementations for similar widgets.
2. Prefer extending existing framework classes.
3. Run or generate tests.
4. Preserve backward compatibility unless explicitly requested.

## Testing Guidelines
Add tests alongside new functionality instead of treating coverage as cleanup work. Name test files to match the implementation path, for example `test/+wt/+test/FileSelector.m` is a test for `widgets/+wt/FileSelector.m`.

For graphics components:
- verify behavior in uifigure environments
- maintain App Designer compatibility
- avoid undocumented graphics APIs unless already used in the repository
- consider desktop, MATLAB Online, and Web App compatibility when relevant

## Code Review Expectations

When reviewing code:
- identify defects before style issues
- identify compatibility risks (It must support MATLAB R2021a to present and future)
- identify missing tests
- identify API breaking changes
- suggest reuse of existing widgets before introducing new ones

## Release Guidelines
Before proposing a release:
- run relevant automated tests
- update documentation if user-facing behavior changes
- update examples if needed
- verify toolbox packaging still succeeds


## Commit & Pull Request Guidelines


Pull requests should include:

- a brief description of the change
- any setup or verification steps
- linked issue or task reference when available
- screenshots or sample output for UI or CLI changes

## Configuration & Secrets
Do not commit secrets, credentials, or machine-local config. Use environment variables and provide a sanitized example file such as `.env.example` when needed.
