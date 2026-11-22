# Documentation

Build and publish the package documentation.

## Overview

The documentation build produces a DocC website for GitHub Pages. The same build script can generate the site locally
without publishing it. Generated files stay under `.build/` and are not committed.

## Requirements

Use Xcode 26.5 with its iOS Simulator SDK. Select that installation with `xcode-select` or `DEVELOPER_DIR` to match CI.
Run commands from the repository root.

Package resolution needs network access when dependencies are not cached. Publishing requires GitHub Pages configured
for GitHub Actions; local generation does not require deployment permissions.

## Continuous Integration

The [Documentation workflow](/.github/workflows/documentation.yml) runs on pushes to `main` and manual dispatch. Its
`Build Documentation` job builds the site, configures GitHub Pages, and uploads `.build/github-pages/`. The dependent
`Deploy Documentation` job publishes that artifact on `ubuntu-latest` after the build job succeeds. Separating upload
and deployment avoids looking up the artifact immediately after upload in the same job.

The deployment URL appears in the `github-pages` environment. A failed build or upload prevents deployment. A newer
Pages run cancels an older run in progress. If deployment fails, rerun only the failed deployment job while its artifact
is still available; this reuses the upload instead of creating another artifact with the same name.

## Build Script

[BuildDocumentation.swift](/Scripts/BuildDocumentation.swift) generates the website:

```shell
swift Scripts/BuildDocumentation.swift
```

The script takes no arguments. It writes the site to `.build/github-pages/` and adds a landing-page redirect after a
successful build. Build or file-writing failures return a nonzero exit status. The script does not publish the site.

The script invokes `xcodebuild docbuild` for the `BuyMeACoffee` scheme using a generic iOS Simulator destination. DocC
prepares static hosting under the `swiftui-buymeacoffee` base path in the same invocation. Intermediate build products
live in `.build/documentation/`; the site root redirects to `documentation/buymeacoffee/`.
