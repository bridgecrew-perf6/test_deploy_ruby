function add_carrier_fields() {
  var count = $("table tbody tr").length;
  var number = $("table tbody tr:not(.hidden)").length;

  var tmp = '' +
  '<tr>' +
    '<td align="center">' + (number + 1) + '</td>' +
    '<td>' +
    '<input type="text" value="" name="carrier[carrier_items_attributes][' + count + '][description]" id="carrier_carrier_items_attributes_' + count + '_description" class="carrier_description carrier_field" autocomplete="off">' +
    '<input type="hidden" name="carrier[carrier_items_attributes][' + count + '][_destroy]" id="carrier_carrier_items_attributes_' + count + '__destroy" class="span12">' +
    '<a title="Remove" tabindex="-1" href="#" onclick="remove_revenue_fields(this); return false;"><i class="icon-remove-sign"></i></a>' +
    '</td>' +
    '<td><input type="text" value="0" name="carrier[carrier_items_attributes][' + count + '][amount_usd]" id="carrier_carrier_items_attributes_' + count + '_amount_usd" class="carrier_field money_text amount_usd" autocomplete="off"></td>' +
    '<td><input type="text" value="0" name="carrier[carrier_items_attributes][' + count + '][amount_idr]" id="carrier_carrier_items_attributes_' + count + '_amount_idr" class="carrier_field money_text amount_idr" autocomplete="off"></td>' +
  '</tr>';

  $("table tbody").append(tmp);
}

function remove_carrier_fields(element) {
  $(element).parent().parent().addClass("hidden");
  $(element).prev('input[type=hidden]').val('1');

  count = 0;
  $("#carrier-description table tbody tr").each(function () {
    if (!$(this).hasClass("hidden")) {
      count++;
      $(this).find("td:eq(0)").text(count);
    }
  });
}

function add_shipper_fields() {
  var count = $("table tbody tr").length;
  var number = $("table tbody tr:not(.hidden)").length;

  var tmp = '' +
  '<tr>' +
    '<td align="center">' + (number + 1) + '</td>' +
    '<td>' +
    '<input type="text" value="" name="shipper[shipper_items_attributes][' + count + '][description]" id="shipper_shipper_items_attributes_' + count + '_description" class="shipper_description shipper_field" autocomplete="off">' +
    '<input type="hidden" name="shipper[shipper_items_attributes][' + count + '][_destroy]" id="shipper_shipper_items_attributes_' + count + '__destroy" class="span12">' +
    '<a title="Remove" tabindex="-1" href="#" onclick="remove_revenue_fields(this); return false;"><i class="icon-remove-sign"></i></a>' +
    '</td>' +
    '<td><input type="text" value="0" name="shipper[shipper_items_attributes][' + count + '][amount_usd]" id="shipper_shipper_items_attributes_' + count + '_amount_usd" class="shipper_field money_text amount_usd" autocomplete="off"></td>' +
    '<td><input type="text" value="0" name="shipper[shipper_items_attributes][' + count + '][amount_idr]" id="shipper_shipper_items_attributes_' + count + '_amount_idr" class="shipper_field money_text amount_idr" autocomplete="off"></td>' +
  '</tr>';

  $("table tbody").append(tmp);
}

function remove_shipper_fields(element) {
  $(element).parent().parent().addClass("hidden");
  $(element).prev('input[type=hidden]').val('1');

  count = 0;
  $("#shipper-description table tbody tr").each(function () {
    if (!$(this).hasClass("hidden")) {
      count++;
      $(this).find("td:eq(0)").text(count);
    }
  });
}

function add_sell_invoice_fields() {
  var table = $(".invoice-table");
  var count = $(".invoice-table tbody tr").length;
  var number = $(".invoice-table tbody tr:not(.hidden)").length;
  var invoice_count = 0;

  var attr1 = 'bill_of_lading_invoices_attributes';
  var attr2 = 'bill_of_lading_items_attributes';
  var base = 'calculate_invoice';

  table.each(function(index){
    count = $(this).find("tbody tr").length;
    invoice_count = index;
    number = $(this).find("tbody tr:not(.hidden)").length;  
    var tmp= '' +
    '<tr class="active">' +
      '<td class="hidden"></td>' +
      '<td>' +
        '<input type="text" name="' + base + '[' + attr1 + '][' + invoice_count + '][' + attr2 + '][' + count + '][description]" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_' + attr2 + '_' + count + '_description" class="invoice_description invoice_field" autocomplete="off">' +
        '<input type="hidden" name="' + base + '[' + attr1 + '][' + invoice_count + '][' + attr2 + '][' + count + '][_destroy]" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_' + attr2 + '_' + count + '__destroy" class="span12">' +
        '<a title="Remove" href="#" tabindex="-1" onclick="remove_sell_cost_invoice_fields(this); return false;" class="remove_invoice_description"><i class="icon-remove-sign"></i></a>' +
        '<input type="hidden" value="active" name="' + base + '[' + attr1 + '][' + invoice_count + '][' + attr2 + '][' + count + '][item_type]" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_' + attr2 + '_' + count + '_item_type" class="span12 item_type">' +
      '</td>' +
      '<td class="text-right"><input type="text" name="' + base + '[' + attr1 + '][' + invoice_count + '][' + attr2 + '][' + count + '][volume]" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_' + attr2 + '_' + count + '_volume" class="invoice_field invoice_volume volume_text volume" autocomplete="off"></td>' +
      '<td><input type="text" name="' + base + '[' + attr1 + '][' + invoice_count + '][' + attr2 + '][' + count + '][amount_usd]" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_' + attr2 + '_' + count + '_amount_usd" class="invoice_field money_text amount_usd" autocomplete="off"></td>' +
      '<td><input type="text" name="' + base + '[' + attr1 + '][' + invoice_count + '][' + attr2 + '][' + count + '][amount_idr]" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_' + attr2 + '_' + count + '_amount_idr" class="invoice_field money_text amount_idr" autocomplete="off"></td>' +
      '<td class="text-right"><input type="text" name="' + base + '[' + attr1 + '][' + invoice_count + '][' + attr2 + '][' + count + '][total]" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_' + attr2 + '_' + count + '_total" disabled="disabled" class="invoice_field money_text total" autocomplete="off"></td>' +
      '<td class="text-right"><input type="text" name="' + base + '[' + attr1 + '][' + invoice_count + '][' + attr2 + '][' + count + '][total_after_tax]" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_' + attr2 + '_' + count + '_total_after_tax" disabled="disabled" class="invoice_field money_text total_after_tax" autocomplete="off"></td>' +
      '<td class="text-center"><input type="hidden" value="0" name="' + base + '[' + attr1 + '][' + invoice_count + '][' + attr2 + '][' + count + '][add_vat_10]"><input type="checkbox" value="1" name="' + base + '[' + attr1 + '][' + invoice_count + '][' + attr2 + '][' + count + '][add_vat_10]" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_' + attr2 + '_' + count + '_add_vat_10" class="invoice_checkbox add_vat_10"></td>' +
      '<td class="text-center"><input type="hidden" value="0" name="' + base + '[' + attr1 + '][' + invoice_count + '][' + attr2 + '][' + count + '][add_vat_1]"><input type="checkbox" value="1" name="' + base + '[' + attr1 + '][' + invoice_count + '][' + attr2 + '][' + count + '][add_vat_1]" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_' + attr2 + '_' + count + '_add_vat_1" class="invoice_checkbox add_vat_1"></td>' +
      '<td class="text-center"><input type="hidden" value="0" name="' + base + '[' + attr1 + '][' + invoice_count + '][' + attr2 + '][' + count + '][add_vat_11]"><input type="checkbox" value="1" name="' + base + '[' + attr1 + '][' + invoice_count + '][' + attr2 + '][' + count + '][add_vat_11]" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_' + attr2 + '_' + count + '_add_vat_11" class="invoice_checkbox add_vat_11"></td>' +
      '<td class="text-center"><input type="hidden" value="0" name="' + base + '[' + attr1 + '][' + invoice_count + '][' + attr2 + '][' + count + '][add_vat_1_1]"><input type="checkbox" value="1" name="' + base + '[' + attr1 + '][' + invoice_count + '][' + attr2 + '][' + count + '][add_vat_1_1]" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_' + attr2 + '_' + count + '_add_vat_1_1" class="invoice_checkbox add_vat_1_1"></td>' +
      '<td class="text-center"><input type="hidden" value="0" name="' + base + '[' + attr1 + '][' + invoice_count + '][' + attr2 + '][' + count + '][add_pph_23]"><input type="checkbox" value="1" name="' + base + '[' + attr1 + '][' + invoice_count + '][' + attr2 + '][' + count + '][add_pph_23]" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_' + attr2 + '_' + count + '_add_pph_23" class="invoice_checkbox add_pph_23"></td>' +
    '</tr>';

    // invoice_count++;

    if($(this).find("tbody tr:not('.hidden'):last td:eq(1) input").val() != ""){
      $(this).find("tbody").append(tmp);
    }
  });
}

