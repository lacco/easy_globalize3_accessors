require 'globalize3'

module EasyGlobalize3Accessors
  # Monkey patch Globalize#fallbacks? to make fallbacks configurable
  #
  module ::Globalize
    class << self
      cattr_accessor :with_fallbacks
      def fallbacks?
        with_fallbacks != false && I18n.respond_to?(:fallbacks)
      end
    end
  end

  def globalize_accessors(options = {})
    options.reverse_merge!(:locales => I18n.available_locales, :attributes => translated_attribute_names)

    each_attribute_and_locale(options) do |attr_name, locale|
      define_accessors(attr_name, locale)
    end
  end


  private
    

  def define_accessors(attr_name, locale)
    define_getter(attr_name, locale)
    define_setter(attr_name, locale)
  end

  def define_getter(attr_name, locale)
    accessor = :"#{attr_name}_#{locale}"

    define_method accessor do
      read_attribute(attr_name, :locale => locale)
    end

    define_method :"#{accessor}_without_fallback" do
      old_with_fallbacks = Globalize.with_fallbacks
      Globalize.with_fallbacks = false
      ret_val = self.send(accessor)
      Globalize.with_fallbacks = old_with_fallbacks
      ret_val
    end
  end

  def define_setter(attr_name, locale)
    accessor = :"#{attr_name}_#{locale}"
    define_method :"#{accessor}=" do |value|
      write_attribute(attr_name, value, :locale => locale)
    end
    define_method :"#{accessor}_without_fallback=" do |value|
      self.send("#{accessor}=", value)
    end
  end

  def each_attribute_and_locale(options)
    options[:attributes].each do |attr_name|
      options[:locales].each do |locale|
        yield attr_name, locale
      end
    end
  end

end

ActiveRecord::Base.extend EasyGlobalize3Accessors
