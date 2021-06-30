# frozen_string_literal: true

RSpec::Matchers.define :have_http_status do |expected|
  match do |response|
    response.status == response_codes[expected]
  end

  failure_message do |response|
    'expected last response status to be ' \
      "#{response_codes.fetch(expected, 'unknown')}, " \
      "but was #{response.status}"
  end

  def response_codes
    {
      ok: 200,
      no_content: 204,
      not_authorized: 401,
      not_found: 404,
      redirect: 302,
      server_error: 500
    }.freeze
  end
end

RSpec::Matchers.define :have_content_type do |expected|
  match do |response|
    response.content_type == content_types[expected]
  end

  failure_message do |response|
    'expected last response to have content type ' \
      "'#{content_types.fetch(expected, 'unknown')}', " \
      "but was '#{response.content_type}'"
  end

  def content_types
    {
      html: 'text/html;charset=utf-8',
      json: 'application/json'
    }.freeze
  end
end

RSpec::Matchers.define :redirect_to do |expected|
  match do |response|
    path(response) == expected
  end

  failure_message do |response|
    "expected last response to redirect to '#{expected}', " \
      "but it redirected to '#{path(response)}'"
  end

  def path(response)
    URI(response.location).path
  end
end