function add_cost_invoice_fields() {
  var table = $(".invoice-table");
  var count = $(".invoice-table tbody tr").length;
  var number = $(".invoice-table tbody tr:not(.hidden)").length;
  var invoice_count = 0;
  
  var attr1 = 'payment_invoices_attributes';
  var attr2 = 'payment_items_attributes';
  var base = 'payment_plan';

  table.each(function(index){
    count = $(this).find("tbody tr").length;
    invoice_count = index;
    number = $(this).find("tbody tr:not(.hidden)").length;
    var tmp= '' +
    '<tr class="active">' +
      '<td class="hidden"></td>' +
      '<td>' +
        '<input type="text" autocomplete="off" class="invoice_description invoice_field" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_' + attr2 + '_' + count + '_description" name="' + base + '[' + attr1 + '][' + invoice_count + '][' + attr2 + '][' + count + '][description]">' +
        '<input type="hidden" class="span12" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_' + attr2 + '_' + count + '__destroy" name="' + base + '[' + attr1 + '][' + invoice_count + '][' + attr2 + '][' + count + '][_destroy]">' +
        '<a class="remove_invoice_description" onclick="remove_sell_cost_invoice_fields(this); return false;" tabindex="-1" href="#" title="Remove"><i class="icon-remove-sign"></i></a>' +
        '<input type="hidden" value="active" name="' + base + '[' + attr1 + '][' + invoice_count + '][' + attr2 + '][' + count + '][item_type]" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_' + attr2 + '_' + count + '_item_type" class="span12 item_type">' + 
      '</td>' +
      '<td class="text-right"><input type="text" autocomplete="off" class="invoice_field invoice_volume volume_text volume" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_' + attr2 + '_' + count + '_volume" name="' + base + '[' + attr1 + '][' + invoice_count + '][' + attr2 + '][' + count + '][volume]"></td>' +
      '<td><input type="text" autocomplete="off" class="invoice_field money_text amount_usd" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_' + attr2 + '_' + count + '_amount_usd" name="' + base + '[' + attr1 + '][' + invoice_count + '][' + attr2 + '][' + count + '][amount_usd]"></td>' +
      '<td><input type="text" autocomplete="off" class="invoice_field money_text amount_idr" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_' + attr2 + '_' + count + '_amount_idr" name="' + base + '[' + attr1 + '][' + invoice_count + '][' + attr2 + '][' + count + '][amount_idr]"></td>' +
      '<td><input type="text" name="' + base + '[' + attr1 + '][' + invoice_count + '][' + attr2 + '][' + count + '][total]" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_' + attr2 + '_' + count + '_total" disabled="disabled" class="invoice_field money_text total" autocomplete="off"></td>' +
      '<td class="hidden"><input type="text" name="' + base + '[' + attr1 + '][' + invoice_count + '][' + attr2 + '][' + count + '][total_after_tax]" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_' + attr2 + '_' + count + '_total_after_tax" disabled="disabled" class="invoice_field money_text total_after_tax" autocomplete="off"></td>' +
      '<td class="text-center"><input type="hidden" name="' + base + '[' + attr1 + '][' + invoice_count + '][' + attr2 + '][' + count + '][add_vat_10]" value="0"><input type="checkbox" class="invoice_checkbox add_vat_10" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_' + attr2 + '_' + count + '_add_vat_10" name="' + base + '[' + attr1 + '][' + invoice_count + '][' + attr2 + '][' + count + '][add_vat_10]" value="1"></td>' +
      '<td class="text-center"><input type="hidden" name="' + base + '[' + attr1 + '][' + invoice_count + '][' + attr2 + '][' + count + '][add_vat_1]" value="0"><input type="checkbox" class="invoice_checkbox add_vat_1" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_' + attr2 + '_' + count + '_add_vat_1" name="' + base + '[' + attr1 + '][' + invoice_count + '][' + attr2 + '][' + count + '][add_vat_1]" value="1"></td>' +
      '<td class="text-center"><input type="hidden" name="' + base + '[' + attr1 + '][' + invoice_count + '][' + attr2 + '][' + count + '][add_vat_10]" value="0"><input type="checkbox" class="invoice_checkbox add_vat_11" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_' + attr2 + '_' + count + '_add_vat_11" name="' + base + '[' + attr1 + '][' + invoice_count + '][' + attr2 + '][' + count + '][add_vat_11]" value="1"></td>' +
      '<td class="text-center"><input type="hidden" name="' + base + '[' + attr1 + '][' + invoice_count + '][' + attr2 + '][' + count + '][add_vat_1]" value="0"><input type="checkbox" class="invoice_checkbox add_vat_1_1" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_' + attr2 + '_' + count + '_add_vat_1_1" name="' + base + '[' + attr1 + '][' + invoice_count + '][' + attr2 + '][' + count + '][add_vat_1_1]" value="1"></td>' +
      '<td class="text-center"><input type="hidden" name="' + base + '[' + attr1 + '][' + invoice_count + '][' + attr2 + '][' + count + '][add_pph_23]" value="0"><input type="checkbox" class="invoice_checkbox add_pph_23" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_' + attr2 + '_' + count + '_add_pph_23" name="' + base + '[' + attr1 + '][' + invoice_count + '][' + attr2 + '][' + count + '][add_pph_23]" value="1"></td>' +
    '</tr>';
    
    // invoice_count++;
    // console.log($(this).find("tbody tr:not('.hidden'):last td:eq(1) input").val());
    if($(this).find("tbody tr:not('.hidden'):last td:eq(1) input").val() != ""){
      $(this).find("tbody").append(tmp);
    }
  });
}

function remove_sell_cost_invoice_fields(element) {
  $(element).parent().parent().addClass("hidden");
  $(element).prev('input[type=hidden]').val('1');

  // $(element).prfvvev('input[type=hidden]').val('1');
  // var invoice = $(element).parent().parent().parent();
  // invoice.css("display", "none");

  count = 0;
  $(".invoice-description table tbody tr").each(function () {
    if (!$(this).hasClass("hidden")) {
      count++;
      $(this).find("td:eq(0)").text(count);
    }
  });
  calculate();

  var table = $(".invoice-table");
  table.each(function(index){
    if($(this).find("tbody tr:not('.hidden')").length == 0){
      if($('#shipping_instruction_payment_invoices_attributes_0_payment_date').length != 0)
        add_cost_invoice_fields();
      if($('#shipping_instruction_bill_of_lading_invoices_attributes_0_is_tick_all').length != 0)
        add_sell_invoice_fields();
    }
  });
}

// function add_bill_of_lading_invoice_fields() {
//   var invoice_count = $(".invoice-table").length;
//   var count = 0;
//   // var number = $("table tbody tr:not(.hidden)").length;
//   var attr1 = 'bill_of_lading_invoices_attributes';
//   var attr2 = 'bill_of_lading_items_attributes';

