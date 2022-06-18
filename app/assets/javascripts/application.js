//= require jquery
//= require jquery.turbolinks
//= require jquery_ujs
//= require jquery.ui.datepicker
//= require jquery.ui.autocomplete
//= require turbolinks
//= require bootstrap-transition
//= require bootstrap-alert
//= require bootstrap-button
//= require bootstrap-dropdown
//= require bootstrap-modal
//= require bootstrap-modalmanager
//= require bootstrap-typeahead
//= require bootstrap-collapse
//= require bootstrap-tab
//= require livequery
//= require jquery.tagsinput.min
//= require accounting.min
// require jquery.dataTables.min
//= require dataTables/jquery.dataTables.min
//= require dataTables/Buttons/dataTables.buttons.min
//= require dataTables/Buttons/buttons.flash.min
//= require dataTables/Buttons/buttons.html5.min
//= require dataTables/Buttons/buttons.print.min
//= require dataTables/Buttons/buttons.colVis.min
// require dataTables/Buttons/buttons.jqueryui.min
//= require jquery.dataTables.yadcf
//= require jquery.cookie
//= require form
//= require datatables
//= require format
//= require datepicker
//= require_self
$(document).ready(function () {
  $(document).on("submit", "form[data-turboform]", function(e) {
    Turbolinks.visit(this.action+(this.action.indexOf('?') == -1 ? '?' : '&')+$(this).serialize());
    return false;
  });

  // $(".datepicker").livequery(function () {
  //   $(this).datepicker({
  //     dateFormat: 'dd MM yy',
  //     changeMonth: true,
  //     changeYear: true,
  //     minDate: new Date(year, 0, 1),
  //     // maxdate: new Date(today.getFullYear(), 11, 31) 
  //   });
  // });

  $(".fu-datepicker").livequery(function () {
    $(this).datepicker({
      dateFormat: 'dd M yy',
      changeMonth: true,
      changeYear: true,
      closeText: 'Clear'
    });
  });

  $(".custom_address, #agent_address, #carrier_address, #consignee_address, #shipper_bl_address").livequery(function () {
    $(this).keypress(function (e) {
      var t = $(this);
      var length = t.val().substr(0, t.selectionStart).split("\n").length;

      if (length >= 5 && ((e.keyCode || e.which) == 13)) {
        e.preventDefault();
      }
    });
  });

  // if (window.location.pathname == "/shipment_trackings") {
  //   $.fn.dataTable.ext.afnFiltering.push(
  //     function(settings, data, dataIndex) {
  //       if($("#fu_date")){
  //         var filterNote = $("#fu_date").val().toLowerCase();
  //         var note = data[16].toLowerCase();

  //         if (filterNote == '' || filterNote == note){
  //           return true;
  //         }
  //         return false;
  //       }
  //       else {
  //         return true;
  //       }
  //     }
  //   );
  // }

  // var oTable = $('.dtable').dataTable({
  // var oTable = $('#bill-of-ladings, #payments, #shipments-tracking, #shipping-instructions').DataTable({
  //   stateSave: true,
  //   dom: '<"clear"><B><"clear">frt<"clear">ip',
  //   // buttons: [
  //   //   // {
  //   //   //   extend: 'colvis',
  //   //   //   // columns: ':not(:first-child)'
  //   //   //   collectionLayout: 'fixed two-column'
  //   //   // }
  //   //   // 'columnsToggle'
  //   //   {
  //   //     extend: 'colvis',
  //   //     columns: ':not(:first-child)'
  //   //   }
  //   // ],
  //   lengthMenu: [
  //     [ 10, 25, 50, -1 ],
  //     [ '10 rows', '25 rows', '50 rows', 'Show all' ]
  //   ],
  //   buttons: [
  //     'pageLength',
  //     {
  //       // extend: 'columnsToggle',
  //       // columns: ':not(:nth-child(1))'
  //       // // columns: [{ name: 'Show' }, { name: 'Edit' }, { name: 'Delete' }]
  //       // // columns: ':not(.hidden)'
  //       extend: 'colvis',
  //       collectionLayout: 'fixed two-column',
  //       columns: ':not(:nth-child(1))',
  //       postfixButtons: [ 'colvisRestore' ]
  //     }
  //   ],
  //   pagingType: 'simple',
  //   order: [[ 1, 'desc' ]],
  //   scrollX: true,
  //   // bSort: true,
  //   // bAutoWidth: false,
  //   // "sDom": 'C<"clear">lfrtip',
  //   columnDefs: [
  //     // { 'bSortable': false, 'aTargets': [ 0 ] },
  //     // { targets: -1, visible: false }
  //     { targets: [ 0 ], orderable: false, searchable: false }
  //   ],
  //   // "aaSorting": [
  //   //   [ 1, "desc" ]
  //   // ],
  //   // "iDisplayLength": (parseInt($.cookie("table_row")) || 10)
  // });

  $.extend( true, $.fn.dataTable.defaults, {
    stateSave: true,
    dom: '<"clear"><B><"clear">frt<"clear">ip',
    lengthMenu: [
      // [ 10, 25, 50, 100, -1 ],
      [ 10, 25, 50, 100 ],
      [ '10 rows', '25 rows', '50 rows', '100 rows', 'Show all' ]
    ],
    buttons: [
      'pageLength'
    ],
    pagingType: 'simple',
    order: [[ 3, 'asc' ]],
    scrollX: true,
    columnDefs: [
      { targets: [ 0, 1, 2 ], orderable: false, searchable: false }
    ],
  } );

  // var pTable = $('#agents, #carrier-banks, #consignees, #debit-notes, #outstanding-bonshipment, #outstanding-bonshipment-si, #report-tracking, #invoices, #notes').DataTable();
  var table1 = $('#agents_table, #carrier_banks_table, #consignees_table, #owners_table').DataTable();
  // pTable.table().state.clear();

  var table2 = $('#carriers_table, #shippers_table').DataTable({
    order: [[ 4, 'asc' ]],
    columnDefs: [
      { targets: [ 0, 1, 2, 3 ], orderable: false, searchable: false }
    ],
  });

  var table3 = $('#users_table').DataTable({
    order: [[ 0, 'asc' ]],
    columnDefs: [
      { targets: [ 6, 7 ], orderable: false, searchable: false }
    ],
  });

  // var qTable = $('#control-center').DataTable({
  //   order: [[ 1, 'desc' ]],
  //   columnDefs: [
  //     { targets: [ 0 ], orderable: false, searchable: false }
  //   ],
  // });  

  // if ( $.fn.dataTable.isDataTable( '#carrier-banks' ) == true) {
  // if ( $("#carrier-banks").length ){
    // table = $('#carrier-banks').dataTable({   
    //   bSort: true,
    //   bAutoWidth: false,
    //   "aoColumnDefs": [{ 'bSortable': false, 'aTargets': [ 0 ] }],
    //   "aaSorting": [[ 3, "desc" ]],
    //   // "iDisplayLength": (parseInt($.cookie("table_row")) || 10)
    // });
    
    // new $.fn.dataTable.Buttons( pTable, {
    //   buttons: [
    //     {
    //       extend: 'colvis',
    //       collectionLayout: 'fixed two-column',
    //       postfixButtons: [ 'colvisRestore' ]
    //     }
    //   ]
    // });


    // console.log(pTable.fnSettings());

    // pTable.fnSettings().buttons.push(
    //   {
    //     extend: 'colvis',
    //     collectionLayout: 'fixed two-column',
    //     postfixButtons: [ 'colvisRestore' ]
    //   }
    // )

    // var oldoptions = pTable.fnSettings();
    // var newoptions = $.extend(oldoptions, {
    //     stateSave: true,
    //     buttons:  [
    //       'pageLength',
    //       {
    //         extend: 'colvis',
    //         collectionLayout: 'fixed two-column',
    //         postfixButtons: [ 'colvisRestore' ],
    //         columns: ':not(.hidden)'
    //       },
    //       'colvisRestore'
    //     ],
    //     columnDefs: [
    //       // { targets: [ 2 ], visible: false, 'searchable': false },
    //       { targets: [ 0, 1, 2 ], orderable: false, searchable: false },
    //       // { targets: '_all', visible: false }
    //       { targets: [ 3 ], visible: false },
    //     ]
    //   }
    // );
    // pTable.fnDestroy();
    // $('#carrier-banks').dataTable(newoptions);

    // rTable.column(3).visible(false);
    // pTable.buttons().push(
    //   {
    //     extend: 'colvis',
    //     collectionLayout: 'fixed two-column',
    //     postfixButtons: [ 'colvisRestore' ],
    //     columns: ':not(.hidden)'
    //   }
    // )
    // new $.fn.dataTable.ColVis( rTable, {
    //     buttonText: 'Select columns'
    // } );
    // $( colvis.button() ).insertAfter('div.page-header');
  // }

  // if ( $("#bill-of-ladings").length ){
  //   oTable.column(4).visible(false); // Consignee
  //   oTable.column(5).visible(false); // Notify Party
  //   oTable.column(10).visible(false); // POL
  // }
  // if ( $("#payments").length ){
  //   oTable.column(3).visible(false); // Booking No
  //   oTable.column(6).visible(false); // Volume
  //   oTable.column(9).visible(false); // Notes
  // }
  // if ( $("#shipments-tracking").length ){
  //   oTable.column(3).visible(false); // Shipper SI #
  //   oTable.column(4).visible(false); // MBL #
  //   oTable.column(6).visible(false); // Volume
  //   oTable.column(7).visible(false); // Destination
  // }
  // if ( $("#shipping-instructions").length ){
  //   oTable.column(9).visible(false); // Consignee
  //   oTable.column(10).visible(false); // Notify Party
  //   oTable.column(11).visible(false); // POL
  //   oTable.column(12).visible(false); // Booking No
  //   oTable.column(13).visible(false); // MBL No
  //   oTable.column(14).visible(false); // Order Type
  // }  


  // var billOfLadingTable = $('#bill-of-ladings').DataTable({
  //   order: [[ 1, 'desc' ]],
  //   buttons: [
  //     'pageLength',
  //     {
  //       extend: 'colvis',
  //       collectionLayout: 'fixed two-column',
  //       columns: ':not(:nth-child(1))',
  //       // postfixButtons: [ 'colvisRestore' ],
  //       // {
  //       //   text: 'Reinit',
  //       //   action: function ( e, dt, node, config ) {
  //       //     // dt.table().state.clear();
  //       //     // dt.table().fnDraw();
  //       //     dt.column(4).visible(false); // Consignee
  //       //     dt.column(5).visible(false); // Notify Party
  //       //     dt.column(10).visible(false); // POL
  //       //     table.columns( [ 0, 1, 2, 3 ] ).visible( false, false );
  //       //     table.columns.adjust().draw( false ); // adjust column sizing and redraw
  //       //   }
  //       // }
  //       postfixButtons: [ { 
  //         text: 'Restore visibility',
  //         action: function ( e, dt, node, config ) {
  //           dt.columns().visible( true, false );
  //           dt.columns( [ 5, 6, 9 ]).visible(false, false);
  //           dt.columns.adjust().draw( false );
  //         }
  //       } ]
  //     },
  //     // {
  //     //   text: 'Restore visibility',
  //     //   action: function ( e, dt, node, config ) {
  //     //     // dt.table().state.clear();
  //     //     // dt.table().fnDraw();
  //     //     dt.columns().visible( true, false );
  //     //     // dt.columns( [ 4, 5, 10 ]).visible(false, false); // Consignee, Notify Party, POL
  //     //     dt.columns( [ 5, 6, 9 ]).visible(false, false); 
  //     //     dt.columns.adjust().draw( false ); // adjust column sizing and redraw          
  //     //     // dt.column(4).visible(false); // Consignee
  //     //     // dt.column(5).visible(false); // Notify Party
  //     //     // dt.column(10).visible(false); // POL
  //     //   }
  //     // }
  //   ],
  //   columnDefs: [
  //     { targets: [ 0 ], orderable: false, searchable: false },
  //     // { targets: [ 4, 5, 10 ], visible: false }
  //     { targets: [ 4, 5, 8 ], visible: false } // Consignee, Notify Party, POL
  //   ]
  // });

  var paymentTable = $('#payments').DataTable({
    order: [[ 1, 'desc' ]],
    buttons: [
      'pageLength',
      {
        extend: 'colvis',
        collectionLayout: 'fixed two-column',
        columns: ':not(:nth-child(1))',
        postfixButtons: [ { 
          text: 'Restore visibility',
          action: function ( e, dt, node, config ) {
            dt.columns().visible( true, false );
          dt.columns( [ 3, 6, 9 ] ).visible(false, false);
          dt.columns.adjust().draw( false );
          }
        } ]
      },
    ],
    columnDefs: [
      { targets: [ 0 ], orderable: false, searchable: false },
      { targets: [ 3, 6, 9 ], visible: false } // Booking No, Volume, Notes
    ]
  });

  var paymentInquiryTable = $('#payments-inquiry').DataTable({
    order: [[ 1, 'desc' ]],
    buttons: [
      'pageLength',
      {
        extend: 'colvis',
        collectionLayout: 'fixed two-column',
        columns: ':not(:nth-child(1))',
        postfixButtons: [ { 
          text: 'Restore visibility',
          action: function ( e, dt, node, config ) {
            dt.columns().visible( true, false );
          dt.columns( [ 3, 6, 9 ] ).visible(false, false);
          dt.columns.adjust().draw( false );
          }
        } ]
      },
    ],
    columnDefs: [
      { targets: [ 0 ], orderable: false, searchable: false },
      { targets: [ 3, 6, 9 ], visible: false } // Booking No, Volume, Notes
    ]
  });

  // var paymentOtherTable = $('#payments-plan, #payments-tax, #payments-deposit, #payments-report').DataTable({
  //   order: [[ 1, 'desc' ]],
  //   columnDefs: [
  //     { targets: [ 0 ], orderable: false, searchable: false },
  //   ]
  // });

  // var shipmentsTrackingTable = $('#shipments-tracking').DataTable({
  //   order: [[ 1, 'desc' ]],
  //   buttons: [
  //     'pageLength',
  //     {
  //       extend: 'colvis',
  //       collectionLayout: 'fixed two-column',
  //       columns: ':not(.hidden)',
  //       postfixButtons: [ { 
  //         text: 'Restore visibility',
  //         action: function ( e, dt, node, config ) {
  //           dt.columns().visible( true, false );
  //           // dt.columns( [ 3, 4, 6, 7 ] ).visible(false, false);
  //           dt.columns( [ 9, 10, 11 ] ).visible(false, false);
  //           dt.columns.adjust().draw( false );
  //         }
  //       } ]
  //     },
  //   ],
  //   columnDefs: [
  //     { targets: [ 0 ], orderable: false, searchable: false },
  //     // { targets: [ 3, 4, 6, 7 ], visible: false } // Shipper SI #, MBL #, Volume, Destination
  //     { targets: [ 9, 10, 11 ], visible: false } // Shipper SI #, MBL #, Volume, Destination
  //   ]
  // });

  // var shippingInstructionsTable = $('#shipping-instructions').DataTable({
  //   order: [[ 1, 'desc' ]],
  //   buttons: [
  //     'pageLength',
  //     {
  //       extend: 'colvis',
  //       collectionLayout: 'fixed two-column',
  //       columns: ':not(:nth-child(1))',
  //       postfixButtons: [ { 
  //         text: 'Restore visibility',
  //         action: function ( e, dt, node, config ) {
  //           dt.columns().visible( true, false );
  //           dt.columns( [ 9, 10, 11, 12, 13, 14 ] ).visible(false, false);
  //           dt.columns.adjust().draw( false );
  //         }
  //       } ]
  //     },
  //   ],
  //   columnDefs: [
  //     { targets: [ 0 ], orderable: false, searchable: false },
  //     { targets: [ 9, 10, 11, 12, 13, 14 ], visible: false } // Consignee, Notify Party, POL, Booking No, MBL No, Order Type
  //   ]
  // });

  // var invoicesTable = $('#list-ivn-dbn').DataTable({
  //   order: [[ 1, 'desc' ]],
  //   buttons: [
  //     'pageLength',
  //     {
  //       extend: 'colvis',
  //       collectionLayout: 'fixed two-column',
  //       columns: ':not(.disable)',
  //       postfixButtons: [ { 
  //         text: 'Restore visibility',
  //         action: function ( e, dt, node, config ) {
  //           dt.columns().visible( true, false );
  //           dt.columns.adjust().draw( false );
  //         }
  //       } ]
  //     },
  //   ],
  //   columnDefs: [
  //     { targets: [ 0 ], orderable: false, searchable: false }
  //   ]
  // });
 
  // var costRevenuesTable = $('#cost-revenues').DataTable({
  //   order: [[ 1, 'desc' ]],
  //   buttons: [
  //     'pageLength',
  //     {
  //       extend: 'colvis',
  //       collectionLayout: 'fixed three-column',
  //       columns: ':not(.actions)',
  //       postfixButtons: [ {
  //         text: 'Restore visibility',
  //         action: function ( e, dt, node, config ) {
  //           dt.columns().visible( true, false );
  //           dt.columns.adjust().draw( false );
  //         }
  //       } ]
  //     },
  //   ],
  //   columnDefs: [
  //     { targets: [ 0 ], orderable: false, searchable: false }
  //   ]
  // });
  // cost_revenues.table().state.clear();

  jQuery(".columns li input[type=checkbox]").on("change", function () {
    var index = jQuery(this).attr("id");
    jQuery(".table thead tr th:eq(" + index + ")").toggleClass("hidden");
    jQuery(".table tbody tr").each(function () {
      var tr = jQuery(this);
      tr.find("td:eq(" + index + ")").toggleClass("hidden");
    })
  });

  jQuery(".dataTables_length select").change(function () {
    $.cookie("table_row", $(this).val());
  });

  jQuery(".paginate_enabled_next, .paginate_enabled_previous").on("click", function () {
    if (!jQuery(".dtable").hasClass("skip_checkbox")) {
      jQuery(".dtable thead tr th:gt(0)").addClass("hidden");
      jQuery(".dtable tbody tr").each(function () {
        var tr = jQuery(this);
        tr.find("td:gt(0)").addClass("hidden");
      });

      jQuery(".columns li input[type=checkbox]").each(function () {
        var index = jQuery(this).attr("id");
        if (jQuery(this).prop("checked")) {
          jQuery(".dtable thead tr th:eq(" + index + ")").removeClass("hidden");
          jQuery(".dtable tbody tr").each(function () {
            var tr = jQuery(this);
            tr.find("td:eq(" + index + ")").removeClass("hidden");
          });
        }
      });
    }
  })
})

