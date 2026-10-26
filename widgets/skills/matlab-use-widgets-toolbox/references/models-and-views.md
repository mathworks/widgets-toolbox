# Bind models to reusable views

Use this reference for modular displays or controls that share application data.
These components can be hosted in a hand-coded or App Designer app without
changing the host's chosen development approach.

## Use the existing observation mechanism

Subclass `wt.model.BaseModel` for shared data and domain behavior. Use
`properties (AbortSet, SetObservable)` for editable values whose changes should
notify observers. `PropertyChanged` reports changes in the model itself;
`ModelChanged` also propagates changes from configured aggregated models.

For nested `BaseModel` objects, override the protected
`getAggregatedModelProperties` method to return a string array of property names
that hold those objects. Make those properties observable so replacing a child
reattaches the listeners. Keep the aggregation graph acyclic. The base's copy
implementation also copies configured aggregated models; test independence if
your application depends on deep copies.

Use `wt.model.BaseSession` at the document root when session-app persistence and
dirty tracking are needed. Business logic belongs in the model or a service,
not in UI rendering or a second set of model-change listeners.

## Choose the view base

| View contents | Base class |
| --- | --- |
| Controls, or controls mixed with axes | `wt.abstract.BaseViewController` |
| Axes/chart graphics only | `wt.abstract.BaseViewChart` |

Both incorporate `wt.mixin.ModelObserver`. Implement an observable `Model`
property initialized with an empty array of the appropriate model class.
Model assignment and `ModelChanged` notifications already request a redraw;
do not duplicate that listener wiring. Overrides must preserve the refresh.

The following pair illustrates the minimal contract. Save the classes in
`+myapp/Settings.m` and `+myapp/SettingsView.m` under the user's source root:

```matlab
classdef Settings < wt.model.BaseModel
    %Settings - Store a shared gain value

    % Copyright 2026 The MathWorks, Inc.

    properties (AbortSet, SetObservable)
        Gain (1,1) double = 1
    end
end
```

```matlab
classdef SettingsView < wt.abstract.BaseViewController
    %SettingsView - Edit the gain in a shared settings model

    % Copyright 2026 The MathWorks, Inc.

    properties (AbortSet, SetObservable)
        Model = myapp.Settings.empty(0,0)
    end

    properties (Transient, NonCopyable, SetAccess = private)
        GainField matlab.ui.control.NumericEditField
    end

    methods (Access = protected)
        function setup(obj)
            setup@wt.abstract.BaseViewController(obj);
            obj.Grid.RowHeight = {'fit'};
            obj.Grid.ColumnWidth = {'fit', '1x'};
            uilabel(obj.Grid, 'Text', 'Gain');
            obj.GainField = uieditfield(obj.Grid, 'numeric', ...
                'ValueChangedFcn', @(src,evt)obj.onFieldEdited(evt,"Gain"));
        end

        function update(obj)
            update@wt.abstract.BaseViewController(obj);
            [model, validToDisplay] = obj.getScalarModelToDisplay();
            obj.GainField.Value = model.Gain;
            obj.GainField.Enable = validToDisplay;
        end
    end
end
```

Call the superclass `setup` before creating contents in `Grid`, and preserve
the superclass `update` when its panel/title behavior is wanted. For chart
views, use the base's `TiledLayout` and axes infrastructure instead.

`getScalarModelToDisplay` supplies a default model when no valid scalar model is
attached. The model must therefore support construction without arguments.
Disable editing when `validToDisplay` is false. This handles construction,
model deletion, and contextual view deactivation. Follow the declaration above:
the inherited abstract `Model` property already specifies `wt.model.BaseModel`;
redeclaring its class or adding size/validation constraints in the concrete view
is not supported. Pass the intended model subtype when binding the view, and
preserve the ability to clear it to empty.

`onFieldEdited` handles simple `evt.Value` assignments. Use a dedicated callback
for domain validation, commands, or multi-field changes. Render current state in
`update`; create fixed controls once in `setup`. Use `requestUpdate` in view
hooks when needed. `forceUpdate` / `forceUpdateChart` are debugging helpers,
not the production synchronization mechanism.

## Switch and reuse views

With the classes above on the path:

```matlab
fig = uifigure;
grid = uigridlayout(fig, [1 1]);
pane = wt.ContextualView(grid);
settings = myapp.Settings();
view = pane.launchView("myapp.SettingsView", settings);
settings.Gain = 2;
```

`launchView(viewClassName, model)` creates or reuses the view and attaches its
model. `clearView()` deactivates the current view but keeps it cached. Switching
away clears the old view's `Model` and detaches its parent. Handle both states
without reading a nonexistent scalar model or assuming a figure always exists.
Detached cached views can defer rendering until reattached. Test their detached
model/parent state, and assert refreshed control values once the view is attached
again; do not require an offscreen cached control to redraw immediately.

`ActiveView` and `LoadedViews` provide inspection; `reset()` deletes cached
views, and `relaunchActiveView()` helps during development. These are not needed
on every application update. Because view names are strings, compiled apps need
explicit inclusion of these view classes and their downstream dependencies.

Evidence: `+wt/+model/BaseModel.m`, `+wt/+mixin/ModelObserver.m`,
`+wt/+abstract/BaseViewController.m`, `+wt/+abstract/BaseViewChart.m`,
`+wt/ContextualView.m`, `examples/+zooexample/+model`,
`examples/+zooexample/+view`, and `examples/ContextualViewExample.mlx`.
Repository-only tests include `test/+wt/+test/BaseModel.m`, `ModelObserver.m`,
`BaseViewController.m`, `BaseViewChart.m`, and `ContextualView.m`.

<!-- Copyright 2026 The MathWorks, Inc. -->