//   var tmp= '' +
//   '<div class="row-fluid">' +
//     '<div class="span12">' +
//       '<div class="control-group">' +
//         '<label class="control-label" for=""></label>' +
//         '<div class="controls">' +
//           '<input type="hidden" value="0" name="shipping_instruction[' + attr1 + '][' + invoice_count + '][is_tick_all]"><input type="checkbox" value="1" name="shipping_instruction[' + attr1 + '][' + invoice_count + '][is_tick_all]" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_is_tick_all" class="is_tick_all"> Tick All &nbsp;&nbsp;' +
//           '<input type="hidden" value="0" name="shipping_instruction[' + attr1 + '][' + invoice_count + '][is_ai]"><input type="checkbox" value="1" name="shipping_instruction[' + attr1 + '][' + invoice_count + '][is_ai]" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_is_ai" class="is_ai" checked="checked"> AI &nbsp;&nbsp;' +
//           '<input type="hidden" value="0" name="shipping_instruction[' + attr1 + '][' + invoice_count + '][is_gi]"><input type="checkbox" value="1" name="shipping_instruction[' + attr1 + '][' + invoice_count + '][is_gi]" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_is_gi" class="is_gi"> GI &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' +
//           // '<a target="_blank" href="/create-new-invoice/4899?year=2016">Export</a>' +
//         '</div>' +
//       '</div>' +
//     '</div>' +
//     '<div class="span12" style="overflow-x: scroll;margin-left: 0;">' +
//       '<table class="invoice-table" border="1" width="100%">' +
//         '<thead>' +
//           '<tr>' +
//             '<th colspan="10">INVOICE</th>' +
//           '</tr>' +
//           '<tr style="height:43px;">' +
//             '<th class="hidden"></th>' +
//             '<th>DESCRIPTION</th>' +
//             '<th>QTY</th>' +
//             '<th>AMOUNT USD</th>' +
//             '<th>AMOUNT IDR</th>' +
//             '<th>TOTAL</th>' +
//             '<th>TOTAL AFTER TAX</th>' +
//             '<th>VAT 10%</th>' +
//             '<th>VAT 1%</th>' +
//             '<th>PPH 23</th>' +
//           '</tr>' +
//         '</thead>' +
//         '<tbody>' +
//         '</tbody>' +
//         '<tfoot>' +
//           '<tr>' +
//             '<td class="hidden"></td>' +
//             '<td colspan="5" class="text-left">OTHER</td>' +
//             '<td class="text-right">' +
//               '<input autocomplete="off" class="invoice_field money_text amount_idr other" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_other" name="shipping_instruction[' + attr1 + '][' + invoice_count + '][other]" type="text">' +
//             '</td>' +
//             '<td colspan="3">&nbsp;</td>' +
//           '</tr>' +
//           '<tr>' +
//             '<td class="hidden"></td>' +
//             '<td colspan="5" class="text-left">RATE</td>' +
//             '<td class="text-right">' +
//               '<input autocomplete="off" class="invoice_field money_text amount_idr rate" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_rate" name="shipping_instruction[' + attr1 + '][' + invoice_count + '][rate]" type="text">' +
//             '</td>' +
//             '<td colspan="3">&nbsp;</td>' +
//           '</tr>' +
//           '<tr>' +
//             '<td class="hidden"></td>' +
//             '<td colspan="5" class="text-left">VAT 10%</td>' +
//             '<td class="text-right">' +
//               '<input autocomplete="off" class="invoice_field money_text amount_idr vat_10" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_vat_10" name="shipping_instruction[' + attr1 + '][' + invoice_count + '][vat_10]" type="text">' +
//             '</td>' +
//             '<td colspan="3"><input autocomplete="off" class="invoice_field money_text amount_idr default_vat_10" disabled="disabled" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_default_vat_10" name="shipping_instruction[' + attr1 + '][' + invoice_count + '][default_vat_10]" type="text"></td>' +
//           '</tr>' +
//           '<tr>' +
//             '<td class="hidden"></td>' +
//             '<td colspan="5" class="text-left">VAT 1%</td>' +
//             '<td class="text-right">' +
//               '<input autocomplete="off" class="invoice_field money_text amount_idr vat_1" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_vat_1" name="shipping_instruction[' + attr1 + '][' + invoice_count + '][vat_1]" type="text">' +
//             '</td>' +
//             '<td colspan="3"><input autocomplete="off" class="invoice_field money_text amount_idr default_vat_1" disabled="disabled" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_default_vat_1" name="shipping_instruction[' + attr1 + '][' + invoice_count + '][default_vat_1]" type="text"></td>' +
//           '</tr>' +
//           '<tr>' +
//             '<td class="hidden"></td>' +
//             '<td colspan="5" class="text-left">PPH 23</td>' +
//             '<td class="text-right">' +
//               '<input autocomplete="off" class="invoice_field money_text amount_idr pph_23" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_pph_23" name="shipping_instruction[' + attr1 + '][' + invoice_count + '][pph_23]" type="text">' +
//             '</td>' +
//             '<td colspan="3"><input autocomplete="off" class="invoice_field money_text amount_idr default_pph_23" disabled="disabled" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_default_pph_23" name="shipping_instruction[' + attr1 + '][' + invoice_count + '][default_pph_23]" type="text"></td>' +
//           '</tr>' +
//           '<tr>' +
//             '<td class="hidden"></td>' +
//             '<td colspan="5" class="text-left">TOTAL INVOICE EXCLUDE PPH 23</td>' +
//             '<td class="text-right"><input autocomplete="off" class="invoice_field money_text amount_idr total_invoice_exclude_pph_23" disabled="disabled" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_total_invoice_exclude_pph_23" name="shipping_instruction[' + attr1 + '][' + invoice_count + '][total_invoice_exclude_pph_23]" type="text"></td>' +
//             '<td colspan="3"><input autocomplete="off" class="invoice_field money_text amount_idr default_total_invoice_exclude_pph_23" disabled="disabled" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_default_total_invoice_exclude_pph_23" name="shipping_instruction[' + attr1 + '][' + invoice_count + '][default_total_invoice_exclude_pph_23]" type="text"></td>' +
//           '</tr>' +
//           '<tr>' +
//             '<td class="hidden"></td>' +
//             '<td colspan="5" class="text-left">TOTAL INVOICE</td>' +
//             '<td class="text-right"><input autocomplete="off" class="invoice_field money_text amount_idr total_invoice" disabled="disabled" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_total_invoice" name="shipping_instruction[' + attr1 + '][' + invoice_count + '][total_invoice]" type="text"></td>' +
//             '<td colspan="3"><input autocomplete="off" class="invoice_field money_text amount_idr default_total_invoice" disabled="disabled" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_default_total_invoice" name="shipping_instruction[' + attr1 + '][' + invoice_count + '][default_total_invoice]" type="text"></td>' +
//           '</tr>' +
//         '</tfoot>' +
//       '</table>' +
//       '<div class="text-right">'+
//           '<input class="span12" id="shipping_instruction_' + attr1 + '_' + invoice_count + '__destroy" name="shipping_instruction[' + attr1 + '][' + invoice_count + '][_destroy]" type="hidden">' +
//           '<a href="#" onclick="remove_payment_invoice_fields(this); return false;" tabindex="-1">DELETE</a>' +
//       '</div>' +
//     '</div>' +
//     '<div class="clearfix">&nbsp;</div>' +
//   '</div>';

//   $("#sell-invoices").append(tmp);
// }