// function add_invoice_fields() {
//   var count = $("table tr").length - 1;
//   var tmp = '' +
//     '<tr>' +
//     '<td><input type="text" name="invoice[invoice_details_attributes][' + count + '][description]" class="span12 invoice_description"></td>' +
//     '<td><input type="text" name="invoice[invoice_details_attributes][' + count + '][volume]" class="span12"></td>' +
//     '<td><input type="text" name="invoice[invoice_details_attributes][' + count + '][amount]" class="span12 invoice_amount"></td>' +
//     '<td><input type="hidden" name="invoice[invoice_details_attributes][' + count + '][destroy]" value="0"/>' +
//     '<a onclick="remove_invoice_fields(this); return false;" href="#"><i class="icon-remove-sign"></i></a></td>' +
//     '</tr>';
//   $("table").append(tmp);
// }

// function remove_invoice_fields(element) {
//   $(element).parent().parent().addClass("hidden");
//   $(element).parent().prev().children().focusout();
//   $(element).prev('input[type=hidden]').val('1')
// }

// function add_reference_fields() {
//   var count = $("#payment_references tr").length - 1;
//   // var tmp = '' +
//   //   '<tr>' +
//   //   '<td><input type="text" name="payment[payment_references_attributes][' + count + '][ibl_ref]" class="span12 payment_ibl_ref"></td>' +
//   //   '<td><input type="text" name="payment[payment_references_attributes][' + count + '][booking_no]" class="span12"></td>' +
//   //   '<td><input type="text" name="payment[payment_references_attributes][' + count + '][amount_invoice]" class="span12 payment_amount_invoice" style="text-align: right"></td>' +
//   //   '<td><input type="text" name="payment[payment_references_attributes][' + count + '][amount]" class="span12 payment_amount" style="text-align: right"></td>' +
//   //   '<td><input type="hidden" name="payment[payment_references_attributes][' + count + '][destroy]" value="0"/>' +
//   //   '<a onclick="remove_reference_fields(this); return false;" href="#"><i class="icon-remove-sign"></i></a></td>' +
//   //   '</tr>';
//   var tmp = '' +
//     '<tr>' +
//     '<td><input type="text" name="payment[payment_references_attributes][' + count + '][ibl_ref]" id="payment_payment_references_attributes_' + count + '_ibl_ref" class="span12 reference_ibl_ref" autocomplete="off"></td>' +
//     '<td><input type="text" name="payment[payment_references_attributes][' + count + '][booking_no]" id="payment_payment_references_attributes_' + count + '_booking_no" class="span12" autocomplete="off"></td>' +
//     '<td><input type="text" style="text-align: right" name="payment[payment_references_attributes][' + count + '][amount_invoice]" id="payment_payment_references_attributes_' + count + '_amount_invoice" class="reference_amount_invoice" autocomplete="off"></td>' +
//     '<td><input type="text" style="text-align: right" name="payment[payment_references_attributes][' + count + '][amount]" id="payment_payment_references_attributes_' + count + '_amount" class="reference_amount" autocomplete="off"></td>' +
//     '<td><input type="hidden" value="false" name="payment[payment_references_attributes][' + count + '][_destroy]" id="payment_payment_references_attributes_' + count + '__destroy" class="span12">' +
//     '<a title="Remove" href="#" tabindex="-1" onclick="remove_reference_fields(this); return false;"><i class="icon-remove-sign"></i></a></td>' +
//     '</tr>';
//   $("#payment_references").append(tmp);
// }

