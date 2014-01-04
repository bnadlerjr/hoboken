module Hoboken
  module Actions
    def gem(name, version, opts={})
      verbose = opts.has_key?(:verbose) ? opts.delete(:verbose) : true

      parts = [name.inspect, "~> #{version}".inspect]
      opts.each { |k, v| parts << "#{k}: #{v.inspect}" }

      append_file("Gemfile", "\ngem #{parts.join(", ")}", verbose: verbose)
    end
  end
end
