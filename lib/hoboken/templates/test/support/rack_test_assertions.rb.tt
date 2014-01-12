module Rack::Test::Assertions
  RESPONSE_CODES = {
    :ok             => 200,
    :not_authorized => 401,
    :not_found      => 404,
    :redirect       => 302
  }

  CONTENT_TYPES = {
    :json => "application/json;charset=utf-8",
    :html => "text/html;charset=utf-8"
  }

  def assert_body_contains(expected, message=nil)
    msg = build_message(message, "expected body to contain <?>\n#{last_response.body}", expected)
    assert_block(msg) do
      last_response.body.include?(expected)
    end
  end

  def assert_content_type(content_type)
    unless CONTENT_TYPES.keys.include?(content_type)
      raise ArgumentError, "unrecognized content_type (#{content_type})"
    end

    assert_equal CONTENT_TYPES[content_type], last_response.content_type
  end

  def assert_flash(type=:notice, message=nil)
    msg = build_message(message, "expected <?> flash to exist, but was nil", type.to_s)
    assert_block(msg) do
      last_request.env['rack.session']['flash']
    end
  end

  def assert_flash_message(expected, type=:notice, message=nil)
    assert_flash(type, message)
    flash = last_request.env['rack.session']['flash'][type.to_s]
    msg = build_message(message, "expected flash to be <?> but was <?>", expected, flash)
    assert_block(msg) do
      expected == flash
    end
  end

  def assert_has_session(message=nil)
    msg = build_message(message, "expected a valid session")
    assert_block(msg) do
      last_request.env["rack.session"]
    end
  end

  def assert_session_has_key(key, message=nil)
    assert_has_session
    msg = build_message(message, "expected session to have key named <?>", key)
    assert_block(msg) do
      last_request.env["rack.session"].keys.include?(key.to_s)
    end
  end

  def assert_session(key, expected, message=nil)
    assert_session_has_key(key)
    actual = last_request.env["rack.session"][key.to_s]
    msg = build_message(message, "expected session key <?> to be <?>, but was <?>", key, expected, actual)
    assert_block(msg) do
      expected == actual
    end
  end

  def assert_response(expected, message=nil)
    status = last_response.status
    msg = build_message(
      message,
      "expected last response to be <?> but was <?>",
      "#{RESPONSE_CODES[expected]}:#{expected}",
      "#{status}:#{RESPONSE_CODES.key(status)}"
    )

    assert_block(msg) do
      status == RESPONSE_CODES[expected]
    end
  end

  def assert_redirected_to(expected, msg=nil)
    assert_response(:redirect)
    actual = URI(last_response.location).path
    msg = build_message(message, "expected to be redirected to <?> but was <?>", expected, actual)

    assert_block(msg) do
      expected == actual
    end
  end
end
