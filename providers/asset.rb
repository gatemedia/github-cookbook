#
# Cookbook Name:: github
# Provider:: asset
#
# Author:: Jamie Winsor (<jamie@vialstudios.com>)
#

use_inline_resources

attr_reader :asset

def load_current_resource
  @asset = GithubCB::Asset.new(new_resource.repo, name: new_resource.name,
    release: new_resource.release)
end

action :download do
  if Chef::Resource::ChefGem.instance_methods(false).include?(:compile_time)
    chef_gem "octokit" do
      compile_time true
      version "4.21.0"
    end
  else
    chef_gem "octokit" do
      action :nothing
      version "4.21.0"
    end.run_action(:install)
  end

  Chef::Log.info "github_asset[#{new_resource.name}] downloading asset"
  updated = asset.download(user: new_resource.github_user, token: new_resource.github_token,
    force: new_resource.force, path: new_resource.asset_path, retries: new_resource.retries,
    retry_delay: new_resource.retry_delay, checksum: new_resource.checksum)
  new_resource.updated_by_last_action(updated)
end

action :delete do
  file @asset.asset_path do
    action :delete
  end

  directory new_resource.extract_to do
    recursive true
    action :delete
  end
end