// function remove_reference_fields(element) {
//   $(element).parent().parent().addClass("hidden");
//   $(element).parent().prev().children().focusout();
//   $(element).prev('input[type=hidden]').val('1')
// }

function add_attachment_fields(obj) {
  var count = $("#attachments > div.row-fluid").length;
  var tmp = '' +
    '<div class="row-fluid">' +
    '<div class="span6">' +
    '<input type="text" placeholder="Attachment Name" name="' + obj + '[attachments_attributes][' + count + '][name]" id="' + obj + '_attachments_attributes_' + count + '_name" autocomplete="off">' +
    '<input type="hidden" name="' + obj + '[attachments_attributes][' + count + '][_destroy]" id="' + obj + '_attachments_attributes_' + count + '__destroy" class="span12">' +
    ' <a title="Remove" href="#" tabindex="-1" onclick="remove_attachment_fields(this); return false;" style="text-decoration: none"><i class="icon-remove-sign"></i></a>' +
    '</div>' +
    '<div class="span6"><input type="file" name="' + obj + '[attachments_attributes][' + count + '][asset]" id="' + obj + '_attachments_attributes_' + count + '_asset"></div>' +
    '</div>';
  $("#attachments").append(tmp);
}

function remove_attachment_fields(element) {
  $(element).parent().parent().addClass("hidden");
  $(element).prev('input[type=hidden]').val('1')
}

function add_debit_note_fields() {
  var count = $("table tr").length - 1;
  var tmp = '' +
    '<tr>' +
    '<td><input type="text" name="debit_note[debit_note_details_attributes][' + count + '][description]" class="span12 debit_note_description"></td>' +
    '<td><input type="text" name="debit_note[debit_note_details_attributes][' + count + '][volume]" class="span12"></td>' +
    '<td><input type="text" name="debit_note[debit_note_details_attributes][' + count + '][amount]" class="span12 invoice_amount"></td>' +
    '<td><input type="hidden" name="debit_note[debit_note_details_attributes][' + count + '][destroy]" value="0"/>' +
    '<a onclick="remove_invoice_fields(this); return false;" href="#"><i class="icon-remove-sign"></i></a></td>' +
    '</tr>';
  $("table").append(tmp);
}

function remove_debit_note_fields(element) {
  $(element).parent().parent().addClass("hidden");
  $(element).parent().prev().children().focusout();
  $(element).prev('input[type=hidden]').val('1')
}

function add_note_fields() {
  var count = $("table tr").length - 1;
  var tmp = '' +
    '<tr>' +
    '<td><input type="text" name="note[note_details_attributes][' + count + '][description]" class="span12 note_description"></td>' +
    '<td><input type="text" name="note[note_details_attributes][' + count + '][volume]" class="span12"></td>' +
    '<td><input type="text" name="note[note_details_attributes][' + count + '][amount]" class="span12 invoice_amount"></td>' +
    '<td><input type="hidden" name="note[note_details_attributes][' + count + '][destroy]" value="0"/>' +
    '<a onclick="remove_invoice_fields(this); return false;" href="#"><i class="icon-remove-sign"></i></a></td>' +
    '</tr>';
  $("table").append(tmp);
}

function remove_note_fields(element) {
  $(element).parent().parent().addClass("hidden");
  $(element).parent().prev().children().focusout();
  $(element).prev('input[type=hidden]').val('1')
}

function add_vessel_fields() {
  if ($(".vessel-group:not(.hidden)").length < 5) {
    var count = $(".vessel-group").length;
    var tmp = '' +
      '<div class="vessel-group">' +
      '<div class="control-group">' +
      '<label class="control-label" for="">Vessel Name :</label>' +
      '<div class="controls">' +
      '<input type="text" name="shipping_instruction[vessels_attributes][' + count + '][vessel_name]" id="shipping_instruction_vessels_attributes_' + count + '_vessel_name" class="span11 vessel_name">' +
      '<input type="hidden" value="false" name="shipping_instruction[vessels_attributes][' + count + '][_destroy]" id="shipping_instruction_vessels_attributes_' + count + '__destroy" class="span12">' +
      ' <a title="Remove" href="#" onclick="remove_vessel_fields(this); return false;"><i class="icon-remove-sign"></i></a>' +
      '</div>' +
      '</div>' +
      '<div class="control-group">' +
      '<label class="control-label" for="">ETD :</label>' +
      '<div class="controls">' +
      '<input type="text" name="shipping_instruction[vessels_attributes][' + count + '][etd_no]" id="shipping_instruction_vessels_attributes_' + count + '_etd_no" class="span5 etd_no"> ' +
      '<input type="text" name="shipping_instruction[vessels_attributes][' + count + '][etd_date]" id="shipping_instruction_vessels_attributes_' + count + '_etd_date" class="span6 datepicker etd_date">' +
      '</div>' +
      '</div>' +
      '<div class="control-group">' +
      '<label class="control-label" for="">ETA :</label>' +
      '<div class="controls">' +
      '<input type="text" name="shipping_instruction[vessels_attributes][' + count + '][eta_no]" id="shipping_instruction_vessels_attributes_' + count + '_eta_no" class="span5 eta_no"> ' +
      '<input type="text" name="shipping_instruction[vessels_attributes][' + count + '][eta_date]" id="shipping_instruction_vessels_attributes_' + count + '_eta_date" class="span6 datepicker eta_date">' +
      '</div>' +
      '</div>' +
      '</div>';
    $("#shipping_schedule").append(tmp);
  }
}

