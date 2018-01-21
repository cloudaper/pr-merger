require 'gh_pr_merger/version'
require 'tty-command'
require 'octokit'

Octokit.auto_paginate = true

# Merges all opened GitHub PRs to a new branch
class GhPrMerger
  APP_CONTEXT    = 'ci/gh_pr_merger'.freeze
  AUTOMERGE_SKIP = '[automerge skip]'.freeze

  def initialize(access_token:)
    @gh = Octokit::Client.new(access_token: access_token)
  end

  def run(base_repo:, base_branch:, merge_branch:, fork_repo:)
    @base_repo   = base_repo
    @base_branch = base_branch

    pull_requests = @gh.pull_requests(@base_repo, state: 'open').reverse

    cmd = TTY::Command.new
    active_branch_result = cmd.run! 'git rev-parse --abbrev-ref HEAD'

    if active_branch_result.success?
      previous_branch = active_branch_result.out.strip
    else
      previous_branch = cmd.run('cat .git/HEAD').strip
    end

    cmd.run 'git checkout', @base_branch

    if fork_repo
      cmd.run! 'git remote add upstream', "git@github.com:#{@base_repo}.git"
      cmd.run 'git fetch upstream', @base_branch
      cmd.run 'git reset --hard', "upstream/#{@base_branch}"
    else
      cmd.run 'git reset --hard', "origin/#{@base_branch}"
    end

    cmd.run 'git checkout -b', merge_branch

    merge_statuses = pull_requests.map do |pr|
      process_pr(pr, cmd)
    end

    cmd.run 'git checkout', previous_branch

    merge_statuses.all? { |status| status }
  end

  private

  # Process a given pull request
  def process_pr(pr, cmd)
    head = pr[:head]
    repo = head[:repo]

    pending_status(pr, 'Merge in progress.')

    return true if skip_pr?(pr)

    begin
      cmd.run 'git fetch', repo[:ssh_url], head[:ref] if repo

      merge_status = cmd.run! 'git merge --no-ff --no-edit', head[:sha]

      if merge_status.success?
        success_status(pr, "Merge with '#{base_branch}' was successful.")
      else
        cmd.run 'git merge --abort'

        message = "Failed to merge '#{head[:ref]} with #{@base_branch}."
        failure_status(pr, message)
      end
    rescue => e
      failure_status(pr, "Merge encountered an error: #{e.class.name}.")

      return false
    end

    true
  end

  # Skip a given pull request if it includes automerge skip message
  def skip_pr?(pr)
    return false unless pr[:title].include?(AUTOMERGE_SKIP)

    failure_status(pr, "Skipping #{pr[:head][:ref]}.")

    true
  end

  def pending_status(pr, message)
    send_status(pr, 'pending', message)
  end

  def error_status(pr, message)
    send_status(pr, 'error', message)
  end

  def failure_status(pr, message)
    send_status(pr, 'failure', message)
  end

  def success_status(pr, message)
    send_status(pr, 'success', message)
  end

  # Send Octokit status
  def send_status(pr, status, message)
    @gh.create_status(
      @base_repo,
      pr[:head][:sha],
      status,
      context: APP_CONTEXT,
      description: message
    )
  end
end
