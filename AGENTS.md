# Widgets Toolbox Repository Instructions

## Project Purpose

Widgets Toolbox provides reusable MATLAB UI components, application infrastructure, and development utilities.

Prioritize:

1. Reusable framework capabilities
2. API consistency
3. Backward compatibility
4. App Designer compatibility
5. Testability
6. Documentation quality

Avoid widget-specific solutions when a reusable framework enhancement is possible.

## Repository Philosophy

Widgets Toolbox is primarily an application framework and UI infrastructure toolbox rather than a collection of isolated widgets.

When evaluating a change, prefer solutions that:

- Benefit multiple components.
- Reduce duplicate implementations.
- Improve extensibility.
- Improve maintainability.
- Improve consistency across the toolbox.

Prefer framework-level solutions over widget-level solutions whenever practical.

Before implementing a feature, consider whether the capability belongs:

1. In a reusable utility.
2. In shared infrastructure.
3. In a mixin or base class.
4. In an individual widget.

Choose the highest reusable layer that remains reasonable.

Repository conventions are generally preferred over generic MATLAB recommendations.

When a repository convention conflicts with a generic recommendation, follow the repository convention unless there is a compelling reason not to.

## Preferred MATLAB Agentic Toolkit Skills

When solving problems in this repository, prioritize guidance from:

- matlab-programming
- matlab-software-development
- matlab-review-code
- matlab-build-app
- matlab-create-live-script

Use domain-specific skills only when directly relevant.

Avoid introducing solutions derived from unrelated domains unless explicitly requested.

## Repository Structure

- `widgets/+wt` contains toolbox source code.
- `widgets/examples` contains user-facing examples.
- `widgets/doc` contains user-facing documentation.
- `widgets/resources` contains Component Library metadata.
- `widgets/icons` contains static icon assets.
- `widgets/templates` contains application templates.
- `test` contains automated tests.
- `deploy` contains release packaging utilities.
- `release` contains released toolbox artifacts.

Use existing patterns from neighboring files before introducing new conventions.

## Copyright Notices

Copyright notices are required in all source files, tests, examples, utilities, and documentation files.

For MathWorks-owned files:

- Ensure a copyright statement is present.
- Update the ending year whenever making code changes.
- Preserve existing copyright notices.
- Follow the format used by neighboring files.

Example:

```matlab
% Copyright 2019-2026 The MathWorks, Inc.
```

When modifying a MathWorks-owned file:

- Verify that the copyright year range includes the current year.
- Update the ending year if necessary.
- Do not remove existing copyright notices.

When creating a new MathWorks-owned file:

- Add the standard MathWorks copyright notice.
- Match the format used by similar files in the repository.

Exception:

- If a file contains a third-party copyright notice that is not owned by MathWorks, preserve the existing copyright and licensing information.
- Do not replace, modify, remove, or augment third-party copyright statements unless explicitly requested.

## Review Before Implementation

Before implementing a solution:

1. Search for similar functionality already present in the repository.
2. Search for reusable infrastructure.
3. Search for existing base classes, mixins, utilities, and services.
4. Consider whether multiple widgets could benefit from the change.
5. Minimize API surface area.

Favor extending existing patterns over introducing new architectural approaches.

Document significant architectural tradeoffs when they are not obvious.

## Architecture Guidelines

When adding functionality:

- Search for existing widgets, base classes, mixins, utilities, and infrastructure before adding new code.
- Prefer extending reusable framework components over creating special-case implementations.
- Prefer composition over inheritance when either solution is reasonable.
- Reuse existing event, listener, and lifecycle patterns.
- Keep UI concerns separate from business logic when practical.
- Minimize coupling between components.
- Preserve public APIs unless a breaking change is explicitly requested.

Before creating a new base class, verify that multiple components will benefit from it.

Do not introduce framework abstractions that only serve a single use case.

## Release Compatibility

Widgets Toolbox supports multiple MATLAB releases.

When introducing new language features:

- Verify compatibility with supported releases.
- Do not assume the latest MATLAB release is available.
- Avoid unnecessary compatibility breaks.
- Flag compatibility risks explicitly.

