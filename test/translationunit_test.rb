# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2015-2020 Harald Sitter <sitter@kde.org>
# SPDX-FileCopyrightText: 2017 Jonathan Riddell <jr@jriddell.org>

require_relative 'lib/testme'
require_relative '../lib/releaseme/translationunit'

class TestTranslationUnit < Testme
  def setup
    # Disable querying VCS by default.
    ReleaseMe::TranslationUnit.languages = []
  end

  def create(type)
    @svn = mock('svn')
    @svn.stubs(:cat).with('subdirs').returns("de\nx-test\n")

    # mock an attr
    @repository = ''
    @svn.stubs(:repository=).with do |v|
      @repository.replace(v)
      true
    end
    @svn.stubs(:repository).returns(@repository)

    l = ReleaseMe::TranslationUnit.new(type, 'amarok', File::NULL, vcs: @svn)
    l.target = "#{@dir}/l10n"
    l
  end

  def create_plasma(type)
    @svn = mock('svn')
    @svn.stubs(:cat).with('subdirs').returns("de\nx-test\n")

    # mock an attr
    @repository = ''
    @svn.stubs(:repository=).with do |v|
      @repository.replace(v)
      true
    end
    @svn.stubs(:repository).returns(@repository)

    l = ReleaseMe::TranslationUnit.new(type, 'khotkeys', 'kde-workspace',
                                       vcs: @svn)
    l.target = "#{@dir}/l10n"
    l
  end

  def create_trunk
    create(ReleaseMe::TranslationUnit::TRUNK)
  end

  def create_stable
    create(ReleaseMe::TranslationUnit::STABLE)
  end

  def create_lts
    create(ReleaseMe::TranslationUnit::LTS)
  end

  def create_lts_plasma
    create_plasma(ReleaseMe::TranslationUnit::LTS)
  end

  def test_0_attr
    l = create_trunk

    assert_equal("#{@dir}/l10n", l.target)
    assert_equal(ReleaseMe::TranslationUnit::TRUNK, l.type)
    assert_equal(File::NULL, l.i18n_path)
  end

  def test_0_repo_url_init_trunk
    l = create_trunk
    assert_equal(ReleaseMe::TranslationUnit::TRUNK, l.type)
    l.init_repo_url('file://a')
    assert_equal('file://a/trunk/l10n-kf5/', l.vcs.repository)
  end

  def test_0_repo_url_init_stable
    l = create_stable
    assert_equal(ReleaseMe::TranslationUnit::STABLE, l.type)
    l.init_repo_url('file://a')
    assert_equal(l.vcs.repository, 'file://a/branches/stable/l10n-kf5/')
  end

  def test_0_repo_url_init_lts_plasma
    l = create_lts_plasma
    assert_equal(ReleaseMe::TranslationUnit::LTS, l.type)
    l.init_repo_url('file://a')
    assert_equal(l.vcs.repository, 'file://a/branches/stable/l10n-kf5-plasma-lts/')
  end

  def test_invalid_inits
    assert_raises do
      ReleaseMe::TranslationUnit.new(nil, 'amarok', File::NULL)
    end
    assert_raises do
      ReleaseMe::TranslationUnit.new(ReleaseMe::TranslationUnit::TRUNK, nil, 'null')
    end
    assert_raises do
      ReleaseMe::TranslationUnit.new(ReleaseMe::TranslationUnit::TRUNK, 'amarok', nil)
    end
  end

  def test_invalid_type
    assert_raises do
      # :fishyfishy is a bad type and can't be mapped to a repo path
      ReleaseMe::TranslationUnit.new(:fishyfishy, 'amarok', File::NULL)
    end
  end

  def test_simple_kde4
    # Technically we could handle kde4, given this is a fairly low level class
    # we may just get away with this.
    u = ReleaseMe::TranslationUnit.new(ReleaseMe::Origin::TRUNK_KDE4, 'amarok',
                                       File::NULL)
    assert_equal('svn://anonsvn.kde.org/home/kde//trunk/l10n-kde4/',
                 u.vcs.repository)
  end

  def test_default_exclusion
    ReleaseMe::TranslationUnit.languages = nil # force detection
    u = create_trunk
    langs = u.languages
    refute_includes(langs, 'x-test')
    refute(langs.empty?)
  end

  def test_exclusion
    ReleaseMe::TranslationUnit.languages = nil # force detection
    u = create_trunk
    u.default_excluded_languages = []
    assert_includes(u.languages, 'x-test')
    # Make sure the exclusion list is not cached so it can be changed later.
    u.default_excluded_languages = nil
    refute_includes(u.languages, 'x-test')
  end
end