function remove_vessel_fields(element) {
  $(element).parent().parent().parent().addClass("hidden");
  $(element).prev('input[type=hidden]').val('1')
}

function add_custom_field(type, obj) {
  var count = $("#custom-fields .control-group").length;
  var tmp = '<div class="control-group">';
  switch (type) {
    case "address":
      tmp += '<label class="control-label"><input type="text" name="' + obj + '[custom_fields_attributes][' + count + '][field_name]" id="carrier_custom_fields_attributes_' + count + '_field_name" style="width: 90%" value="Address"></label>';
      tmp += '<div class="controls">';
      tmp += '<textarea style="height: 110px" name="' + obj + '[custom_fields_attributes][' + count + '][field_value]" id="carrier_custom_fields_attributes_' + count + '_field_value" class="span11 custom_address"></textarea>';
      tmp += '<input type="hidden" name="' + obj + '[custom_fields_attributes][' + count + '][field_key]" value="address" id="carrier_custom_fields_attributes_' + count + '_field_key">';
      tmp += '<input type="hidden" value="0" name="' + obj + '[custom_fields_attributes][' + count + '][_destroy]" id="carrier_custom_fields_attributes_' + count + '__destroy">';
      tmp += ' <a title="Remove" href="#" onclick="remove_custom_field(this); return false;"><i class="icon-remove-sign"></i></a>'
      tmp += '</div>';
      break;
    case "email":
      tmp += '<label class="control-label"><input type="text" name="' + obj + '[custom_fields_attributes][' + count + '][field_name]" id="carrier_custom_fields_attributes_' + count + '_field_name" style="width: 90%" value="Email Address"></label>';
      tmp += '<div class="controls">';
      tmp += '<input type="email" name="' + obj + '[custom_fields_attributes][' + count + '][field_value]" id="carrier_custom_fields_attributes_' + count + '_field_value" class="span11"/>';
      tmp += '<input type="hidden" name="' + obj + '[custom_fields_attributes][' + count + '][field_key]" value="email" id="carrier_custom_fields_attributes_' + count + '_field_key">';
      tmp += '<input type="hidden" value="0" name="' + obj + '[custom_fields_attributes][' + count + '][_destroy]" id="carrier_custom_fields_attributes_' + count + '__destroy">';
      tmp += ' <a title="Remove" href="#" onclick="remove_custom_field(this); return false;"><i class="icon-remove-sign"></i></a>'
      tmp += '</div>';
      break;
    case "phone":
      tmp += '<label class="control-label"><input type="text" name="' + obj + '[custom_fields_attributes][' + count + '][field_name]" id="carrier_custom_fields_attributes_' + count + '_field_name" style="width: 90%" value="Phone"></label>';
      tmp += '<div class="controls">';
      tmp += '<input type="text" name="' + obj + '[custom_fields_attributes][' + count + '][field_value]" id="carrier_custom_fields_attributes_' + count + '_field_value" class="span11"/>';
      tmp += '<input type="hidden" name="' + obj + '[custom_fields_attributes][' + count + '][field_key]" value="phone" id="carrier_custom_fields_attributes_' + count + '_field_key">';
      tmp += '<input type="hidden" value="0" name="' + obj + '[custom_fields_attributes][' + count + '][_destroy]" id="carrier_custom_fields_attributes_' + count + '__destroy">';
      tmp += ' <a title="Remove" href="#" onclick="remove_custom_field(this); return false;"><i class="icon-remove-sign"></i></a>'
      tmp += '</div>';
      break;
    case "pic":
      tmp += '<label class="control-label"><input type="text" name="' + obj + '[custom_fields_attributes][' + count + '][field_name]" id="carrier_custom_fields_attributes_' + count + '_field_name" style="width: 90%" value="PIC"></label>';
      tmp += '<div class="controls">';
      tmp += '<input type="text" name="' + obj + '[custom_fields_attributes][' + count + '][field_value]" id="carrier_custom_fields_attributes_' + count + '_field_value" class="span11"/>';
      tmp += '<input type="hidden" name="' + obj + '[custom_fields_attributes][' + count + '][field_key]" value="pic" id="carrier_custom_fields_attributes_' + count + '_field_key">';
      tmp += '<input type="hidden" value="0" name="' + obj + '[custom_fields_attributes][' + count + '][_destroy]" id="carrier_custom_fields_attributes_' + count + '__destroy">';
      tmp += ' <a title="Remove" href="#" onclick="remove_custom_field(this); return false;"><i class="icon-remove-sign"></i></a>'
      tmp += '</div>';
      break;
    case "url":
      tmp += '<label class="control-label"><input type="text" name="' + obj + '[custom_fields_attributes][' + count + '][field_name]" id="carrier_custom_fields_attributes_' + count + '_field_name" style="width: 90%" value="URL"></label>';
      tmp += '<div class="controls">';
      tmp += '<input type="url" name="' + obj + '[custom_fields_attributes][' + count + '][field_value]" id="carrier_custom_fields_attributes_' + count + '_field_value" class="span11"/>';
      tmp += '<input type="hidden" name="' + obj + '[custom_fields_attributes][' + count + '][field_key]" value="url" id="carrier_custom_fields_attributes_' + count + '_field_key">';
      tmp += '<input type="hidden" value="0" name="' + obj + '[custom_fields_attributes][' + count + '][_destroy]" id="carrier_custom_fields_attributes_' + count + '__destroy">';
      tmp += ' <a title="Remove" href="#" onclick="remove_custom_field(this); return false;"><i class="icon-remove-sign"></i></a>'
      tmp += '</div>';
      break;
    case "custom":
      tmp += '<label class="control-label"><input type="text" name="' + obj + '[custom_fields_attributes][' + count + '][field_name]" id="carrier_custom_fields_attributes_' + count + '_field_name" style="width: 90%" value="Other"></label>';
      tmp += '<div class="controls">';
      tmp += '<input type="text" name="' + obj + '[custom_fields_attributes][' + count + '][field_value]" id="carrier_custom_fields_attributes_' + count + '_field_value" class="span11"/>';
      tmp += '<input type="hidden" name="' + obj + '[custom_fields_attributes][' + count + '][field_key]" value="custom" id="carrier_custom_fields_attributes_' + count + '_field_key">';
      tmp += '<input type="hidden" value="0" name="' + obj + '[custom_fields_attributes][' + count + '][_destroy]" id="carrier_custom_fields_attributes_' + count + '__destroy">';
      tmp += ' <a title="Remove" href="#" onclick="remove_custom_field(this); return false;"><i class="icon-remove-sign"></i></a>'
      tmp += '</div>';
      break;
    case "fax":
      tmp += '<label class="control-label"><input type="text" name="' + obj + '[custom_fields_attributes][' + count + '][field_name]" id="carrier_custom_fields_attributes_' + count + '_field_name" style="width: 90%" value="Fax"></label>';
      tmp += '<div class="controls">';
      tmp += '<input type="text" name="' + obj + '[custom_fields_attributes][' + count + '][field_value]" id="carrier_custom_fields_attributes_' + count + '_field_value" class="span11"/>';
      tmp += '<input type="hidden" name="' + obj + '[custom_fields_attributes][' + count + '][field_key]" value="fax" id="carrier_custom_fields_attributes_' + count + '_field_key">';
      tmp += '<input type="hidden" value="0" name="' + obj + '[custom_fields_attributes][' + count + '][_destroy]" id="carrier_custom_fields_attributes_' + count + '__destroy">';
      tmp += ' <a title="Remove" href="#" onclick="remove_custom_field(this); return false;"><i class="icon-remove-sign"></i></a>'
      tmp += '</div>';
      break;
  }

  tmp += '</div>';
  $("#custom-fields").append(tmp);
  $('#carrier_custom_fields_attributes_' + count + '_field_value').focus();
}

function remove_custom_field(element) {
  $(element).parent().parent().addClass("hidden");
  $(element).prev('input[type=hidden]').val('1')
}


// function add_revenue_fields() {
//   var count = $(".revenue-table tbody tr").length;
//   var number = $(".revenue-table tbody tr:not(.hidden)").length;

