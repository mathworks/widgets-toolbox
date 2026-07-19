# 2026-07 Maintainer Review

Scope: `widgets/+wt`, `test/+wt/+test`, `README.md`, `buildfile.m`, and the MATLAB project entry point `WidgetsToolbox.prj`.

This review is aimed at release readiness. MATLAB Code Analyzer was quiet on the main hotspot files, so the concerns below are primarily architectural, compatibility, and supportability risks rather than syntax-level defects.

## Architectural Concerns

### 1. Overloaded application base class

- `widgets/+wt/+apps/BaseApp.m`
  - `BaseApp` mixes window lifecycle, preference persistence, theme handling, dialog orchestration, custom display behavior, and debugging support into one superclass.
  - This creates a high fan-in dependency: app subclasses inherit a large behavioral surface even when they only need a small subset.
  - Any change to figure management, theme logic, or preferences risks regressions across the app framework.

### 2. Duplicated dialog framework split by hosting mode

- `widgets/+wt/+abstract/BaseInternalDialog.m`
- `widgets/+wt/+abstract/BaseExternalDialog.m`
  - These classes implement parallel dialog concepts with overlapping lifecycle and button-management behavior, but diverge because one targets embedded panels and the other separate figures.
  - The duplication increases maintenance cost and makes fixes likely to land in only one path.
  - Both files are also marked as prototype components, which weakens the contract for downstream users late in a release cycle.

### 3. Centralized and fragile model/event backbone

- `widgets/+wt/+model/BaseModel.m`
  - `BaseModel` owns property listeners, recursive aggregated-model notifications, copy behavior, display behavior, and load-time repair concerns.
  - That concentration makes the class a single point of failure for model synchronization and persistence.
  - Recursive event propagation is especially risky because small changes can alter notification order or create hard-to-debug listener cascades.

### 4. Dynamic view loading couples navigation, construction, and ownership

- `widgets/+wt/ContextualView.m`
  - `ContextualView` handles dynamic class loading, model injection, caching/reuse of loaded views, active-view switching, and cleanup.
  - That is a powerful API, but it also means navigation behavior depends on runtime strings, object validity state, and implicit conventions for hosted views.
  - The result is a flexible but difficult-to-reason-about framework seam.

## Technical Debt

### 1. Release compatibility policy is inconsistent

- `README.md`
- `buildfile.m`
  - The README says the toolbox is for new development starting with `R2021a`.
  - `buildfile.m` requires `R2023b` or later for build tasks.
  - That split may be acceptable if runtime and build-time support differ intentionally, but it is not explained clearly enough for maintainers or contributors.

### 2. Internal MATLAB APIs are part of the theme path

- `widgets/+wt/+apps/BaseApp.m`
- `widgets/+wt/+abstract/BaseWidget.m`
- `widgets/+wt/+abstract/BaseViewController.m`
  - These files call `matlab.graphics.internal.themes.getAttributeValue(...)`.
  - Internal APIs are more likely to change without compatibility guarantees, so this creates avoidable release fragility.
  - The risk is amplified because these classes sit near the center of the framework.

### 3. Version gates are scattered across the codebase

- `widgets/+wt/+apps/BaseApp.m`
- `widgets/+wt/+abstract/BaseInternalDialog.m`
- `widgets/+wt/+abstract/BaseExternalDialog.m`
- `widgets/+wt/DropDownListManager.m`
- `widgets/+wt/SearchDropDown.m`
- `widgets/+wt/ListSelector.m`
- `widgets/+wt/ContextualView.m`
  - Repeated `isMATLABReleaseOlderThan(...)` branches indicate the compatibility strategy is distributed instead of isolated.
  - That makes future release work harder because maintainers must rediscover version-specific behavior in many unrelated classes.

### 4. Prototype and deprecated surfaces are still in the active framework

- `widgets/+wt/SearchDropDown.m`
- `widgets/+wt/+abstract/BaseInternalDialog.m`
- `widgets/+wt/+abstract/BaseExternalDialog.m`
- `widgets/+wt/+abstract/BaseDialog.m`
  - `SearchDropDown`, `BaseInternalDialog`, and `BaseExternalDialog` are explicitly labeled prototype.
  - `BaseDialog` is marked deprecated.
  - Shipping a major release with prototype and deprecated framework layers still visible to users increases support ambiguity.

