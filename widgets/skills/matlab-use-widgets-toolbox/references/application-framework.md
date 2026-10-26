# Reuse the application framework

Use this reference for a hand-coded application whose development approach is
already established. Existing App Designer apps can consume widgets and models
without adopting these top-level app base classes.

## Select a base class

| Requirement | Base class | Template under `examples/templates` |
| --- | --- | --- |
| App window and preferences; no managed document files | `wt.apps.BaseApp` | `TemplateBaseApp.m` |
| One saved document/session at a time | `wt.apps.BaseSingleSessionApp` | `TemplateBaseSingleSessionApp.m` |
| Multiple simultaneously open sessions | `wt.apps.BaseMultiSessionApp` | `TemplateBaseMultiSessionApp.m` |

Copy the selected template into the user's project and rename its class/file.
Use the full source path: older duplicate templates exist under `templates`.
Do not add both template directories to the path. The Zoo example is a richer
multi-session reference, not a required starting architecture.

## Preserve the lifecycle

`BaseApp` creates `Figure` and the root `Grid`. Implement protected `setup` to
create controls in that grid and protected `update` to refresh existing controls.
It also provides `preSetup` and `postSetup` extension hooks in current source.
Do not replace its figure/grid or call its constructor twice.

Preferences load before setup. The constructor runs the setup hooks, applies
remaining property/value inputs, and performs the initial update. Avoid assuming
arbitrary constructor properties were assigned before `setup`. Session bases
create or configure session state through their internal lifecycle.

For `BaseApp`, call `update` from application callbacks when state changes need
a refresh; this is not a `ComponentContainer` with automatic updates. Session
bases listen for session changes. When overriding their notification hooks,
preserve the superclass behavior needed for refresh and title/dirty indicators.
Do not override sealed internals.

Current `BaseApp` implements `close`; subclasses must implement `setup` and
`update`. Older documentation describes `close` as abstract, so check the
selected source. Use `close(app)` for normal session-app shutdown so unsaved
changes are handled. `delete(app)` is destruction, not a substitute for the
save/cancel workflow.

## Store documents in session models

Create a user-owned subclass of `wt.model.BaseSession`; put persistent document
data in it, and mark editable properties `SetObservable` so changes participate
in dirty tracking. Keep UI handles, listeners, and background tasks out of the
saved model. Nested models need the aggregation mechanism described in
[Models and views](models-and-views.md).

For example, save this as `+myapp/Session.m` under a folder on the MATLAB path:

```matlab
classdef Session < wt.model.BaseSession
    %Session - Store editable application settings

    % Copyright 2026 The MathWorks, Inc.

    properties (AbortSet, SetObservable)
        Gain (1,1) double = 1
    end
end
```

Implement the app's protected `createNewSession` method to return
`myapp.Session()`. The factory must work during app construction, before controls
exist. For a single-session app, refresh from `app.Session`; for a multi-session
app, refresh from `app.SelectedSession` and handle an empty selection.

Use `newSession`, `loadSession`, and `saveSession` for app commands instead of
directly replacing sessions and bypassing unsaved-change prompts. In the
single-session base, `saveSession(false)` saves to an existing session file;
it still prompts for Save As when that file does not exist. `saveSession(true)`
always uses Save As. Setting `FilePath` alone does not suppress the first-save
dialog. The multi-session base also accepts a session argument; use its
`selectSession` and `closeSession` methods instead of assigning read-only
selection properties. Inspect the selected version for complete signatures.

For model-level persistence, `session.save(filePath)` writes a MAT file
containing the variable `session`; `wt.model.BaseSession.open(filePath)` loads
it. The model's class and dependencies must be available when loading. Validate
the loaded model against the application's expected class. This format is not
an arbitrary-data MAT-file importer or a cross-version schema migration system.

Test dirty transitions and save/load round trips. If customizing save behavior,
test write failures too: current `BaseSession.save` sets `FilePath` and clears
`Dirty` before writing, so successful state alone is not proof of disk success.

## Keep preferences separate

Use `app.getPreference(name, defaultValue)` and
`app.setPreference(name, value)` for user settings. The base stores preferences
on destruction and restores them on the next launch. `PreferenceGroup` defaults
to the app class name; choose a stable, application-specific group when needed.
Use `wt.model.Preferences` only for preferences, not session data or credentials.

For custom settings, subclass `wt.model.Preferences` and declare public
properties with defaults, for example in `+myapp/Preferences.m`:

```matlab
classdef Preferences < wt.model.Preferences
    %Preferences - Store user settings between application launches

    % Copyright 2026 The MathWorks, Inc.

    properties (AbortSet)
        LastMode (1,1) string = "default"
    end
end
```

Pass `"Preferences", myapp.Preferences()` to the app's superclass constructor,
along with its other constructor arguments, so preferences load before setup.
Use `setPreference("LastMode", value)` after that. The current base preferences
object does not support dynamically adding an undeclared property; passing an
unknown name to `setPreference` fails. Saved properties must be public for both
get and set, have defaults, and not be transient, hidden, or constant.

In tests, use a unique preference group and restore or remove only that test
group after deleting the app. Test both missing preferences and a second launch.
Avoid opening a user's saved sessions merely to smoke-test the app.

Evidence: `+wt/+apps`, `+wt/+model/BaseSession.m`,
`+wt/+model/Preferences.m`, `doc/AppSuperclasses.html`,
`doc/AppPreferences.html`, and `examples/+zooexample/+app/@ZooHierarchy`.
Repository-only tests include `test/+wt/+test/BaseApp.m`, `TemplateApps.m`, and
`ZooHierarchyApp.m`.

<!-- Copyright 2026 The MathWorks, Inc. -->
