# Imagetypers API
require 'net/http'
require 'base64'
require 'json'

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
PROXY_CHECK_ENDPOINT = 'http://captchatypers.com/captchaAPI/GetReCaptchaTextJSON.ashx'
GEETEST_SUBMIT_ENDPOINT = 'http://captchatypers.com/captchaapi/UploadGeeTest.ashx'
GEETEST_RETRIEVE_ENDPOINT = 'http://captchatypers.com/captchaapi/getrecaptchatext.ashx'
RETRIEVE_JSON_ENDPOINT = 'http://captchatypers.com/captchaapi/GetCaptchaResponseJson.ashx'
CAPY_ENDPOINT = 'http://captchatypers.com/captchaapi/UploadCapyCaptchaUser.ashx'
HCAPTCHA_ENDPOINT = 'http://captchatypers.com/captchaapi/UploadHCaptchaUser.ashx'
TIKTOK_ENDPOINT = 'http://captchatypers.com/captchaapi/UploadTikTokCaptchaUser.ashx'

CAPTCHA_ENDPOINT_CONTENT_TOKEN = '/Forms/UploadFileAndGetTextNEWToken.ashx'
CAPTCHA_ENDPOINT_URL_TOKEN = '/Forms/FileUploadAndGetTextCaptchaURLToken.ashx'
RECAPTCHA_SUBMIT_ENDPOINT_TK = '/captchaapi/UploadRecaptchaToken.ashx'
RECAPTCHA_RETRIEVE_ENDPOINT_TK = '/captchaapi/GetRecaptchaTextToken.ashx'
BALANCE_ENDPOINT_TOKEN = '/Forms/RequestBalanceToken.ashx'
BAD_IMAGE_ENDPOINT_TOKEN = '/Forms/SetBadImageToken.ashx'
PROXY_CHECK_ENDPOINT_TOKEN = 'http://captchatypers.com/captchaAPI/GetReCaptchaTextTokenJSON.ashx'
GEETEST_SUBMIT_ENDPOINT_TK = 'http://captchatypers.com/captchaapi/UploadGeeTestToken.ashx'

# user agent used in requests
# ---------------------------
USER_AGENT = 'rubyAPI1.0'