//   var attr = 'active_items_attributes';
//   // var tmp = '' +
//   //   '<tr>' +
//   //   '<td align="center">' + (number + 1) + '</td>' +
//   //   '<td>' +
//   //   '<input type="text" value="" name="cost_revenue[cost_revenue_items_attributes][' + count + '][description]" id="cost_revenue_cost_revenue_items_attributes_' + count + '_description" class="cost_revenue_description cost_revenue_field" autocomplete="off">' +
//   //   '<input type="hidden" name="cost_revenue[cost_revenue_items_attributes][' + count + '][_destroy]" id="cost_revenue_cost_revenue_items_attributes_' + count + '__destroy" class="span12">' +
//   //   '<a class="remove_cost_revenue_description" title="Remove" tabindex="-1" href="#" onclick="remove_revenue_fields(this); return false;"><i class="icon-remove-sign"></i></a>' +
//   //   '</td>' +
//   //   '<td><input type="text" value="0" name="cost_revenue[cost_revenue_items_attributes][' + count + '][selling_usd]" id="cost_revenue_cost_revenue_items_attributes_' + count + '_selling_usd" class="cost_revenue_field money_text selling_usd" autocomplete="off"></td>' +
//   //   '<td><input type="text" value="0" name="cost_revenue[cost_revenue_items_attributes][' + count + '][selling_idr]" id="cost_revenue_cost_revenue_items_attributes_' + count + '_selling_idr" class="cost_revenue_field money_text selling_idr" autocomplete="off"></td>' +
//   //   '<td><input type="text" value="0" name="cost_revenue[cost_revenue_items_attributes][' + count + '][buying_usd]" id="cost_revenue_cost_revenue_items_attributes_' + count + '_buying_usd" class="cost_revenue_field money_text buying_usd" autocomplete="off"></td>' +
//   //   '<td><input type="text" value="0" name="cost_revenue[cost_revenue_items_attributes][' + count + '][buying_idr]" id="cost_revenue_cost_revenue_items_attributes_' + count + '_buying_idr" class="cost_revenue_field money_text buying_idr" autocomplete="off"></td>' +
//   //   '<td><input type="text" value="0" name="cost_revenue[cost_revenue_items_attributes][' + count + '][profit_usd]" id="cost_revenue_cost_revenue_items_attributes_' + count + '_profit_usd" disabled="disabled" class="cost_revenue_field money_text profit_usd"></td>' +
//   //   '<td><input type="text" value="0" name="cost_revenue[cost_revenue_items_attributes][' + count + '][profit_idr]" id="cost_revenue_cost_revenue_items_attributes_' + count + '_profit_idr" disabled="disabled" class="cost_revenue_field money_text profit_idr"></td>' +
//   //   '</tr>';
//   var tmp = '' +
//   '<tr class="active">' +
//   '<td align="center">' + (count+1) + '</td>' +
//   '<td>' +
//   '  <input type="text" name="cost_revenue[' + attr + '][' + count + '][description]" id="cost_revenue_' + attr + '_' + count + '_description" class="cost_revenue_description cost_revenue_field" autocomplete="off">' +
//   '  <input type="hidden" name="cost_revenue[' + attr + '][' + count + '][_destroy]" id="cost_revenue_' + attr + '_' + count + '__destroy" class="span12">' +
//   '  <a title="Remove" href="#" tabindex="-1" onclick="remove_revenue_fields(this); return false;" class="remove_cost_revenue_description"><i class="icon-remove-sign"></i></a>' +
//   '</td>' +
//   '<td class="text-right"><input type="text" name="cost_revenue[' + attr + '][' + count + '][selling_volume]" id="cost_revenue_' + attr + '_' + count + '_selling_volume" class="cost_revenue_field cost_revenue_volume volume_text selling_volume" autocomplete="off"></td>' +
//   '<td><input type="text" name="cost_revenue[' + attr + '][' + count + '][selling_usd]" id="cost_revenue_' + attr + '_' + count + '_selling_usd" class="cost_revenue_field money_text selling_usd" autocomplete="off"></td>' +
//   '<td><input type="text" name="cost_revenue[' + attr + '][' + count + '][selling_idr]" id="cost_revenue_' + attr + '_' + count + '_selling_idr" class="cost_revenue_field money_text selling_idr" autocomplete="off"></td>' +
//   '<td class="text-right cost_revenue_static"></td>' +
//   '<td class="text-right cost_revenue_static"></td>' +
//   '<td class="text-right"><input type="text" name="cost_revenue[' + attr + '][' + count + '][buying_volume]" id="cost_revenue_' + attr + '_' + count + '_buying_volume" class="cost_revenue_field cost_revenue_volume volume_text buying_volume" autocomplete="off"></td>' +
//   '<td><input type="text" name="cost_revenue[' + attr + '][' + count + '][buying_usd]" id="cost_revenue_' + attr + '_' + count + '_buying_usd" class="cost_revenue_field money_text buying_usd" autocomplete="off"></td>' +
//   '<td><input type="text" name="cost_revenue[' + attr + '][' + count + '][buying_idr]" id="cost_revenue_' + attr + '_' + count + '_buying_idr" class="cost_revenue_field money_text buying_idr" autocomplete="off"></td>' +
//   '<td class="text-right cost_revenue_static"></td>' +
//   '<td class="text-right cost_revenue_static"></td>' +
//   '</tr>';

//   $(".revenue-table tbody").append(tmp);

//   counter_revenue_fields();
// }

// function remove_revenue_fields(element) {
//   $(element).parent().parent().addClass("hidden");
//   $(element).prev('input[type=hidden]').val('1');

//   // count = 0;
//   // $(".revenue-table tbody tr").each(function () {
//   //   if (!$(this).hasClass("hidden")) {
//   //     count++;
//   //     $(this).find("td:eq(0)").text(count);
//   //   }
//   // });
//   counter_revenue_fields();
// }

// function counter_revenue_fields(element) {
//   count = 1;
//   $(".revenue-table tbody tr:not('.hidden')").each(function () {
//     $(this).find("td:eq(0)").text(count);
//     count++;
//   });
// }

// function add_cost_invoice_fields(invoice) {
//   var table = $(".invoice-table");
//   var count = $(".invoice-table tbody tr").length;
//   var number = $(".invoice-table tbody tr:not(.hidden)").length;
//   var invoice_count = 0;
//   var attr1 = 'payment_invoices_attributes';
//   // var attr2 = 'active_items_attributes';
//   var attr2 = 'payment_items_attributes';
//   table.each(function(index){
//     count = $(this).find("tbody tr").length;
//     invoice_count = index;
//     number = $(this).find("tbody tr:not(.hidden)").length;
//     // var tmp = '' +
//     //   '<tr>' +
//     //   '<td align="center">' + (number + 1) + '</td>' +
//     //   '<td>' +
//     //   '<input type="text" value="" name="carrier[carrier_items_attributes][' + count + '][description]" id="carrier_carrier_items_attributes_' + count + '_description" class="carrier_description carrier_field" autocomplete="off">' +
//     //   '<input type="hidden" name="carrier[carrier_items_attributes][' + count + '][_destroy]" id="carrier_carrier_items_attributes_' + count + '__destroy" class="span12">' +
//     //   '<a title="Remove" tabindex="-1" href="#" onclick="remove_revenue_fields(this); return false;"><i class="icon-remove-sign"></i></a>' +
//     //   '</td>' +
//     //   '<td><input type="text" value="0" name="carrier[carrier_items_attributes][' + count + '][selling_usd]" id="carrier_carrier_items_attributes_' + count + '_selling_usd" class="carrier_field money_text selling_usd" autocomplete="off"></td>' +
//     //   '<td><input type="text" value="0" name="carrier[carrier_items_attributes][' + count + '][selling_idr]" id="carrier_carrier_items_attributes_' + count + '_selling_idr" class="carrier_field money_text selling_idr" autocomplete="off"></td>' +
//     //   '</tr>';
//     var tmp= '' +
//       // '<tr>' +
//       // '<td class="hidden"></td>' +
//       // '<td>' +
//       // '  <input type="text" name="' + invoice + '[' + invoice + '_items_attributes][' + count + '][description]" id="' + invoice + '_' + invoice + '_items_attributes_' + count + '_description" class="invoice_description invoice_field" autocomplete="off">' +
//       // '  <a class="remove_invoice_description" title="Remove" href="#" tabindex="-1" onclick="remove_sell_cost_invoice_fields(this); return false;"><i class="icon-remove-sign"></i></a>' +
//       // '  <input type="hidden" name="' + invoice + '[' + invoice + '_items_attributes][' + count + '][_destroy]" id="' + invoice + '_' + invoice + '_items_attributes_' + count + '__destroy" class="span12">' +
//       // '</td>' +