### 5. Several framework classes are already large enough to resist safe change

- `widgets/+wt/SearchDropDown.m` at about 620 lines
- `widgets/+wt/+abstract/BaseInternalDialog.m` at about 596 lines
- `widgets/+wt/+abstract/BaseExternalDialog.m` at about 460 lines
- `widgets/+wt/+apps/BaseApp.m` at about 438 lines
- `widgets/+wt/ListSelectorTwoPane.m` at about 436 lines
- `widgets/+wt/ListSelector.m` at about 419 lines
- `widgets/+wt/+model/BaseModel.m` at about 382 lines
- `widgets/+wt/DropDownListManager.m` at about 381 lines
- `widgets/+wt/FileSelector.m` at about 379 lines
  - These are not automatically problematic, but in this repository the size correlates with mixed responsibilities and compatibility branching.

## Missing Tests

### 1. Public widgets are tested more consistently than the internal framework

- `test/+wt/+test`
  - Top-level widgets generally have same-name tests.
  - Internal framework packages are much thinner:
    - `widgets/+wt/+abstract`: 8 source classes, 2 same-name tests
    - `widgets/+wt/+apps`: 4 source classes, 1 same-name test
    - `widgets/+wt/+dialog`: 2 source classes, 0 same-name tests
    - `widgets/+wt/+mixin`: 16 source classes, 1 same-name test
    - `widgets/+wt/+model`: 3 source classes, 0 same-name tests
    - `widgets/+wt/+toolbar`: 3 source classes, 0 same-name tests
    - `widgets/+wt/+utility`: 12 source classes, 0 same-name tests
    - `widgets/+wt/+validators`: 3 source classes, 0 same-name tests

### 2. Core framework classes lack direct regression protection

- `widgets/+wt/+model/BaseModel.m`
  - No direct same-name test exists in `test/+wt/+test`.
  - Given that it underpins model observation and propagation, this is a major gap.

- `widgets/+wt/+abstract/BaseInternalDialog.m`
- `widgets/+wt/+abstract/BaseExternalDialog.m`
  - Dialog behavior is exercised indirectly through `test/+wt/+test/ListSelectionDialog.m`, but the base classes themselves do not have direct suites.
  - That leaves modal behavior, teardown paths, and shared lifecycle behavior vulnerable to regressions.

- `widgets/+wt/+abstract/BaseTimeAlignedChart.m`
  - Coverage appears to be limited to a smoke-style test in `test/+wt/+test/BaseViewChart.m`.
  - There is little evidence of deeper tests around axes count changes, legend/grid toggles, limit propagation, or selection behavior.

- `widgets/+wt/ContextualView.m`
  - `test/+wt/+test/ContextualView.m` now covers key launches and invalid view classes, but dynamic reuse, cleanup after deletion, and model reassignment semantics still carry higher risk than the current suite suggests.

- `widgets/+wt/SearchDropDown.m`
  - `test/+wt/+test/SearchDropDown.m` improved coverage, but the widget remains complex enough that keyboard interaction, focus state, filtered-list synchronization, and release-gated behavior deserve broader regression tests.

### 3. Supporting infrastructure packages are effectively untested as units

- `widgets/+wt/+eventdata`
- `widgets/+wt/+utility`
- `widgets/+wt/+validators`
- `widgets/+wt/+toolbar`
  - These packages may be exercised transitively, but they do not appear to have targeted unit tests.
  - That makes it harder to refactor internals safely because failures surface only through higher-level UI tests.

## API Concerns

### 1. Prototype APIs are difficult to support long term

- `widgets/+wt/SearchDropDown.m`
- `widgets/+wt/+abstract/BaseInternalDialog.m`
- `widgets/+wt/+abstract/BaseExternalDialog.m`
  - If these classes remain public, maintainers will be asked to preserve behavior despite their prototype disclaimers.
  - If they are not intended as stable APIs, that boundary should be made much clearer before release.

### 2. Similar selector widgets expose overlapping but different semantics

