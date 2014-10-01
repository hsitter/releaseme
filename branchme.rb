#!/usr/bin/env ruby
#--
# Copyright (C) 2014 Harald Sitter <apachelogger@ubuntu.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of
# the License or (at your option) version 3 or any later version
# accepted by the membership of KDE e.V. (or its successor approved
# by the membership of KDE e.V.), which shall act as a proxy
# defined in Section 14 of version 3 of the license.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#++

require 'optparse'

options = {}
OptionParser.new do |opts|
    opts.banner = "Usage: branchme.rb [options]"

    opts.on("--name BRANCHNAME",
            "Branch name.",
            "   Branch names usually are prefixed by a project name (e.g. Plasma/1.0)") do |v|
        options[:branch] = v
    end
end.parse!

if options[:branch].nil?
    puts "error, you need to set branchname"
    exit 1
end

# TODO: single project tag
# project_name = ARGV.pop
#
# p options
# p ARGV
# p project_name

#################

require_relative 'lib/project'
require_relative 'lib/source'

class TagProject
    attr :project, true
    attr :git_rev, true

end

# FIXME: move to lib :@
def read_release_data()
    projects = Array.new
    File.open('release_data', 'r') do | file |
        file.each_line do | line |
            parts = line.split(';')
            next if parts.size < 3 # If we don't manage 3 parts the line is definitely crap.
            # 0 = project
            # 1 = branch
            # 2 = git rev
            project = TagProject.new
            project.project = Project.new(parts[0])
            while not project.project.resolve! do
                puts "Resolving the project #{parts[0]} failed. Going to try again in 5 seconds"
                sleep 5
            end
            project.project.vcs.branch = parts[1]
            project.git_rev = parts[2]
            projects << project
        end
    end
    return projects
end

tag_projects = read_release_data()
tag_projects.each do | tag_project |
    puts "--- #{tag_project.project.id} ---"
    source = Source.new
    source.target = "tmp-branchme"
    source.cleanup()
    source.get(tag_project.project.vcs, false)

    Dir.chdir(source.target) do
        puts "::git branch #{options[:branch]} #{tag_project.git_rev}"
        %x[git branch #{options[:branch]} #{tag_project.git_rev}]
        puts "::git checkout #{options[:branch]}"
        %x[git checkout #{options[:branch]}]
        puts "::git push origin #{options[:branch]}"
        %x[git push origin #{options[:branch]}]
    end

    # TODO: impl l10n and docs and what have you
end