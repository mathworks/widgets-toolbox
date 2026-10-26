# Select and integrate components

Use this reference after establishing App Designer or hand code. All source and
documentation paths below are relative to the selected toolbox installation.

## Match the task

| Need | Candidates | Starting example or reference |
| --- | --- | --- |
| File, output file, or folder selection | `wt.FileSelector` | `examples/FileSelectorExample.mlx` |
| Numeric value, range, or array editing | `wt.SliderSpinner`, `wt.RangeField`, `wt.NumericArray` | Corresponding `examples/*Example.mlx` |
| Select, reorder, or transfer list items | `wt.ListSelector`, `wt.ListSelectorTwoPane`, `wt.DropDownListManager` | Corresponding examples |
| Search a list or select multiple options | `wt.SearchDropDown`, `wt.CheckboxList` | Corresponding examples |
| Date/time input | `wt.DatetimeSelector`, `wt.DateSlider`, `wt.DateRangeSlider` | `examples/DatetimeSelectorExample.mlx`; slider class help and release requirements |
| Group actions or repeated controls | `wt.ButtonGrid`, `wt.SliderCheckboxGroup`, `wt.RowEntriesTable` | `examples/ButtonGridExample.mlx`, `SliderCheckboxExample.mlx`, `RowEntriesTableExample.mlx` |
| Progress and task status | `wt.ProgressBar`, `wt.TaskStatusTable` | Corresponding examples |
| Toolbar or popup actions | `wt.Toolbar`, `wt.MenuButton` | Corresponding examples |
| Color or masked text input | `wt.ColorSelector`, `wt.PasswordField` | Corresponding examples |
| In-app selection or login dialog | `wt.dialog.ListSelection`, `wt.dialog.Login` | `examples/ListSelectionDialogExample.mlx`, `LoginDialogExample.mlx` |
| Switch model-bound views | `wt.ContextualView` | [Models and views](models-and-views.md) |

Inspect the class and its example before choosing property names. Similar
controls do not necessarily use identical value, selection, or event contracts.
Password masking and a login dialog provide UI behavior; authentication belongs
to the application.

## Parent and lay out explicitly

For App Designer, use the installed Widgets Toolbox Component Library when the
chosen control is registered. Configure its public properties and callbacks in
the app's supported workflow. For a runtime-created control, create it in an
existing app container during startup and retain it in an app property. Do not
manually rewrite generated app internals to change inheritance.

For hand code, use a `uigridlayout` and the component's `Layout.Row` and
`Layout.Column`. The top-level figure may have an initial `Position`; structural
panels and controls should resize through layouts.

This standalone hand-code example uses a callback only to display the selected
path; replace that callback with the application's file-handling method:

```matlab
fig = uifigure;
grid = uigridlayout(fig, [2 1]);
grid.RowHeight = {30, '1x'};
selector = wt.FileSelector(grid);
selector.Layout.Row = 1;
selector.SelectionType = "file";
selector.Filter = "*.mat";
selector.ValueChangedFcn = @(src,evt)disp(src.FullPath);
```

`SelectionType` supports `"file"`, `"putfile"`, and `"folder"`. With a
`RootDirectory`, `Value` is relative and `FullPath` resolves the full path.
Use `ValueIsValidPath` according to the selection mode; a new output file need
not already exist. `ShowHistory` enables the recent-path dropdown.

## Connect public callbacks

`HasCallbackProperty` events expose a companion property, for example
`ValueChanged` / `ValueChangedFcn`. A callback receives `(source,eventData)`.
Read the relevant `+wt/+eventdata` class: `ValueChangedData` has `Value` and
`PreviousValue`, while `ButtonPushedData` identifies the button in `Button` and
also carries `Text`, `Tag`, and `Value`.

Do not assume assigning `widget.Value` fires a user-interaction callback. Update
application state explicitly when setting controls programmatically. Likewise,
avoid depending on hidden child controls as the consumer interface, even where
repository tests access them for UI gestures.

## Build a toolbar from sections

```matlab
fig = uifigure;
grid = uigridlayout(fig, [2 1]);
grid.RowHeight = {100, '1x'};
toolbar = wt.Toolbar(grid);
section = wt.toolbar.HorizontalSection();
section.Title = "FILE";
icon = fullfile(wt.utility.widgetsRoot(), 'icons', 'open_24.png');
openButton = section.addButton(icon, "Open");
section.ButtonPushedFcn = @(src,evt)disp(evt.Button.Text);
toolbar.Section = section;
```

Assemble sections before assigning `toolbar.Section`. Use `addStateButton` for
toggle actions and `addVerticalSection` for a nested section. Manually inserted
controls in a section's `Component` array need their own callbacks.

Route a command through either the section or toolbar callback to avoid handling
it twice. Replacing an added button's own callback bypasses its original
forwarding handler; do that only when intentionally handling that button
independently. Inspect `examples/ToolbarExample.mlx` for the mixed-control case.

## Report progress and wire cancellation

With `grid` an existing application layout:

```matlab
progress = wt.ProgressBar(grid);
progress.ShowCancel = true;
progress.CancelPressedFcn = @(src,evt)disp("Cancellation requested");
progress.startProgress("Starting");
progress.setProgress(0.5, "Processing");
% Finish only after the application's operation has completed or stopped.
progress.finishProgress("Finished");
```

Progress values are fractions from 0 to 1. Set `Indeterminate = true` when the
fraction is unknown. `CancelPressedFcn` and `CancelRequested` communicate a
request; the application must stop or cancel its work. Starting and finishing
progress reset the cancellation state, so inspect it before finishing if needed.
The widget does not move computation off the UI thread. Choose background
execution supported by the user's MATLAB release and dependencies for long work,
and update graphics on the client. Clean up task resources when the app closes.

For dialogs, follow the corresponding example's button/close contract and handle
cancellation without applying the selection. See `doc/DialogsList.html`; do not
assume every dialog has MATLAB's `uiconfirm` return-value interface.

Evidence: `+wt/FileSelector.m`, `+wt/ProgressBar.m`, `+wt/Toolbar.m`,
`+wt/+toolbar/HorizontalSection.m`, and the named examples. Repository-only
regressions include `test/+wt/+test/FileSelector.m`, `Toolbar.m`, and
`ProgressBar.m`.

<!-- Copyright 2026 The MathWorks, Inc. -->