function add_bill_of_lading_invoice_fields() {
  var invoice_count = $(".invoice-table").length;
  var count = 0;
  // var number = $("table tbody tr:not(.hidden)").length;
  var attr1 = 'bill_of_lading_invoices_attributes';
  var attr2 = 'bill_of_lading_items_attributes';
  var base = 'calculate_invoice';

  var tmp= '' +
  '<div class="row-fluid">' +
    '<div class="span12">' +
      '<div class="control-group">' +
        '<label class="control-label" for=""></label>' +
        '<div class="controls">' +
          '<input type="hidden" value="0" name="' + base + '[' + attr1 + '][' + invoice_count + '][is_tick_all]"><input type="checkbox" value="1" name="' + base + '[' + attr1 + '][' + invoice_count + '][is_tick_all]" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_is_tick_all" class="is_tick_all"> Tick All &nbsp;&nbsp;' +
          '<input type="hidden" value="0" name="' + base + '[' + attr1 + '][' + invoice_count + '][is_ai]"><input type="checkbox" value="1" name="' + base + '[' + attr1 + '][' + invoice_count + '][is_ai]" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_is_ai" class="is_ai" checked="checked"> AI &nbsp;&nbsp;' +
          '<input type="hidden" value="0" name="' + base + '[' + attr1 + '][' + invoice_count + '][is_gi]"><input type="checkbox" value="1" name="' + base + '[' + attr1 + '][' + invoice_count + '][is_gi]" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_is_gi" class="is_gi"> GI &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' +
          // '<a target="_blank" href="/create-new-invoice/4899?year=2016">Export</a>' +
        '</div>' +
      '</div>' +
    '</div>' +
    '<div class="span12" style="overflow-x: scroll;margin-left: 0;">' +
      '<table class="invoice-table" border="1" width="100%">' +
        '<thead>' +
          '<tr>' +
            '<th colspan="11">INVOICE</th>' +
          '</tr>' +
          '<tr style="height:43px;">' +
            '<th class="hidden"></th>' +
            '<th>DESCRIPTION</th>' +
            '<th>QTY</th>' +
            '<th>AMOUNT USD</th>' +
            '<th>AMOUNT IDR</th>' +
            '<th>TOTAL</th>' +
            '<th>TOTAL AFTER TAX</th>' +
            '<th>VAT 10%</th>' +
            '<th>VAT 1%</th>' +
            '<th>VAT 11%</th>' +
            '<th>VAT 1.1%</th>' +
            '<th>PPH 23</th>' +
          '</tr>' +
        '</thead>' +
        '<tbody>' +
        '</tbody>' +
        '<tfoot>' +
          '<tr>' +
            '<td class="hidden"></td>' +
            '<td colspan="5" class="text-left">OTHER</td>' +
            '<td><input autocomplete="off" class="invoice_field money_text amount_idr other" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_other" name="' + base + '[' + attr1 + '][' + invoice_count + '][other]" type="text"></td>' +
            '<td colspan="5"></td>' +
          '</tr>' +
          '<tr>' +
            '<td class="hidden"></td>' +
            '<td colspan="5" class="text-left">RATE</td>' +
            '<td><input autocomplete="off" class="invoice_field money_text amount_idr rate" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_rate" name="' + base + '[' + attr1 + '][' + invoice_count + '][rate]" type="text"></td>' +
            '<td colspan="3"></td>' +
          '</tr>' +
          '<tr>' +
            '<td class="hidden"></td>' +
            '<td colspan="5" class="text-left">VAT 10%</td>' +
            '<td><input autocomplete="off" class="invoice_field money_text amount_idr vat_10" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_vat_10" name="' + base + '[' + attr1 + '][' + invoice_count + '][vat_10]" type="text" disabled="disabled"></td>' +
            '<td colspan="5"><input autocomplete="off" class="invoice_field money_text amount_idr default_vat_10" disabled="disabled" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_default_vat_10" name="' + base + '[' + attr1 + '][' + invoice_count + '][default_vat_10]" type="hidden"></td>' +
          '</tr>' +
          '<tr>' +
            '<td class="hidden"></td>' +
            '<td colspan="5" class="text-left">VAT 1%</td>' +
            '<td><input autocomplete="off" class="invoice_field money_text amount_idr vat_1" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_vat_1" name="' + base + '[' + attr1 + '][' + invoice_count + '][vat_1]" type="text" disabled="disabled"></td>' +
            '<td colspan="5"><input autocomplete="off" class="invoice_field money_text amount_idr default_vat_1" disabled="disabled" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_default_vat_1" name="' + base + '[' + attr1 + '][' + invoice_count + '][default_vat_1]" type="hidden"></td>' +
          '</tr>' +
          '<tr>' +
            '<td class="hidden"></td>' +
            '<td colspan="5" class="text-left">VAT 11%</td>' +
            '<td><input autocomplete="off" class="invoice_field money_text amount_idr vat_11" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_vat_11" name="' + base + '[' + attr1 + '][' + invoice_count + '][vat_11]" type="text" disabled="disabled"></td>' +
            '<td colspan="5"><input autocomplete="off" class="invoice_field money_text amount_idr default_vat_11" disabled="disabled" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_default_vat_10" name="' + base + '[' + attr1 + '][' + invoice_count + '][default_vat_11]" type="hidden"></td>' +
          '</tr>' +
          '<tr>' +
            '<td class="hidden"></td>' +
            '<td colspan="5" class="text-left">VAT 1.1%</td>' +
            '<td><input autocomplete="off" class="invoice_field money_text amount_idr vat_1_1" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_vat_1_1" name="' + base + '[' + attr1 + '][' + invoice_count + '][vat_1_1]" type="text" disabled="disabled"></td>' +
            '<td colspan="5"><input autocomplete="off" class="invoice_field money_text amount_idr default_vat_1_1" disabled="disabled" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_default_vat_1" name="' + base + '[' + attr1 + '][' + invoice_count + '][default_vat_1_1]" type="hidden"></td>' +
          '</tr>' +
          '<tr>' +
            '<td class="hidden"></td>' +
            '<td colspan="5" class="text-left">PPH 23</td>' +
            '<td><input autocomplete="off" class="invoice_field money_text amount_idr pph_23" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_pph_23" name="' + base + '[' + attr1 + '][' + invoice_count + '][pph_23]" type="text" disabled="disabled"></td>' +
            '<td colspan="5"><input autocomplete="off" class="invoice_field money_text amount_idr default_pph_23" disabled="disabled" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_default_pph_23" name="' + base + '[' + attr1 + '][' + invoice_count + '][default_pph_23]" type="hidden"></td>' +
          '</tr>' +
          '<tr>' +
            '<td class="hidden"></td>' +
            '<td colspan="5" class="text-left">TOTAL INVOICE EXCLUDE PPH 23</td>' +
            '<td><input autocomplete="off" class="invoice_field money_text amount_idr total_invoice_exclude_pph_23" disabled="disabled" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_total_invoice_exclude_pph_23" name="' + base + '[' + attr1 + '][' + invoice_count + '][total_invoice_exclude_pph_23]" type="text"></td>' +
            '<td colspan="5"><input autocomplete="off" class="invoice_field money_text amount_idr default_total_invoice_exclude_pph_23" disabled="disabled" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_default_total_invoice_exclude_pph_23" name="' + base + '[' + attr1 + '][' + invoice_count + '][default_total_invoice_exclude_pph_23]" type="hidden"></td>' +
          '</tr>' +
          '<tr>' +
            '<td class="hidden"></td>' +
            '<td colspan="5" class="text-left">TOTAL INVOICE</td>' +
            '<td><input autocomplete="off" class="invoice_field money_text amount_idr total_invoice" disabled="disabled" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_total_invoice" name="' + base + '[' + attr1 + '][' + invoice_count + '][total_invoice]" type="text"></td>' +
            '<td colspan="5"><input autocomplete="off" class="invoice_field money_text amount_idr default_total_invoice" disabled="disabled" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_default_total_invoice" name="' + base + '[' + attr1 + '][' + invoice_count + '][default_total_invoice]" type="hidden"></td>' +
          '</tr>' +
        '</tfoot>' +
      '</table>' +
      '<div class="text-right">'+
          '<input class="span12" id="shipping_instruction_' + attr1 + '_' + invoice_count + '__destroy" name="' + base + '[' + attr1 + '][' + invoice_count + '][_destroy]" type="hidden">' +
          '<a href="#" onclick="remove_payment_invoice_fields(this); return false;" tabindex="-1">DELETE</a>' +
      '</div>' +
    '</div>' +
    '<div class="clearfix">&nbsp;</div>' +
  '</div>';

  $("#sell-invoices").append(tmp);
}

function remove_bill_of_lading_invoice_fields(element) {
  // $(element).parent().parent().addClass("hidden");
  $(element).prev('input[type=hidden]').val('1');
  var invoice = $(element).parent().parent().parent();
  invoice.css("display", "none");
  invoice.find('.invoice-table').addClass("hidden");
  calculate();
  // console.log(invoice);
  // table2.prev('div').css("display", "none");

  // count = 0;
  // $("#invoice-description table tbody tr").each(function () {
  //   if (!$(this).hasClass("hidden")) {
  //     count++;
  //     $(this).find("td:eq(0)").text(count);
  //   }
  // });
}

