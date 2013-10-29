class BuildsController < ApplicationController
  skip_before_filter :authenticate

  def show
    @build = Build.find(params[:id])
  end

  def create
    if build_runner.valid?
      Delayed::Job.enqueue(build_job)

      render nothing: true
    else
      render text: 'Invalid GitHub action', status: 404
    end
  end

  private

  def build_job
    BuildJob.new(build_runner)
  end

  def build_runner
    @build_runner ||= BuildRunner.new(pull_request, builds_url)
  end

  def pull_request
    PullRequest.new(params[:payload])
  end
end