//       // '<td class="text-right"><input type="text" name="' + invoice + '[' + invoice + '_items_attributes][' + count + '][volume]" id="' + invoice + '_' + invoice + '_items_attributes_' + count + '_volume" class="invoice_field invoice_volume money_text volume" autocomplete="off"></td>' +
//       // '<td><input type="text" name="' + invoice + '[' + invoice + '_items_attributes][' + count + '][amount_usd]" id="' + invoice + '_' + invoice + '_items_attributes_' + count + '_amount_usd" class="invoice_field money_text amount_usd" autocomplete="off"></td>' +
//       // '<td><input type="text" name="' + invoice + '[' + invoice + '_items_attributes][' + count + '][amount_idr]" id="' + invoice + '_' + invoice + '_items_attributes_' + count + '_amount_idr" class="invoice_field money_text amount_idr" autocomplete="off"></td>' +
//       // '<td class="text-right invoice_static"></td>' +
//       // '<td class="text-right invoice_static"></td>' +
//       // '<td class="text-center"><input type="hidden" value="0" name="' + invoice + '[' + invoice + '_items_attributes][' + count + '][add_vat_10]"><input type="checkbox" value="1" name="' + invoice + '[' + invoice + '_items_attributes][' + count + '][add_vat_10]" id="' + invoice + '_' + invoice + '_items_attributes_' + count + '_add_vat_10" class="invoice_checkbox add_vat_10"></td>' +
//       // '<td class="text-center"><input type="hidden" value="0" name="' + invoice + '[' + invoice + '_items_attributes][' + count + '][add_vat_1]"><input type="checkbox" value="1" name="' + invoice + '[' + invoice + '_items_attributes][' + count + '][add_vat_1]" id="' + invoice + '_' + invoice + '_items_attributes_' + count + '_add_vat_1" class="invoice_checkbox add_vat_1"></td>' +
//       // '<td class="text-center"><input type="hidden" value="0" name="' + invoice + '[' + invoice + '_items_attributes][' + count + '][add_pph_23]"><input type="checkbox" value="1" name="' + invoice + '[' + invoice + '_items_attributes][' + count + '][add_pph_23]" id="' + invoice + '_bill_of_lading_items_attributes_' + count + '_add_pph_23" class="invoice_checkbox add_pph_23"></td>' +
//       // '</tr>';

//     '<tr class="active">' +
//       '<td class="hidden"></td>' +
//       '<td>' +
//         '<input type="text" autocomplete="off" class="invoice_description invoice_field" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_' + attr2 + '_' + count + '_description" name="shipping_instruction[' + attr1 + '][' + invoice_count + '][' + attr2 + '][' + count + '][description]">' +
//         '<a class="remove_invoice_description" onclick="remove_sell_cost_invoice_fields(this); return false;" tabindex="-1" href="#" title="Remove"><i class="icon-remove-sign"></i></a>' +
//         '<input type="hidden" class="span12" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_' + attr2 + '_' + count + '__destroy" name="shipping_instruction[' + attr1 + '][' + invoice_count + '][' + attr2 + '][' + count + '][_destroy]">' +
//         '<input type="hidden" value="active" name="shipping_instruction[' + attr1 + '][' + invoice_count + '][' + attr2 + '][' + count + '][item_type]" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_' + attr2 + '_' + count + '_item_type" class="span12 item_type">' + 
//       '</td>' +
//       '<td class="text-right"><input type="text" autocomplete="off" class="invoice_field invoice_volume volume_text volume" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_' + attr2 + '_' + count + '_volume" name="shipping_instruction[' + attr1 + '][' + invoice_count + '][' + attr2 + '][' + count + '][volume]"></td>' +
//       '<td><input type="text" autocomplete="off" class="invoice_field money_text amount_usd" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_' + attr2 + '_' + count + '_amount_usd" name="shipping_instruction[' + attr1 + '][' + invoice_count + '][' + attr2 + '][' + count + '][amount_usd]"></td>' +
//       '<td><input type="text" autocomplete="off" class="invoice_field money_text amount_idr" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_' + attr2 + '_' + count + '_amount_idr" name="shipping_instruction[' + attr1 + '][' + invoice_count + '][' + attr2 + '][' + count + '][amount_idr]"></td>' +
//       '<td><input type="text" name="shipping_instruction[' + attr1 + '][' + invoice_count + '][' + attr2 + '][' + count + '][total]" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_' + attr2 + '_' + count + '_total" disabled="disabled" class="invoice_field money_text total" autocomplete="off"></td>' +
//       '<td><input type="text" name="shipping_instruction[' + attr1 + '][' + invoice_count + '][' + attr2 + '][' + count + '][total_after_tax]" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_' + attr2 + '_' + count + '_total_after_tax" disabled="disabled" class="invoice_field money_text total_after_tax" autocomplete="off"></td>' +
//       '<td class="text-center"><input type="hidden" name="shipping_instruction[' + attr1 + '][' + invoice_count + '][' + attr2 + '][' + count + '][add_vat_10]" value="0"><input type="checkbox" class="invoice_checkbox add_vat_10" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_' + attr2 + '_' + count + '_add_vat_10" name="shipping_instruction[' + attr1 + '][' + invoice_count + '][' + attr2 + '][' + count + '][add_vat_10]" value="1"></td>' +
//       '<td class="text-center"><input type="hidden" name="shipping_instruction[' + attr1 + '][' + invoice_count + '][' + attr2 + '][' + count + '][add_vat_1]" value="0"><input type="checkbox" class="invoice_checkbox add_vat_1" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_' + attr2 + '_' + count + '_add_vat_1" name="shipping_instruction[' + attr1 + '][' + invoice_count + '][' + attr2 + '][' + count + '][add_vat_1]" value="1"></td>' +
//       '<td class="text-center"><input type="hidden" name="shipping_instruction[' + attr1 + '][' + invoice_count + '][' + attr2 + '][' + count + '][add_pph_23]" value="0"><input type="checkbox" class="invoice_checkbox add_pph_23" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_' + attr2 + '_' + count + '_add_pph_23" name="shipping_instruction[' + attr1 + '][' + invoice_count + '][' + attr2 + '][' + count + '][add_pph_23]" value="1"></td>' +
//     '</tr>';
    
//     invoice_count++;
//     // console.log($(this).find("tbody tr:not('.hidden'):last td:eq(1) input").val());
//     if($(this).find("tbody tr:not('.hidden'):last td:eq(1) input").val() != ""){
//       $(this).find("tbody").append(tmp);
//     }
//   });
// }

// function add_sell_invoice_fields(invoice) {
//   var count = $(".invoice-table tbody tr").length;
//   var number = $(".invoice-table tbody tr:not(.hidden)").length;

//   var attr1 = 'bill_of_lading_invoice_attributes';
//   // var attr2 = 'active_items_attributes';
//   var attr2 = 'bill_of_lading_items_attributes';
//   // var tmp = '' +
//   //   '<tr>' +
//   //   '<td align="center">' + (number + 1) + '</td>' +
//   //   '<td>' +
//   //   '<input type="text" value="" name="carrier[carrier_items_attributes][' + count + '][description]" id="carrier_carrier_items_attributes_' + count + '_description" class="carrier_description carrier_field" autocomplete="off">' +
//   //   '<input type="hidden" name="carrier[carrier_items_attributes][' + count + '][_destroy]" id="carrier_carrier_items_attributes_' + count + '__destroy" class="span12">' +
//   //   '<a title="Remove" tabindex="-1" href="#" onclick="remove_revenue_fields(this); return false;"><i class="icon-remove-sign"></i></a>' +
//   //   '</td>' +
//   //   '<td><input type="text" value="0" name="carrier[carrier_items_attributes][' + count + '][selling_usd]" id="carrier_carrier_items_attributes_' + count + '_selling_usd" class="carrier_field money_text selling_usd" autocomplete="off"></td>' +
//   //   '<td><input type="text" value="0" name="carrier[carrier_items_attributes][' + count + '][selling_idr]" id="carrier_carrier_items_attributes_' + count + '_selling_idr" class="carrier_field money_text selling_idr" autocomplete="off"></td>' +
//   //   '</tr>';
//   var tmp= '' +
//     // '<tr>' +
//     // '<td class="hidden"></td>' +
//     // '<td>' +
//     // '  <input type="text" name="' + invoice + '[' + invoice + '_items_attributes][' + count + '][description]" id="' + invoice + '_' + invoice + '_items_attributes_' + count + '_description" class="invoice_description invoice_field" autocomplete="off">' +
//     // '  <a class="remove_invoice_description" title="Remove" href="#" tabindex="-1" onclick="remove_sell_cost_invoice_fields(this); return false;"><i class="icon-remove-sign"></i></a>' +
//     // '  <input type="hidden" name="' + invoice + '[' + invoice + '_items_attributes][' + count + '][_destroy]" id="' + invoice + '_' + invoice + '_items_attributes_' + count + '__destroy" class="span12">' +
//     // '</td>' +

