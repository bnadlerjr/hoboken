# frozen_string_literal: true

module Hoboken
  # Custom actions.
  #
  module Actions
    def gem(name, opts={})
      verbose = opts.key?(:verbose) ? opts.delete(:verbose) : true
      version = opts.key?(:version) ? opts.delete(:version) : nil

      parts = ["'#{name}'"]
      parts << "'~> #{version}'" unless version.nil? || version.empty?
      opts.each { |k, v| parts << "#{k}: #{v.inspect}" }
      append_file('Gemfile', "gem #{parts.join(', ')}\n", verbose: verbose)
    end

    def indent(text, num_spaces)
      text.gsub(/^/, 1.upto(num_spaces).map { |_| ' ' }.join)
    end
  end
end
