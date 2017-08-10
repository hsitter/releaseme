#--
# Copyright (C) 2007-2017 Harald Sitter <sitter@kde.org>
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
require 'thwait'

require_relative 'cmakeeditor'
require_relative 'logable'
require_relative 'source'
require_relative 'svn'
require_relative 'translationunit'

module ReleaseMe
  class DocumentationL10n < TranslationUnit
    prepend Logable

    def vcs_l10n_path(lang)
      "#{lang}/docs/#{@i18n_path}/#{@project_name}"
    end

    def get(srcdir)
      @srcdir = File.expand_path(srcdir)
      @podir = if Dir.exist?("#{@srcdir}/po")
                 "#{@srcdir}/po"
               elsif Dir.exist?("#{@srcdir}/poqm")
                 "#{@srcdir}/poqm"
               else
                 "#{@srcdir}/po" # Default to po
               end

      langs_with_documentation = []
      langs_without_documentation = []

      log_info "Downloading documentations for #{srcdir}"

      # return false if doc_dirs.empty?
      unless translatables?
        log_warn <<-EOF
Could not find any documentation by checking for *.docbook files in the source.
Skipping documentation :(
        EOF
        return
      end

      queue = languages_queue(%w[en])
      threads = []
      THREAD_COUNT.times do
        threads << Thread.new do
          Thread.current.abort_on_exception = true
          until queue.empty?
            language = queue.pop(true)
            if get_language(language)
              langs_with_documentation << language
            else
              langs_without_documentation << language
            end
          end
        end
      end
      ThreadsWait.all_waits(threads)

      if !langs_with_documentation.empty?
        CMakeEditor.append_doc_install_instructions!(@podir)
      else
        log_warn 'There are no translations at all!'
      end

      return if langs_without_documentation.empty?
      log_info "No translations for: #{langs_without_documentation.join(', ')}"
    end

    private

    def docbook_dirs
      Dir.glob("#{@srcdir}/**/*.docbook").collect do |file|
        next nil if manpage?(file)
        name = File.basename(File.dirname(file))
        %w[doc docs docbook documentation].include?(name) ? nil : name
      end
    end

    def kdoctools_dirs
      Dir.glob("#{@srcdir}/**/CMakeLists.txt").collect do |file|
        next unless file.include?('doc/')
        regex = Regexp.new('kdoctools_create_handbook\s*\(.+\s+SUBDIR\s+(?<subdir>[^\)\s]+)\)',
                           Regexp::IGNORECASE | Regexp::MULTILINE)
        matchdata = regex.match(File.read(file))
        next nil unless matchdata
        matchdata.named_captures.fetch('subdir', nil)
      end.compact
    end

    def manpages
      Dir.glob("#{@srcdir}/**/CMakeLists.txt").collect do |file|
        next unless file.include?('doc/')
        regex = Regexp.new('kdoctools_create_manpage\s*\(\s*(?<man>man-[^\)\s]+\.docbook)',
                           Regexp::IGNORECASE | Regexp::MULTILINE)
        matchdata = regex.match(File.read(file))
        next nil unless matchdata
        matchdata.named_captures.fetch('man', nil)
      end.compact
    end

    def doc_dirs
      (docbook_dirs + kdoctools_dirs).uniq.compact
    end

    def translatables?
      !doc_dirs.empty? || !manpages.empty?
    end

    def manpage?(path)
      File.basename(path) =~ /man-.+\.docbook/
    end

    def find_all_docs(dir)
      doc_dirs.select do |doc_dir|
        Dir.exist?("#{dir}/#{doc_dir}")
      end
    end

    def find_all_manpages(dir)
      manpages.collect do |manpage|
        Dir.glob("#{dir}/**/#{manpage}").collect do |x|
          Pathname.new(x).relative_path_from(Pathname.new(dir)).to_s
        end
      end.flatten
    end

    def get_language(language)
      Dir.mktmpdir(self.class.to_s) do |tmpdir|
        @vcs.get(tmpdir, "#{language}/docs/#{@i18n_path}")

        selection = (find_all_docs(tmpdir) + find_all_manpages(tmpdir)).uniq
        selection.each do |d|
          dest = "#{@podir}/#{language}/docs/#{File.dirname(d)}"
          FileUtils.mkpath(dest, verbose: true)
          FileUtils.cp_r("#{tmpdir}/#{d}", dest, verbose: true)
        end

        return !selection.empty?
      end
    end
  end
end
