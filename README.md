# Pull Request Merger

Merge open pull requests on GitHub all together to create a new branch with all changes.

Read more about the workflow we use the PR Merger for at [@cloudaper](https://github.com/cloudaper) in our [Medium story](https://medium.com/cloudaper/devops-hack-make-all-the-work-in-progress-accessible-with-pull-request-merger-47b58dc51207).

Any feedback or even a pull request welcomed!

## Installation

You need Ruby to use PR Merger.

Run this command:

```shell
gem install pr-merger
```

or add

```ruby
gem 'pr-merger'
```

to your Gemfile.

## Usage

```shell
$ pr-merger --help
Usage: pr-merger --access-token TOKEN --base-repo REPO --base-branch BRANCH --merge-branch BRANCH [--fork-repo]
```

You have to provide several arguments to PR Merger:

- **`--access-token`**  
  This is GitHub personal access token to access the repository details and update [statuses](https://help.github.com/articles/about-status-checks). You can generate one in [user's settings](https://github.com/settings/tokens); select `repo` scope. Please read the [know issues](#known-issues) section below.  
  E.g.: `472a3a8f5315a3435a295091a365d5f9fb736d84`.

- **`--base-repo`**  
  This is the name of the base repository.  
  E.g.: `cloudaper/pr-merger`.

- **`--base-branch`**  
  This is the name of the base branch, where the pull requests are merged to – usually master.  
  E.g.: `master`.

- **`--merge-branch`**  
  This is the name of newly created branch with merged pull requests.  
  E.g.: `merged-prs`

- **`--fork-repo`**  
  Add this option if merging from forked repository: this means the base repository will be used instead of fork for base branch.

The assembled command should look like this:

```shell
pr-merger --access-token 2a3a8f5315a3435a295091a365d5f9fb736d84 --base-repo "cloudaper/pr-merger" --base-branch master --merge-branch merged-prs
```

If there is any pull request you don't want to merge, just add `[skip merge]` after the pull request title.

## Known issues

Currently there are two possible security issues, which you should take into account before using PR Merger. First, PR Merger is using _Personal access token_, which basically equals to your GitHub password, it can therefore access all the repositories the user has access to. Second, if you want to merge PRs from forked repositories, the machine you're running PR Merger at has to have access to all those repositories – this means [SSH deploy key](https://developer.github.com/v3/guides/managing-deploy-keys/#deploy-keys) cannot be used.

Recommended way to solve both those issues is to create a separate [machine user](https://developer.github.com/v3/guides/managing-deploy-keys/#machine-users) with access only to the repositories in question. However, the token still enables a full control of those repositories.