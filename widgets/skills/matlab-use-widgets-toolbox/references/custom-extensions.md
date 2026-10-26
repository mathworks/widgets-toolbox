# Extend the toolbox in the user's project

Use this reference when the required behavior is not already provided by an
existing control, application base, or model/view component.

## Choose an extension point

- Compose existing widgets for an application-specific panel.
- Use a utility or service for reusable non-UI behavior.
- Subclass `wt.abstract.BaseWidget` for a reusable composite control. Inspect
  `+wt/FileSelector.m` or `+wt/RangeField.m` for established patterns.
- Use the model/view bases for model-bound controls or charts; see
  [Models and views](models-and-views.md).
- For custom dialogs, inspect `wt.abstract.BaseInternalDialog` (inside a
  figure) and `wt.abstract.BaseExternalDialog` (a separate window), along with
  their examples. `wt.abstract.BaseDialog` is a deprecated prototype and should
  not be the starting point for a new dialog.

Keep new application classes in the user's namespace. A consumer app should not
modify an installed toolbox to add its own functionality.

## Implement the component lifecycle

In a `BaseWidget` subclass, call `setup@wt.abstract.BaseWidget(obj)` before
placing contents into the supplied `Grid`. Create fixed graphics in `setup` and
refresh them in `update`. The optional `postSetup` hook runs after setup and
input assignment; use it when initialization depends on configured properties.

The base installs its own construction callback for `postSetup`. Do not replace
that mechanism with a competing `CreateFcn`. Inspect neighboring components
before introducing custom constructors or setters that access child controls.

Use public properties for configuration and value, and events for meaningful
user actions. `events (HasCallbackProperty, NotifyAccess = protected)` produces
the standard callback property. Emit the correct `wt.eventdata` type from the
interaction handler after updating the component state. Programmatic value
assignment and user actions are distinct contracts; test whichever behavior
the new component promises.

ComponentContainer updates are deferred. Request updates through the base when
internal state changes need a redraw; keep rendering free of model mutations
that could create feedback loops. Avoid using forced updates as ordinary app
logic. Test repeated changes over multiple rendering cycles.

Mark UI resources `Transient` and `NonCopyable` where appropriate. Store
listeners and task handles so their lifetime is explicit, and release resources
owned by the extension on deletion. Let normal parent ownership clean up child
graphics; explicitly handle resources that live outside that ownership tree.

## Reuse applicable mixins

Inspect `+wt/+mixin` before duplicating enable, tooltip, font, color, error
handling, or model-observation behavior. Mixins often require populating a list
of affected components during setup. For example, `Enableable` and `FontStyled`
rely on the concrete class identifying its child controls. Use a neighboring
implementation for the precise protected property names and update hooks.

Do not add a mixin merely because it exists, or promise every widget exposes
every style property. Theme support is release-sensitive: use
`wt.utility.supportsUIThemes()` before newer theme APIs, and preserve MATLAB's
default appearance unless the user requests styling.

Other reusable infrastructure includes `wt.utility.widgetsRoot` for installed
assets, `wt.utility.resolveFilePath` / `getRelativeFilePath` for applicable path
operations, and validators in `+wt/+validators`. Check their contracts and
whether a built-in MATLAB function already meets the need before reusing them.

## Preserve App Designer usability

A new runtime component does not automatically become a registered Component
Library item. If design-time placement is required, follow the target release's
custom-component registration workflow for the user's own component library.
Use the toolbox's `resources/appDesigner.json` as evidence of its registered
surface, not as a file to edit for a consumer's custom class.

Validate constructor defaults, property inspection, runtime behavior, and
editor load in the actual target release. Metadata that parses as JSON is not
sufficient evidence of successful App Designer registration. See
[Validation and deployment](validation-and-deployment.md).

Evidence: `+wt/+abstract/BaseWidget.m`, `+wt/+mixin`,
`+wt/+abstract/BaseInternalDialog.m`, `+wt/+abstract/BaseExternalDialog.m`, and
`resources/appDesigner.json`. Repository-only test patterns include
`test/+wt/+test/BaseWidgetTest.m`, `BaseInternalDialog.m`, and
`BaseExternalDialog.m`; they are not installed consumer dependencies.

<!-- Copyright 2026 The MathWorks, Inc. -->
