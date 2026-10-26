---
name: matlab-use-widgets-toolbox
description: Build or extend MATLAB applications using Widgets Toolbox controls, app bases, sessions, preferences, and model/view infrastructure. Use when the user requests Widgets Toolbox or an existing app uses the wt namespace. Requires existing application code that establishes the development approach, or an explicit choice of App Designer versus hand code, before app planning or implementation.
---

# Develop applications with Widgets Toolbox

Use Widgets Toolbox as a dependency in the user's application. Reuse its
components and framework capabilities before implementing equivalent behavior.
Keep application-specific code in the user's own namespace, outside `+wt`.

## Establish the development approach first

Before recommending an application architecture, planning the app, or writing
application code, require one of these:

- **Existing application code:** Inspect it to establish App Designer or hand
  code as the development approach. Preserve that approach unless the user
  requests a change. A standalone widget or an unrelated MATLAB script does not
  establish the approach for a new application.
- **An explicit choice:** Accept an approach already stated by the user.
  Otherwise explain the comparison below, then ask, **"Do you want to use App
  Designer or hand code?"** Wait for the answer before dependent planning or
  implementation.

If the existing application mixes approaches or the target is ambiguous, ask
which approach governs the requested work. Do not select one automatically
from app complexity, appearance, or expected lifetime. Read-only discovery can
continue while waiting. Do not repeat this question once the choice is clear.

Use this comparison to help a user choosing an approach for a new app:

| Approach | Advantages | Tradeoffs |
| --- | --- | --- |
| **App Designer** | Convenient visual layout editing: move controls, adjust spacing, and reorganize panels interactively. Integrated property and callback tools reduce UI setup work. Apps can host reusable Widgets Toolbox controls, models, and view components. | The generated top-level app structure provides less flexibility for custom inheritance and code organization. Widgets Toolbox's `wt.apps` base classes are intended for hand-coded apps. |
| **Hand code** | Much greater flexibility for modular architecture and code reuse. Organize functionality into focused classes, namespaces, and separate files; compose reusable views and services; customize inheritance and lifecycle hooks; and share app infrastructure across projects. Directly use Widgets Toolbox app bases for sessions and preferences. | You lose App Designer's ease of visual layout changes. Moving controls, changing spacing, and restructuring panels requires editing layout code and running the app to inspect the result. Developers configure and maintain the grid layouts and resizing behavior. |

Both approaches support reusable components, separated application logic, and
automated testing. The `wt.apps` base classes are not an alternative superclass
to insert into a generated `.mlapp` class. Reusable model/view components can
still be hosted within an App Designer application.

## Locate the toolbox and establish compatibility

Inspect the user's project and dependencies before changing paths. Prefer an
existing MATLAB MCP session when available. Confirm its release and intended
project before project-sensitive execution.

```matlab
version('-release')
which('wt.FileSelector', '-all')
toolboxRoot = wt.utility.widgetsRoot();
```

Use the selected installation's source, help, examples, and metadata as the
authority for exact API names and availability. Multiple `which` results may
indicate conflicting installations. Resolve the intended dependency before
editing code; do not disable add-ons automatically.

For a source checkout used as a dependency, add `widgets` and `widgets/icons`
to the consumer project's path using its normal project setup. Add
`widgets/examples` only when inspecting or running examples. Do not add `+wt`
itself or recursively add every folder. Installed toolbox packages configure
their runtime paths.

Do not open `WidgetsToolbox.prj` merely to consume the toolbox: its maintainer
startup closes figures, clears classes, and disables an installed toolbox copy.
Open the user's application project when its workflow requires that project.

The repository declares MATLAB R2021a+ support, but individual capabilities may
need newer releases. For example, `wt.DateSlider` requires R2023b+,
`wt.DateRangeSlider` requires R2024b+, and MATLAB UI theme APIs need R2025a+.
Check both the user's release and the selected toolbox version. Maintainer
Build Tool requirements are separate from application runtime requirements.

## Choose the smallest useful toolbox layer

| Application need | Read when relevant |
| --- | --- |
| Add controls, dialogs, a toolbar, or progress feedback | [Components](references/components.md) |
| Build a hand-coded app with preferences or saved sessions | [Application framework](references/application-framework.md) |
| Share models between views or switch contextual content | [Models and views](references/models-and-views.md) |
| Create a reusable widget, view, or dialog | [Custom extensions](references/custom-extensions.md) |
| Test interactions, check App Designer, or deploy an app | [Validation and deployment](references/validation-and-deployment.md) |

Compose existing controls into the user's current app when that meets the need.
Choose an app superclass only when its lifecycle or session management is
useful. The toolbox's MVC infrastructure already supplies model observation and
view refresh; preserve it rather than adding a duplicate binding framework.

Read only the references needed for the task. Paths in these references are
relative to `toolboxRoot` unless explicitly marked repository-only. They remain
usable when this skill folder is copied into an agent's skill directory.

## Find examples and implement

- Read `doc/UserGuide.html`, `doc/WidgetsList.html`, and the relevant example
  under `examples`. In a checkout, documentation `.mlx` sources are also
  available; installed packages omit most of those documentation sources.
- Use `help('wt.FileSelector')` or inspect the resolved class for exact property,
  method, and event contracts. Resolve disagreements in older prose against
  the selected source and relevant tests.
- Open local HTML with `web(fullfile(toolboxRoot,'doc','UserGuide.html'))` when
  requested. These are local HTML pages; a search index alone does not prove
  native MATLAB `doc` integration.
- Open examples by full path. `wtExamplesFolder` changes the current folder,
  and `wtExamplesList` expects documentation sources that may be absent from an
  installed package. Avoid those side effects when locating examples.
- Adapt examples into the user's namespace. Keep business logic separate from
  UI callbacks, preserve public component interfaces, and verify callbacks
  against their actual event data rather than guessing field names.
- Validate the changed application behavior using the final reference. Report
  the MATLAB release, checks performed, and any limitations.

## Work with other skills when available

This skill is self-contained. Do not require another skill to be installed.
When available, use `matlab-build-app` for app layout and App Designer authoring
after the development approach above is established. Use the toolbox's
app/model/view patterns where selected; a separate MVVM layer is not required.

Use `matlab-build-chart` for plot design, `matlab-apply-theme` when styling is
requested, `matlab-write-tests` and `matlab-run-tests` for focused testing,
`matlab-review-code` for code review, and `matlab-appdesigner-compatibility` for
editor-load or component-registration problems. Respect the user's release
baseline and avoid adding products solely to follow an optional example.

<!-- Copyright 2026 The MathWorks, Inc. -->
