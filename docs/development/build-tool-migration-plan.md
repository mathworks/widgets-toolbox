# Build Tool Migration Plan

<!-- Copyright 2026 The MathWorks, Inc. -->

## Goal

Integrate the existing release workflow from `deploy/wtPackageRelease.m` into MATLAB Build Tool so that:

- `buildfile.m` is the primary entry point
- `deploy/wtPackageRelease.m` becomes a thin compatibility wrapper
- existing release behavior is preserved
- release outputs do not change
- code churn stays low

## Version Policy

The repository should document two distinct version concepts:

- maintainer build and release environment: latest MATLAB release
- shipped toolbox runtime support: `R2021a` or later

These are intentionally different:

- maintainers use the latest MATLAB release to run Build Tool and perform packaging
- toolbox consumers install and use the packaged release on supported MATLAB releases back to `R2021a`

This distinction should be stated consistently in:

- `buildfile.m` comments
- contributor-facing documentation such as `README.md`
- packaging code comments near `opts.MinimumMatlabRelease = "R2021a"`
- migration notes for the Build Tool rollout

## Current State

`deploy/wtPackageRelease.m` currently performs the full release pipeline:

1. Increment deploy version via `wt.deploy.incrementVersionNumber`
2. Resolve project root from `currentProject`
3. Run unit tests via `runTestSuite`
4. Publish `widgets/doc/*.mlx` to HTML in `widgets/doc`
5. Publish `widgets/examples/*.mlx` to HTML in `widgets/doc`
6. Publish `widgets/doc/GettingStarted.mlx` to HTML
7. Rebuild the documentation search database in `widgets/doc`
8. Build the toolbox package via `wt.deploy.getPackageOptions` and `matlab.addons.toolbox.packageToolbox`
9. Add the generated `.mltbx` to the project
10. Open the `release` folder

`buildfile.m` currently provides:

- `check` via `CodeIssuesTask`
- `test` via `TestTask`
- `archive` as a function task depending on `check` and `test`

It does not yet cover documentation publishing, search database generation, adding the installer to the project, or preserving the exact legacy test entry point.

The current repository also leaves the version policy implicit:

- `buildfile.m` currently states a Build Tool requirement of `R2023b+`
- package metadata declares a minimum supported MATLAB release of `R2021a`

The migration should replace that ambiguity with an explicit maintainer-versus-runtime support statement.

## Proposed Build Task Graph

Use `buildfile.m` as the orchestration layer and keep task names close to the current workflow.

```text
check
test
prepareRelease
publishDocHtml
publishExampleHtml
publishGettingStarted
buildDocSearchDb
package
finalizeRelease
archive
```

Recommended dependencies:

- `check`: no dependencies
- `test`: no dependencies initially
- `prepareRelease`: depends on `test`
- `publishDocHtml`: depends on `prepareRelease`
- `publishExampleHtml`: depends on `prepareRelease`
- `publishGettingStarted`: depends on `prepareRelease`
- `buildDocSearchDb`: depends on `publishDocHtml`, `publishExampleHtml`, `publishGettingStarted`
- `package`: depends on `check`, `buildDocSearchDb`
- `finalizeRelease`: depends on `package`
- `archive`: depends on `finalizeRelease`

Recommended default tasks:

- keep `DefaultTasks = ["check","test"]`

Recommended release invocation:

- `buildtool archive`

Rationale:

- preserves the current default lightweight developer flow
- makes the full release flow explicit
- isolates side-effecting steps into small task functions
- avoids changing packaged artifacts or release folder contents

## Functions To Extract

Move the release implementation into reusable helpers under `deploy/+wt/+deploy/` and let `buildfile.m` own the orchestration.

Recommended extracted functions:

### `deploy/+wt/+deploy/getReleaseContext.m`

Purpose:

- centralize `currentProject` lookup
- compute `projectRoot`
- compute doc/examples/getting-started input and output paths

Why:

- these paths are currently assembled inline in `wtPackageRelease.m`
- `buildfile.m` and the wrapper script will need identical path resolution

### `deploy/+wt/+deploy/runReleaseTests.m`

Purpose:

- wrap the current `runTestSuite` behavior
- preserve pass/fail semantics from `wtPackageRelease.m`

Why:

- `runTestSuite` is the current release gate
- using a wrapper avoids changing release behavior while allowing Build Tool to call the same implementation

### `deploy/+wt/+deploy/publishReleaseDocumentation.m`

Purpose:

- publish `widgets/doc/*.mlx`

Why:

- isolates one existing workflow block with no behavior change

### `deploy/+wt/+deploy/publishReleaseExamples.m`

Purpose:

- publish `widgets/examples/*.mlx` to `widgets/doc`

Why:

- preserves the current output location and side effects

### `deploy/+wt/+deploy/publishGettingStartedHtml.m`

Purpose:

- publish `widgets/doc/GettingStarted.mlx`

Why:

- keeps the special-case behavior explicit

### `deploy/+wt/+deploy/buildDocumentationSearchDb.m`

Purpose:

- wrap `builddocsearchdb(docOutputPath)`

Why:

- separates a release-specific side effect into a dedicated build step

### `deploy/+wt/+deploy/packageRelease.m`

Purpose:

- read version
- build options
- call `matlab.addons.toolbox.packageToolbox`
- return output file path

Why:

- this is the core packaging step already split across `wtPackageRelease.m` and `getPackageOptions.m`

### `deploy/+wt/+deploy/finalizeRelease.m`

Purpose:

- add installer to project
- open release folder

Why:

- preserves legacy release behavior
- keeps UI/project side effects out of the package step

## New File Structure

Proposed minimal structure:

```text
buildfile.m
deploy/
    wtPackageRelease.m
    +wt/
        +deploy/
            buildDocumentationSearchDb.m
            finalizeRelease.m
            getPackageOptions.m
            getReleaseContext.m
            incrementVersionNumber.m
            packageRelease.m
            publishGettingStartedHtml.m
            publishLiveScriptToHtml.m
            publishReleaseDocumentation.m
            publishReleaseExamples.m
            runReleaseTests.m
```

Notes:

- keep `runTestSuite.m` in place for backward compatibility
- `buildfile.m` should call the extracted functions directly and own task sequencing
- `wtPackageRelease.m` should become a thin wrapper for backward compatibility only
- no release logic should be duplicated between `buildfile.m` and `wtPackageRelease.m`

## Proposed Responsibility Split

### `buildfile.m`

Owns:

- task definitions
- task dependencies
- release entry point selection
- Build Tool version gating
- sequencing of the release workflow
- calling the extracted `wt.deploy.*` helpers

Does not own:

- path assembly details
- documentation publishing logic
- packaging logic
- project side effects

### `deploy/wtPackageRelease.m`

Owns:

- legacy script entry point only
- either forwarding to `buildtool archive` or invoking a single shared release entry helper if direct Build Tool invocation is not appropriate

Does not own:

- task graph definition
- inline implementation of release steps

### `deploy/+wt/+deploy/*`

Owns:

- implementation of each release step
- shared behavior used by both script and Build Tool

## Migration Plan

### Phase 1: Extract Without Behavioral Change

1. Add `getReleaseContext`
2. Add `runReleaseTests`
3. Add documentation publishing wrappers
4. Add `buildDocumentationSearchDb`
5. Add `packageRelease`
6. Add `finalizeRelease`
7. Rewrite `deploy/wtPackageRelease.m` to become a thin wrapper over the shared release implementation

Success criteria:

- running `deploy/wtPackageRelease.m` yields the same `.mltbx`, HTML outputs, search database updates, project update, and release-folder open behavior as before

### Phase 2: Wire Build Tool To The Same Implementation

1. Update `buildfile.m` to define release tasks
2. Make each release task call the extracted `wt.deploy.*` helper
3. Keep `archive` as the top-level release task
4. Preserve current default tasks unless there is an explicit decision to change developer workflow
5. Make `buildtool archive` the documented primary release command
6. Update maintainer-facing comments and docs so they explicitly state that builds run in the latest MATLAB release while packaged toolbox support remains `R2021a+`

Success criteria:

- `buildtool archive` performs the same release workflow as `deploy/wtPackageRelease.m`

### Phase 3: Compatibility Validation

1. Compare generated release artifact name and location
2. Compare generated HTML files and search DB side effects
3. Confirm version increment behavior is unchanged
4. Confirm project update still occurs
5. Confirm release-folder open behavior still occurs

Success criteria:

- no external release output changes

### Phase 4: Deprecation Posture

1. Retain `deploy/wtPackageRelease.m` as a supported wrapper
2. Add a short header comment indicating `buildtool archive` is now the preferred entry point
3. Keep the wrapper minimal enough that future release changes are made only in `buildfile.m` and `deploy/+wt/+deploy/`
4. Do not remove the wrapper in the same change set

Success criteria:

- existing users of the script are not broken

## Risks And Compatibility Concerns

### Release Behavior Drift

Risk:

- switching from `runTestSuite` to pure `TestTask` may alter selected tests, reporting, or failure semantics

Mitigation:

- keep `runReleaseTests` backed by `runTestSuite` initially
- treat `TestTask` as a developer-facing test entry point, not the authoritative release gate until equivalence is proven

### Build Tool Release Gating

Risk:

- maintainers may interpret the Build Tool MATLAB requirement as the supported runtime floor for toolbox users

Mitigation:

- document explicitly that releases are built in the latest MATLAB release, while toolbox support for consumers remains `R2021a+`
- update `buildfile.m`, `README.md`, and packaging comments to reflect that split consistently
- keep `wtPackageRelease.m` available as a compatibility wrapper during migration

### Project Context Assumptions

Risk:

- `wtPackageRelease.m` currently assumes `currentProject` is loaded

Mitigation:

- make `getReleaseContext` validate project availability and fail with a targeted message
- do not silently change path behavior

### Duplicate Side Effects

Risk:

- publishing documentation or incrementing the version in multiple tasks can create inconsistent state if tasks are invoked independently

Mitigation:

- confine version increment to `prepareRelease`
- document that `archive` is the supported full-release entry point
- keep intermediate tasks available for diagnostics but not as the normal release command
- keep `wtPackageRelease.m` thin so it cannot diverge from `buildfile.m`

### Output Drift

Risk:

- reorganizing helpers could accidentally change output locations, timestamps, or package metadata

Mitigation:

- keep `getPackageOptions` unchanged initially
- keep doc and example output paths unchanged
- use wrapper functions around existing calls instead of rewriting logic

### UI Side Effects In Automation

Risk:

- `winopen(releaseFolder)` and `proj.addFile(outputFile)` may be undesirable in CI or headless use

Mitigation:

- preserve them initially to meet the no-output-change requirement
- defer any optional headless mode until after migration parity is established

## Recommended First Implementation Slice

The lowest-risk first change is:

1. Extract `getReleaseContext`
2. Extract `runReleaseTests`
3. Extract `packageRelease`
4. Add the remaining doc publishing and search DB helpers
5. Update `buildfile.m` so `archive` owns the full release workflow through those helpers
6. Convert `wtPackageRelease.m` into a thin wrapper

This sequence keeps the release flow centered in `buildfile.m`, keeps code churn local to `deploy/+wt/+deploy/`, and avoids changing package outputs while the migration is underway.
