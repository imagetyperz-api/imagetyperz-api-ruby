# Imagetypers API
require 'net/http'
require 'base64'

# endpoints
# -------------------------------------------------------------------------------------------
ROOT_DOMAIN = 'captchatypers.com'
# endpoints
# -------------------------------------------------------------------------------------------
CAPTCHA_ENDPOINT = '/Forms/UploadFileAndGetTextNEW.ashx'
RECAPTCHA_SUBMIT_ENDPOINT = '/captchaapi/UploadRecaptchaV1.ashx'
RECAPTCHA_RETRIEVE_ENDPOINT = '/captchaapi/GetRecaptchaText.ashx'
BALANCE_ENDPOINT = '/Forms/RequestBalance.ashx'
BAD_IMAGE_ENDPOINT = '/Forms/SetBadImage.ashx'

CAPTCHA_ENDPOINT_CONTENT_TOKEN = '/Forms/UploadFileAndGetTextNEWToken.ashx'
CAPTCHA_ENDPOINT_URL_TOKEN = '/Forms/FileUploadAndGetTextCaptchaURLToken.ashx'
RECAPTCHA_SUBMIT_ENDPOINT_TK = '/captchaapi/UploadRecaptchaToken.ashx'
RECAPTCHA_RETRIEVE_ENDPOINT_TK = '/captchaapi/GetRecaptchaTextToken.ashx'
BALANCE_ENDPOINT_TOKEN = '/Forms/RequestBalanceToken.ashx'
BAD_IMAGE_ENDPOINT_TOKEN = '/Forms/SetBadImageToken.ashx'

# user agent used in requests
# ---------------------------
USER_AGENT = 'rubyAPI1.0'

# captcha class
class Captcha
  def initialize(response)
    parse_response response   # parse response
  end
  def parse_response(response)
    s = response.split('|')
    if s.length < 2
      raise "cannot parse response from server: #{response}"
    end
    # at this point, we have the right length, save it to obj

    @_captcha_id = s[0]
    s.shift(1)
    @_text = s.join('|')
  end

  def captcha_id
    @_captcha_id
  end

  def text
    @_text
  end
end

# recaptcha class
class Recaptcha
  def initialize(captcha_id)
    @_captcha_id = captcha_id
  end

  def set_response(response)
    @_response = response
  end
  def response
    @_response
  end
  def captcha_id
    @_captcha_id
  end
end

