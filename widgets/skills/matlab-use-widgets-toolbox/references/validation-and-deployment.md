# Verify and deliver the consumer application

Use the user's existing test conventions. Toolbox repository tests are useful
evidence and examples when a checkout is available, but consumer apps must not
depend on `wt.test` or expect it in an installed toolbox.

## Test the changed behavior

Use `matlab.unittest.TestCase` for model/service tests and
`matlab.uitest.TestCase` for supported UI gestures. Test public behavior and
observable effects. Programmatically assigning a property verifies state
synchronization, not a user callback; use a supported gesture for that contract.
Use fixture teardown for figures, temporary session files, listeners, and any
test-specific preference group.

For asynchronous UI updates, prefer constraints instead of arbitrary delays:

```matlab
% Inside a test method, with a view bound to model:
import matlab.unittest.constraints.Eventually
import matlab.unittest.constraints.IsEqualTo
model.Gain = 3;
testCase.verifyThat(@()view.GainField.Value, ...
    Eventually(IsEqualTo(3), 'WithTimeoutOf', 5));
```

Before pressing a newly added toolbar button, wait until its ancestor figure is
the intended figure with `Eventually(IsEqualTo(fig))` applied to
`@()ancestor(button,'figure')`. Assigning `Toolbar.Section` schedules parenting
during the component's update; an immediate gesture can run before it is ready.

Select the scenarios relevant to the change:

| Area | Observable checks |
| --- | --- |
| Controls | Initial values, edits, callback count/payload, invalid input, enable state, resizing |
| Model/view | Property changes redraw; model replacement stops old-model updates; empty/deleted model is handled |
| Aggregated models | Child edits propagate; replacing a child detaches old listeners; copies are independent |
| Contextual views | Switching detaches old models; returning reuses the correct view; clearing leaves no active content |
| Session apps | Edit marks dirty; save/load round trip; invalid file; save failure; cancellation preserves the current session |
| Preferences | Defaults on first use; persistence on reopening; isolation from user preferences |
| Long work | Progress reporting; cancellation stops application work; close releases owned tasks/resources |

Tests that exercise `myapp.SettingsView` can inspect its public read-only
`GainField` from the example. For other widgets, do not assume the toolbox's
internal test access is an application API.

## Keep file-dialog workflows deterministic

Test persistence separately from prompting. Call `session.save(filePath)` and
`wt.model.BaseSession.open(filePath)` with temporary files to verify data,
dirty state, and invalid-file handling without opening OS dialogs.

For app workflow tests, derive a test-only subclass of the app and override its
public `promptToSaveAs`, `promptToLoad`, and `promptYesNoCancel` methods. Return a
fixture path or a cancellation result from the first two, and a controlled
`"Yes"`, `"No"`, or `"Cancel"` from the third. Match the selected implementation's
signatures and return types, including its empty-string cancellation result.
The test subclass can store configured responses and call counts in properties.
This lightweight test double needs no mocking framework or production changes.

Exercise first save, Save As, loading a different session, and cancellation with
these overrides, including cancellation before replacing a dirty session. Verify
both the resulting files and preservation of the current session. Do not mock
`saveSession` or `loadSession` themselves when those workflows are under test.

Setting `Session.FilePath` to a nonexistent file does not avoid the OS dialog:
`saveSession(false)` still prompts for its first save. Use the prompt override,
or first create a real fixture session with `session.save(filePath)` when only
testing a subsequent Save command. Avoid globally shadowing `uigetfile` or
`uiputfile`, automating native dialogs through fragile keystrokes, or leaving an
automated suite waiting for a person. Keep a small, separate manual smoke check
for the native dialogs themselves.

For widgets that call OS dialogs directly, test their public state and
post-selection behavior separately. Add a narrowly scoped injectable file-picker
dependency in the user's application only if that application needs an automated
dialog boundary; do not modify the installed toolbox solely to test a consumer.

Run focused tests through MATLAB MCP when available, expanding only as needed.
Use the narrowest established runner in the user's project. If MATLAB is
unavailable, perform static checks and label runtime behavior unverified.

## Check App Designer separately

For changes involving App Designer, validate both runtime construction and the
app's editor load on the target release. Check that the selected components are
registered and the saved app reloads without missing/errored custom-component
warnings. Test design-time properties and a representative interaction.

When registration is broken, inspect path/version conflicts and the installed
metadata first. Use `matlab-appdesigner-compatibility` if available; otherwise
follow the release's supported workflow and report the actual editor outcome.
Do not copy undocumented diagnostic internals into application runtime code.

Repository-only evidence is in `test/+wt/+test/AppDesignerMetadata.m`; it includes
registration-framework checks beyond JSON parsing. Its passing metadata checks
alone do not establish that a particular user's app opens successfully.

## Check release and deployment constraints

The packaged toolbox declares R2021a+ support, while the current repository CI
tests selected newer releases. A passing test on one release does not verify
all releases. Check individual controls and APIs against the user's baseline,
including date sliders, UI gestures, theme support, and background execution.
Require only the products needed by the application; using Widgets Toolbox
does not by itself require MATLAB Compiler or a parallel computing product.

For an app that will be compiled, include its custom view/model classes,
dependencies, and assets. `ContextualView.launchView` instantiates by class-name
string, so automatic dependency discovery may miss those views. Make inclusion
explicit and test the deployed app. Use installation-relative asset paths and
confirm images and other files are present in the deployed build.

MATLAB Online support in toolbox metadata does not establish that every custom
application or Web App Server workflow works unchanged. Verify the intended
environment, especially file dialogs and client/server file access. Do not use
desktop-only assumptions when specifying a browser-hosted app.

Consumer delivery should identify the required toolbox version/release,
application entry point, dependency setup, and checks actually performed.
Keep generated applications independent of example namespaces such as
`zooexample` unless the user explicitly intends to ship that example.

## Keep maintainer operations separate

`buildtool archive` and `deploy/wtPackageRelease.m` are toolbox release workflows;
they are not consumer installation or application validation commands. The
archive workflow increments versions and regenerates release artifacts.

For maintainers validating this skill's distribution, inspect
`wt.deploy.getPackageOptions(projectRoot, toolboxVersion).ToolboxFiles` and
`ToolboxMatlabPath`: all skill files should be included, and the skill folder
does not need to be on the MATLAB path. Do not publish a toolbox release merely
to verify skill inclusion.

Evidence: `doc/AppSuperclasses.html`, `examples/ContextualViewExample.mlx`,
`resources/appDesigner.json`, and repository-only `.github/workflows/git-ci.yml`,
`deploy/+wt/+deploy/getPackageOptions.m`, and `test/+wt/+test`.

<!-- Copyright 2026 The MathWorks, Inc. -->
