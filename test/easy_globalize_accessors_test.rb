require 'test/test_helper'

# https://github.com/svenfuchs/i18n/wiki/Fallbacks
require "i18n/backend/fallbacks"
I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)

class EasyGlobalizeAccessorsTest < ActiveSupport::TestCase
 
  class Unit < ActiveRecord::Base
    translates :name, :title
    globalize_accessors
  end

  class UnitTranslatedWithOptions < ActiveRecord::Base
    set_table_name :units
    translates :name
    globalize_accessors :locales => [:pl], :attributes => [:name]
  end

  setup do
    assert_equal :en, I18n.locale
    I18n.fallbacks[:en] = [:en]
    I18n.fallbacks[:pl] = [:pl]
  end

  test "read and write on new object" do
    u = Unit.new(:name_en => "Name en", :title_pl => "Title pl")

    assert_equal "Name en",  u.name
    assert_equal "Name en",  u.name_en
    assert_equal "Title pl", u.title_pl

    assert_nil u.name_pl
    assert_nil u.title_en
  end

  test "write on new object and read on saved" do
    u = Unit.create!(:name_en => "Name en", :title_pl => "Title pl")

    assert_equal "Name en",  u.name
    assert_equal "Name en",  u.name_en
    assert_equal "Title pl", u.title_pl

    assert_nil u.name_pl
    assert_nil u.title_en
  end 

  test "read on existing object" do
    u = Unit.create!(:name_en => "Name en", :title_pl => "Title pl")
    u = Unit.find(u.id)
    
    assert_equal "Name en",  u.name
    assert_equal "Name en",  u.name_en
    assert_equal "Title pl", u.title_pl

    assert_nil u.name_pl
    assert_nil u.title_en
  end

  test "read and write on existing object" do
    u = Unit.create!(:name_en => "Name en", :title_pl => "Title pl")
    u = Unit.find(u.id)

    u.name_pl = "Name pl"
    u.name_en = "Name en2"
    u.save!

    assert_equal "Name en2",  u.name
    assert_equal "Name en2",  u.name_en
    assert_equal "Name pl",   u.name_pl
    assert_equal "Title pl",  u.title_pl
    
    assert_nil u.title_en
  end

  test "read and write on class with options" do
    u = UnitTranslatedWithOptions.new()

    assert u.respond_to?(:name_pl)
    assert u.respond_to?(:name_pl=)

    assert ! u.respond_to?(:name_en)
    assert ! u.respond_to?(:name_en=)

    u.name = "Name en"
    u.name_pl = "Name pl"

    assert_equal "Name en",  u.name
    assert_equal "Name pl",  u.name_pl
  end

  test "using fallbacks" do
    u = Unit.new(:name_pl => "Name pl")

    assert_nil u.name_en
    assert_nil u.name_en_without_fallback
    assert_equal "Name pl", u.name_pl
    assert_equal "Name pl", u.name_pl_without_fallback

    I18n.fallbacks[:en] = [:en, :pl]

    assert_equal "Name pl", u.name_en
    assert_nil u.name_en_without_fallback
    assert_equal "Name pl", u.name_pl
    assert_equal "Name pl", u.name_pl_without_fallback
  end

end
