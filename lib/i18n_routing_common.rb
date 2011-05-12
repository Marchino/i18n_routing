# encoding: utf-8

# I18nRouting module for common usage methods
module I18nRouting
  def self.locale_escaped(locale)
    locale.to_s.downcase.gsub('-', '_')
  end
  
  # Return the correct translation for given values
  def self.translation_for(name, type = :resources, option = nil, current_scope = nil)
    # First, if an option is given, try to get the translation in the routes scope
    if option
      default = "{option}Noi18nRoutingTranslation"
      t = I18n.t(option, :scope => "routes.#{name}.#{type}", :default => default)
      return (t == default ? nil : t)
    else
      if current_scope 
        default = "{resource}Noi18nRoutingTranslation"
        
        if current_scope[:original_path]
          t = I18n.t(:as, :scope => "routes.#{current_scope[:original_path].gsub(/^\//, '')}.#{name}", :default => default)
        else
          t = I18n.t(:as, :scope => "routes.#{current_scope[:path].gsub(/^\//, '')}.#{name}", :default => default)
        end
        return (t == default ? nil : t)
        
        # original_path = current_scope[:path].gsub(/^\//, '').split('/')
        # current_path = []
        # translated_path = []
        # original_path.each do |p|
        #   current_path << p
        #   t = I18n.t(:as, :scope => "routes.#{current_path.join('.')}", :default => default)
        #   translated_path << t if t != default
        # end
        # t = I18n.t(:as, :scope => "routes.#{current_path.join('.')}.#{name}", :default => default)
        # translated_path << t if t != default
        # return ( ( (translated_path.count - 1) == original_path.count) ? translated_path.join('/') : nil )
      else
        default = "{name}Noi18nRoutingTranslation"

        # Try to get the translation in routes namescope first      
        t = I18n.t(:as, :scope => "routes.#{name}", :default => default)

        return t if t and t != default

        t = I18n.t(name.to_s, :scope => type, :default => default)
        return (t == default ? nil : t)
      end
    end
  end

  DefaultPathNames = [:new, :edit]
  PathNamesKeys = [:path_names, :member, :collection]

  # Return path names hash for given resource
  def self.path_names(name, options)
    h = (options[:path_names] || {}).dup
    
    path_names = DefaultPathNames
    PathNamesKeys.each do |v|
      path_names += options[v].keys if options[v] and Hash === options[v]
    end
    
    path_names.each do |pn|

      n = translation_for(name, :path_names, pn)
      n = nil if n == pn.to_s
      # Try with path_names in current resource scope if a path is specified
      n ||= I18n.t(pn, :scope => "routes.#{options[:path].gsub(/^\//, '')}.#{name}.path_names", :default => name.to_s) if options[:path]
      # Get default path_names in path_names scope if no path_names found
      n ||= I18n.t(pn, :scope => :path_names, :default => name.to_s)

      h[pn] = n if n and n != name.to_s

    end
      # puts "PATH NAMES: #{h.inspect} - #{options[:original_path]}" if 
    return h
  end
end