function add_payment_invoice_fields() {
  var invoice_count = $(".invoice-table").length;
  var count = 0;
  // var number = $("table tbody tr:not(.hidden)").length;
  var attr1 = 'payment_invoices_attributes';
  var attr2 = 'payment_items_attributes';
  var base = 'payment_plan';

  var tmp= '' +
  '<div class="row-fluid">' +
    '<div class="span12">' +
      '<div class="control-group">' +
        '<label for="" class="control-label">Payment Date</label>' +
        '<div class="controls">: ' +
          '<input autocomplete="off" class="datepicker invoice_payment_date" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_payment_date" name="' + base + '[' + attr1 + '][' + invoice_count + '][payment_date]" type="text">' +
        '</div>' +
      '</div>' +
      '<div class="control-group">' +
        '<label for="" class="control-label">Carrier</label>' +
        '<div class="controls">: ' +
          // '<input autocomplete="off" class="invoice_carrier" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_carrier" name="' + base + '[' + attr1 + '][' + invoice_count + '][carrier]" type="text">' +
          '<div class="input-append">' +
            '<input autocomplete="off" class="invoice_carrier" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_carrier" name="' + base + '[' + attr1 + '][' + invoice_count + '][carrier]" type="text">' +
            '<button class="btn btn-carrier" type="button" data-toggle="modal" href="#carriersModal" data-no-turbolink="true">Find Carrier</button>' +
            '<input id="shipping_instruction_' + attr1 + '_' + invoice_count + '_carrier_id" name="' + base + '[' + attr1 + '][' + invoice_count + '][carrier_id]" type="hidden">' +
          '</div>' +
        '</div>' +
      '</div>' +
      '<div class="control-group">' +
        '<label for="" class="control-label">Paid</label>' +
        '<div class="controls">: ' +
          '<input name="' + base + '[' + attr1 + '][' + invoice_count + '][is_paid]" value="0" type="hidden"><input id="shipping_instruction_' + attr1 + '_' + invoice_count + '_is_paid" name="' + base + '[payment_invoices_attributes][' + invoice_count + '][is_paid]" value="1" type="checkbox">' +
        '</div>' +
      '</div>' +
    '</div>' +
    '<div class="span12" style="overflow-x: scroll;margin-left: 0;">' +
      '<table class="invoice-table" border="1" width="100%">' +
        '<thead>' +
          '<tr>' +
            '<th colspan="11">INVOICE</th>' +
          '</tr>' +
          '<tr style="height:43px;">' +
            '<th class="hidden"></th>' +
            '<th>DESCRIPTION</th>' +
            '<th>QTY</th>' +
            '<th>AMOUNT USD</th>' +
            '<th>AMOUNT IDR</th>' +
            '<th>TOTAL</th>' +
            '<th class="hidden">TOTAL AFTER TAX</th>' +
            '<th>VAT 10%</th>' +
            '<th>VAT 1%</th>' +
            '<th>VAT 11%</th>' +
            '<th>VAT 1.1%</th>' +
            '<th>PPH 23</th>' +
          '</tr>' +
        '</thead>' +
        '<tbody>' +
        '</tbody>' +
        '<tfoot>' +
          '<tr>' +
            '<td class="hidden"></td>' +
            '<td colspan="4" class="text-left">OTHER</td>' +
            '<td><input autocomplete="off" class="invoice_field money_text amount_idr other" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_other" name="' + base + '[' + attr1 + '][' + invoice_count + '][other]" type="text"></td>' +
            '<td class="hidden"></td>' +
            '<td colspan="5"></td>' +
          '</tr>' +
          '<tr>' +
            '<td class="hidden"></td>' +
            '<td colspan="4" class="text-left">RATE</td>' +
            '<td><input autocomplete="off" class="invoice_field money_text amount_idr rate" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_rate" name="' + base + '[' + attr1 + '][' + invoice_count + '][rate]" type="text"></td>' +
            '<td class="hidden"></td>' +
            '<td colspan="5"></td>' +
          '</tr>' +
          '<tr>' +
            '<td class="hidden"></td>' +
            '<td colspan="4" class="text-left">VAT 10%</td>' +
            '<td><input autocomplete="off" class="invoice_field money_text amount_idr vat_10" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_vat_10" name="' + base + '[' + attr1 + '][' + invoice_count + '][vat_10]" type="text"></td>' +
            '<td class="hidden"></td>' +
            '<td colspan="5"><input autocomplete="off" class="invoice_field money_text amount_idr default_vat_10" disabled="disabled" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_default_vat_10" name="' + base + '[' + attr1 + '][' + invoice_count + '][default_vat_10]" type="text"></td>' +
          '</tr>' +
          '<tr>' +
            '<td class="hidden"></td>' +
            '<td colspan="4" class="text-left">VAT 1%</td>' +
            '<td><input autocomplete="off" class="invoice_field money_text amount_idr vat_1" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_vat_1" name="' + base + '[' + attr1 + '][' + invoice_count + '][vat_1]" type="text"></td>' +
            '<td class="hidden"></td>' +
            '<td colspan="5"><input autocomplete="off" class="invoice_field money_text amount_idr default_vat_1" disabled="disabled" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_default_vat_1" name="' + base + '[' + attr1 + '][' + invoice_count + '][default_vat_1]" type="text"></td>' +
          '</tr>' +
          '<tr>' +
            '<td class="hidden"></td>' +
            '<td colspan="4" class="text-left">VAT 11%</td>' +
            '<td><input autocomplete="off" class="invoice_field money_text amount_idr vat_11" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_vat_11" name="' + base + '[' + attr1 + '][' + invoice_count + '][vat_11]" type="text"></td>' +
            '<td class="hidden"></td>' +
            '<td colspan="5"><input autocomplete="off" class="invoice_field money_text amount_idr default_vat_11" disabled="disabled" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_default_vat_11" name="' + base + '[' + attr1 + '][' + invoice_count + '][default_vat_11]" type="text"></td>' +
          '</tr>' +
          '<tr>' +
            '<td class="hidden"></td>' +
            '<td colspan="4" class="text-left">VAT 1.1%</td>' +
            '<td><input autocomplete="off" class="invoice_field money_text amount_idr vat_1_1" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_vat_1_1" name="' + base + '[' + attr1 + '][' + invoice_count + '][vat_1_1]" type="text"></td>' +
            '<td class="hidden"></td>' +
            '<td colspan="5"><input autocomplete="off" class="invoice_field money_text amount_idr default_vat_1_1" disabled="disabled" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_default_vat_1_1" name="' + base + '[' + attr1 + '][' + invoice_count + '][default_vat_1_1]" type="text"></td>' +
          '</tr>' +
          '<tr>' +
            '<td class="hidden"></td>' +
            '<td colspan="4" class="text-left">PPH 23</td>' +
            '<td><input autocomplete="off" class="invoice_field money_text amount_idr pph_23" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_pph_23" name="' + base + '[' + attr1 + '][' + invoice_count + '][pph_23]" type="text"></td>' +
            '<td class="hidden"></td>' +
            '<td colspan="5"><input autocomplete="off" class="invoice_field money_text amount_idr default_pph_23" disabled="disabled" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_default_pph_23" name="' + base + '[' + attr1 + '][' + invoice_count + '][default_pph_23]" type="text"></td>' +
          '</tr>' +
          '<tr>' +
            '<td class="hidden"></td>' +
            '<td colspan="4" class="text-left">TOTAL INVOICE</td>' +
            '<td><input autocomplete="off" class="invoice_field money_text amount_idr total_invoice" disabled="disabled" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_total_invoice" name="' + base + '[' + attr1 + '][' + invoice_count + '][total_invoice]" type="text"></td>' +
            '<td class="hidden"></td>' +
            '<td colspan="5"><input autocomplete="off" class="invoice_field money_text amount_idr default_total_invoice" disabled="disabled" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_default_total_invoice" name="' + base + '[' + attr1 + '][' + invoice_count + '][default_total_invoice]" type="text"></td>' +
          '</tr>' +
          '<tr>' +
            '<td class="hidden"></td>' +
            '<td colspan="4" class="text-left">TOTAL INVOICE INCLUDING PPH 23</td>' +
            '<td><input autocomplete="off" class="invoice_field money_text amount_idr total_invoice_include_pph_23" disabled="disabled" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_total_invoice_include_pph_23" name="' + base + '[' + attr1 + '][' + invoice_count + '][total_invoice_include_pph_23]" type="text"></td>' +
            '<td class="hidden"></td>' +
            '<td colspan="5"><input autocomplete="off" class="invoice_field money_text amount_idr default_total_invoice_include_pph_23" disabled="disabled" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_default_total_invoice_include_pph_23" name="' + base + '[' + attr1 + '][' + invoice_count + '][default_total_invoice_include_pph_23]" type="text"></td>' +
          '</tr>' +
        '</tfoot>' +
      '</table>' +
      '<div class="text-right">'+
          '<input class="span12" id="shipping_instruction_' + attr1 + '_' + invoice_count + '__destroy" name="' + base + '[' + attr1 + '][' + invoice_count + '][_destroy]" type="hidden">' +
          '<a href="#" onclick="remove_payment_invoice_fields(this); return false;" tabindex="-1">DELETE</a>' +
      '</div>' +
    '</div>' +
    '<div class="clearfix">&nbsp;</div>' +
  '</div>';

  $("#cost-invoices").append(tmp);
}

function remove_payment_invoice_fields(element) {
  // $(element).parent().parent().addClass("hidden");
  $(element).prev('input[type=hidden]').val('1');
  var invoice = $(element).parent().parent().parent();
  invoice.css("display", "none");
  invoice.find('.invoice-table').addClass("hidden");
  calculate();
  // console.log(invoice);
  // table2.prev('div').css("display", "none");

  // count = 0;
  // $("#invoice-description table tbody tr").each(function () {
  //   if (!$(this).hasClass("hidden")) {
  //     count++;
  //     $(this).find("td:eq(0)").text(count);
  //   }
  // });
}

// function add_invoice_fields(invoice) {
//   var count = $(".invoice-table tbody tr").length - 1;
//   var attr = invoice + '_details_attributes';
//   var tmp = '' +
//   '<tr>' +
//     '<td><input type="text" name="' + invoice + '[' + attr + '][' + count + '][description]" class="span12 invoice_description" autocomplete="off"></td>' +
//     '<td><input type="text" name="' + invoice + '[' + attr + '][' + count + '][volume]" class="span12 invoice_volume volume_text" autocomplete="off"></td>' +
//     '<td><input type="text" name="' + invoice + '[' + attr + '][' + count + '][amount]" class="span12 invoice_amount money_text" autocomplete="off"></td>' +
//     // '<td><span class="invoice_subtotal"></span></td>' +
//     '<td><input type="text" name="' + invoice + '[' + attr + '][' + count + '][subtotal]" class="span12 invoice_subtotal money_text" autocomplete="off" disabled="disabled"></td>' +
//     '<td><input type="hidden" name="' + invoice + '[' + attr + '][' + count + '][destroy]" value="0"/>' +
//     '<a class="remove_invoice_description" onclick="remove_invoice_fields(this); return false;" href="#"><i class="icon-remove-sign"></i></a></td>' +
//   '</tr>';
//   $(".invoice-table tbody").append(tmp);
// }


function add_invoice_fields(invoice) {
  var count = $(".invoice-table tbody tr").length;
  var attr = invoice + '_details_attributes';
  var tmp = '' +
  '<tr>' +
    '<td><input type="text" name="' + invoice + '[' + attr + '][' + count + '][description]" class="span12 invoice_description" autocomplete="off"></td>' +
    '<td><input type="text" name="' + invoice + '[' + attr + '][' + count + '][volume]" class="span12 invoice_volume volume_text" autocomplete="off"></td>' +
    '<td><input type="text" name="' + invoice + '[' + attr + '][' + count + '][amount]" class="span12 invoice_amount money_text" autocomplete="off"></td>' +
    // '<td><span class="invoice_subtotal"></span></td>' +
    '<td><input type="text" name="' + invoice + '[' + attr + '][' + count + '][subtotal]" class="span12 invoice_subtotal money_text" autocomplete="off" disabled="disabled"></td>' +
    '<td><input type="text" name="' + invoice + '[' + attr + '][' + count + '][default_amount]" class="span12 invoice_default_amount money_text" autocomplete="off" disabled="disabled"></td>' +
    '<td><input type="hidden" name="' + invoice + '[' + attr + '][' + count + '][destroy]" value="0"/>' +
    '<a class="remove_invoice_description" onclick="remove_invoice_fields(this); return false;" href="#"><i class="icon-remove-sign"></i></a></td>' +
  '</tr>';
  $(".invoice-table tbody").append(tmp);
}

