require 'gh_pr_merger/version'
require 'octokit'
require 'tty-command'

module GhPrMerger

  APP_CONTEXT = 'ci/gh_pr_merger'

  def self.run(base_repo, access_token, base_branch, merge_branch, fork_repo)
    cmd = TTY::Command.new
    Octokit.auto_paginate = true
    client = Octokit::Client.new(access_token: access_token)
    pull_requests = client.pull_requests(base_repo, state: 'open').reverse
    active_branch_result = cmd.run! 'git rev-parse --abbrev-ref HEAD'
    if active_branch_result.failure?
      previous_branch = cmd.run('cat .git/HEAD')
    else
      previous_branch = active_branch_result.out
    end
    cmd.run 'git checkout', base_branch

    if fork_repo
      cmd.run! 'git remote add upstream', "git@github.com:#{base_repo}.git"
      cmd.run 'git fetch upstream', base_branch
      cmd.run 'git reset --hard', "upstream/#{base_branch}"
    else
      cmd.run 'git reset --hard', "origin/#{base_branch}"
    end
    cmd.run 'git checkout -b', merge_branch
    merge_statuses = pull_requests.map do |pr|
      process_pr(pr, client, cmd, base_repo, base_branch, fork_repo)
    end
    cmd.run 'git checkout', previous_branch
    merge_statuses.all? { |status| status }
  end

  private

  def self.process_pr(pr, client, cmd, base_repo, base_branch, fork_repo)
    head = pr[:head]
    repo = head[:repo]
    puts "Attempting to merge #{head[:ref]}."
    client.create_status(base_repo, head[:sha], 'pending', context: APP_CONTEXT, description: 'Merge in progress.')
    begin
      cmd.run "git fetch", repo[:ssh_url], head[:ref]
      merge_status = cmd.run! 'git merge --no-ff --no-edit', head[:sha]
      if merge_status.failure?
        cmd.run 'git merge --abort'
        client.create_status(base_repo, head[:sha], 'failure', context: APP_CONTEXT, description: "Failed to merge '#{head[:ref]} with #{base_branch}. Check for merge conflicts.")
      else
        client.create_status(base_repo, head[:sha], 'success', context: APP_CONTEXT, description: "Merge with '#{base_branch}' was successful.")
      end
    rescue => e
      p e
      client.create_status(base_repo, head[:sha], 'error', context: APP_CONTEXT, description: "Merge encountered an error: #{e.class.name}.")
      return false
    end
    return true
  end
end