# Imagetypers API class
class ImageTyperzAPI
  def initialize(access_token, affiliate_id = '0', timeout = 60000)
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

  def submit_image(image_path, is_case_sensitive = false, is_math = false, is_phrase = false, digits_only = false, letters_only = false, min_length = 0, max_length = 0)
    data = {}
    image_data = ''
    if !@_username.empty?
      data["username"] = @_username
      data["password"] = @_password
      url = CAPTCHA_ENDPOINT

      # check if not http
      if image_path.start_with? 'http'
        raise 'HTTP URL as captcha image works only if authenticated with access token'
      end

      # check if file exists
      if !File.file?(image_path)
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
        if !File.file?(image_path)
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

    # optional parameters
    if is_case_sensitive
      data['iscase'] = 'true'
    end
    if is_phrase
      data['isphrase'] = 'true'
    end
    if is_math
      data['ismath'] = 'true'
    end

    # digits, letters, or both
    if digits_only
      data['alphanumeric'] = '1'
    elsif letters_only
      data['alphanumeric'] = '2'
    end

    # min, max length
    if min_length != 0
      data['minlength'] = min_length
    end
    if max_length != 0
      data['maxlength'] = max_length
    end

    data['file'] = image_data
    # check for affiliate id
    if !@_affiliateid.empty?
      data['affiliateid'] = @_affiliateid
    end

    # make request
    http = Net::HTTP.new(ROOT_DOMAIN, 80)
    http.read_timeout = @_timeout
    req = Net::HTTP::Post.new(url, @_headers)
    res = http.request(req, URI.encode_www_form(data))
    response_text = res.body # get response body

    # check if error
    if response_text.include?("ERROR:")
      response_err = response_text.split('ERROR:')[1].strip() # get only the
      @_error = response_err
      raise @_error
    end

    # split the response_text for | and return
    response_text.split('|')[0]
  end

  def submit_recaptcha(d)
    page_url = d['page_url']
    sitekey = d['sitekey']
    # params
    data = {
        "action" => "UPLOADCAPTCHA",
        "pageurl" => page_url,
        "googlekey" => sitekey
    }

    if !@_username.empty?
      data["username"] = @_username
      data["password"] = @_password
      url = RECAPTCHA_SUBMIT_ENDPOINT
    else
      data["token"] = @_access_token
      url = RECAPTCHA_SUBMIT_ENDPOINT_TK
    end

    # proxy
    if d.key? 'proxy'
      data['proxy'] = d['proxy']
    end

    # affiliate id
    if @_affiliateid.to_s != '0'
      data["affiliateid"] = @_affiliateid.to_s
    end

    # user agent
    if d.key? 'user_agent'
      data['useragent'] = d['user_agent']
    end

    # v3
    if d.key? 'type'
      data['recaptchatype'] = d['type']
    end
    if d.key? 'v3_action'
      data['captchaaction'] = d['v3_action']
    end
    if d.key? 'v3_min_score'
      data['score'] = d['v3_min_score']
    end
    if d.key? 'data-s'
      data['data-s'] = d['data-s']
    end


    # make request
    http = Net::HTTP.new(ROOT_DOMAIN, 80)
    http.read_timeout = @_timeout
    req = Net::HTTP::Post.new(url, @_headers)
    res = http.request(req, URI.encode_www_form(data))
    response_text = res.body # get response body

    # check if error
    if response_text.include?("ERROR:")
      response_err = response_text.split('ERROR:')[1].strip() # get only the
      @_error = response_err
      raise @_error
    end
    response_text
  end

  def submit_geetest(d)
    d['action'] = 'UPLOADCAPTCHA'
    # user or token ?
    if !@_username.empty?
      d["username"] = @_username
      d["password"] = @_password
      url = GEETEST_SUBMIT_ENDPOINT
    else
      d["token"] = @_access_token
      url = GEETEST_SUBMIT_ENDPOINT_TK
    end

    # affiliate id
    if @_affiliateid.to_s != '0'
      d["affiliateid"] = @_affiliateid.to_s
    end

    # create url
    params = URI.encode_www_form(d)
    url = '%s?%s' % [url, params]

    # make request
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    data = http.get(uri.request_uri)
    response_text = data.body

    # check if error
    if response_text.include?("ERROR:")
      response_err = response_text.split('ERROR:')[1].strip() # get only the
      @_error = response_err
      raise @_error
    end
    response_text
  end

  def submit_capy(d)
    d['action'] = 'UPLOADCAPTCHA'
    d['captchatype'] = '12'
    # user or token ?
    if !@_username.empty?
      d["username"] = @_username
      d["password"] = @_password
    else
      d["token"] = @_access_token
    end

    url = CAPY_ENDPOINT

    # affiliate id
    if @_affiliateid.to_s != '0'
      d["affiliateid"] = @_affiliateid.to_s
    end

    # create url
    params = URI.encode_www_form(d)
    url = '%s?%s' % [url, params]

    # make request
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    data = http.get(uri.request_uri)
    response_text = data.body

    # check if error
    if response_text.include?("ERROR:")
      response_err = response_text.split('ERROR:')[1].strip() # get only the
      @_error = response_err
      raise @_error
    end
    (JSON.parse response_text)[0]['CaptchaId']
  end

  def submit_tiktok(d)
    d['action'] = 'UPLOADCAPTCHA'
    d['captchatype'] = '10'
    # user or token ?
    if !@_username.empty?
      d["username"] = @_username
      d["password"] = @_password
    else
      d["token"] = @_access_token
    end

    url = TIKTOK_ENDPOINT

    # affiliate id
    if @_affiliateid.to_s != '0'
      d["affiliateid"] = @_affiliateid.to_s
    end

    # create url
    params = URI.encode_www_form(d)
    url = '%s?%s' % [url, params]

    # make request
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    data = http.get(uri.request_uri)
    response_text = data.body

    # check if error
    if response_text.include?("ERROR:")
      response_err = response_text.split('ERROR:')[1].strip() # get only the
      @_error = response_err
      raise @_error
    end
    (JSON.parse response_text)[0]['CaptchaId']
  end

  def submit_hcaptcha(d)
    d['action'] = 'UPLOADCAPTCHA'
    d['captchatype'] = '11'
    # user or token ?
    if !@_username.empty?
      d["username"] = @_username
      d["password"] = @_password
    else
      d["token"] = @_access_token
    end

    url = HCAPTCHA_ENDPOINT

    # affiliate id
    if @_affiliateid.to_s != '0'
      d["affiliateid"] = @_affiliateid.to_s
    end

    # create url
    params = URI.encode_www_form(d)
    url = '%s?%s' % [url, params]

    # make request
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    data = http.get(uri.request_uri)
    response_text = data.body

    # check if error
    if response_text.include?("ERROR:")
      response_err = response_text.split('ERROR:')[1].strip() # get only the
      @_error = response_err
      raise @_error
    end
    (JSON.parse response_text)[0]['CaptchaId']
  end

  def retrieve_response(captcha_id)
    # params
    data = {
        "action" => "GETTEXT",
        "captchaid" => captcha_id,
    }

    if !@_username.empty?
      data["username"] = @_username
      data["password"] = @_password
    else
      data["token"] = @_access_token
    end

    # make request
    http = Net::HTTP.new(ROOT_DOMAIN, 80)
    http.read_timeout = @_timeout
    req = Net::HTTP::Post.new(RETRIEVE_JSON_ENDPOINT, @_headers)
    res = http.request(req, URI.encode_www_form(data))
    response_text = res.body # get response body

    # check if error
    if response_text.include?("ERROR:") and response_text.split('|').length != 2
      response_err = response_text.split('ERROR:')[1].strip().split('"')[0] # get only the
      @_error = response_err
      raise @_error
    end
    begin
      js = (JSON.parse response_text)[0]
      status = js['Status']
      if status  == 'Pending'
        return nil
      end
      return js
    rescue
      raise 'invalid JSON response from server: ' + response_text + ', check your input'
    end
  end

  # get accounts balance
  def account_balance
    data = {
        "action" => "REQUESTBALANCE",
        "submit" => "Submit"
    }

    if !@_username.empty?
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
    response_text = res.body # get response body

    # check if error
    if response_text.include?("ERROR:")
      response_err = response_text.split('ERROR:')[1].strip() # get only the
      @_error = response_err
      raise @_error
    end

    return "$#{response_text}" # all good, return
  end

  # set captcha bad
  def set_captcha_bad(captcha_id)
    data = {
        "action" => "SETBADIMAGE",
        "imageid" => captcha_id.to_s,
        "submit" => "Submissssst"
    }

    if !@_username.empty?
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
    response_text = res.body # get response body

    # check if error
    if response_text.include?("ERROR:")
      response_err = response_text.split('ERROR:')[1].strip # get only the
      @_error = response_err
      raise @_error
    end
    response_text # all good, return
  end
end

