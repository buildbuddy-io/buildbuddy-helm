# Contributing Guidelines

Thank you for your interest in contributing! Please see the [BuildBuddy Contribution Guide](https://www.buildbuddy.io/docs/contributing) which describes the process for making code contributions across BuildBuddy projects and [join our Slack channel](https://slack.buildbuddy.io) to ask questions from community members and the BuildBuddy core team.

## How to Contribute to the buildbuddy-helm repository

1. Fork this repository, develop, and test your changes.
1. Submit a pull request.

***NOTE***: In order to make testing and merging of PRs easier, please submit changes to multiple charts in separate PRs.

### Technical Requirements

* Must pass linting and installing with the [chart-testing](https://github.com/helm/chart-testing) tool
* Must follow [best practices](https://github.com/helm/helm/tree/master/docs/chart_best_practices) and [review guidelines](https://github.com/helm/charts/blob/master/REVIEW_GUIDELINES.md)

### Documentation Requirements

* A chart's `README.md` must include configuration options
* A chart's `NOTES.txt` must include relevant post-installation information

### Merge Approval and Release Process

* Must pass CI jobs for linting and installing changed charts
* Any change to a chart requires a version bump following [semver](https://semver.org/) principles

Once changes have been merged, the release job will automatically run to package and release changed charts.

### Checking release versions

The release workflow runs a read-only validator using Bazelisk. Its Bazel target
fetches a pinned `mikefarah/yq` v4 binary, so `yq` does not need to be installed
on the host. To run it locally:

```bash
bazelisk run //scripts:validate_release_versions
```

The validator checks the release-critical relationships that have broken before:
chart `appVersion` must match the default image tag, and each managed dependency
must match its lock file and checked-in package. The enterprise package is also
checked recursively through its executor and cache-proxy dependencies.

When changing a dependency, run `helm dependency update <chart-directory>` and
commit the requirement, lock file, and vendored chart together.