function remove_invoice_fields(element) {
  $(element).parent().parent().addClass("hidden");
  $(element).parent().prev().children().focusout();
  $(element).prev('input[type=hidden]').val('1');
}

// function add_reference_fields() {
//   var count = $("#payment_references tr").length - 1;
//   var tmp = '' +
//     '<tr>' +
//     '<td><input type="text" name="payment[payment_references_attributes][' + count + '][ibl_ref]" id="payment_payment_references_attributes_' + count + '_ibl_ref" class="span12 reference_ibl_ref" autocomplete="off"></td>' +
//     '<td><input type="text" name="payment[payment_references_attributes][' + count + '][booking_no]" id="payment_payment_references_attributes_' + count + '_booking_no" class="span12" autocomplete="off"></td>' +
//     '<td><input type="text" style="text-align: right" name="payment[payment_references_attributes][' + count + '][amount_invoice]" id="payment_payment_references_attributes_' + count + '_amount_invoice" class="reference_amount_invoice money_text" autocomplete="off"></td>' +
//     '<td><input type="text" style="text-align: right" name="payment[payment_references_attributes][' + count + '][amount]" id="payment_payment_references_attributes_' + count + '_amount" class="reference_amount money_text" autocomplete="off"></td>' +
//     '<td><input type="hidden" value="false" name="payment[payment_references_attributes][' + count + '][_destroy]" id="payment_payment_references_attributes_' + count + '__destroy" class="span12">' +
//     '<a title="Remove" href="#" tabindex="-1" onclick="remove_reference_fields(this); return false;"><i class="icon-remove-sign"></i></a></td>' +
//     '</tr>';
//   $("#payment_references").append(tmp);
// }

function add_reference_fields() {
  var count = $("#payment_references tbody tr").length;
  var tmp = '' +
    '<tr>' +
      '<td><input autocomplete="off" class="span12 reference_ibl_ref" id="payment_payment_references_attributes_' + count + '_ibl_ref" name="payment[payment_references_attributes][' + count + '][ibl_ref]" type="text"></td>' +
      '<td class="hidden"><input autocomplete="off" class="span12" id="payment_payment_references_attributes_' + count + '_booking_no" name="payment[payment_references_attributes][' + count + '][booking_no]" type="hidden"></td>' +
      '<td><input autocomplete="off" class="span12 reference_master_bl_no" id="payment_payment_references_attributes_' + count + '_master_bl_no" name="payment[payment_references_attributes][' + count + '][master_bl_no]" type="text"></td>' +
      '<td><input autocomplete="off" class="span12 reference_amount money_text" id="payment_payment_references_attributes_' + count + '_amount" name="payment[payment_references_attributes][' + count + '][amount]" value="0" type="text"></td>' +
      '<td><input autocomplete="off" class="span12 reference_amount_use_deposit money_text" id="payment_payment_references_attributes_' + count + '_amount_use_deposit" name="payment[payment_references_attributes][' + count + '][amount_use_deposit]" type="text" disabled="disabled"></td>' +
      '<td><input autocomplete="off" class="span12 reference_amount_misc money_text" id="payment_payment_references_attributes_' + count + '_amount_misc" name="payment[payment_references_attributes][' + count + '][amount_misc]" type="text"></td>' +
      '<td><input autocomplete="off" class="span12 reference_amount_overpaid money_text" id="payment_payment_references_attributes_' + count + '_amount_overpaid" name="payment[payment_references_attributes][' + count + '][amount_overpaid]" type="text"></td>' +
      '<td><input autocomplete="off" class="span12 reference_amount_invoice money_text" id="payment_payment_references_attributes_' + count + '_amount_invoice" name="payment[payment_references_attributes][' + count + '][amount_invoice]" type="text"></td>' +
      '<td><input autocomplete="off" class="span12 reference_amount_estimate money_text" id="payment_payment_references_attributes_' + count + '_amount_estimate" name="payment[payment_references_attributes][' + count + '][amount_estimate]" type="text" disabled="disabled"></td>' +
      '<td>' +
        '<input class="span12" id="payment_payment_references_attributes_' + count + '__destroy" name="payment[payment_references_attributes][' + count + '][_destroy]" value="false" type="hidden">' +
        '<a onclick="remove_reference_fields(this); return false;" tabindex="-1" href="#" title="Remove"><i class="icon-remove-sign"></i></a>' +
      '</td>' +
    '</tr>';
  $("#payment_references tbody").append(tmp);
}

function remove_reference_fields(element) {
  $(element).parent().parent().addClass("hidden");
  $(element).parent().prev().children().focusout();
  $(element).prev('input[type=hidden]').val('1');
}

// function add_deposit_fields() {
//   var count = $("#payment_deposits tr").length - 1;
//   var tmp = '' +
//   '<tr>' +
//     // '<td><input type="text" name="payment[payment_deposits_attributes][' + count + '][ibl_deposit]" class="span12 deposit_ibl_deposit" autocomplete="off"></td>' +
//     '<td><select name="payment[payment_deposits_attributes][' + count + '][ibl_deposit]" class="span12 deposit_ibl_deposit"></select></td>' +
//     '<td><input type="text" name="payment[payment_deposits_attributes][' + count + '][master_bl_no]" class="span12 deposit_mbl_no" autocomplete="off"></td>' +
//     '<td><input type="text" name="payment[payment_deposits_attributes][' + count + '][amount]" class="span12 deposit_amount money_text" autocomplete="off"></td>' +
//     '<td><input type="text" name="payment[payment_deposits_attributes][' + count + '][ibl_ref]" class="span12 deposit_ibl_ref" autocomplete="off"></td>' +
//     '<td><input type="hidden" name="payment[payment_deposits_attributes][' + count + '][destroy]" value="0"/>' +
//     '<a onclick="remove_deposit_fields(this); return false;" href="#"><i class="icon-remove-sign"></i></a></td>' +
//   '</tr>';
//   $("#payment_deposits").append(tmp);
// }

function add_deposit_fields() {
  var count = $("#payment_deposits tbody tr").length;
  var tmp = '' +
    '<tr>' +
      '<td><select name="payment[payment_deposits_attributes][' + count + '][ibl_deposit]" id="payment_payment_deposits_attributes_' + count + '_ibl_deposit" class="span12 deposit_ibl_deposit"></select></td>' +
      // '<td><input autocomplete="off" class="span12 deposit_ibl_deposit" id="payment_payment_deposits_attributes_' + count + '_ibl_deposit" name="payment[payment_deposits_attributes][' + count + '][ibl_deposit]" type="text"></td>' +
      '<td class="hidden"><input autocomplete="off" class="span12 deposit_mbl_no" id="payment_payment_deposits_attributes_' + count + '_master_bl_no" name="payment[payment_deposits_attributes][' + count + '][master_bl_no]" type="hidden"></td>' +
      '<td><input autocomplete="off" class="span12 deposit_amount money_text" id="payment_payment_deposits_attributes_' + count + '_amount" name="payment[payment_deposits_attributes][' + count + '][amount]"></td>' +
      '<td><input autocomplete="off" class="span12 deposit_ibl_ref" id="payment_payment_deposits_attributes_' + count + '_ibl_ref" name="payment[payment_deposits_attributes][' + count + '][ibl_ref]" type="text"></td>' +
      '<td>' +
        '<input class="span12" id="payment_payment_deposits_attributes_' + count + '__destroy" name="payment[payment_deposits_attributes][' + count + '][_destroy]" value="false" type="hidden">' +
        '<a onclick="remove_deposit_fields(this); return false;" tabindex="-1" href="#" title="Remove"><i class="icon-remove-sign"></i></a>' +
      '</td>' +
    '</tr>';
  $("#payment_deposits tbody").append(tmp);
}

function remove_deposit_fields(element) {
  $(element).parent().parent().addClass("hidden");
  $(element).parent().prev().children().focusout();
  $(element).prev('input[type=hidden]').val('1');
}

function add_tax_fields() {
  var count = $("#payment_taxes tbody tr").length;
  var tmp = '' +
  '<tr>' +
    '<td><input type="text" name="payment[payment_taxes_attributes][' + count + '][ibl_ref]" class="span12 tax_ibl_ref" autocomplete="off"></td>' +
    '<td><input type="text" name="payment[payment_taxes_attributes][' + count + '][amount]" class="span12 tax_amount money_text"></td>' +
    '<td><input type="hidden" name="payment[payment_taxes_attributes][' + count + '][destroy]" value="0"/>' +
    '<a onclick="remove_tax_fields(this); return false;" href="#"><i class="icon-remove-sign"></i></a></td>' +
  '</tr>';
  $("#payment_taxes tbody").append(tmp);
}

