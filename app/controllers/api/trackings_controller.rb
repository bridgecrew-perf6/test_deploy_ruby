module API
  class TrackingsController < ActionController::Base
    # before_action :set_response_headers

    # TRACKING = {
    #   :ANL => "ANL CONTAINER LINE",
    #   :APL => "APL",
    #   :CMA_CGM => "CMA CGM",
    #   :CNC => "CNC",
    #   :GOLD_STAR => "GOLD STAR LINE LTD",
    #   :MCC => "MCC TRANSPORT",
    #   :OOCL => "OOCL",
    #   :PIL => "PIL",
    #   :PIL_INDO => "PT. PELAYARAN SAMUDERA SELATAN",
    #   :SAFMARINE => "SAFMARINE",
    #   :YANG_MING => "YANG MING"
    # }

    # # GET Method
    # ANL = "https://www.anl.com.au/ebusiness/tracking/search?SearchBy=Booking&search=Search&Reference=%s"
    # APL = "http://homeport.apl.com/gentrack/trackingMain.do?trackInput01=%s"
    # CMA_CGM = "https://www.cma-cgm.com/ebusiness/tracking/search?SearchBy=Booking&search=Search&Reference=%s"
    # CNC = "https://www.cnc-ebusiness.com/ebusiness/tracking/search?SearchBy=Booking&search=Search&Reference=%s"
    # GOLD_STAR = "http://www.goldstarline.com/tracing.aspx?hidSearch=true&hidFromHomePage=false&hidSearchType=1&id=166&l=4&rb=BLNum&submit=Show+Moves&textBLNumber=%s"
    # MCC = "http://www.mcc.com.sg/v2/index.cfm/tracking:main?nr=%s"
    # OOCL = "http://www.oocl.com/Pages/ExpressLink.aspx?eltype=ct&booking_no=%s"
    # PIL = "https://www.pilship.com/--/120.html?search_type=bl&refnumbers=%s"
    # SAFMARINE = "http://mysaf2.safmarine.com/wps/portal/Safmarine/etrackUnregistered?linktype=unreg&queryorigin=Header&queryoriginauto=HeaderNonSecure&searchType=Document&searchNumberString=%s"
    # YANG_MING = "http://www.yangming.com/english/ASP/e-service/track_trace/blconnect.asp?num1=%s"

    # # POST Method, currently not supported
    # EVERGREEN = "http://www.shipmentlink.com/servlet/TDB1_CargoTracking.do"
    # HAMBURG_SUD = "https://ecom.hamburgsud.com/ecom/en/ecommerce_portal/track_trace/track__trace/ep_trackandtrace.xhtml?lang=EN"
    # HANJIN_SHIPPING = "https://www.hanjin.com/hanjin/CUP_HOM_3301.do"
    # KMTC = "http://www.ekmtc.com/CCIT100/searchContainerList.do"
    # KLINE = "http://ecom.kline.com/tracking"
    # SAMUDERA = "https://cts.samudera.com:9600/ifcr-monitoring/applicationMssqlServer/script/home.php"
    # SINOKOR = "http://www.sinokor.co.kr/"
    # SINOTRANS = "http://ebusiness.sinolines.com/ebusiness/CargoTrackingE.aspx"
    # SITC = "http://www.sitcline.com/index.jsp?viewId=menuItem_view_SmiCargoTrack&url=/pages/track/biz/trackCargoTrackSearchNew.jsp"

    def shipment
      # number = params[:number].to_s

      # if shipping_instruction = ShippingInstruction.find_by("booking_no = :booking_no OR master_bl_no = :master_bl_no", 
      #                           booking_no: number, master_bl_no: number)
      #   agent = Mechanize.new { |a| a.history.max_size=1_000_000 }
      #   agent.user_agent = "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.0)"
      #   agent.retry_change_requests = false
      #   agent.follow_meta_refresh = true
      #   agent.idle_timeout = 600

      #   response = begin
      #     case shipping_instruction.carrier
      #     when TRACKING[:ANL]
      #       sprintf(ANL, shipping_instruction.booking_no.presence || shipping_instruction.master_bl_no)
      #     when TRACKING[:APL]
      #       sprintf(APL, shipping_instruction.booking_no)
      #     when TRACKING[:CMA_CGM]
      #       sprintf(CMA_CGM, shipping_instruction.booking_no)
      #     when TRACKING[:CNC]
      #       sprintf(CNC, shipping_instruction.booking_no)
      #     when TRACKING[:GOLD_STAR]
      #       sprintf(GOLD_STAR, shipping_instruction.booking_no)
      #     when TRACKING[:MCC]
      #       sprintf(MCC, shipping_instruction.booking_no)
      #     when TRACKING[:OOCL]
      #       sprintf(OOCL, shipping_instruction.booking_no)
      #     when TRACKING[:PIL], TRACKING[:PIL_INDO]
      #       sprintf(PIL, shipping_instruction.master_bl_no)
      #     when TRACKING[:SAFMARINE]
      #       sprintf(SAFMARINE, shipping_instruction.booking_no)
      #     when TRACKING[:YANG_MING]
      #       sprintf(YANG_MING, shipping_instruction.booking_no)
      #     else
      #       nil
      #     end
      #   end

      #   if response
      #     render_json_response({ success: true, content: response })
      #     return
      #   end
      # end

      # render_json_response({ success: false, content: "Shipment not found." })
      render text: ""
    end

    private
    def set_response_headers
      # headers['Access-Control-Allow-Origin'] = 'interbenualog.com'
      # headers['Access-Control-Expose-Headers'] = 'ETag'
      # headers['Access-Control-Allow-Methods'] = 'GET'
      # headers['Access-Control-Allow-Headers'] = '*,x-requested-with,Content-Type,If-Modified-Since,If-None-Match,Auth-User-Token'
      # headers['Access-Control-Max-Age'] = '86400'
      # headers['Access-Control-Allow-Credentials'] = 'true'
    end

    def render_json_response(the_hash)
      # render status: 200, json: the_hash
    end
  end
end
