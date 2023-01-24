# BuildBuddy Helm Charts ![Build Status](https://img.shields.io/github/actions/workflow/status/buildbuddy-io/buildbuddy-helm/release.yaml?branch=master)

This repository collects a set of [Helm](https://helm.sh) charts curated by [BuildBuddy](https://www.buildbuddy.io).

Click on the following links to see installation instructions for each chart:

- [buildbuddy](charts/buildbuddy/)
- [buildbuddy-enterprise](charts/buildbuddy-enterprise/)
- [buildbuddy-executor](charts/buildbuddy-executor/)

## Usage

[Helm](https://helm.sh) must be installed and initialized to use the charts.
Please refer to Helm's [documentation](https://helm.sh/docs/) to get started.

Once Helm is set up properly, add the repo as follows:

```bash
$ helm repo add buildbuddy https://helm.buildbuddy.io
```

## Contributing

We welcome contributions.
Please refer to our [contribution guidelines](CONTRIBUTING.md) for details.