function remove_tax_fields(element) {
  $(element).parent().parent().addClass("hidden");
  $(element).parent().prev().children().focusout();
  $(element).prev('input[type=hidden]').val('1');
}

// function add_invoice_payment_fields() {
//   // var global_count = $("#invoice_payments tbody tr:not('.hidden')").length;
//   var base = $("#invoice_payments tbody tr");
//   var count = base.length;
//   var attr = 'invoice_payments_attributes';
//   var tmp = '' +
//     '<tr>' +
//       '<td><input type="text" name="invoice[' + attr + '][' + count + '][payment_date]" id="invoice_' + attr + '_' + count + '_payment_date" class="item_field datepicker" autocomplete="off"></td>' +
//       '<td><input type="text" name="invoice[' + attr + '][' + count + '][amount_paid]" id="invoice_' + attr + '_' + count + '_amount_paid" class="item_field money_text" autocomplete="off"></td>' +
//       '<td><input type="text" name="invoice[' + attr + '][' + count + '][rounding]" id="invoice_' + attr + '_' + count + '_rounding" class="item_field money_text" autocomplete="off"></td>' +
//       '<td><input type="text" name="invoice[' + attr + '][' + count + '][bank_charge]" id="invoice_' + attr + '_' + count + '_bank_charge" class="item_field money_text" autocomplete="off"></td>' +
//       '<td><input type="text" name="invoice[' + attr + '][' + count + '][discount]" id="invoice_' + attr + '_' + count + '_discount" class="item_field money_text" autocomplete="off"></td>' +
//       '<td><input type="text" name="invoice[' + attr + '][' + count + '][short_paid]" id="invoice_' + attr + '_' + count + '_short_paid" class="item_field money_text" autocomplete="off"></td>' +
//       '<td><input type="text" name="invoice[' + attr + '][' + count + '][deposit]" id="invoice_' + attr + '_' + count + '_deposit" class="item_field money_text" autocomplete="off"></td>' +
//       '<td><input type="text" name="invoice[' + attr + '][' + count + '][total]" id="invoice_' + attr + '_' + count + '_total" disabled="disabled" class="item_field money_text" autocomplete="off"></td>' +
//       '<td><textarea name="invoice[' + attr + '][' + count + '][note]" id="invoice_' + attr + '_' + count + '_note" class="item_field" autocomplete="off"></textarea></td>' +
//     '</tr>';
//   // base.last().after( tmp );
//   $("#invoice_payments tbody").append( tmp );
// };

function add_sell_cost_fields(name) {
  var global_count = $(".revenue-table tbody tr:not('.hidden')").length;
  // var base = $(".revenue-table tr."+name);
  var base = $(".revenue-table tbody tr");
  var count = base.length;
  // var attr = name+'_items_attributes';
  var attr = 'cost_revenue_items_attributes';
  var tmp = '' +
  '<tr class="' + name + '">' +
    '<td align="center">' + (global_count+1) + '</td>' +
    '<td>' +
      '<input type="text" name="cost_revenue[' + attr + '][' + count + '][description]" id="cost_revenue_' + attr + '_' + count + '_description" class="cost_revenue_field cost_revenue_description" autocomplete="off">' +
      '<input type="hidden" name="cost_revenue[' + attr + '][' + count + '][_destroy]" id="cost_revenue_' + attr + '_' + count + '__destroy" class="span12">' +
      '<a title="Remove" href="#" tabindex="-1" onclick="remove_revenue_fields(this); return false;" class="remove_cost_revenue_description"><i class="icon-remove-sign"></i></a>' +
      '<input type="hidden" value="' + name + '" name="cost_revenue[' + attr + '][' + count + '][item_type]" id="cost_revenue_' + attr + '_' + count + '_item_type" class="span12 item_type">' +
    '</td>' +
    '<td class="text-right"><input type="text" name="cost_revenue[' + attr + '][' + count + '][selling_volume]" id="cost_revenue_' + attr + '_' + count + '_selling_volume" class="cost_revenue_field cost_revenue_volume volume_text selling_volume" autocomplete="off"></td>' +
    '<td><input type="text" name="cost_revenue[' + attr + '][' + count + '][selling_usd]" id="cost_revenue_' + attr + '_' + count + '_selling_usd" class="cost_revenue_field money_text selling_usd" autocomplete="off"></td>' +
    '<td><input type="text" name="cost_revenue[' + attr + '][' + count + '][selling_idr]" id="cost_revenue_' + attr + '_' + count + '_selling_idr" class="cost_revenue_field money_text selling_idr" autocomplete="off"></td>' +
    '<td class="text-right"><input type="text" name="cost_revenue[' + attr + '][' + count + '][selling_total]" id="cost_revenue_' + attr + '_' + count + '_selling_total" class="cost_revenue_field money_text selling_total" autocomplete="off" disabled="disabled"></td>' +
    // '<td class="text-right"><input type="text" name="cost_revenue[' + attr + '][' + count + '][selling_total_after_tax]" id="cost_revenue_' + attr + '_' + count + '_selling_total_after_tax" class="cost_revenue_field money_text selling_total_after_tax" autocomplete="off" disabled="disabled"></td>' +
    '<td class="text-right"><input type="text" name="cost_revenue[' + attr + '][' + count + '][selling_total_after_tax]" id="cost_revenue_' + attr + '_' + count + '_selling_total_after_tax" class="cost_revenue_field money_text selling_total_after_tax" autocomplete="off"></td>' +
    
    '<td class="text-right"><input type="text" name="cost_revenue[' + attr + '][' + count + '][buying_volume]" id="cost_revenue_' + attr + '_' + count + '_buying_volume" class="cost_revenue_field cost_revenue_volume volume_text buying_volume" autocomplete="off"></td>' +
    '<td><input type="text" name="cost_revenue[' + attr + '][' + count + '][buying_usd]" id="cost_revenue_' + attr + '_' + count + '_buying_usd" class="cost_revenue_field money_text buying_usd" autocomplete="off"></td>' +
    '<td><input type="text" name="cost_revenue[' + attr + '][' + count + '][buying_idr]" id="cost_revenue_' + attr + '_' + count + '_buying_idr" class="cost_revenue_field money_text buying_idr" autocomplete="off"></td>' +
    '<td class="text-right"><input type="text" name="cost_revenue[' + attr + '][' + count + '][buying_total]" id="cost_revenue_' + attr + '_' + count + '_buying_total" class="cost_revenue_field money_text buying_total" autocomplete="off" disabled="disabled"></td>' +
    // '<td class="text-right"><input type="text" name="cost_revenue[' + attr + '][' + count + '][buying_total_after_tax]" id="cost_revenue_' + attr + '_' + count + '_buying_total_after_tax" class="cost_revenue_field money_text buying_total_after_tax" autocomplete="off" disabled="disabled"></td>' +
    '<td class="text-right"><input type="text" name="cost_revenue[' + attr + '][' + count + '][buying_total_after_tax]" id="cost_revenue_' + attr + '_' + count + '_buying_total_after_tax" class="cost_revenue_field money_text buying_total_after_tax" autocomplete="off"></td>' +
  '</tr>';
  // base.last().after( tmp );
  $(".revenue-table tbody").append( tmp );
  // $(".revenue-table tr."+name+"_group").before( tmp );
  counter_revenue_fields();
};

function remove_revenue_fields(element) {
  $(element).parent().parent().addClass("hidden");
  $(element).prev('input[type=hidden]').val('1');

  counter_revenue_fields();
  calculate();
  
  if($(".revenue-table tbody tr:not('.hidden')").length == 0)
    add_sell_cost_fields('active');
}

function counter_revenue_fields(element) {
  count = 1;
  $(".revenue-table tbody tr:not('.hidden')").each(function () {
    $(this).find("td:eq(0)").text(count);
    count++;
  });
}

