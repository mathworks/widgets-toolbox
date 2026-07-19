# 2026-07 Maintainer Issue Drafts

These issue drafts are derived from [2026-07-maintainer-review.md](/c:/AI/widgets-toolbox/docs/reviews/2026-07-maintainer-review.md).

GitHub issue creation was not completed from this session because `gh auth status` reports an invalid token for the configured account. The drafts below are ready to file manually.

## 1. Clarify supported MATLAB versions for runtime, build, and CI

**Title**: Clarify and document the supported MATLAB version matrix

**Summary**

The repository currently presents conflicting version expectations. `README.md` says the toolbox is intended for new development from `R2021a` onward, while `buildfile.m` requires `R2023b` or later for build tasks. That difference may be intentional, but it is not documented clearly enough for maintainers or contributors.

**Affected files**

- `README.md`
- `buildfile.m`
- `.github/workflows/git-ci.yml`

**Why this matters**

- Contributors cannot tell whether CI/build requirements are stricter than runtime requirements by design.
- Release support statements are part of the public contract.
- Version confusion increases support churn and complicates triage for compatibility bugs.

**Acceptance criteria**

- The repository documents runtime support separately from build/test support.
- `README.md` states the supported release range unambiguously.
- `buildfile.m` comments explain why `R2023b+` is required for build tasks, if that remains true.
- CI configuration is consistent with the documented support policy.

## 2. Add direct unit coverage for `wt.model.BaseModel`

**Title**: Add direct regression tests for `wt.model.BaseModel`

**Summary**

`widgets/+wt/+model/BaseModel.m` is a core framework class with no direct same-name test in `test/+wt/+test`. It handles observable properties, listener setup, recursive aggregated-model notifications, copy behavior, and load-related repair logic.

**Affected files**

- `widgets/+wt/+model/BaseModel.m`
- `test/+wt/+test`

**Why this matters**

- `BaseModel` is central infrastructure and a single regression can break multiple apps and widgets.
- Current coverage appears indirect rather than explicit.
- Event ordering and listener cleanup are high-risk areas that are difficult to debug after the fact.

**Acceptance criteria**

- A new class-based unit test directly targets `wt.model.BaseModel` behavior.
- Tests cover `PropertyChanged` notifications for observable properties.
- Tests cover aggregated or nested model change propagation.
- Tests cover copy or lifecycle behavior that could leave stale listeners behind.
- Tests follow repository conventions and pass in the full suite.

## 3. Add direct tests for dialog base classes

**Title**: Add direct tests for `BaseInternalDialog` and `BaseExternalDialog`

**Summary**

Dialog behavior is exercised indirectly through `test/+wt/+test/ListSelectionDialog.m`, but the framework base classes themselves do not have direct same-name tests. These classes are large, duplicated, and marked as prototype components.

**Affected files**

- `widgets/+wt/+abstract/BaseInternalDialog.m`
- `widgets/+wt/+abstract/BaseExternalDialog.m`
- `test/+wt/+test`

**Why this matters**

- Base dialog regressions can affect every dialog subclass.
- Modal behavior, button state, cleanup, and close actions should be protected directly.
- Shared behaviors are harder to refactor safely without targeted tests.

**Acceptance criteria**

- New tests directly exercise each base dialog path.
- Tests cover button configuration and `DialogButtonPushed` behavior.
- Tests cover modal and non-modal behavior.
- Tests cover close/delete lifecycle and cleanup.
- Tests verify no warnings on basic creation and teardown paths.

## 4. Expand `BaseTimeAlignedChart` regression coverage

**Title**: Expand test coverage for `BaseTimeAlignedChart`

**Summary**

`widgets/+wt/+abstract/BaseTimeAlignedChart.m` appears to be covered only indirectly by the smoke-style test in `test/+wt/+test/BaseViewChart.m`. The class manages axes count, selection, legends, grid state, colors, labels, and dependent limit properties.

**Affected files**

- `widgets/+wt/+abstract/BaseTimeAlignedChart.m`
- `test/+wt/+test/BaseViewChart.m`
- `test/+wt/+test`

**Why this matters**

- Chart layout and axes state are typically sensitive to regressions.
- The class is a reusable framework piece rather than a one-off example.
- Smoke coverage is not enough for a major release boundary.

**Acceptance criteria**

- Tests cover `NumAxes` changes and resulting axes layout updates.
- Tests cover `ShowGrid`, `ShowLegend`, and selected-axes behavior.
- Tests cover dependent properties such as `YLim` and `YLimMode`.
- Tests verify representative label and color propagation behavior.

## 5. Isolate version and theme compatibility logic

**Title**: Introduce a compatibility layer for MATLAB release gates and theme access

**Summary**

Version gates and internal theme API usage are scattered across framework classes. Centralizing that logic would reduce release churn and lower the risk of inconsistencies across widgets.

**Affected files**

- `widgets/+wt/+apps/BaseApp.m`
- `widgets/+wt/+abstract/BaseWidget.m`
- `widgets/+wt/+abstract/BaseViewController.m`
- `widgets/+wt/DropDownListManager.m`
- `widgets/+wt/SearchDropDown.m`
- `widgets/+wt/ListSelector.m`
- `widgets/+wt/ContextualView.m`

**Why this matters**

- `isMATLABReleaseOlderThan(...)` branches are distributed across unrelated components.
- `matlab.graphics.internal.themes.getAttributeValue(...)` introduces dependence on an internal MATLAB API.
- Compatibility work should be isolated rather than reimplemented ad hoc.

