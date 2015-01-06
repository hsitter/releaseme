#--
# Copyright (C) 2007-2014 Harald Sitter <apachelogger@ubuntu.com>
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

require 'fileutils'

require_relative 'vcs'

# FIXME: git is not tested
class Git < Vcs
    # Git branch to get() from, when nil no explicit argument is passed to git
    attr_accessor :branch

    # Git hash of the gotten source. This is nil unless get() finished successfully
    # --
    # FIXME: might need to move to Vcs base?
    # ++
    attr_reader :hash

    # Clones repository into target directory
    # @param shallow whether or not to create a shallow clone
    def get(target, shallow = true)
        args = []
        args << "--depth 1" if shallow
        args << "--branch #{branch}" unless branch.nil? or branch.empty? # defaults to master
        puts "git clone #{args.join(' ')} #{repository} #{target} 2>&1"
        %x[git clone #{args.join(' ')} #{repository} #{target} 2>&1]

        # Set hash accordingly
        previous_wd = Dir.pwd
        Dir.chdir(target)
        @hash = %x[git rev-parse HEAD].chop()
        Dir.chdir(previous_wd)
    end

    # Removes target/.git.
    def clean!(target)
        FileUtils::rm_rf("#{target}/.git")
    end
end