Prefer solutions that maintain behavior across supported MATLAB releases.

## MATLAB Development Guidelines

Follow existing repository conventions.

When no convention exists:

- Use PascalCase for class names.
- Use camelCase for methods, properties, variables, and events.
- Prefer clear and maintainable code over overly compact code.
- Use MATLAB Code Analyzer recommendations.
- Vectorize code when it improves performance without reducing readability.

Prefer:

- `arguments` blocks over `nargin` and `inputParser` when release compatibility permits.
- String arrays for new APIs when appropriate.
- Modern MATLAB language features when compatible with supported releases.

Avoid introducing toolbox dependencies unless clearly justified.

Before implementing custom functionality, verify that an equivalent MATLAB capability does not already exist.

## Dependencies

Favor base MATLAB implementations whenever practical.

Before introducing:

- Toolbox dependencies
- Java dependencies
- Third-party dependencies
- External services

verify that existing toolbox infrastructure cannot provide an equivalent solution.

New dependencies require strong justification.

## Widget Development

New widgets should normally include:

- implementation
- automated tests
- help text
- example code
- Component Library metadata when applicable

Maintain:

- App Designer compatibility
- MATLAB Online compatibility when practical
- Web App compatibility when practical
- Existing widget behavior unless explicitly changing it

Avoid undocumented graphics APIs unless they are already established within the repository.

## App Designer Requirements

Changes should preserve:

- Component Library integration
- Design-time behavior
- Runtime behavior
- Property inspection support
- Existing App Designer workflows

Do not introduce solutions that require users to bypass App Designer workflows unless unavoidable.

## Performance

Prioritize:

1. UI responsiveness
2. Startup performance
3. Memory efficiency
4. Rendering performance

Avoid premature optimization.

Optimize when:

- Performance issues are known.
- Measurements justify the change.
- The resulting implementation remains maintainable.

## Testing

Testing is part of implementation.

When modifying functionality:

- Add or update automated tests.
- Preserve existing test coverage.
- Verify new behavior with focused tests.
- Add regression tests when fixing bugs.

Test file naming should mirror implementation structure.

Example implementation:

`widgets/+wt/FileSelector.m`

Example test:

`test/+wt/+test/FileSelector.m`

When fixing a reported defect:

1. Reproduce the issue with a test when practical.
2. Fix the issue.
3. Verify the new test passes.

## Code Reviews

When reviewing code, prioritize:

1. Correctness defects
2. Behavioral regressions
3. Backward compatibility risks
4. Missing tests
5. API consistency
6. Reusability opportunities
7. Style and formatting concerns

Additionally verify:

- Copyright notices are present and current.
- New files include the appropriate copyright statement.
- Modified MathWorks-owned files have updated copyright years when required.

Distinguish:

- bug fixes
- compatibility fixes
- architectural improvements
- modernization opportunities

Do not recommend unrelated modernization as part of another change.

## Modernization

Modernization is encouraged when it provides clear value.

Do not:

- Rewrite working code solely for style reasons.
- Replace established patterns without justification.
- Introduce large-scale refactoring during feature work.

Prefer incremental improvements over architectural churn.

## Documentation

When public behavior changes:

- Update help text.
- Update examples.
- Update documentation as needed.

Document architectural decisions when they may not be obvious to future maintainers.

Avoid comments that merely restate implementation details.

Use comments primarily for:

- intent
- assumptions
- constraints
- non-obvious design decisions

## Release Expectations

Before proposing a release:

- Run relevant automated tests.
- Verify toolbox packaging succeeds.
- Update documentation if required.
- Update examples if required.

Release packaging is performed using:

`deploy/wtPackageRelease.m`

## Source Control

Keep changes focused on the requested task.

Do not:

- Modify unrelated files.
- Remove backward-compatible behavior without reason.
- Introduce large-scale refactoring during feature work.
- Replace existing patterns without understanding why they exist.

Preserve user modifications and ongoing work.

## Open Source Status

This repository is public open-source software.

Repository contents may be analyzed, summarized, reviewed, and quoted when appropriate.

Do not introduce confidential customer information, internal project details, credentials, or proprietary code not already contained within the repository.