function add_close_payment_fields() {
  var count = $("#close_payments tbody tr").length;
  var attr = 'close_payments_attributes';
  // var base = 'invoice';
  var base = 'bulk_close_payment';
  var tmp = '' +
  '<tr>' +
    '<td>' +
      // '<input autocomplete="off" class="close_payment_field" id="invoice_' + attr + '_' + count + '_ibl_ref" name="invoice[' + attr + '][' + count + '][ibl_ref]" type="hidden">' +
      '<select name="' + base + '[' + attr + '][' + count + '][ibl_ref]" id="invoice_' + attr + '_' + count + '_ibl_ref" class="close_payment_field ibl_ref_with_invoice_no">' +
    '</td>' +
    '<td><span class="customer_text"></span><input autocomplete="off" class="close_payment_field customer" id="invoice_' + attr + '_' + count + '_customer" name="' + base + '[' + attr + '][' + count + '][customer]" type="hidden"></td>' +
    '<td><span class="shipper_text"></span><input autocomplete="off" class="close_payment_field shipper" id="invoice_' + attr + '_' + count + '_shipper" name="' + base + '[' + attr + '][' + count + '][shipper]" type="hidden"></td>' +
    '<td><span class="invoice_no_text"></span><input autocomplete="off" class="close_payment_field invoice_no" id="invoice_' + attr + '_' + count + '_invoice_no" name="' + base + '[' + attr + '][' + count + '][invoice_no]" type="hidden"></td>' +
    '<td style="text-align:right"><span class="amount_text"></span><input autocomplete="off" class="close_payment_field money_text amount" id="invoice_' + attr + '_' + count + '_amount" name="' + base + '[' + attr + '][' + count + '][amount]" type="hidden"></td>' +
    '<td style="text-align:right"><input autocomplete="off" class="close_payment_field money_text amount_paid" disabled="disabled" id="invoice_' + attr + '_' + count + '_amount_paid" name="' + base + '[' + attr + '][' + count + '][amount_paid]" style="width: 130px;" type="text"></td>' +
    '<td>' +
      '<input autocomplete="off" class="close_payment_field currency" id="invoice_' + attr + '_' + count + '_currency" name="' + base + '[' + attr + '][' + count + '][currency]" type="hidden">' +
      '<input autocomplete="off" class="close_payment_field rate" id="invoice_' + attr + '_' + count + '_rate" name="' + base + '[' + attr + '][' + count + '][rate]" type="hidden">' +
      '<input autocomplete="off" class="close_payment_field payment_date" id="invoice_' + attr + '_' + count + '_payment_date" name="' + base + '[' + attr + '][' + count + '][payment_date]" type="hidden">' +
      '<input autocomplete="off" class="close_payment_field status" id="invoice_' + attr + '_' + count + '_status" name="' + base + '[' + attr + '][' + count + '][status]" value="0" type="hidden">' +
      '<input class="" id="invoice_' + attr + '_' + count + '__destroy" name="' + base + '[' + attr + '][' + count + '][_destroy]" type="hidden">' +
      '<a onclick="remove_reference_fields(this); return false;" tabindex="-1" href="#" title="Remove"><i class="icon-remove-sign"></i></a>' +  
    '</td>' +
  '</tr>';
  $("#close_payments tbody").append(tmp);
}

function remove_reference_fields(element) {
  $(element).parent().parent().addClass("hidden");
  $(element).parent().prev().children().focusout();
  $(element).prev('input[type=hidden]').val('1');
}

function add_invoice_payment_fields() {
  var count = $("#invoice_payments tbody tr").length;
  var attr = 'additional_payments_attributes';
  var base = 'bulk_close_payment';
  var tmp = '' +
    '<tr>' +
      '<td><input autocomplete="off" class="invoice_payment_field invoice_no" id="invoice_' + attr + '_' + count + '_invoice_no" name="' + base + '[' + attr + '][' + count + '][invoice_no]" type="text"></td>' +
      '<td><input autocomplete="off" class="invoice_payment_field money_text bank_charge" id="invoice_' + attr + '_' + count + '_bank_charge" name="' + base + '[' + attr + '][' + count + '][bank_charge]" type="text"></td>' +
      // '<td><input autocomplete="off" class="invoice_payment_field money_text discount" id="invoice_' + attr + '_' + count + '_discount" name="' + base + '[' + attr + '][' + count + '][discount]" type="text"></td>' +
      '<td><input autocomplete="off" class="invoice_payment_field money_text rounding" id="invoice_' + attr + '_' + count + '_rounding" name="' + base + '[' + attr + '][' + count + '][rounding]" type="text"></td>' +
      '<td><input autocomplete="off" class="invoice_payment_field money_text short_paid" id="invoice_' + attr + '_' + count + '_short_paid" name="' + base + '[' + attr + '][' + count + '][short_paid]" type="text"></td>' +
      '<td><input autocomplete="off" class="invoice_payment_field money_text deposit" id="invoice_' + attr + '_' + count + '_deposit" name="' + base + '[' + attr + '][' + count + '][deposit]" type="text"></td>' +
      '<td><input autocomplete="off" class="invoice_payment_field money_text pph_23" id="invoice_' + attr + '_' + count + '_pph_23" name="' + base + '[' + attr + '][' + count + '][pph_23]" type="text"></td>' +
      '<td><input autocomplete="off" class="invoice_payment_field money_text other" id="invoice_' + attr + '_' + count + '_other" name="' + base + '[' + attr + '][' + count + '][other]" type="text"></td>' +
      '<td><textarea autocomplete="off" class="invoice_payment_field note" id="invoice_' + attr + '_' + count + '_note" name="' + base + '[' + attr + '][' + count + '][note]"></textarea></td>' +
      '<td>' +
        '<input autocomplete="off" class="invoice_payment_field payment_date" id="invoice_' + attr + '_' + count + '_payment_date" name="' + base + '[' + attr + '][' + count + '][payment_date]" type="hidden">' +
          '<input class="" id="invoice_' + attr + '_' + count + '__destroy" name="' + base + '[' + attr + '][' + count + '][_destroy]" type="hidden">' +
        '<a onclick="remove_reference_fields(this); return false;" tabindex="-1" href="#" title="Remove"><i class="icon-remove-sign"></i></a>' +
      '</td>' +
    '</tr>';
  // base.last().after( tmp );
  $("#invoice_payments tbody").append( tmp );
};

function add_invoice_deposit_fields() {
  var count = $("#invoice_deposits tbody tr").length;
  var attr = 'deposit_payments_attributes';
  var base = 'bulk_close_payment';
  var tmp = '' +
    // '<tr>' +
    //   '<td><select name="payment[invoice_deposits_attributes][' + count + '][invoice_deposit]" id="payment_invoice_deposits_attributes_' + count + '_invoice_deposit" class="invoice_deposit deposit_invoice_deposit"></select></td>' +
    //   // '<td><input autocomplete="off" class="invoice_deposit deposit_ibl_deposit" id="payment_invoice_deposits_attributes_' + count + '_ibl_deposit" name="payment[invoice_deposits_attributes][' + count + '][ibl_deposit]" type="text"></td>' +
    //   '<td class="hidden"><input autocomplete="off" class="invoice_deposit deposit_mbl_no" id="payment_invoice_deposits_attributes_' + count + '_master_bl_no" name="payment[invoice_deposits_attributes][' + count + '][master_bl_no]" type="hidden"></td>' +
    //   '<td><input autocomplete="off" class="invoice_deposit deposit_amount money_text" id="payment_invoice_deposits_attributes_' + count + '_amount" name="payment[invoice_deposits_attributes][' + count + '][amount]"></td>' +
    //   '<td><input autocomplete="off" class="invoice_deposit deposit_ibl_ref" id="payment_invoice_deposits_attributes_' + count + '_ibl_ref" name="payment[invoice_deposits_attributes][' + count + '][ibl_ref]" type="text"></td>' +
    //   '<td>' +
    //     '<input class="invoice_deposit" id="payment_invoice_deposits_attributes_' + count + '__destroy" name="payment[invoice_deposits_attributes][' + count + '][_destroy]" value="false" type="hidden">' +
    //     '<a onclick="remove_deposit_fields(this); return false;" tabindex="-1" href="#" title="Remove"><i class="icon-remove-sign"></i></a>' +
    //   '</td>' +
    // '</tr>';
    '<tr>' +
      '<td><select class="invoice_deposit deposit_invoice_deposit" id="invoice_' + attr + '_' + count + '_invoice_deposit" name="' + base + '[' + attr + '][' + count + '][invoice_deposit]"></select></td>' +
      '<td><input autocomplete="off" class="invoice_deposit_field amount money_text" id="invoice_' + attr + '_' + count + '_amount" name="' + base + '[' + attr + '][' + count + '][amount]" style="text-align: right" type="text"></td>' +
      '<td><input autocomplete="off" class="invoice_deposit_field invoice_no" id="invoice_' + attr + '_' + count + '_invoice_no" name="' + base + '[' + attr + '][' + count + '][invoice_no]" type="text"></td>' +
      '<td>' +
        '<input autocomplete="off" class="invoice_deposit_field ibl_deposit" id="invoice_' + attr + '_' + count + '_ibl_deposit" name="' + base + '[' + attr + '][' + count + '][ibl_deposit]" type="hidden">' +
          '<input class="invoice_deposit_field" id="invoice_' + attr + '_' + count + '__destroy" name="' + base + '[' + attr + '][' + count + '][_destroy]" type="hidden">' +
        '<a onclick="remove_deposit_fields(this); return false;" tabindex="-1" href="#" title="Remove"><i class="icon-remove-sign"></i></a>' +
      '</td>' +
    '</tr>';
  $("#invoice_deposits tbody").append(tmp);
}

function remove_deposit_fields(element) {
  $(element).parent().parent().addClass("hidden");
  $(element).parent().prev().children().focusout();
  $(element).prev('input[type=hidden]').val('1');
}
