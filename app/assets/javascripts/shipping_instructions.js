var readySI;
readySI = function(){
  'use strict';
  // $(function(){
  //   if($("#shipping_instruction_gw").val() != ''){
  //     $("#shipping_instruction_gw").val(number_format($("#shipping_instruction_gw").val().split(" ")[0]));
  //     $("#shipping_instruction_gw").val(money_with_decimal_format($("#shipping_instruction_gw").val()));
  //     $("#shipping_instruction_gw").val($("#shipping_instruction_gw").val() + " KGS");
  //   }

  //   if($("#shipping_instruction_nw").val() != ''){
  //     $("#shipping_instruction_nw").val(number_format($("#shipping_instruction_nw").val().split(" ")[0]));
  //     $("#shipping_instruction_nw").val(money_with_decimal_format($("#shipping_instruction_nw").val()));
  //     $("#shipping_instruction_nw").val($("#shipping_instruction_nw").val() + " KGS");
  //   }

  //   if($("#shipping_instruction_measurement").val() != ''){
  //     $("#shipping_instruction_measurement").val(number_format($("#shipping_instruction_measurement").val().split(" ")[0]));
  //     $("#shipping_instruction_measurement").val(volume_with_decimal_format($("#shipping_instruction_measurement").val()));
  //     $("#shipping_instruction_measurement").val($("#shipping_instruction_measurement").val() + " M3");
  //   }
  // });

  $("#shipping_instruction_gw").livequery(function () {
    $(this).focus(function(){
      $(this).val(number_format($(this).val().split(" ")[0]));
      // alert($(this).val());
    })
    .focusout(function(){
      $(this).val(money_with_decimal_format($(this).val()));
      $(this).val($(this).val() + " KGS");
      alert($(this).val());
    })
  })

  $("#shipping_instruction_nw").livequery(function () {
    $(this).focus(function(){
      $(this).val(number_format($(this).val().split(" ")[0]));
    })
    .focusout(function(){
      $(this).val(money_with_decimal_format($(this).val()));
      $(this).val($(this).val() + " KGS");
    })
  })

  $("#shipping_instruction_measurement").livequery(function () {
    $(this).focus(function(){
      $(this).val(number_format($(this).val().split(" ")[0]));
    })
    .focusout(function(){
      $(this).val(volume_with_decimal_format($(this).val()));
      $(this).val($(this).val() + " M3");
    })
  })

  $("#other_detail").change(function(){
    if($(this).val() != '')
      $(this).prev().val("OTHER=" + $(this).val().toUpperCase());
    else
      $(this).prev().val('');
  })

  // $('#country_of_origin').typeahead({
  //   source: [
  //   <% @countries.each do |c| %>
  //   "<%= c.name %>",
  //   <% end %>
  //   ]
  // });
  // // $("#shipping_instruction_carrier").typeahead({
  // //   source: [
  // //   <%# @carriers.each do |c| %>
  // //   "<%# c.name %>",
  // //   <%# end %>
  // //   ]
  // // })
  $("#shipping_instruction_place_of_receipt").change(function(){
    $("#shipping_instruction_port_of_loading").val($(this).val());
  })
  // $("#shipping_instruction_port_of_discharge").change(function(){
  //   $("#shipping_instruction_final_destination").val($(this).val());
  // });
  // $("#shipping_instruction_vessels_attributes_0_vessel_name").livequery(function(){
  //   $(this).change(function(){
  //     $("#shipping_instruction_feeder_vessel").val($(this).val());
  //   });
  // });
  // $("#shipping_instruction_vessels_attributes_1_vessel_name").livequery(function(){
  //   $(this).change(function(){
  //     $("#shipping_instruction_connection_vessel").val($(this).val());
  //   });
  // });
  $("#find_shipper").click(function(e){
    e.preventDefault();
  });
  $("#find_consignee").click(function(e){
    e.preventDefault();
  });

  $(".container-fluid input[type=text], .container-fluid textarea").on("change", function(){
    $(this).val($(this).val().toUpperCase())
  });

  $("#shipping_instruction_shipper_name, #shipping_instruction_consignee_name, #shipping_instruction_notify_party").keypress(function(e){
    var t = $(this);
    var length = t.val().substr(0, t.selectionStart).split("\n").length;

    if(length >= 6 && ((e.keyCode || e.which) == 13)){
      e.preventDefault();
    }
  });

  $("#shipping_instruction_freight").keypress(function(e){
    var t = $(this);
    var length = t.val().substr(0, t.selectionStart).split("\n").length;

    if(length >= 2 && ((e.keyCode || e.which) == 13)){
      e.preventDefault();
    }
  });

  $("#shipping_instruction_marks_no").keypress(function(e){
    var t = $(this);
    var length = t.val().substr(0, t.selectionStart).split("\n").length;

    if(length >= 38 && ((e.keyCode || e.which) == 13)){
      e.preventDefault();
    }
  });

  $("#shipping_instruction_description_packages").keypress(function(e){
    var t = $(this);
    var length = t.val().substr(0, t.selectionStart).split("\n").length;

    if(length >= 38 && ((e.keyCode || e.which) == 13)){
      e.preventDefault();
    }
  });

  $("#shipping_instruction_special_instructions, #shipping_instruction_container_no, #shipping_instruction_container_no_2, #shipping_instruction_dimension").keypress(function(e){
    var t = $(this);
    var length = t.val().substr(0, t.selectionStart).split("\n").length;

    if(length >= 5 && ((e.keyCode || e.which) == 13)){
      e.preventDefault();
    }
  });

  $("#shipping_instruction_container_no, #shipping_instruction_container_no_2").on("focusout", function(){
    var t = $(this);
    var arr = t.val().substr(0, t.selectionStart).split("\n");
    var newArr = arr.slice(0, 5);
    t.val(newArr.join("\n"))
  })

  $("#shipping_instruction_hs_code").keypress(function(e){
    var t = $(this);
    var length = t.val().substr(0, t.selectionStart).split("\n").length;

    if(length >= 3 && ((e.keyCode || e.which) == 13)){
      e.preventDefault();
    }
  });

  // $("#volume input[type=text]").focusout(function(){
  //   var objArray = [
  //     <% Container.all.each do |c| %>
  //       "<%= c.container_type %>",
  //     <% end %>
  //   ];
  //   var tmp = new Array();
  //   var freight = "";

  //   $("#volume input[type=text]").each(function(index, value){
  //     var numb = parseInt($(this).val());

  //     if(index == 0 && !isNaN(numb) && numb != 0)
  //       freight = "LCL - LCL";

  //     if(index > 0 && !isNaN(numb) && numb != 0)
  //       freight = "FCL - FCL";

  //     if(!isNaN(numb) && numb != 0)
  //     {
  //       if(index == 0)
  //         tmp.push(objArray[index])
  //       else
  //         tmp.push(numb + "x" + objArray[index])
  //     }
  //   });
  //   // $("#shipping_instruction_description_packages").val(tmp.join(' & ') + " CONTAINER STC: \n");
  //   var desc_text = $("#shipping_instruction_description_packages").val().substr(0, $("#shipping_instruction_description_packages").selectionStart).split("\n");
  //   type = $("#shipping_instruction_si_containers_attributes_5_volum").val();
  //   desc_text[0] = tmp.join(' & ') + ((type == "") ? "":" "+type) + " CONTAINER STC: ";
  //   $("#shipping_instruction_description_packages").val(desc_text.join("\n"));
  //   $("#shipping_instruction_freight").val("FREIGHT PREPAID\n" + freight);
  // });

  
  $("#import_si_data").on("click", function(e) {
    e.preventDefault();
    // alert("Import start...");
    $.getJSON($(this).attr('href')+'&ibl_ref='+$('#ibl_ref').val(), function(data){
      if (data == "") {
        alert("No data to be imported");
      } else {

        $('#shipping_instruction_shipper_id').val(data.shipper_id);
        $('#shipping_instruction_consignee_id').val(data.consignee_id);
        $('#shipping_instruction_shipper_name').val(data.shipper_name);
        $('#shipping_instruction_consignee_name').val(data.consignee_name);
        $('#shipping_instruction_notify_party').val(data.notify_party);
        $('#shipping_instruction_country_of_origin').val(data.country_of_origin);
        $('#shipping_instruction_carrier').val(data.carrier);
        $('#shipping_instruction_pic').val(data.pic);
        // $('#shipping_instruction_feeder_vessel').val(data.feeder_vessel);
        // $('#shipping_instruction_connection_vessel').val(data.connection_vessel);
        $('#shipping_instruction_feeder_vessel').val('');
        $('#shipping_instruction_connection_vessel').val('');
        $('#shipping_instruction_place_of_receipt').val(data.place_of_receipt);
        $('#shipping_instruction_port_of_loading').val(data.port_of_loading);
        $('#shipping_instruction_port_of_transhipment').val(data.port_of_transhipment);
        $('#shipping_instruction_port_of_discharge').val(data.port_of_discharge);
        $('#shipping_instruction_final_destination').val(data.final_destination);
        $('#shipping_instruction_no_of_obl').val(data.no_of_obl);
        // if(data.si_date != null)
        //   $('#shipping_instruction_si_date').val($.datepicker.formatDate('dd MM yy', new Date(data.si_date)));
        $('#shipping_instruction_si_date').val($.datepicker.formatDate('dd MM yy', new Date()));
        $('#shipping_instruction_marks_no').val(data.marks_no);
        $('#shipping_instruction_description_packages').val(data.description_packages);
        $('#shipping_instruction_gw').val(data.gw);
        $('#shipping_instruction_nw').val(data.nw);
        $('#shipping_instruction_measurement').val(data.measurement);
        $('#shipping_instruction_dimension').val(data.dimension);
        $('#shipping_instruction_freight').val(data.freight);
        $('#shipping_instruction_freight_details').val(data.freight_details);
        $('#shipping_instruction_special_instructions').val(data.special_instructions);
        // $('#shipping_instruction_container_no').val(data.container_no);
        // $('#shipping_instruction_container_no_2').val(data.container_no_2);
        // $('#shipping_instruction_peb_no').val(data.peb_no);
        // if(data.inst_date != null)
        //   $('#shipping_instruction_inst_date').val($.datepicker.formatDate('dd MM yy', new Date(data.inst_date)));
        // $('#shipping_instruction_kpbc').val(data.kpbc);
        $('#shipping_instruction_container_no').val('');
        $('#shipping_instruction_container_no_2').val('');
        $('#shipping_instruction_peb_no').val('');
        $('#shipping_instruction_inst_date').val('');
        $('#shipping_instruction_kpbc').val('');

        $('#shipping_instruction_hs_code').val(data.hs_code);
        $('#shipping_instruction_shipper_reference').val(data.shipper_reference);
        $('#shipping_instruction_status').val(data.status);
        $('#shipping_instruction_order_type').val(data.order_type);
        // $('#shipping_instruction_booking_no').val(data.booking_no);
        // $('#shipping_instruction_master_bl_no').val(data.master_bl_no);
        $('#shipping_instruction_booking_no').val('');
        $('#shipping_instruction_master_bl_no').val('');

        $('#shipping_instruction_trade').val(data.trade);
        $('#shipping_instruction_handle_by').val(data.handle_by);

        $('.shipping_instruction_order_type_details').prop('checked', false);
        // $('#shipping_instruction_order_type_details').val(data.order_type_details);
        $('.shipping_instruction_order_type_details').each(function () {
          $(this).prop("checked", ($.inArray($(this).val(), data.order_type_details) != -1));
        });

        if (data.order_type_details[data.order_type_details.length - 1].indexOf("OTHER") != -1 ){
          $('.shipping_instruction_order_type_details.other').prop('checked', true);
          $('#other_detail').val(data.order_type_details[data.order_type_details.length - 1].split("=")[1]);
        }

        $('.vessel-group a').click();
        $('.vessel-group:not(".hidden"):first .vessel_name').val('');
        $('.vessel-group:not(".hidden"):first .etd_no').val('');
        $('.vessel-group:not(".hidden"):first .etd_date').val('');
        $('.vessel-group:not(".hidden"):first .eta_no').val('');
        $('.vessel-group:not(".hidden"):first .eta_date').val('');
        // alert(data.vessels);
        $.each( data.vessels, function( key, value ) {
          // alert( key + ": " + value );
          $('.vessel-group:not(".hidden"):last .vessel_name').val(value.vessel_name);
          $('.vessel-group:not(".hidden"):last .etd_no').val(value.etd_no);
          $('.vessel-group:not(".hidden"):last .etd_date').val(value.etd_date);
          $('.vessel-group:not(".hidden"):last .eta_no').val(value.eta_no);
          $('.vessel-group:not(".hidden"):last .eta_date').val(value.eta_date);
          add_vessel_fields();
        });
        // add_vessel_fields();

        $('.shipping_instruction_si_containers_volum').val('');
        $.each( data.si_containers, function( key, value ) {
          var container_id = $('.shipping_instruction_si_containers_container_id[value='+value.container_id+']').attr('id').split("_")[5];
          $('#shipping_instruction_si_containers_attributes_'+container_id+'_volum').val(value.volum);
        });
        $(".vessel_name").change();
    //     var row_count = $("#revenue-description").find("tbody tr").length;
    //     if (data.length > row_count) {
    //       for (var i = 0; i < (data.length - row_count); i++)
    //         add_revenue_fields();
    //       add_revenue_fields();
    //       $("#import_cnr_data").trigger("click");
    //       return;
    //     }

    //     var key = "cost_revenue_cost_revenue_items_attributes_";

    //     for (var index in data) {
    //       var id = "#" + key + index;
    //       $(id + "_description").val(data[index].description);
    //       $(id + "_selling_usd").val(accounting.formatMoney(data[index].selling.usd, "", 2, ",", ".")).trigger("focusout");
    //       $(id + "_selling_idr").val(accounting.formatMoney(data[index].selling.idr, "", 2, ",", ".")).trigger("focusout");
    //       $(id + "_buying_usd").val(accounting.formatMoney(data[index].buying.usd, "", 2, ",", ".")).trigger("focusout");
    //       $(id + "_buying_idr").val(accounting.formatMoney(data[index].buying.idr, "", 2, ",", ".")).trigger("focusout");
        // }

        alert("Import done...");
      }
    });
  });

  $('.vessel-group:not(".hidden") .vessel_name').livequery(function(){
    $(this).change(function(){
      // $("#shipping_instruction_feeder_vessel").val($('.vessel-group:not(".hidden"):first .vessel_name').val());
      $(".feeder_vessel").val($('.vessel-group:not(".hidden"):first .vessel_name').val());
      // $("#shipping_instruction_connection_vessel").val($('.vessel-group:not(".hidden"):eq(1) .vessel_name').val());
    });
  });
}