//     // '<td class="text-right"><input type="text" name="' + invoice + '[' + invoice + '_items_attributes][' + count + '][volume]" id="' + invoice + '_' + invoice + '_items_attributes_' + count + '_volume" class="invoice_field invoice_volume money_text volume" autocomplete="off"></td>' +
//     // '<td><input type="text" name="' + invoice + '[' + invoice + '_items_attributes][' + count + '][amount_usd]" id="' + invoice + '_' + invoice + '_items_attributes_' + count + '_amount_usd" class="invoice_field money_text amount_usd" autocomplete="off"></td>' +
//     // '<td><input type="text" name="' + invoice + '[' + invoice + '_items_attributes][' + count + '][amount_idr]" id="' + invoice + '_' + invoice + '_items_attributes_' + count + '_amount_idr" class="invoice_field money_text amount_idr" autocomplete="off"></td>' +
//     // '<td class="text-right invoice_static"></td>' +
//     // '<td class="text-right invoice_static"></td>' +
//     // '<td class="text-center"><input type="hidden" value="0" name="' + invoice + '[' + invoice + '_items_attributes][' + count + '][add_vat_10]"><input type="checkbox" value="1" name="' + invoice + '[' + invoice + '_items_attributes][' + count + '][add_vat_10]" id="' + invoice + '_' + invoice + '_items_attributes_' + count + '_add_vat_10" class="invoice_checkbox add_vat_10"></td>' +
//     // '<td class="text-center"><input type="hidden" value="0" name="' + invoice + '[' + invoice + '_items_attributes][' + count + '][add_vat_1]"><input type="checkbox" value="1" name="' + invoice + '[' + invoice + '_items_attributes][' + count + '][add_vat_1]" id="' + invoice + '_' + invoice + '_items_attributes_' + count + '_add_vat_1" class="invoice_checkbox add_vat_1"></td>' +
//     // '<td class="text-center"><input type="hidden" value="0" name="' + invoice + '[' + invoice + '_items_attributes][' + count + '][add_pph_23]"><input type="checkbox" value="1" name="' + invoice + '[' + invoice + '_items_attributes][' + count + '][add_pph_23]" id="' + invoice + '_bill_of_lading_items_attributes_' + count + '_add_pph_23" class="invoice_checkbox add_pph_23"></td>' +
//     // '</tr>';

//     '<tr>' +
//       '<td class="hidden"></td>' +
//       '<td>' +
//         '<input type="text" name="shipping_instruction[' + attr1 + '][' + attr2 + '][' + count + '][description]" id="shipping_instruction_' + attr1 + '_' + attr2 + '_' + count + '_description" class="invoice_description invoice_field" autocomplete="off">' +
//         '<a title="Remove" href="#" tabindex="-1" onclick="remove_sell_cost_invoice_fields(this); return false;" class="remove_invoice_description"><i class="icon-remove-sign"></i></a>' +
//         '<input type="hidden" name="shipping_instruction[' + attr1 + '][' + attr2 + '][' + count + '][_destroy]" id="shipping_instruction_' + attr1 + '_' + attr2 + '_' + count + '__destroy" class="span12">' +
//         '<input type="hidden" value="active" name="shipping_instruction[' + attr1 + '][' + attr2 + '][' + count + '][item_type]" id="shipping_instruction_' + attr1 + '_' + attr2 + '_' + count + '_item_type" class="span12 item_type">' +
//       '</td>' +

//       '<td class="text-right"><input type="text" name="shipping_instruction[' + attr1 + '][' + attr2 + '][' + count + '][volume]" id="shipping_instruction_' + attr1 + '_' + attr2 + '_' + count + '_volume" class="invoice_field invoice_volume volume_text volume" autocomplete="off"></td>' +
//       '<td><input type="text" name="shipping_instruction[' + attr1 + '][' + attr2 + '][' + count + '][amount_usd]" id="shipping_instruction_' + attr1 + '_' + attr2 + '_' + count + '_amount_usd" class="invoice_field money_text amount_usd" autocomplete="off"></td>' +
//       '<td><input type="text" name="shipping_instruction[' + attr1 + '][' + attr2 + '][' + count + '][amount_idr]" id="shipping_instruction_' + attr1 + '_' + attr2 + '_' + count + '_amount_idr" class="invoice_field money_text amount_idr" autocomplete="off"></td>' +
//       '<td class="text-right"><input type="text" name="shipping_instruction[' + attr1 + '][' + attr2 + '][' + count + '][total]" id="shipping_instruction_' + attr1 + '_' + attr2 + '_' + count + '_total" disabled="disabled" class="invoice_field money_text total" autocomplete="off"></td>' +
//       '<td class="text-right"><input type="text" name="shipping_instruction[' + attr1 + '][' + attr2 + '][' + count + '][total_after_tax]" id="shipping_instruction_' + attr1 + '_' + attr2 + '_' + count + '_total_after_tax" disabled="disabled" class="invoice_field money_text total_after_tax" autocomplete="off"></td>' +
//       '<td class="text-center"><input type="hidden" value="0" name="shipping_instruction[' + attr1 + '][' + attr2 + '][' + count + '][add_vat_10]"><input type="checkbox" value="1" name="shipping_instruction[' + attr1 + '][' + attr2 + '][' + count + '][add_vat_10]" id="shipping_instruction_' + attr1 + '_' + attr2 + '_' + count + '_add_vat_10" class="invoice_checkbox add_vat_10"></td>' +
//       '<td class="text-center"><input type="hidden" value="0" name="shipping_instruction[' + attr1 + '][' + attr2 + '][' + count + '][add_vat_1]"><input type="checkbox" value="1" name="shipping_instruction[' + attr1 + '][' + attr2 + '][' + count + '][add_vat_1]" id="shipping_instruction_' + attr1 + '_' + attr2 + '_' + count + '_add_vat_1" class="invoice_checkbox add_vat_1"></td>' +
//       '<td class="text-center"><input type="hidden" value="0" name="shipping_instruction[' + attr1 + '][' + attr2 + '][' + count + '][add_pph_23]"><input type="checkbox" value="1" name="shipping_instruction[' + attr1 + '][' + attr2 + '][' + count + '][add_pph_23]" id="shipping_instruction_' + attr1 + '_' + attr2 + '_' + count + '_add_pph_23" class="invoice_checkbox add_pph_23"></td>' +
//     '</tr>';

//   if($(".invoice-table tbody tr:not('.hidden'):last td:eq(1) input").val() != ""){
//     $(".invoice-table tbody").append(tmp);
//   }
// }

// function remove_sell_cost_invoice_fields(element) {
//   $(element).parent().parent().addClass("hidden");
//   $(element).prev('input[type=hidden]').val('1');

//   count = 0;
//   $(".invoice-description table tbody tr").each(function () {
//     if (!$(this).hasClass("hidden")) {
//       count++;
//       $(this).find("td:eq(0)").text(count);
//     }
//   });
// }

// function add_payment_invoice_fields() {
//   var invoice_count = $(".invoice-table").length;
//   var count = 0;
//   // var number = $("table tbody tr:not(.hidden)").length;
//   var attr1 = 'payment_invoices_attributes';
//   var attr2 = 'payment_items_attributes';

//   var tmp= '' +
//   // '<div class="span6" style="margin-left: 0;"></div>' +
//   // '<div class="span6" style="margin-left: 0;">' +
//   '<div>' +
//     '<div class="details">' +
//       '<div>' +
//         '<strong>PAYMENT DATE <span class="pull-right">:</span></strong>' +
//         '<span class="invoice_text"><input type="text" autocomplete="off" class="span12 datepicker invoice_payment_date" id="shipping_instruction_payment_invoices_attributes_' + invoice_count + '_payment_date" name="shipping_instruction[' + attr1 + '][' + invoice_count + '][payment_date]">&nbsp;</span>' +
//       '</div>' +
//       '<div>' +
//         '<strong>CARRIER <span class="pull-right">:</span></strong>' +
//         '<span class="invoice_text"><input type="text" autocomplete="off" class="span12 invoice_carrier" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_carrier" name="shipping_instruction[' + attr1 + '][' + invoice_count + '][carrier]">&nbsp;</span>' +
//       '</div>' +
//       '<div>' +
//         '<strong>PAID <span class="pull-right">:</span></strong>' +
//         '<span><input type="hidden" name="shipping_instruction[' + attr1 + '][' + invoice_count + '][is_paid]" value="0"><input type="checkbox" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_is_paid" name="shipping_instruction[' + attr1 + '][' + invoice_count + '][is_paid]" value="1">&nbsp;</span>' +
//       '</div>' +
//     '</div>' +
//     '<div style="margin-top: 10px;">' +
//       '<table width="100%" border="1" class="invoice-table">' +
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
//           // '<tr class="volume_group"></tr>' +
//           // '<tr class="shipper_group"></tr>' +
//           // '<tr class="carrier_group"></tr>' +
//           // '<tr class="active_group"></tr>' +
          