# Imagetypers API class
class ImageTyperzAPI
  def initialize(access_token, affiliate_id = '0', timeout = 60)
    @_access_token = access_token
    @_affiliateid = affiliate_id.to_s
    @_timeout = timeout.to_i
    @_headers = {"User-Agent" => USER_AGENT}
    @_username = ""
    @_password = ""
  end

  # set username and password (legacy)
  def set_user_and_password(user, password)
    @_username = user
    @_password = password
  end

  # get accounts balance
  def account_balance
    data = {
        "action" => "REQUESTBALANCE",
        "submit" => "Submit"
    }

    if ! @_username.empty?
      data["username"] = @_username
      data["password"] = @_password
      url = BALANCE_ENDPOINT
    else
      data["token"] = @_access_token
      url = BALANCE_ENDPOINT_TOKEN
    end

    # make request
    http = Net::HTTP.new(ROOT_DOMAIN, 80)
    http.read_timeout = @_timeout
    req = Net::HTTP::Post.new(url, @_headers)
    res = http.request(req, URI.encode_www_form(data))
    response_text = res.body    # get response body

    # check if error
    if response_text.include?("ERROR:")
      response_err = response_text.split('ERROR:')[1].strip()   # get only the
      @_error = response_err
      raise @_error
    end

    return "$#{response_text}"    # all good, return
  end

  # solve normal captcha
  def solve_captcha(image_path, case_sensitive = false)
    data = {}
    image_data = ''
    if ! @_username.empty?
      data["username"] = @_username
      data["password"] = @_password
      url = CAPTCHA_ENDPOINT

      # check if not http
      if image_path.start_with? 'http'
        raise 'HTTP URL as captcha image works only if authenticated with access token'
      end

      # check if file exists
      if ! File.file?(image_path)
        raise 'given captcha file does not exist'
      end
      # get it as b64
      content = File.binread(image_path)
      image_data = Base64.encode64(content)
    else
      # check if URL
      if image_path.start_with? 'http'
        url = CAPTCHA_ENDPOINT_URL_TOKEN
        image_data = image_path
      else
        # it's image
        url = CAPTCHA_ENDPOINT_CONTENT_TOKEN
        # check if file exists
        if ! File.file?(image_path)
          raise 'given captcha file does not exist'
        end
        # get it as b64
        content = File.binread(image_path)
        image_data = Base64.encode64(content)
      end
      # set token
      data["token"] = @_access_token
    end

    data['action'] = 'UPLOADCAPTCHA'
    data['chkCase'] = case_sensitive ? '1' : '0'
    data['file'] = image_data
    # check for affiliate id
    if ! @_affiliateid.empty?
      data['affiliateid'] = @_affiliateid
    end

    # make request
    http = Net::HTTP.new(ROOT_DOMAIN, 80)
    http.read_timeout = @_timeout
    req = Net::HTTP::Post.new(url, @_headers)
    res = http.request(req, URI.encode_www_form(data))
    response_text = res.body    # get response body

    # check if error
    if response_text.include?("ERROR:")
      response_err = response_text.split('ERROR:')[1].strip()   # get only the
      @_error = response_err
      raise @_error
    end

    # split the response_text for | and return
    return response_text.split('|')[1]
  end

  # submit recaptcha to server for completion
  def submit_recaptcha(page_url, sitekey)
    # params
    data = {
        "action" => "UPLOADCAPTCHA",
        "pageurl" => page_url,
        "googlekey" => sitekey
    }

    if ! @_username.empty?
      data["username"] = @_username
      data["password"] = @_password
      url = RECAPTCHA_SUBMIT_ENDPOINT
    else
      data["token"] = @_access_token
      url = RECAPTCHA_SUBMIT_ENDPOINT_TK
    end

    # if proxy was set, add it to request
    if @_proxy
      data['proxy'] = @_proxy['proxy']
    end

    # affiliate id
    if @_affiliateid.to_s != '0'
      data["affiliateid"] = @_affiliateid.to_s
    end

    # make request
    http = Net::HTTP.new(ROOT_DOMAIN, 80)
    http.read_timeout = @_timeout
    req = Net::HTTP::Post.new(url, @_headers)
    res = http.request(req, URI.encode_www_form(data))
    response_text = res.body    # get response body

    # check if error
    if response_text.include?("ERROR:")
      response_err = response_text.split('ERROR:')[1].strip()   # get only the
      @_error = response_err
      raise @_error
    end

    @_recaptcha = Recaptcha.new response_text   # init recaptcha obj
    return @_recaptcha.captcha_id     # return id
  end

  # retrieve recaptcha response using id
  def retrieve_recaptcha(captcha_id)
    # params
    data = {
        "action" => "GETTEXT",
        "captchaid" => captcha_id,
    }

    if ! @_username.empty?
      data["username"] = @_username
      data["password"] = @_password
      url = RECAPTCHA_RETRIEVE_ENDPOINT
    else
      data["token"] = @_access_token
      url = RECAPTCHA_RETRIEVE_ENDPOINT_TK
    end

    # make request
    http = Net::HTTP.new(ROOT_DOMAIN, 80)
    http.read_timeout = @_timeout
    req = Net::HTTP::Post.new(url, @_headers)
    res = http.request(req, URI.encode_www_form(data))
    response_text = res.body    # get response body

    # check if error
    if response_text.include?("ERROR:")
      response_err = response_text.split('ERROR:')[1].strip()   # get only the
      @_error = response_err
      raise @_error
    end

    @_recaptcha.set_response response_text    # set response to recaptcha obj
    return @_recaptcha.response   # return response
  end

  # tells if recaptcha is still in progress
  def in_progress(captcha_id)
    begin
      retrieve_recaptcha captcha_id     # try to retrieve it
      return false      # no error, it's done
    rescue => details
      if details.message.include? 'NOT_DECODED'
        return true
      end

      raise   # re-raise if different error
    end
  end

  # set captcha bad
  def set_captcha_bad(captcha_id)
    data = {
        "action" => "SETBADIMAGE",
        "imageid" => captcha_id.to_s,
        "submit" => "Submissssst"
    }

    if ! @_username.empty?
      data["username"] = @_username
      data["password"] = @_password
      url = BAD_IMAGE_ENDPOINT
    else
      data["token"] = @_access_token
      url = BAD_IMAGE_ENDPOINT_TOKEN
    end

    # make request
    http = Net::HTTP.new(ROOT_DOMAIN, 80)
    http.read_timeout = @_timeout
    req = Net::HTTP::Post.new(url, @_headers)
    res = http.request(req, URI.encode_www_form(data))
    response_text = res.body    # get response body

    # check if error
    if response_text.include?("ERROR:")
      response_err = response_text.split('ERROR:')[1].strip()   # get only the
      @_error = response_err
      raise @_error
    end

    return response_text    # all good, return
  end

  # set recaptcha proxy
  def set_recaptcha_proxy(proxy)
    @_proxy = {
        "proxy" => proxy
    }
  end

  # captcha text
  def captcha_text
    if @_captcha
      return @_captcha.text
    else
      return ''
    end
  end

  # captcha id
  def captcha_id
    if @_captcha
      return @_captcha.captcha_id
    else
      return ''
    end
  end

  # recaptcha id
  def recaptcha_id
    if @_recaptcha
      return @_recaptcha.captcha_id
    else
      return ''
    end
  end

  # recaptcha response
  def recaptcha_response
    if @_recaptcha
      return @_recaptcha.response
    else
      return ''
    end
  end

  # error
  def error
    @_error
  end
end

