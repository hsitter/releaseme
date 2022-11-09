#!/usr/bin/env ruby
# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2017-2020 Jonathan Riddell <jr@jriddell.org>

require_relative 'plasma_version'
require 'git'
require 'json'
require 'httparty'

# check the tag has been pushed
class PlasmaTagTest
  attr_accessor :version
  attr_accessor :repos

  def initialize
    plasma_versions = PlasmaVersion.new
    @version = plasma_versions.version
  end

  def grab_git_repos
    file_contents = File.read('git-repositories-for-release')
    @repos = file_contents.split(' ')
  end

  def check_tags
    missing_tags = []
    repos.each do |repo|
      path = get_kde_category(repo)
      tag_refs = Git.ls_remote("invent:#{path}/#{repo}")['tags']["v#{@version}"]
      missing_tags.push(repo) if tag_refs == nil
      puts "Repo #{repo} has tag v#{@version}" if tag_refs != nil
      puts "Not found tag v#{@version} in #{repo}" if tag_refs == nil
    end
    if missing_tags.length > 0
      puts "missing tags #{missing_tags.to_s}"
    else
      puts 'All good!'
    end
  end

  def get_kde_category(project)
    # download https://projects.kde.org/api/v1/identifier/#{project}
    response = HTTParty.get("https://projects.kde.org/api/v1/identifier/#{project}")
    # parse json
    identifier_json = JSON.parse(response.body)
    # get result['path']
    path = identifier_json['path']
    # return split ('/')[0]
    result = path.split('/')
    result[0]
  end
end
