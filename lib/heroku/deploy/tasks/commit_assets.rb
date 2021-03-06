module Heroku::Deploy::Task
  class CommitAssets < Base
    include Heroku::Deploy::Shell

    def before_deploy
      assets_folder = "public/assets"

      has_changes = false
      task "Checking to see if there are any changes in #{colorize assets_folder, :cyan}" do
        changes = git %{status #{assets_folder} --porcelain}
        has_changes = !changes.empty?
      end

      if has_changes
        task "Commiting #{colorize assets_folder, :cyan} for deployment" do
          git %{add #{assets_folder}}
          git %{commit #{assets_folder} -m "[heroku-deploy] Compiled assets for deployment"}

          @deployment_commit = git 'rev-parse --verify HEAD'
        end
      end
    end

    def rollback_before_deploy
      # Revert back to the commit before we compiled assets
      if @deployment_commit
        git %{reset #{@deployment_commit}~1 --hard}
      end
    end
  end
end