**Acceptance criteria**

- A dedicated internal compatibility utility or package is introduced.
- Existing release gates are reduced or routed through the shared utility.
- Theme access is wrapped behind a single abstraction with clear fallback behavior.
- Existing tests continue to pass after the compatibility logic is centralized.

## 6. Extract shared dialog core from internal and external dialog bases

**Title**: Refactor dialog framework to share a common dialog core

**Summary**

`BaseInternalDialog` and `BaseExternalDialog` implement similar concepts with duplicated logic. The duplicated surface makes future fixes and enhancements expensive and error-prone.

**Affected files**

- `widgets/+wt/+abstract/BaseInternalDialog.m`
- `widgets/+wt/+abstract/BaseExternalDialog.m`
- `widgets/+wt/+dialog/ListSelection.m`

**Why this matters**

- Bug fixes can land in one dialog mode and not the other.
- The current duplication makes behavior drift more likely over time.
- This is a natural follow-on after targeted test coverage exists.

**Acceptance criteria**

- Shared dialog state and button-management logic are extracted into one internal layer.
- Host-specific behavior remains isolated to figure-specific versus panel-specific concerns.
- Existing dialog subclasses continue to behave the same.
- Direct dialog tests cover both hosting modes before and after refactoring.

## 7. Split `BaseApp` responsibilities into narrower framework services

**Title**: Reduce `BaseApp` scope by extracting theme, preferences, and dialog responsibilities

**Summary**

`widgets/+wt/+apps/BaseApp.m` currently mixes too many responsibilities for a framework superclass. Its size and breadth make it a high-risk class for future changes.

**Affected files**

- `widgets/+wt/+apps/BaseApp.m`
- `widgets/+wt/+apps/AbstractSessionApp.m`
- `widgets/+wt/+apps/BaseSingleSessionApp.m`
- `widgets/+wt/+apps/BaseMultiSessionApp.m`

**Why this matters**

- App subclasses inherit a wide API surface regardless of what they need.
- Theme handling, preference persistence, and dialog orchestration change for different reasons and should not be tightly coupled.
- This class is a likely source of breaking changes as the framework evolves.

**Acceptance criteria**

- `BaseApp` responsibilities are mapped and split into smaller internal services, collaborators, or mixins.
- Public subclass behavior is preserved or intentionally deprecated with migration notes.
- Session-app subclasses continue to pass existing tests.
- The resulting `BaseApp` has fewer mixed concerns and clearer extension points.

## 8. Align shared selection logic between `ListSelector` variants

**Title**: Extract shared selection/index translation logic from `ListSelector` widgets

**Summary**

`widgets/+wt/ListSelector.m` and `widgets/+wt/ListSelectorTwoPane.m` expose related selection workflows but maintain separate implementations. The overlap suggests a shared internal selection core should exist.

**Affected files**

- `widgets/+wt/ListSelector.m`
- `widgets/+wt/ListSelectorTwoPane.m`
- `test/+wt/+test/ListSelector.m`
- `test/+wt/+test/ListSelectorTwoPane.m`

**Why this matters**

- Similar widgets can drift semantically when bug fixes are applied independently.
- Shared item/value/index handling logic is difficult to keep consistent across separate implementations.
- This is a maintainability issue first, but it also creates user-facing inconsistency risk.

**Acceptance criteria**

- Common item, value, highlight, and index translation logic is extracted into a shared helper or internal selector core.
- Both selector widgets preserve current observable behavior.
- Existing selector tests pass, with new regression coverage added for shared edge cases.

## 9. Decide support status and stabilization plan for `SearchDropDown`

**Title**: Define whether `SearchDropDown` is experimental or supported and align code/tests accordingly

**Summary**

`widgets/+wt/SearchDropDown.m` is explicitly labeled as a prototype widget, but it is also part of the shipped widget set and already has dedicated tests. The current position is ambiguous from a support standpoint.

**Affected files**

- `widgets/+wt/SearchDropDown.m`
- `test/+wt/+test/SearchDropDown.m`
- `README.md`

**Why this matters**

- Prototype labeling conflicts with the expectations users will have for a public widget.
- The class is large and interaction-heavy, which raises support burden if treated as stable.
- Major releases should avoid ambiguous support boundaries.

**Acceptance criteria**

- A maintainer decision is made to either stabilize or explicitly constrain support for `SearchDropDown`.
- Documentation is updated to reflect that decision.
- If stabilized, additional tests cover keyboard interaction, focus behavior, and filtered-list synchronization.
- If not stabilized, the prototype status is documented clearly and surfaced consistently.

## 10. Expand lifecycle and reuse tests for `ContextualView`

**Title**: Add deeper lifecycle and reuse tests for `ContextualView`

**Summary**

`widgets/+wt/ContextualView.m` has useful direct coverage now, but it still owns a complex lifecycle: dynamic class loading, model reassignment, reuse of loaded views, active-view switching, and deletion-aware cleanup.

**Affected files**

- `widgets/+wt/ContextualView.m`
- `test/+wt/+test/ContextualView.m`

**Why this matters**

- This class uses string-based dynamic loading and cached view instances.
- Runtime-only errors are more likely here than in static widgets.
- Coverage should protect reuse semantics before any refactoring or API hardening.

**Acceptance criteria**

- Tests cover relaunching the same view class with an existing loaded instance.
- Tests cover behavior when a previously loaded view has been deleted.
- Tests cover model reassignment semantics explicitly.
- Tests verify cleanup and active-view state after transitions.