//           // '<tr class="active">' +
//           //   '<td class="hidden"></td>' +
//           //   '<td>' +
//           //     '<input type="text" autocomplete="off" class="invoice_description invoice_field" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_' + attr2 + '_' + count + '_description" name="shipping_instruction[' + attr1 + '][' + invoice_count + '][' + attr2 + '][' + count + '][description]">' +
//           //     '<a class="remove_invoice_description" onclick="remove_sell_cost_invoice_fields(this); return false;" tabindex="-1" href="#" title="Remove"><i class="icon-remove-sign"></i></a>' +
//           //     '<input type="hidden" class="span12" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_' + attr2 + '_' + count + '__destroy" name="shipping_instruction[' + attr1 + '][' + invoice_count + '][' + attr2 + '][' + count + '][_destroy]">' +
//           //     '<input type="hidden" value="active" name="shipping_instruction[' + attr1 + '][' + invoice_count + '][' + attr2 + '][' + count + '][item_type]" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_' + attr2 + '_' + count + '_item_type" class="span12 item_type">' + 
//           //   '</td>' +
//           //   '<td class="text-right"><input type="text" autocomplete="off" class="invoice_field invoice_volume money_text volume" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_' + attr2 + '_' + count + '_volume" name="shipping_instruction[' + attr1 + '][' + invoice_count + '][' + attr2 + '][' + count + '][volume]"></td>' +
//           //   '<td><input type="text" autocomplete="off" class="invoice_field money_text amount_usd" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_' + attr2 + '_' + count + '_amount_usd" name="shipping_instruction[' + attr1 + '][' + invoice_count + '][' + attr2 + '][' + count + '][amount_usd]"></td>' +
//           //   '<td><input type="text" autocomplete="off" class="invoice_field money_text amount_idr" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_' + attr2 + '_' + count + '_amount_idr" name="shipping_instruction[' + attr1 + '][' + invoice_count + '][' + attr2 + '][' + count + '][amount_idr]"></td>' +
//           //   '<td><input type="text" name="shipping_instruction[' + attr1 + '][' + invoice_count + '][' + attr2 + '][' + count + '][total]" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_' + attr2 + '_' + count + '_total" disabled="disabled" class="invoice_field money_text total" autocomplete="off"></td>' +
//           //   '<td><input type="text" name="shipping_instruction[' + attr1 + '][' + invoice_count + '][' + attr2 + '][' + count + '][total_after_tax]" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_' + attr2 + '_' + count + '_total_after_tax" disabled="disabled" class="invoice_field money_text total_after_tax" autocomplete="off"></td>' +  
//           //   '<td class="text-center"><input type="hidden" name="shipping_instruction[' + attr1 + '][' + invoice_count + '][' + attr2 + '][' + count + '][add_vat_10]" value="0"><input type="checkbox" class="invoice_checkbox add_vat_10" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_' + attr2 + '_' + count + '_add_vat_10" name="shipping_instruction[' + attr1 + '][' + count + '][' + attr2 + '][' + count + '][add_vat_10]" value="1"></td>' +
//           //   '<td class="text-center"><input type="hidden" name="shipping_instruction[' + attr1 + '][' + invoice_count + '][' + attr2 + '][' + count + '][add_vat_1]" value="0"><input type="checkbox" class="invoice_checkbox add_vat_1" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_' + attr2 + '_' + count + '_add_vat_1" name="shipping_instruction[' + attr1 + '][' + count + '][' + attr2 + '][' + count + '][add_vat_1]" value="1"></td>' +
//           //   '<td class="text-center"><input type="hidden" name="shipping_instruction[' + attr1 + '][' + invoice_count + '][' + attr2 + '][' + count + '][add_pph_23]" value="0"><input type="checkbox" class="invoice_checkbox add_pph_23" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_' + attr2 + '_' + count + '_add_pph_23" name="shipping_instruction[' + attr1 + '][' + count + '][' + attr2 + '][' + count + '][add_pph_23]" value="1"></td>' +
//           // '</tr>' +

          
//         '</tbody>' +
//           // '    <tfoot>' +
//           // '      <tr>' +
//           // '        <td class="hidden"></td>' +
//           // '        <td colspan="4" class="text-right">TOTAL INVOICE EXCLUDE PPH 23</td>' +
//           // '        <td class="text-right"></td>' +
//           // '        <td>&nbsp;</td>' +
//           // '        <td>&nbsp;</td>' +
//           // '        <td>&nbsp;</td>' +
//           // '        <td>&nbsp;</td>' +
//           // '      </tr>' +
//           // '      <tr>' +
//           // '        <td class="hidden"></td>' +
//           // '        <td colspan="4" class="text-right">TOTAL INVOICE</td>' +
//           // '        <td class="text-right"></td>' +
//           // '        <td>&nbsp;</td>' +
//           // '        <td>&nbsp;</td>' +
//           // '        <td>&nbsp;</td>' +
//           // '        <td>&nbsp;</td>' +
//           // '      </tr>' +
//           // '    </tfoot>' +
//         '<tfoot>' +
//           '<tr>' +
//             '<td class="hidden"></td>' +
//             '<td class="text-left" colspan="5">OTHER</td>' +
//             '<td class="text-right">' +
//               '<input type="text" name="shipping_instruction[' + attr1 + '][' + invoice_count + '][other]" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_other" class="invoice_field money_text amount_idr other" autocomplete="off">' +
//             '</td>' +
//             '<td colspan="3">&nbsp;</td>' +
//           '</tr>' +
//           '<tr>' +
//             '<td class="hidden"></td>' +
//             '<td class="text-left" colspan="5">RATE</td>' +
//             '<td class="text-right">' +
//               '<input type="text" name="shipping_instruction[' + attr1 + '][' + invoice_count + '][rate]" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_rate" class="invoice_field money_text amount_idr rate" autocomplete="off">' +
//             '</td>' +
//             '<td colspan="3">&nbsp;</td>' +
//           '</tr>' +
//           '<tr>' +
//             '<td class="hidden"></td>' +
//             '<td class="text-left" colspan="5">VAT 10%</td>' +
//             '<td class="text-right">' +
//               '<input type="text" name="shipping_instruction[' + attr1 + '][' + invoice_count + '][vat_10]" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_vat_10" class="invoice_field money_text amount_idr vat_10" autocomplete="off" disabled="disabled">' +
//             '</td>' +
//             '<td colspan="3">&nbsp;</td>' +
//           '</tr>' +
//           '<tr>' +
//             '<td class="hidden"></td>' +
//             '<td class="text-left" colspan="5">VAT 1%</td>' +
//             '<td class="text-right">' +
//               '<input type="text" name="shipping_instruction[' + attr1 + '][' + invoice_count + '][vat_1]" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_vat_1" class="invoice_field money_text amount_idr vat_1" autocomplete="off" disabled="disabled">' +
//             '</td>' +
//             '<td colspan="3">&nbsp;</td>' +
//           '</tr>' +
//           '<tr>' +
//             '<td class="hidden"></td>' +
//             '<td class="text-left" colspan="5">PPH 23</td>' +
//             '<td class="text-right">' +
//               '<input type="text" name="shipping_instruction[' + attr1 + '][' + invoice_count + '][pph_23]" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_pph_23" class="invoice_field money_text amount_idr pph_23" autocomplete="off" disabled="disabled">' +
//             '</td>' +
//             '<td colspan="3">&nbsp;</td>' +
//           '</tr>' +
//           '<tr>' +
//             '<td class="hidden"></td>' +
//             '<td class="text-left" colspan="5">TOTAL INVOICE</td>' +
//             '<td class="text-right"><input type="text" name="shipping_instruction[' + attr1 + '][' + invoice_count + '][total_invoice]" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_total_invoice" disabled="disabled" class="invoice_field money_text amount_idr total_invoice" autocomplete="off"></td>' +
//             '<td colspan="3">&nbsp;</td>' +
//           '</tr>' +
//           '<tr>' +
//             '<td class="hidden"></td>' +
//             '<td class="text-left" colspan="5">TOTAL INVOICE INCLUDING PPH 23</td>' +
//             '<td class="text-right"><input type="text" name="shipping_instruction[' + attr1 + '][' + invoice_count + '][total_invoice_include_pph_23]" id="shipping_instruction_' + attr1 + '_' + invoice_count + '_total_invoice_include_pph_23" disabled="disabled" class="invoice_field money_text amount_idr total_invoice_include_pph_23" autocomplete="off"></td>' +
//             '<td colspan="3">&nbsp;</td>' +
//           '</tr>' +
//         '</tfoot>' +
//       '</table>' +
//     '</div>' +
//     '<div class="text-right">' +
//     // '  <a href="#" onclick="add_payment_invoice_fields(); return false;">ADD INVOICE</a>' +
//       '<input type="hidden" name="shipping_instruction[' + attr1 + '][' + invoice_count + '][_destroy]" id="shipping_instruction_' + attr1 + '_' + invoice_count + '__destroy" class="span12">' +
//       '<a href="#" onclick="remove_payment_invoice_fields(this); return false;" tabindex="-1">DELETE</a>' +
//     '</div>' +
//     '<br/><br/>';
//   '</div>';

//   $("#cost-invoices").append(tmp);
// }

// function remove_payment_invoice_fields(element) {
//   // $(element).parent().parent().addClass("hidden");
//   $(element).prev('input[type=hidden]').val('1');
//   var table2 = $(element).parent().parent();
//   table2.css("display", "none");
//   // table2.prev('div').css("display", "none");

//   // count = 0;
//   // $("#invoice-description table tbody tr").each(function () {
//   //   if (!$(this).hasClass("hidden")) {
//   //     count++;
//   //     $(this).find("td:eq(0)").text(count);
//   //   }
//   // });
// }

// function remove_cost_invoice_fields(element) {
//   $(element).prev('input[type=hidden]').val('1');
//   var table2 = $(element).parent().parent();
//   table2.css("display", "none");
// }
