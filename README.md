# GhPrMerger

Merge open pull requests from GitHub together to create a new master with all of the changes.

Useful for pushing all proposed changes to the development server for testing.

## Installation

```
$ gem install gh_pr_merger
```

## Usage

```
$ gh_pr_merger --help
Usage: gh_pr_merger --access-token TOKEN --base-repo REPO --base-branch BRANCH --merge-branch BRANCH [--fork-repo]
```