- `widgets/+wt/ListSelector.m`
- `widgets/+wt/ListSelectorTwoPane.m`
  - Both solve list selection problems, but they differ in property model and interaction semantics.
  - Supporting both as separate public abstractions will become harder if bug fixes or enhancements need to stay behaviorally aligned.

### 3. String-based dynamic view launching is flexible but brittle

- `widgets/+wt/ContextualView.m`
  - Requiring callers to pass class names as strings increases runtime-only failure modes.
  - This is workable, but the API is harder to validate statically and harder to evolve without breaking calling code.

### 4. App framework behavior likely exposes too much inherited surface area

- `widgets/+wt/+apps/BaseApp.m`
- `widgets/+wt/+apps/AbstractSessionApp.m`
- `widgets/+wt/+apps/BaseSingleSessionApp.m`
- `widgets/+wt/+apps/BaseMultiSessionApp.m`
  - The application framework appears convenient for authors, but it likely exposes a large inherited API that will be difficult to change once external apps depend on it.
  - Preference persistence, session management, theme behavior, and figure lifecycle are all areas where small interface changes could become breaking changes.

## Recommended Refactoring

### 1. Split `BaseApp` into narrower services

- `widgets/+wt/+apps/BaseApp.m`
  - Extract theme handling, preference persistence, and dialog coordination behind separate internal collaborators or mixins.
  - The goal is to reduce the amount of framework behavior every app subclass inherits by default.

### 2. Create a shared dialog core

- `widgets/+wt/+abstract/BaseInternalDialog.m`
- `widgets/+wt/+abstract/BaseExternalDialog.m`
  - Consolidate shared state, button configuration, and lifecycle rules into a common internal layer.
  - Keep only host-specific figure-versus-panel behavior in the concrete dialog bases.

### 3. Isolate compatibility logic behind one facade

- `widgets/+wt/+apps/BaseApp.m`
- `widgets/+wt/+abstract/BaseWidget.m`
- `widgets/+wt/+abstract/BaseViewController.m`
- `widgets/+wt/DropDownListManager.m`
  - Move version checks and internal theme access behind a dedicated compatibility utility.
  - This reduces scattered release branching and makes future MATLAB upgrade work more predictable.

### 4. Reduce selector duplication

- `widgets/+wt/ListSelector.m`
- `widgets/+wt/ListSelectorTwoPane.m`
  - Extract common item/value/index translation and ordering logic into a shared internal helper or selector core.
  - That should lower the risk of semantic drift between the two widgets.

### 5. Simplify `BaseModel` event plumbing

- `widgets/+wt/+model/BaseModel.m`
  - Separate listener registration, aggregated-model tracking, and persistence/copy repair into smaller internal methods or collaborators.
  - This is a good candidate for refactoring before adding more model subclasses.

### 6. Decide whether `SearchDropDown` is experimental or supported

- `widgets/+wt/SearchDropDown.m`
  - Either reduce scope and harden it as a supported widget, or keep it clearly experimental and exclude it from stable API promises.
  - The current state is in between, which is the hardest position to support.

## Open Questions

1. What is the actual supported MATLAB range for this release?
   - `README.md` implies runtime support from `R2021a`, while `buildfile.m` requires `R2023b` for build tasks.

2. Which classes are intended to be stable public APIs versus internal framework details?
   - This is especially important for `BaseApp`, `BaseModel`, `ContextualView`, and the dialog base classes.

3. Are prototype-tagged components expected to carry compatibility guarantees for external users?
   - If yes, the prototype labels should likely be removed.
   - If no, their public exposure should be reduced or documented more sharply.

4. Is reliance on `matlab.graphics.internal.themes.getAttributeValue(...)` acceptable for the release target?
   - If not, theme behavior needs a public-API fallback path.

5. How much direct unit coverage is expected for internal packages?
   - A major release would be more defensible with explicit tests for `BaseModel`, dialog bases, compatibility helpers, and time-aligned chart behavior.

6. Are `ListSelector` and `ListSelectorTwoPane` meant to converge or remain separate long-term products?
   - That decision affects whether the current duplication is temporary or structural debt.
