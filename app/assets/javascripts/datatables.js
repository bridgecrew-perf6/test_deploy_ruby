var ready;
var shippingInstructionsTable, billOfLadingsTable, shipmentsTrackingTable, invoicesTable, paymentsPlanTable, paymentsInquiryTable, paymentsTaxTable, paymentsDepositTable, controlCenterTable, controlCenterShortPaidTable, controlCenterDepositTable, costRevenuesTable;
ready = function(){
  'use strict';
  // if(shippingInstructionsTable != undefined)
  //     shippingInstructionsTable.destroy();
  // if(billOfLadingsTable != undefined)
  //     billOfLadingsTable.destroy();

// if(typeof dataTable === 'undefined'){
  if($('#shipping_instructions_table').length != 0){
    // shippingInstructionsTable = undefined;
    if( $.fn.dataTable.isDataTable('#shipping_instructions_table') == false){
      // if(shippingInstructionsTable == undefined){
      shippingInstructionsTable = $('#shipping_instructions_table').DataTable({
        order: [[ 1, 'desc' ]],
        buttons: [
          'pageLength',
          {
            extend: 'colvis',
            collectionLayout: 'fixed two-column',
            columns: ':not(.disable)',
            postfixButtons: [ {
              text: 'Restore visibility',
              action: function ( e, dt, node, config ) {
                dt.columns().visible( true, false );
                dt.columns( [ 9, 10, 11, 12, 14 ] ).visible(false, false);
                dt.columns.adjust().draw( false );
              }
            } ]
          },
        ],
        columnDefs: [
          { targets: [ 0 ], orderable: false, searchable: false },
          { targets: [ 9, 10, 11, 12, 13, 14 ], visible: false }, // Consignee, Notify Party, POL, Booking No, MBL No, Order Type
          // { targets: [ 15, 16, 17, 18, 19 ], visible: false }
        ],
        footerCallback: function ( row, data, start, end, display ) {
          var api = this.api(), data;

          // Remove the formatting to get integer data for summation
          var intVal = function ( i ) {
            // return typeof i === 'string' ? i.replace(/[\USD IDR,]/g, '')*(1 : typeof i === 'number' ? i : 0;
            var flag = 1;
            i = i+'';
            if(i.indexOf('(') != -1 || i.indexOf(')') != -1)
              flag = -1;
            return typeof i === 'string' ? i.replace(/[\()USD IDR,]/g, '')*1*flag : typeof i === 'number' ? i*flag : 0;
          };

          // Total over all pages
          var summary = Array();
          var si = {};
          var cancel_si = {};
          api.rows({search:'applied'}).every( function ( rowIdx, tableLoop, rowLoop ) {
            var data = this.data();

            if (data[21] == 'false') {
              var index = data[15] ? data[15]:'undefined';
              if (si[index]) {
                si[index]++;
              } else {
                si[index] = 1;
              }
              if(data[20].indexOf("Cancel") != -1){
                if (cancel_si[index]) {
                  cancel_si[index]++;
                } else {
                  cancel_si[index] = 1;
                }
              }
            }
          });

          console.log(si);
          console.log(cancel_si);
          // Total over this page
          var tmp = '';
          tmp = '' +
          '<table width="100%" border="1">' +
            '<thead>' +
              '<tr>' +
                '<th>SI</th>' +
                '<th>Cancel SI</th>' +
                '<th>Shipment</th>' +
                '<th>Handle By</th>' +
              '</tr>' +
            '</thead>' +
            '<tbody>';
            $.each(si, function(i, row){
              if (!si[i]) si[i] = 0;
              if (!cancel_si[i]) cancel_si[i] = 0;
              tmp += '' +
                '<tr>' +
                  '<td>'+si[i]+'</td>' +
                  '<td>'+cancel_si[i]+'</td>' +
                  '<td>'+(si[i] - cancel_si[i])+'</td>' +
                  '<td>'+i+'</td>' +
                '</tr>';
            });
            var sum_si = 0;
            var sum_cancel_si = 0;
            $.each(si,function(){ sum_si+=number_format(this); });
            $.each(cancel_si,function(){ sum_cancel_si+=number_format(this); });
            tmp += '' +
            '</tbody>' +
            '<tfoot>' +
              '<tr>' +
                '<td>'+sum_si+'</td>' +
                '<td>'+sum_cancel_si+'</td>' +
                '<td>'+(sum_si - sum_cancel_si)+'</td>' +
                '<td>Total</td>' +
              '</tr>' +
            '</tfoot>' +
          '</table>';

          $('#viewSummaryModal .modal-body').html(tmp);
        }
      });
      // shippingInstructionsTable.page.len( 100 ).draw();
      // }
      // var tables = $('.dataTable').DataTable();
      // shippingInstructionsTable = tables.table('#shipping_instructions_table');
      // var api = new jQuery.fn.dataTable.Api('#shipping_instructions_table'); var oTable = api.table();
    }
      yadcf.init(shippingInstructionsTable, [
        // {column_number : 1, filter_container_id: "si_no", filter_type: "auto_complete", filter_default_label: ""},
        // {column_number : 2, filter_container_id: "shipper_reference", filter_type: "auto_complete", filter_default_label: ""},
        {column_number : 3, filter_container_id: "shipper", filter_type: "auto_complete", filter_default_label: ""},
        {column_number : 4, filter_container_id: "volume", filter_type: "auto_complete", filter_default_label: "", text_data_delimiter: " &amp; "},
        {column_number : 5, filter_container_id: "destination", filter_type: "auto_complete", filter_default_label: ""},
        // {column_number : 6, filter_container_id: "etd_vessel", filter_type: "date", date_format: "dd-M-yy", filter_default_label: ""},
        {column_number : 7, filter_container_id: "si_date", filter_type: "date", date_format: "dd-M-yy", filter_default_label: ""},
        {column_number : 8, filter_container_id: "carrier", filter_type: "auto_complete", filter_default_label: ""},
        {column_number : 9, filter_container_id: "consignee", filter_type: "auto_complete", filter_default_label: ""},
        // {column_number : 10, filter_container_id: "notify_party", filter_type: "auto_complete", filter_default_label: ""},
        {column_number : 11, filter_container_id: "pol", filter_type: "auto_complete", filter_default_label: ""},
        // {column_number : 12, filter_container_id: "booking_no", filter_type: "auto_complete", filter_default_label: ""},
        // {column_number : 13, filter_container_id: "mbl_no", filter_type: "auto_complete", filter_default_label: ""},
        {column_number : 14, filter_container_id: "order_type", filter_type: "auto_complete", filter_default_label: ""},
        {column_number : 15, filter_container_id: "handle_by", filter_type: "auto_complete", filter_default_label: ""},
        {column_number : 16, filter_container_id: "monthly", filter_type: "auto_complete", filter_default_label: ""},
        {column_number : 17, filter_container_id: "date_range", filter_type: "range_date"},
        // {column_number : 18  , filter_container_id: "ibl_ref", filter_type: "auto_complete", filter_default_label: ""}
      ], { externally_triggered: true });
    // }
  }

  if($('#bill_of_ladings_table').length != 0){
    if( $.fn.dataTable.isDataTable('#bill_of_ladings_table') == false){
      billOfLadingsTable = $('#bill_of_ladings_table').DataTable({
        order: [[ 1, 'desc' ]],
        buttons: [
          'pageLength',
          {
            extend: 'colvis',
            collectionLayout: 'fixed two-column',
            columns: ':not(.disable)',
            postfixButtons: [ {
              text: 'Restore visibility',
              action: function ( e, dt, node, config ) {
                dt.columns().visible( true, false );
                dt.columns( [ 5, 6 ]).visible(false, false);
                dt.columns.adjust().draw( false );
              }
            } ]
          },
        ],
        columnDefs: [
          { targets: [ 0 ], orderable: false, searchable: false },
          { targets: [ 4, 5, 8 ], visible: false } // Consignee, Notify Party, POL
        ]
      });
      // billOfLadingsTable.page.len( 100 ).draw();
    }
    yadcf.init(billOfLadingsTable, [
      // {column_number : 1, filter_container_id: "si_no", filter_type: "auto_complete", filter_default_label: ""},
      // {column_number : 2, filter_container_id: "mbl_no", filter_type: "auto_complete", filter_default_label: ""},
      {column_number : 3, filter_container_id: "carrier", filter_type: "auto_complete", filter_default_label: ""},
      {column_number : 4, filter_container_id: "shipper", filter_type: "auto_complete", filter_default_label: ""},
      // {column_number : 5, filter_container_id: "consignee", filter_type: "auto_complete", filter_default_label: ""},
      // {column_number : 6, filter_container_id: "notify_party", filter_type: "auto_complete", filter_default_label: ""},
      {column_number : 7, filter_container_id: "destination", filter_type: "auto_complete", filter_default_label: ""},
      // {column_number : 8, filter_container_id: "invoice", filter_type: "auto_complete", filter_default_label: ""},
      // {column_number : 9, filter_container_id: "volume", filter_type: "auto_complete", filter_default_label: ""},
      {column_number : 10, filter_container_id: "order_type", filter_type: "auto_complete", filter_default_label: ""},
      // {column_number : 11, filter_container_id: "payment", filter_type: "auto_complete", filter_default_label: "", text_data_delimiter: "<br>"},
      {column_number : 12, filter_container_id: "pol", filter_type: "auto_complete", filter_default_label: ""},
      // {column_number : 13, filter_container_id: "etd_vessel", filter_type: "date", date_format: "dd-M-yy", filter_default_label: ""},
      // {column_number : 14, filter_container_id: "delivery_doc", filter_type: "auto_complete", filter_default_label: ""},
      {column_number : 15, filter_container_id: "monthly", filter_type: "auto_complete", filter_default_label: ""},
      {column_number : 16, filter_container_id: "date_range", filter_type: "range_date"},
      // {column_number : 18, filter_container_id: "ibl_ref", filter_type: "auto_complete", filter_default_label: ""},
      // {column_number : 19, filter_container_id: "invoice", filter_type: "auto_complete", filter_default_label: "", text_data_delimiter: "<br>"},
      // {column_number : 20, filter_container_id: "payment", filter_type: "auto_complete", filter_default_label: "", text_data_delimiter: "<br>"},
      {column_number : 21, filter_container_id: "delivery_doc",
        data: [ { value: "Not Yet", label: "Not Yet"},
                { value: "Done", label: "Done"} ],
        filter_default_label: "All"},
    ], { externally_triggered: true });
  }

  if($('#shipments_tracking_table').length != 0){
    if( $.fn.dataTable.isDataTable('#shipments_tracking_table') == false){
      shipmentsTrackingTable = $('#shipments_tracking_table').DataTable({
        order: [[ 1, 'desc' ]],
        buttons: [
          'pageLength',
          {
            extend: 'colvis',
            collectionLayout: 'fixed two-column',
            columns: ':not(.disable)',
            postfixButtons: [ {
              text: 'Restore visibility',
              action: function ( e, dt, node, config ) {
                dt.columns().visible( true, false );
                // dt.columns( [ 3, 4, 6, 7 ] ).visible(false, false);
                dt.columns( [ 9, 10, 11 ] ).visible(false, false);
                dt.columns.adjust().draw( false );
              }
            } ]
          },
        ],
        columnDefs: [
          { targets: [ 0 ], orderable: false, searchable: false },
          // { targets: [ 3, 4, 6, 7 ], visible: false } // Shipper SI #, MBL #, Volume, Destination
          { targets: [ 9, 10, 11 ], visible: false } // Shipper SI #, MBL #, Volume, Destination
        ]
      });
      // shipmentsTrackingTable.page.len( 100 ).draw();
    }
    yadcf.init(shipmentsTrackingTable, [
      // {column_number : 1, filter_container_id: "ibl_ref", filter_type: "auto_complete", filter_default_label: ""},
      {column_number : 2, filter_container_id: "shipper", filter_type: "auto_complete", filter_default_label: ""},
      {column_number : 3, filter_container_id: "consignee", filter_type: "auto_complete", filter_default_label: ""},
      {column_number : 4, filter_container_id: "carrier", filter_type: "auto_complete", filter_default_label: ""},
      {column_number : 5, filter_container_id: "feeder", filter_type: "auto_complete", filter_default_label: ""},
      // {column_number : 6, filter_container_id: "etd_feeder", filter_type: "date", date_format: "dd-M-yy", filter_default_label: ""},
      {column_number : 7, filter_container_id: "pol", filter_type: "auto_complete", filter_default_label: ""},
      {column_number : 8, filter_container_id: "destination", filter_type: "auto_complete", filter_default_label: ""},
      // {column_number : 9, filter_container_id: "eta_dest", filter_type: "date", date_format: "dd-M-yy", filter_default_label: ""},
      // {column_number : 10, filter_container_id: "shipper_ref", filter_type: "auto_complete", filter_default_label: ""},
      // {column_number : 11, filter_container_id: "booking_no", filter_type: "auto_complete", filter_default_label: ""},
      // {column_number : 12, filter_container_id: "mbl", filter_type: "auto_complete", filter_default_label: ""},
      // {column_number : 13, filter_container_id: "transit_time", filter_type: "auto_complete", filter_default_label: ""},
      {column_number : 14, filter_container_id: "free_time",
        data: [ { value: "Request", label: "Request"},
                { value: "Approved", label: "Approved"},
                { value: "No Request", label: "No Request"} ],
        filter_default_label: "All"},
      // {column_number : 15, filter_container_id: "notes", filter_type: "auto_complete", filter_default_label: ""},
      {column_number : 16, filter_container_id: "fu_date", filter_type: "date", date_format: "dd-M-yy", filter_default_label: ""},
      {column_number : 17, filter_container_id: "monthly", filter_type: "auto_complete", filter_default_label: ""},
      {column_number : 18, filter_container_id: "date_range", filter_type: "range_date"},
      // {column_number : 20, filter_container_id: "ibl_ref", filter_type: "auto_complete", filter_default_label: ""},
      // {column_number : 21, filter_container_id: "notes", filter_type: "auto_complete", filter_default_label: ""},
      // {column_number : 21, filter_container_id: "vessel_name", filter_type: "auto_complete", filter_default_label: "", text_data_delimiter: "<br>"},
    ], { externally_triggered: true });
  }

  if($('#invoices_table').length != 0){
    if( $.fn.dataTable.isDataTable('#invoices_table') == false){
      invoicesTable = $('#invoices_table').DataTable({
        order: [[ 1, 'desc' ]],
        buttons: [
          'pageLength',
          {
            extend: 'colvis',
            collectionLayout: 'fixed two-column',
            columns: ':not(.disable)',
            postfixButtons: [ {
              text: 'Restore visibility',
              action: function ( e, dt, node, config ) {
                dt.columns().visible( true, false );
                dt.columns( [ 4, 6, 7, 10, 12, 14 ] ).visible(false, false);
                dt.columns.adjust().draw( false );
              }
            } ]
          },
        ],
        columnDefs: [
          { targets: [ 0 ], orderable: false, searchable: false },
          { targets: [ 4, 6, 7, 10, 12, 14 ], visible: false }
        ]
      });
      // invoicesTable.page.len( 100 ).draw();
    }
    yadcf.init(invoicesTable, [
      // {column_number : 1, filter_container_id: "invoice_no", filter_type: "auto_complete", filter_default_label: ""},
      // {column_number : 2, filter_container_id: "ibl_ref", filter_type: "auto_complete", filter_default_label: ""},
      {column_number : 3, filter_container_id: "currency",
        data: [ { value: "USD", label: "USD"},
                { value: "IDR", label: "IDR"} ],
        filter_default_label: "All"},
      // {column_number : 4, filter_container_id: "total", filter_type: "auto_complete", filter_default_label: ""},
      {column_number : 5, filter_container_id: "customer", filter_type: "auto_complete", filter_default_label: ""},
      {column_number : 6, filter_container_id: "shipper", filter_type: "auto_complete", filter_default_label: ""},
      // {column_number : 7, filter_container_id: "pol", filter_type: "auto_complete", filter_default_label: ""},
      {column_number : 8, filter_container_id: "invoice_status",
        data: [ { value: "Open", label: "Open"},
                // { value: "Closed", label: "Closed"},
                { value: "Printed", label: "Printed"},
                { value: "Cancel", label: "Cancel"} ],
        filter_default_label: "All"},
      // {column_number : 9, filter_container_id: "vat_10_no", filter_type: "auto_complete", filter_default_label: ""},
      // {column_number : 10, filter_container_id: "vat_10", filter_type: "auto_complete", filter_default_label: ""},
      // {column_number : 11, filter_container_id: "vat_1_no", filter_type: "auto_complete", filter_default_label: ""},
      // {column_number : 12, filter_container_id: "vat_1", filter_type: "auto_complete", filter_default_label: ""},
      // {column_number : 13, filter_container_id: "pph_23_no", filter_type: "auto_complete", filter_default_label: ""},
      // {column_number : 14, filter_container_id: "pph_23", filter_type: "auto_complete", filter_default_label: ""},
      {column_number : 15, filter_container_id: "tax_status",
        data: [ { value: "Open", label: "Open"},
                { value: "Completed", label: "Completed"} ],
        filter_default_label: "All"},
      {column_number : 16, filter_container_id: "tax_issued", filter_type: "auto_complete", filter_default_label: ""},
      {column_number : 17, filter_container_id: "paid_month", filter_type: "auto_complete", filter_default_label: ""},
      {column_number : 18, filter_container_id: "monthly", filter_type: "auto_complete", filter_default_label: ""},
      {column_number : 19, filter_container_id: "date_range", filter_type: "range_date"},
      // {column_number : 21, filter_container_id: "ibl_ref", filter_type: "auto_complete", filter_default_label: ""},
      // {column_number : 22, filter_container_id: "invoice_no", filter_type: "auto_complete", filter_default_label: ""},
      {column_number : 23, filter_container_id: "head_letter",
        data: [ { value: "Invoice", label: "Invoice"},
                { value: "Credit Note", label: "Credit Note"},
                { value: "Reimbursement Cost", label: "Reimbursement Cost"},
                { value: "Debit Note", label: "Debit Note"} ],
        filter_default_label: "All" },
    ], { externally_triggered: true });
  }

  if($('#payments_plan_table').length != 0){
    if( $.fn.dataTable.isDataTable('#payments_plan_table') == false){
      paymentsPlanTable = $("#payments_plan_table").DataTable({
        order: [[ 1, "desc" ]],
        buttons: [
          'pageLength',
          {
            extend: 'colvis',
            collectionLayout: 'fixed two-column',
            columns: ':not(.disable)',
            postfixButtons: [ {
              text: 'Restore visibility',
              action: function ( e, dt, node, config ) {
                dt.columns().visible( true, false );
                dt.columns.adjust().draw( false );
              }
            } ]
          },
        ],
        columnDefs: [
          { targets: [ 0 ], orderable: false, searchable: false },
        ]
      });
      // paymentsPlanTable.page.len( 100 ).draw();
    }
    yadcf.init(paymentsPlanTable, [
      // {column_number : 1, filter_container_id: "si_no", filter_type: "auto_complete", filter_default_label: ""},
      // {column_number : 2, filter_container_id: "booking_no", filter_type: "auto_complete", filter_default_label: ""},
      // {column_number : 3, filter_container_id: "mbl_no", filter_type: "auto_complete", filter_default_label: ""},
      // {column_number : 4, filter_container_id: "volume", filter_type: "auto_complete", filter_default_label: ""},
      {column_number : 5, filter_container_id: "carrier", filter_type: "auto_complete", filter_default_label: ""},
      {column_number : 6, filter_container_id: "shipper", filter_type: "auto_complete", filter_default_label: ""},
      {column_number : 7, filter_container_id: "pol", filter_type: "auto_complete", filter_default_label: ""},
      {column_number : 8, filter_container_id: "destination", filter_type: "auto_complete", filter_default_label: ""},
      // {column_number : 9, filter_container_id: "amount", filter_type: "auto_complete", filter_default_label: ""},
      {column_number : 10, filter_container_id: "payment_date", filter_type: "date", date_format: "dd-M-yy", filter_default_label: ""},
      // {column_number : 11, filter_container_id: "etd_vessel", filter_type: "date", date_format: "dd-M-yy", filter_default_label: ""},
      // {column_number : 12, filter_container_id: "paid_status",
      //   data: [ { value: "Yes", label: "Yes"},
      //           { value: "No", label: "No"} ],
      //   filter_default_label: "All" },
      {column_number : 13, filter_container_id: "bl_status",
        data: [ { value: "Cancel", label: "Cancel"},
                { value: "On Going", label: "On Going"},
                { value: "Draft BL", label: "Draft BL"} ],
        filter_default_label: "All" },
      {column_number : 14, filter_container_id: "monthly", filter_type: "auto_complete", filter_default_label: ""},
      {column_number : 15, filter_container_id: "date_range", filter_type: "range_date"},
      // {column_number : 16, filter_container_id: "ibl_ref", filter_type: "auto_complete", filter_default_label: ""},
    ], { externally_triggered: true });
  }

  if($('#payments_inquiry_table').length != 0){
    if( $.fn.dataTable.isDataTable('#payments_inquiry_table') == false){
      paymentsInquiryTable = $("#payments_inquiry_table").DataTable({
        order: [[ 1, "desc" ]],
        buttons: [
          'pageLength',
          {
            extend: 'colvis',
            collectionLayout: 'fixed two-column',
            columns: ':not(.disable)',
            postfixButtons: [ {
              text: 'Restore visibility',
              action: function ( e, dt, node, config ) {
                dt.columns().visible( true, false );
                dt.columns.adjust().draw( false );
              }
            } ]
          },
        ],
        columnDefs: [
          { targets: [ 0 ], orderable: false, searchable: false },
        ]
      });
      // paymentsInquiryTable.page.len( 100 ).draw();
    }
    yadcf.init(paymentsInquiryTable, [
      // {column_number : 1, filter_container_id: "payment_no", filter_type: "auto_complete", filter_default_label: ""},
      // {column_number : 2, filter_container_id: "ibl_ref", filter_type: "auto_complete", filter_default_label: ""},
      // {column_number : 3, filter_container_id: "booking_no", filter_type: "auto_complete", filter_default_label: ""},
      {column_number : 4, filter_container_id: "shipper", filter_type: "auto_complete", filter_default_label: ""},
      {column_number : 5, filter_container_id: "pol", filter_type: "auto_complete", filter_default_label: ""},
      {column_number : 6, filter_container_id: "destination", filter_type: "auto_complete", filter_default_label: ""},
      // {column_number : 7, filter_container_id: "volume", filter_type: "auto_complete", filter_default_label: ""},
      {column_number : 8, filter_container_id: "carrier", filter_type: "auto_complete", filter_default_label: ""},
      // {column_number : 9, filter_container_id: "amount", filter_type: "auto_complete", filter_default_label: ""},
      // {column_number : 10, filter_container_id: "notes", filter_type: "auto_complete", filter_default_label: ""},
      // {column_number : 11, filter_container_id: "etd_vessel", filter_type: "date", date_format: "dd-M-yy", filter_default_label: ""},
      // {column_number : 12, filter_container_id: "payment_date", filter_type: "date", date_format: "dd-M-yy", filter_default_label: ""},
      {column_number : 13, filter_container_id: "status",
        data: [ { value: "Open", label: "Open"},
                { value: "Send", label: "Send"},
                { value: "Cancel", label: "Cancel"} ],
        filter_default_label: "All" },
      {column_number : 14, filter_container_id: "monthly", filter_type: "auto_complete", filter_default_label: ""},
      {column_number : 15, filter_container_id: "date_range", filter_type: "range_date"},
      // {column_number : 17, filter_container_id: "ibl_ref", filter_type: "auto_complete", filter_default_label: ""},
      {column_number : 18, filter_container_id: "currency",
        data: [ { value: "USD", label: "USD"},
                { value: "IDR", label: "IDR"} ],
        filter_default_label: "All" },
      {column_number : 20, filter_container_id: "payment_date_monthly", filter_type: "auto_complete", filter_default_label: ""},
      {column_number : 21, filter_container_id: "payment_date_date_range", filter_type: "range_date"},
      {column_number : 22, filter_container_id: "method",
        data: [ { value: "Cash", label: "Cash"},
                { value: "Bank Transaction", label: "Bank Transaction"} ],
        filter_default_label: "All" },
    ], { externally_triggered: true });
  }

  if($('#payments_tax_table').length != 0){
    if( $.fn.dataTable.isDataTable('#payments_tax_table') == false){
      paymentsTaxTable = $("#payments_tax_table").DataTable({
        order: [[ 1, "desc" ]],
        buttons: [
          'pageLength',
          {
            extend: 'colvis',
            collectionLayout: 'fixed two-column',
            columns: ':not(.disable)',
            postfixButtons: [ {
              text: 'Restore visibility',
              action: function ( e, dt, node, config ) {
                dt.columns().visible( true, false );
                dt.columns.adjust().draw( false );
              }
            } ]
          },
        ],
        columnDefs: [
          { targets: [ 0 ], orderable: false, searchable: false },
        ]
      });
      // paymentsTaxTable.page.len( 100 ).draw();
    }
    // yadcf.init(paymentsTaxTable, [
    //   {column_number : 1, filter_container_id: "carrier", filter_type: "auto_complete", filter_default_label: ""},
    //   // {column_number : 2, filter_container_id: "ibl_ref", filter_type: "auto_complete", filter_default_label: ""},
    //   // {column_number : 3, filter_container_id: "amount_tax", filter_type: "auto_complete", filter_default_label: ""},
    //   // {column_number : 4, filter_container_id: "tax_no", filter_type: "auto_complete", filter_default_label: ""},
    //   {column_number : 5, filter_container_id: "tax_issued", filter_type: "auto_complete", filter_default_label: ""},
    //   {column_number : 6, filter_container_id: "paid",
    //     data: [ { value: "Yes", label: "Yes"},
    //             { value: "No", label: "No"} ],
    //     filter_default_label: "All" },
    //   {column_number : 7, filter_container_id: "monthly", filter_type: "auto_complete", filter_default_label: ""},
    //   {column_number : 8, filter_container_id: "date_range", filter_type: "range_date"},
    //   // {column_number : 10, filter_container_id: "ibl_ref", filter_type: "auto_complete", filter_default_label: ""},
    // ], { externally_triggered: true });
    yadcf.init(paymentsTaxTable, [
      // {column_number : 1, filter_container_id: "ibl_ref", filter_type: "auto_complete", filter_default_label: ""},
      {column_number : 2, filter_container_id: "carrier", filter_type: "auto_complete", filter_default_label: ""},
      {column_number : 3, filter_container_id: "vat_type",
        data: [ { value: "VAT 10%", label: "VAT 10%"},
                { value: "VAT 1%", label: "VAT 1%"},
                { value: "PPH 23", label: "PPH 23"} ],
        filter_default_label: "All" },
      // {column_number : 4, filter_container_id: "amount_tax", filter_type: "auto_complete", filter_default_label: ""},
      // {column_number : 5, filter_container_id: "tax_no", filter_type: "auto_complete", filter_default_label: ""},
      // {column_number : 6, filter_container_id: "tax_issued", filter_type: "auto_complete", filter_default_label: ""},
      // {column_number : 7, filter_container_id: "payment_date", filter_type: "auto_complete", filter_default_label: ""},
      // {column_number : 8, filter_container_id: "invoice_no", filter_type: "auto_complete", filter_default_label: ""},
      // {column_number : 9, filter_container_id: "paid_status",
      //   data: [ { value: "Yes", label: "Yes"},
      //           { value: "No", label: "No"} ],
      //   filter_default_label: "All" },
      // {column_number : 10, filter_container_id: "status",
      //   data: [ { value: "Open", label: "Open"},
      //           { value: "Close", label: "Close"} ],
      //   filter_default_label: "All" },
      {column_number : 11, filter_container_id: "monthly", filter_type: "auto_complete", filter_default_label: ""},
      {column_number : 12, filter_container_id: "date_range", filter_type: "range_date"},
      // {column_number : 14, filter_container_id: "ibl_ref", filter_type: "auto_complete", filter_default_label: ""},
      {column_number : 16, filter_container_id: "payment_date", filter_type: "auto_complete", filter_default_label: ""},
      {column_number : 17, filter_container_id: "status",
        data: [ { value: "Open", label: "Open"},
                { value: "Close", label: "Close"} ],
        filter_default_label: "All" },
    ], { externally_triggered: true });
  }

  // if($('#payments_deposit_table').length != 0){
  //   if( $.fn.dataTable.isDataTable('#payments_deposit_table') == false){
  //     paymentsDepositTable = $("#payments_deposit_table").DataTable({
  //       order: [[ 1, "desc" ]],
  //       buttons: [
  //         'pageLength',
  //         {
  //           extend: 'colvis',
  //           collectionLayout: 'fixed two-column',
  //           columns: ':not(.disable)',
  //           postfixButtons: [ {
  //             text: 'Restore visibility',
  //             action: function ( e, dt, node, config ) {
  //               dt.columns().visible( true, false );
  //               dt.columns.adjust().draw( false );
  //             }
  //           } ]
  //         },
  //       ],
  //       columnDefs: [
  //         { targets: [ 0 ], orderable: false, searchable: false },
  //       ]
  //     });
  //     // paymentsDepositTable.page.len( 100 ).draw();
  //   }
  //   yadcf.init(paymentsDepositTable, [
  //     {column_number : 1, filter_container_id: "carrier", filter_type: "auto_complete", filter_default_label: ""},
  //     {column_number : 2, filter_container_id: "mbl", filter_type: "auto_complete", filter_default_label: ""},
  //     {column_number : 3, filter_container_id: "ibl_deposit", filter_type: "auto_complete", filter_default_label: ""},
  //     {column_number : 4, filter_container_id: "deposit_balance", filter_type: "auto_complete", filter_default_label: ""},
  //     {column_number : 5, filter_container_id: "monthly", filter_type: "auto_complete", filter_default_label: ""},
  //     {column_number : 6, filter_container_id: "date_range", filter_type: "range_date"},
  //     // {column_number : 14, filter_container_id: "ibl_ref", filter_type: "auto_complete", filter_default_label: ""},
  //     // {column_number : 20, filter_container_id: "invoice", filter_type: "auto_complete", filter_default_label: "", text_data_delimiter: "<br>"},
  //     // {column_number : 21, filter_container_id: "payment", filter_type: "auto_complete", filter_default_label: "", text_data_delimiter: "<br>"},
  //     // {column_number : 22, filter_container_id: "delivery_doc", filter_type: "auto_complete", filter_default_label: ""},
  //   ], { externally_triggered: true });
  // }

  if($('#payments_deposit_table').length != 0){
    if( $.fn.dataTable.isDataTable('#payments_deposit_table') == false){
      paymentsDepositTable = $("#payments_deposit_table").DataTable({
        order: [[ 1, "desc" ]],
        buttons: [
          'pageLength',
          {
            extend: 'colvis',
            collectionLayout: 'fixed two-column',
            columns: ':not(.disable)',
            postfixButtons: [ {
              text: 'Restore visibility',
              action: function ( e, dt, node, config ) {
                dt.columns().visible( true, false );
                dt.columns.adjust().draw( false );
              }
            } ]
          },
        ],
        columnDefs: [
          { targets: [ 0 ], orderable: false, searchable: false },
        ],
        footerCallback: function ( row, data, start, end, display ) {
            var api = this.api(), data;

            // Remove the formatting to get integer data for summation
            var intVal = function ( i ) {
              // return typeof i === 'string' ? i.replace(/[\USD IDR,]/g, '')*1 : typeof i === 'number' ? i : 0;
              var flag = 1;
              i = i+'';
              if(i.indexOf('(') != -1 || i.indexOf(')') != -1)
                flag = -1;
              return typeof i === 'string' ? i.replace(/[\()USD IDR,]/g, '')*1*flag : typeof i === 'number' ? i*flag : 0;
            };

            // Total over all pages
            var grand_total_usd = 0;
            var grand_total_idr = 0;
            api.column( 3, {search:'applied'} ).data().each( function (a) {
              grand_total_idr += number_format(a); }
            );
            api.column( 4, {search:'applied'} ).data().each( function (a) {
              grand_total_usd += number_format(a); }
            );
            var total_idr = {};
            var total_usd = {};
            api.rows({search:'applied'}).every( function ( rowIdx, tableLoop, rowLoop ) {
              var data = this.data();

              var index = data[1] ? data[1]:'undefined';
              if(number_format(data[3]) != 0 || number_format(data[4]) != 0){
                if (total_idr[index]) {
                  total_idr[index] += number_format(data[3]);
                } else {
                  total_idr[index] = number_format(data[3]);
                }
                if (total_usd[index]) {
                  total_usd[index] += number_format(data[4]);
                } else {
                  total_usd[index] = number_format(data[4]);
                }
              }
            });
            // var total = [];
            // if(total_usd != 0)
            //   total.push(parentheses_format(total_usd, "USD"));
            // if(total_idr != 0)
            //   total.push(parentheses_format(total_idr, "IDR"));
            // $( "#summary_control_center tbody td:eq(2)" ).html(total.join("<br>"));
            // $( api.column( 3 ).footer() ).html(total_idr.join("<br>"));
            // $( api.column( 4 ).footer() ).html(total_usd.join("<br>"));
            var total_text = [];
            var total_idr_text = [];
            var total_usd_text = [];
            total_text.push("TOTAL");
            total_idr_text.push((grand_total_idr != 0) ? parentheses_format(grand_total_idr, "IDR") : "");
            total_usd_text.push((grand_total_usd != 0) ? parentheses_format(grand_total_usd, "USD") : "");

            $.each(total_idr, function(key, value){
              total_text.push('<span style="font-weight: normal;">'+key+'</span>');
              total_idr_text.push('<span style="font-weight: normal;">'+((value != 0) ? money_format(value): "")+'</span>');
            });
            $.each(total_usd, function(key, value){
              total_usd_text.push('<span style="font-weight: normal;">'+((value != 0) ? money_format(value): "")+'</span>');
            });

            // $( api.column( 3 ).footer() ).html(parentheses_format(grand_total_idr, "IDR"));
            // $( api.column( 4 ).footer() ).html(parentheses_format(grand_total_usd, "USD"));
            $( api.column( 1 ).footer() ).html(total_text.join("<br>"));
            $( api.column( 3 ).footer() ).html(total_idr_text.join("<br>"));
            $( api.column( 4 ).footer() ).html(total_usd_text.join("<br>"));
        }
      });
      // paymentsDepositTable.page.len( 100 ).draw();
    }
    yadcf.init(paymentsDepositTable, [
      {column_number : 1, filter_container_id: "carrier", filter_type: "auto_complete", filter_default_label: ""},
      // {column_number : 2, filter_container_id: "ibl_deposit", filter_type: "auto_complete", filter_default_label: ""},
      // {column_number : 3, filter_container_id: "idr_balance",
      //   data: [ { value: "All", label: "All"},
      //           { value: "Settle", label: "Settle"},
      //           { value: "Outstanding", label: "Outstanding"} ],
      //   filter_default_label: "All" },
      // {column_number : 4, filter_container_id: "usd_balance",
      //   data: [ { value: "All", label: "All"},
      //           { value: "Settle", label: "Settle"},
      //           { value: "Outstanding", label: "Outstanding"} ],
      //   filter_default_label: "All" },
      // {column_number : 5, filter_container_id: "monthly", filter_type: "auto_complete", filter_default_label: ""},
      // {column_number : 6, filter_container_id: "date_range", filter_type: "range_date"},
      // {column_number : 8, filter_container_id: "ibl_ref", filter_type: "auto_complete", filter_default_label: ""},
      {column_number : 9, filter_container_id: "status",
        data: [ { value: "Settle", label: "Settle"},
                { value: "Outstanding", label: "Outstanding"} ],
        filter_default_label: "All" },
    ], { externally_triggered: true });
  }

  if($('#control_center_table').length != 0){
    if( $.fn.dataTable.isDataTable('#control_center_table') == false){
      controlCenterTable = $("#control_center_table").DataTable({
        order: [[ 1, "desc" ]],
        buttons: [
          'pageLength',
          {
            extend: 'colvis',
            collectionLayout: 'fixed two-column',
            columns: ':not(.disable)',
            postfixButtons: [ {
              text: 'Restore visibility',
              action: function ( e, dt, node, config ) {
                dt.columns().visible( true, false );
                dt.columns( [ 4, 5, 6, 8, 9, 10, 13, 15, 18 ] ).visible(false, false);
                dt.columns.adjust().draw( false );
              }
            } ]
          },
        ],
        columnDefs: [
          { targets: [ 0 ], orderable: false, searchable: false },
          { targets: [ 4, 5, 6, 8, 9, 10, 13, 15, 18 ], visible: false },
        ],
        footerCallback: function ( row, data, start, end, display ) {
          var api = this.api(), data;

          // Remove the formatting to get integer data for summation
          var intVal = function ( i ) {
            // return typeof i === 'string' ? i.replace(/[\USD IDR,]/g, '')*1 : typeof i === 'number' ? i : 0;
            var flag = 1;
            i = i+'';
            if(i.indexOf('(') != -1 || i.indexOf(')') != -1)
              flag = -1;
            return typeof i === 'string' ? i.replace(/[\()USD IDR,]/g, '')*1*flag : typeof i === 'number' ? i*flag : 0;
          };

          var summary = Array();
          var customer = {};
          api.rows({search:'applied'}).every( function ( rowIdx, tableLoop, rowLoop ) {
            var data = this.data();

            if(data[17].indexOf("Open") != -1){
              var index = data[3] ? data[3]:'undefined';
              if (customer[index]) {
                customer[index]["USD"] += number_format(data[11]);
                customer[index]["IDR"] += number_format(data[12]);
              } else {
                customer[index] = {"USD": number_format(data[11]), "IDR": number_format(data[12])}
              }
            }
          });
          // console.log(customer);

          // Total over this page
          var tmp = '';
          tmp = '' +
          '<table width="100%" border="1">' +
            '<thead>' +
              '<tr>' +
                '<th>Customer</th>' +
                '<th>USD</th>' +
                '<th>IDR</th>' +
              '</tr>' +
            '</thead>' +
            '<tbody>';
            $.each(customer, function(i, row){
              tmp += '' +
                '<tr>' +
                  '<td>'+i+'</td>' +
                  '<td style="text-align: right;">'+money_format(row["USD"])+'</td>' +
                  '<td style="text-align: right;">'+money_format(row["IDR"])+'</td>' +
                '</tr>';
            });
            var sum_usd = 0;
            var sum_idr = 0;
            $.each(customer,function(){ sum_usd+=number_format(this["USD"]); });
            $.each(customer,function(){ sum_idr+=number_format(this["IDR"]); });
            tmp += '' +
            '</tbody>' +
            '<tfoot>' +
              '<tr>' +
                '<th>Total</th>' +
                '<th style="text-align: right;">'+money_format(sum_usd)+'</th>' +
                '<th style="text-align: right;">'+money_format(sum_idr)+'</th>' +
              '</tr>' +
            '</tfoot>' +
          '</table>';

          $('#viewSummaryModal .modal-body').html(tmp);
        }
      });
      // controlCenterTable.page.len( 100 ).draw();
    }
    yadcf.init(controlCenterTable, [
      // {column_number : 1, filter_container_id: "close_ref", filter_type: "auto_complete", filter_default_label: ""},
      // {column_number : 2, filter_container_id: "ibl_ref", filter_type: "auto_complete", filter_default_label: ""},
      {column_number : 3, filter_container_id: "customer", filter_type: "select", filter_default_label: "All Customer"},
      {column_number : 4, filter_container_id: "shipper", filter_type: "select", filter_default_label: "All Shipper"},
      // {column_number : 5, filter_container_id: "shipper_ref", filter_type: "auto_complete", filter_default_label: ""},
      // {column_number : 6, filter_container_id: "mbl", filter_type: "auto_complete", filter_default_label: ""},
      // {column_number : 7, filter_container_id: "invoice_no", filter_type: "auto_complete", filter_default_label: ""},
      // {column_number : 8, filter_container_id: "qty", filter_type: "auto_complete", filter_default_label: ""},
      // {column_number : 9, filter_container_id: "pol", filter_type: "auto_complete", filter_default_label: ""},
      // {column_number : 10, filter_container_id: "destination", filter_type: "auto_complete", filter_default_label: ""},
      // {column_number : 11, filter_container_id: "usd", filter_type: "auto_complete", filter_default_label: ""},
      // {column_number : 12, filter_container_id: "idr", filter_type: "auto_complete", filter_default_label: ""},
      // {column_number : 13, filter_container_id: "invoice_date", filter_type: "date", date_format: "dd-M-yy", filter_default_label: ""},
      // {column_number : 14, filter_container_id: "etd_date", filter_type: "date", date_format: "dd-M-yy", filter_default_label: ""},
      // {column_number : 15, filter_container_id: "due_date", filter_type: "date", date_format: "dd-M-yy", filter_default_label: ""},
      // {column_number : 16, filter_container_id: "payment_date", filter_type: "date", date_format: "dd-M-yy", filter_default_label: ""},
      {column_number : 17, filter_container_id: "status",
        data: [ { value: "Open", label: "Open"},
                { value: "Closed", label: "Closed"},
                { value: "Cancel", label: "Cancel"} ],
        filter_default_label: "All" },
      // {column_number : 17, filter_container_id: "note", filter_type: "auto_complete", filter_default_label: ""},
      // {column_number : 18, filter_container_id: "close_payment", filter_type: "auto_complete", filter_default_label: ""},
      {column_number : 20, filter_container_id: "monthly", filter_type: "auto_complete", filter_default_label: ""},
      {column_number : 21, filter_container_id: "date_range", filter_type: "range_date"},
      // {column_number : 22, filter_container_id: "ibl_ref", filter_type: "auto_complete", filter_default_label: ""},
      // {column_number : 23, filter_container_id: "invoice", filter_type: "auto_complete", filter_default_label: "", text_data_delimiter: "<br>"},
      // {column_number : 24, filter_container_id: "head_letter", filter_type: "auto_complete", filter_default_label: "", text_data_delimiter: "<br>"},
      {column_number : 26, filter_container_id: "due_date", filter_type: "range_date"},
      {column_number : 27, filter_container_id: "payment_date", filter_type: "range_date"},
    ], { externally_triggered: true });
  }

  if($('#control_center_short_paid_table').length != 0){
    if( $.fn.dataTable.isDataTable('#control_center_short_paid_table') == false){
      controlCenterShortPaidTable = $("#control_center_short_paid_table").DataTable({
        order: [[ 1, "desc" ]],
        buttons: [
          'pageLength',
          {
            extend: 'colvis',
            collectionLayout: 'fixed two-column',
            columns: ':not(.disable)',
            postfixButtons: [ {
              text: 'Restore visibility',
              action: function ( e, dt, node, config ) {
                dt.columns().visible( true, false );
                dt.columns.adjust().draw( false );
              }
            } ]
          },
        ],
        columnDefs: [
          { targets: [ 0 ], orderable: false, searchable: false },
        ],
        footerCallback: function ( row, data, start, end, display ) {
            var api = this.api(), data;

            // Remove the formatting to get integer data for summation
            var intVal = function ( i ) {
              // return typeof i === 'string' ? i.replace(/[\USD IDR,]/g, '')*1 : typeof i === 'number' ? i : 0;
              var flag = 1;
              i = i+'';
              if(i.indexOf('(') != -1 || i.indexOf(')') != -1)
                flag = -1;
              return typeof i === 'string' ? i.replace(/[\()USD IDR,]/g, '')*1*flag : typeof i === 'number' ? i*flag : 0;
            };

            // // Total over all pages
            // var total_usd = 0;
            // var total_idr = 0;
            // api.column( 5, {search:'applied'} ).data().each( function (a) {
            //   if(a.includes("USD")) total_usd += number_format(a);
            //   else total_idr += number_format(a); }
            // );
            // var total = [];
            // if(total_usd != 0)
            //   total.push(parentheses_format(total_usd, "USD"));
            // if(total_idr != 0)
            //   total.push(parentheses_format(total_idr, "IDR"));
            // // $( "#summary_control_center tbody td:eq(2)" ).html(total.join("<br>"));
            // $( api.column( 5 ).footer() ).html(total.join("<br>"));



            // var grand_total_usd = 0;
            // var grand_total_idr = 0;
            // api.column( 5, {search:'applied'} ).data().each( function (a) {
            //   grand_total_idr += number_format(a); }
            // );
            // api.column( 6, {search:'applied'} ).data().each( function (a) {
            //   grand_total_usd += number_format(a); }
            // );
            var total_idr = {};
            var total_usd = {};
            api.rows({search:'applied'}).every( function ( rowIdx, tableLoop, rowLoop ) {
              var data = this.data();

              var index = data[2] ? data[2]:'undefined';
              if((number_format(data[5]) != 0 || number_format(data[6]) != 0) && data[7].indexOf("Open") != -1){
                if (total_idr[index]) {
                  total_idr[index] += number_format(data[5]);
                } else {
                  total_idr[index] = number_format(data[5]);
                }
                if (total_usd[index]) {
                  total_usd[index] += number_format(data[6]);
                } else {
                  total_usd[index] = number_format(data[6]);
                }
              }
            });
            var total_text = [];
            var total_idr_text = [];
            var total_usd_text = [];
            // total_text.push("TOTAL");
            // total_idr_text.push((grand_total_idr != 0) ? parentheses_format(grand_total_idr, "IDR") : "");
            // total_usd_text.push((grand_total_usd != 0) ? parentheses_format(grand_total_usd, "USD") : "");

            // $.each(total_idr, function(key, value){
            //   total_text.push('<span style="font-weight: normal;">'+key+'</span>');
            //   total_idr_text.push('<span style="font-weight: normal;">'+((value != 0) ? money_format(value): "")+'</span>');
            // });
            // $.each(total_usd, function(key, value){
            //   total_usd_text.push('<span style="font-weight: normal;">'+((value != 0) ? money_format(value): "")+'</span>');
            // });

            var sum_usd = 0;
            var sum_idr = 0;
            $.each(total_idr,function(key, value){ sum_idr+=number_format(value); });
            $.each(total_usd,function(key, value){ sum_usd+=number_format(value); });
            total_text.push("TOTAL");
            total_idr_text.push((sum_idr != 0) ? parentheses_format(sum_idr, "IDR") : "");
            total_usd_text.push((sum_usd != 0) ? parentheses_format(sum_usd, "USD") : "");

            $.each(total_idr, function(key, value){
              total_text.push('<span style="font-weight: normal;">'+key+'</span>');
              total_idr_text.push('<span style="font-weight: normal;">'+((value != 0) ? money_format(value): "")+'</span>');
            });
            $.each(total_usd, function(key, value){
              total_usd_text.push('<span style="font-weight: normal;">'+((value != 0) ? money_format(value): "")+'</span>');
            });

            $( api.column( 1 ).footer() ).html(total_text.join("<br>"));
            $( api.column( 5 ).footer() ).html(total_idr_text.join("<br>"));
            $( api.column( 6 ).footer() ).html(total_usd_text.join("<br>"));
        }
      });
      // controlCenterShortPaidTable.page.len( 100 ).draw();
    }
    yadcf.init(controlCenterShortPaidTable, [
      // {column_number : 1, filter_container_id: "payment_date", filter_type: "date", date_format: "dd-M-yy", filter_default_label: ""},
      {column_number : 2, filter_container_id: "customer", filter_type: "select", filter_default_label: "All"},
      // {column_number : 3, filter_container_id: "ibl_ref", filter_type: "auto_complete", filter_default_label: ""},
      // {column_number : 4, filter_container_id: "invoice_no", filter_type: "auto_complete", filter_default_label: ""},
      // {column_number : 5, filter_container_id: "idr_balance", filter_type: "auto_complete", filter_default_label: ""},
      // {column_number : 6, filter_container_id: "usd_balance", filter_type: "auto_complete", filter_default_label: ""},
      {column_number : 7, filter_container_id: "status",
        data: [ { value: "Open", label: "Open"},
                { value: "Close", label: "Close"} ],
        filter_default_label: "All" },
      // {column_number : 8, filter_container_id: "closing_date", filter_type: "auto_complete", filter_default_label: ""},
      // {column_number : 9, filter_container_id: "note", filter_type: "auto_complete", filter_default_label: ""},
      {column_number : 10, filter_container_id: "monthly", filter_type: "auto_complete", filter_default_label: ""},
      {column_number : 11, filter_container_id: "date_range", filter_type: "range_date"},
    ], { externally_triggered: true });
  }

  if($('#control_center_deposit_table').length != 0){
    if( $.fn.dataTable.isDataTable('#control_center_deposit_table') == false){
      // controlCenterDepositTable = $("#control_center_deposit_table").DataTable({
      //   order: [[ 1, "desc" ]],
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
      //     { targets: [ 0 ], orderable: false, searchable: false },
      //   ],
      //   footerCallback: function ( row, data, start, end, display ) {
      //       var api = this.api(), data;

      //       // Remove the formatting to get integer data for summation
      //       var intVal = function ( i ) {
      //         // return typeof i === 'string' ? i.replace(/[\USD IDR,]/g, '')*1 : typeof i === 'number' ? i : 0;
      //         var flag = 1;
      //         i = i+'';
      //         if(i.indexOf('(') != -1 || i.indexOf(')') != -1)
      //           flag = -1;
      //         return typeof i === 'string' ? i.replace(/[\()USD IDR,]/g, '')*1*flag : typeof i === 'number' ? i*flag : 0;
      //       };

      //       // Total over all pages
      //       var total_usd = 0;
      //       var total_idr = 0;
      //       api.column( 5, {search:'applied'} ).data().each( function (a) {
      //         if(a.includes("USD")) total_usd += number_format(a);
      //         else total_idr += number_format(a); }
      //       );
      //       var total = [];
      //       if(total_usd != 0)
      //         total.push(parentheses_format(total_usd, "USD"));
      //       if(total_idr != 0)
      //         total.push(parentheses_format(total_idr, "IDR"));
      //       // $( "#summary_control_center tbody td:eq(2)" ).html(total.join("<br>"));
      //       $( api.column( 5 ).footer() ).html(total.join("<br>"));
      //   }
      // });
      controlCenterDepositTable = $("#control_center_deposit_table").DataTable({
        order: [[ 1, "desc" ]],
        buttons: [
          'pageLength',
          {
            extend: 'colvis',
            collectionLayout: 'fixed two-column',
            columns: ':not(.disable)',
            postfixButtons: [ {
              text: 'Restore visibility',
              action: function ( e, dt, node, config ) {
                dt.columns().visible( true, false );
                dt.columns.adjust().draw( false );
              }
            } ]
          },
        ],
        columnDefs: [
          { targets: [ 0 ], orderable: false, searchable: false },
        ],
        footerCallback: function ( row, data, start, end, display ) {
            var api = this.api(), data;

            // Remove the formatting to get integer data for summation
            var intVal = function ( i ) {
              // return typeof i === 'string' ? i.replace(/[\USD IDR,]/g, '')*1 : typeof i === 'number' ? i : 0;
              var flag = 1;
              i = i+'';
              if(i.indexOf('(') != -1 || i.indexOf(')') != -1)
                flag = -1;
              return typeof i === 'string' ? i.replace(/[\()USD IDR,]/g, '')*1*flag : typeof i === 'number' ? i*flag : 0;
            };

            // Total over all pages
            var grand_total_usd = 0;
            var grand_total_idr = 0;
            api.column( 3, {search:'applied'} ).data().each( function (a) {
              grand_total_idr += number_format(a); }
            );
            api.column( 4, {search:'applied'} ).data().each( function (a) {
              grand_total_usd += number_format(a); }
            );
            var total_idr = {};
            var total_usd = {};
            api.rows({search:'applied'}).every( function ( rowIdx, tableLoop, rowLoop ) {
              var data = this.data();

              var index = data[1] ? data[1]:'undefined';
              if(number_format(data[3]) != 0 || number_format(data[4]) != 0){
                if (total_idr[index]) {
                  total_idr[index] += number_format(data[3]);
                } else {
                  total_idr[index] = number_format(data[3]);
                }
                if (total_usd[index]) {
                  total_usd[index] += number_format(data[4]);
                } else {
                  total_usd[index] = number_format(data[4]);
                }
              }
            });

            var total_text = [];
            var total_idr_text = [];
            var total_usd_text = [];
            total_text.push("TOTAL");
            total_idr_text.push((grand_total_idr != 0) ? parentheses_format(grand_total_idr, "IDR") : "");
            total_usd_text.push((grand_total_usd != 0) ? parentheses_format(grand_total_usd, "USD") : "");

            $.each(total_idr, function(key, value){
              total_text.push('<span style="font-weight: normal;">'+key+'</span>');
              total_idr_text.push('<span style="font-weight: normal;">'+((value != 0) ? money_format(value): "")+'</span>');
            });
            $.each(total_usd, function(key, value){
              total_usd_text.push('<span style="font-weight: normal;">'+((value != 0) ? money_format(value): "")+'</span>');
            });

            $( api.column( 1 ).footer() ).html(total_text.join("<br>"));
            $( api.column( 3 ).footer() ).html(total_idr_text.join("<br>"));
            $( api.column( 4 ).footer() ).html(total_usd_text.join("<br>"));
        }
      });
      // controlCenterDepositTable.page.len( 100 ).draw();
    }
    // yadcf.init(controlCenterDepositTable, [
    //   // {column_number : 1, filter_container_id: "payment_date", filter_type: "date", date_format: "dd-M-yy", filter_default_label: ""},
    //   {column_number : 2, filter_container_id: "customer", filter_type: "select", filter_default_label: "All"},
    //   // {column_number : 3, filter_container_id: "ibl_ref", filter_type: "auto_complete", filter_default_label: ""},
    //   // {column_number : 4, filter_container_id: "invoice_no", filter_type: "auto_complete", filter_default_label: ""},
    //   // {column_number : 5, filter_container_id: "short_paid", filter_type: "auto_complete", filter_default_label: ""},
    //   {column_number : 6, filter_container_id: "status",
    //     data: [ { value: "Open", label: "Open"},
    //             { value: "Close", label: "Close"} ],
    //     filter_default_label: "All" },
    //   // {column_number : 7, filter_container_id: "closing_date", filter_type: "auto_complete", filter_default_label: ""},
    //   // {column_number : 8, filter_container_id: "note", filter_type: "auto_complete", filter_default_label: ""},
    //   {column_number : 9, filter_container_id: "monthly", filter_type: "auto_complete", filter_default_label: ""},
    //   {column_number : 10, filter_container_id: "date_range", filter_type: "range_date"},
    // ], { externally_triggered: true });

    yadcf.init(controlCenterDepositTable, [
      {column_number : 1, filter_container_id: "customer", filter_type: "select", filter_default_label: "All"},
      // {column_number : 2, filter_container_id: "ibl_deposit", filter_type: "auto_complete", filter_default_label: ""},
      // {column_number : 3, filter_container_id: "idr_balance",
      //   data: [ { value: "All", label: "All"},
      //           { value: "Settle", label: "Settle"},
      //           { value: "Outstanding", label: "Outstanding"} ],
      //   filter_default_label: "All" },
      // {column_number : 4, filter_container_id: "usd_balance",
      //   data: [ { value: "All", label: "All"},
      //           { value: "Settle", label: "Settle"},
      //           { value: "Outstanding", label: "Outstanding"} ],
      //   filter_default_label: "All" },
      // {column_number : 5, filter_container_id: "monthly", filter_type: "auto_complete", filter_default_label: ""},
      // {column_number : 6, filter_container_id: "date_range", filter_type: "range_date"},
      // {column_number : 8, filter_container_id: "ibl_ref", filter_type: "auto_complete", filter_default_label: ""},
      {column_number : 9, filter_container_id: "status",
        data: [ { value: "Settle", label: "Settle"},
                { value: "Outstanding", label: "Outstanding"} ],
        filter_default_label: "All" },
    ], { externally_triggered: true });
  }

  if($('#cost_revenues_table').length != 0){
    if( $.fn.dataTable.isDataTable('#cost_revenues_table') == false){
      costRevenuesTable = $("#cost_revenues_table").DataTable({
        order: [[ 1, "desc" ]],
        buttons: [
          'pageLength',
          {
            extend: 'colvis',
            collectionLayout: 'fixed three-column',
            columns: ':not(.disable)',
            postfixButtons: [ {
              text: 'Restore visibility',
              action: function ( e, dt, node, config ) {
                dt.columns().visible( true, false );
                dt.columns( [ 2, 3, 4, 6, 7, 9, 10, 13, 15 ] ).visible(false, false);
                dt.columns.adjust().draw( false );
              }
            } ]
          },
        ],
        columnDefs: [
          { targets: [ 0 ], orderable: false, searchable: false },
          { targets: [ 2, 3, 4, 6, 7, 9, 10, 13, 15 ], visible: false }
        ],
        footerCallback: function ( row, data, start, end, display ) {
          var api = this.api(), data;

          // Remove the formatting to get integer data for summation
          var intVal = function ( i ) {
            // return typeof i === 'string' ? i.replace(/[\USD IDR,]/g, '')*1 : typeof i === 'number' ? i : 0;
            var flag = 1;
            i = i+'';
            if(i.indexOf('(') != -1 || i.indexOf(')') != -1)
              flag = -1;
            return typeof i === 'string' ? i.replace(/[\()USD IDR,]/g, '')*1*flag : typeof i === 'number' ? i*flag : 0;
          };


          // Total over all pages
          var total_sell_vat_10 = 0;
          // api.column( 25, {search:'applied'} ).data().each( function (a) {
          //   total_sell_vat_10 += number_format(a); }
          // );
          var total_sell_vat_1 = 0;
          // api.column( 26, {search:'applied'} ).data().each( function (a) {
          //   total_sell_vat_1 += number_format(a); }
          // );
          var total_sell_pph_23 = 0;
          // api.column( 27, {search:'applied'} ).data().each( function (a) {
          //   total_sell_pph_23 += number_format(a); }
          // );

          var total_cost_vat_10 = 0;
          // api.column( 28, {search:'applied'} ).data().each( function (a) {
          //   total_cost_vat_10 += number_format(a); }
          // );
          var total_cost_vat_1 = 0;
          // api.column( 29, {search:'applied'} ).data().each( function (a) {
          //   total_cost_vat_1 += number_format(a); }
          // );
          var total_cost_pph_23 = 0;
          // api.column( 30, {search:'applied'} ).data().each( function (a) {
          //   total_cost_pph_23 += number_format(a); }
          // );

          var total_addt = 0;
          // api.column( 31, {search:'applied'} ).data().each( function (a) {
          //   total_addt += number_format(a); }
          // );
          var total_npt = 0;
          // api.column( 32, {search:'applied'} ).data().each( function (a) {
          //   total_npt += number_format(a); }
          // );

          // Total over this page
          var tmp = '';

          var from = $('#yadcf-filter--cost_revenues_table-from-date-21.inuse').val();
          var to = $('#yadcf-filter--cost_revenues_table-to-date-21.inuse').val();
          var monthly = $('#yadcf-filter--cost_revenues_table-20.inuse').val();

          tmp += '<p>';
          if(from != undefined || to != undefined){
            var year = new Date().getFullYear();
            if($.urlParam('year') != undefined)
              year = $.urlParam('year');

            tmp += '' +
            'Date : ';
            if(from != undefined)
              tmp += $.datepicker.formatDate('dd MM yy', new Date(from));
            else
              tmp += $.datepicker.formatDate('dd MM yy', new Date(year, 0, 1));;

            tmp += ' - ';
            if(to != undefined)
              tmp += $.datepicker.formatDate('dd MM yy', new Date(to));
            else
              tmp += $.datepicker.formatDate('dd MM yy', new Date());

            if(monthly != undefined)
              tmp += '<br>';
          }

          // var monthly = $('#yadcf-filter--cost_revenues_table-20.inuse').val();
          if(monthly != undefined)
            tmp += '' +
              'Date : ' + monthly+'';

          tmp += '</p>';


          tmp += '' +
          '<table width="100%" border="1">' +
            '<thead>' +
              '<tr>' +
                '<th rowspan="2">IBL Ref</th>' +
                '<th colspan="3">SELL</th>' +
                '<th colspan="3">COST</th>' +
                '<th rowspan="2">ADDT</th>' +
                '<th rowspan="2">NPT</th>' +
              '</tr>' +
              '<tr>' +
                '<th>VAT 10%</th>' +
                '<th>VAT 1%</th>' +
                '<th>PPH 23</th>' +
                '<th>VAT 10%</th>' +
                '<th>VAT 1%</th>' +
                '<th>PPH 23</th>' +
              '</tr>' +
            '</thead>' +
            '<tbody>';
            api.rows({search:'applied'}).every( function ( rowIdx, tableLoop, rowLoop ) {
              var data = this.data();
              // if(data[24].contains("Cancel") == false){
                if(data[14].indexOf("No Status") == -1){
                  total_sell_vat_10 += number_format(data[25]);
                  total_sell_vat_1 += number_format(data[26]);
                  total_sell_pph_23 += number_format(data[27]);
                  total_cost_vat_10 += number_format(data[28]);
                  total_cost_vat_1 += number_format(data[29]);
                  total_cost_pph_23 += number_format(data[30]);
                  total_addt += number_format(data[31]);
                  total_npt += number_format(data[32]);

                  tmp += '' +
                    '<tr>' +
                      '<td>'+data[23]+(data[24].indexOf("Cancel") != -1 ? ' (Cancel)': '')+'</td>' +
                      '<td style="text-align:right;">'+parentheses_format(data[25])+'</td>' +
                      '<td style="text-align:right;">'+parentheses_format(data[26])+'</td>' +
                      '<td style="text-align:right;">'+parentheses_format(data[27])+'</td>' +
                      '<td style="text-align:right;">'+parentheses_format(data[28])+'</td>' +
                      '<td style="text-align:right;">'+parentheses_format(data[29])+'</td>' +
                      '<td style="text-align:right;">'+parentheses_format(data[30])+'</td>' +
                      '<td style="text-align:right;">'+parentheses_format(data[31])+'</td>' +
                      '<td style="text-align:right;">'+parentheses_format(data[32])+'</td>' +
                    '</tr>';
                }
              // }
            });

            tmp += '' +
            '</tbody>' +
            '<tfoot>' +
              '<tr>' +
                '<th>Total</th>' +
                '<th style="text-align:right;">'+parentheses_format(total_sell_vat_10)+'</th>' +
                '<th style="text-align:right;">'+parentheses_format(total_sell_vat_1)+'</th>' +
                '<th style="text-align:right;">'+parentheses_format(total_sell_pph_23)+'</th>' +
                '<th style="text-align:right;">'+parentheses_format(total_cost_vat_10)+'</th>' +
                '<th style="text-align:right;">'+parentheses_format(total_cost_vat_1)+'</th>' +
                '<th style="text-align:right;">'+parentheses_format(total_cost_pph_23)+'</th>' +
                '<th style="text-align:right;">'+parentheses_format(total_addt)+'</th>' +
                '<th style="text-align:right;">'+parentheses_format(total_npt)+'</th>' +
              '</tr>' +
            '</tfoot>' +
          '</table>';

          // if (seen[txt]) {
          //     $(this).remove();
          //     count++;
          //     counters[txt]++;
          // } else {
          //     seen[txt] = true;
          //     counters[txt] = 1;
          // }

          var total_si = api.rows({search:'applied'})[0].length;
          // var total_shipment = api.rows()[0].length;

          var cr_status = Array();
          api.column( 14, {search:'applied'} ).data().each( function (a) {
            if (cr_status[a]) {
              cr_status[a]++;
            } else {
              cr_status[a] = 1;
            }
          });

          var si_status = Array();
          api.column( 24, {search:'applied'} ).data().each( function (a) {
            $.each(a.split('<br>'), function(i, bl){
              if (si_status[bl]) {
                si_status[bl]++;
              } else {
                si_status[bl] = 1;
              }
            });
          });

          tmp += '' +
          '<dl class="dl-horizontal">' +
            '<dt>Total SI</dt>' +
            '<dd>: '+total_si+'</dd>' +
            '<dt>Cancel SI</dt>' +
            '<dd>: '+(si_status["Cancel"]?si_status["Cancel"]:0)+'</dd>' +
            '<dt>Total Shipment</dt>' +
            '<dd>: '+(total_si-(si_status["Cancel"]?si_status["Cancel"]:0))+'</dd>' +
            '<dt>Completed</dt>' +
            '<dd>: '+(cr_status["Completed"]?cr_status["Completed"]:0)+'</dd>' +
          '</dl>';
          $('#viewSummaryModal .modal-body').html(tmp);
        }
      });
      // costRevenuesTable.page.len( 100 ).draw();
    }
    yadcf.init(costRevenuesTable, [
      // {column_number : 1, filter_container_id: "ibl_ref", filter_type: "auto_complete", filter_default_label: ""},
      // {column_number : 2, filter_container_id: "mbl_no", filter_type: "auto_complete", filter_default_label: ""},
      {column_number : 3, filter_container_id: "carrier", filter_type: "auto_complete", filter_default_label: ""},
      // {column_number : 4, filter_container_id: "shipper_ref", filter_type: "auto_complete", filter_default_label: ""},
      {column_number : 5, filter_container_id: "shipper", filter_type: "auto_complete", filter_default_label: ""},
      {column_number : 6, filter_container_id: "consignee", filter_type: "auto_complete", filter_default_label: ""},
      // {column_number : 7, filter_container_id: "vessel", filter_type: "auto_complete", filter_default_label: ""},
      // {column_number : 8, filter_container_id: "etd", filter_type: "date", date_format: "dd-M-yy", filter_default_label: ""},
      {column_number : 9, filter_container_id: "pol", filter_type: "auto_complete", filter_default_label: ""},
      {column_number : 10, filter_container_id: "pod", filter_type: "auto_complete", filter_default_label: ""},
      {column_number : 11, filter_container_id: "destination", filter_type: "auto_complete", filter_default_label: ""},
      // {column_number : 12, filter_container_id: "volume", filter_type: "auto_complete", filter_default_label: ""},
      {column_number : 13, filter_container_id: "owner", filter_type: "auto_complete", filter_default_label: ""},
      // {column_number : 14, filter_container_id: "status",
      //   data: [ { value: "Open", label: "Open"},
      //           { value: "Complete", label: "Complete"},
      //           { value: "No Status", label: "No Status"} ],
      //   filter_default_label: "All"},
      {column_number : 15, filter_container_id: "trade", filter_type: "auto_complete", filter_default_label: ""},
      // {column_number : 16, filter_container_id: "sell_usd", filter_type: "auto_complete", filter_default_label: "", text_data_delimiter: "<br>"},
      // {column_number : 17, filter_container_id: "sell_idr", filter_type: "auto_complete", filter_default_label: "", text_data_delimiter: "<br>"},
      // {column_number : 18, filter_container_id: "cost_usd", filter_type: "auto_complete", filter_default_label: "", text_data_delimiter: "<br>"},
      // {column_number : 19, filter_container_id: "cost_idr", filter_type: "auto_complete", filter_default_label: "", text_data_delimiter: "<br>"},
      {column_number : 20, filter_container_id: "monthly", filter_type: "auto_complete", filter_default_label: ""},
      {column_number : 21, filter_container_id: "date_range", filter_type: "range_date"},
    ], { externally_triggered: true });
  }

  $( "#yadcf-filter--shipping_instructions_table-16, #yadcf-filter--bill_of_ladings_table-15, #yadcf-filter--shipments_tracking_table-17, #yadcf-filter--invoices_table-18, #yadcf-filter--payments_plan_table-14, #yadcf-filter--payments_inquiry_table-14, #yadcf-filter--payments_tax_table-11, #yadcf-filter--payments_tax_table-15, #yadcf-filter--payments_deposit_table-5, #yadcf-filter--control_center_table-20, #yadcf-filter--control_center_short_paid_table-10, #yadcf-filter--control_center_deposit_table-9, #yadcf-filter--cost_revenues_table-20, #yadcf-filter--invoices_table-16, #yadcf-filter--invoices_table-17, #yadcf-filter--payments_inquiry_table-20, #yadcf-filter--payments_tax_table-5" ).datepicker({
      changeMonth: true,
      changeYear: true,
      showButtonPanel: true,
      dateFormat: 'MM yy',
      onClose: function(dateText, inst) {
          var month = $("#ui-datepicker-div .ui-datepicker-month :selected").val();
          var year = $("#ui-datepicker-div .ui-datepicker-year :selected").val();
          $(this).datepicker('setDate', new Date(year, month, 1));
          advance_filter();
      }
    }).focus(function () {
      $(".ui-datepicker-calendar").css("display", "none");
    });

  $(".yadcf-filter, .yadcf-filter-date, .yadcf-filter-range-date").change(function(){
    advance_filter();
  })
};

$.urlParam = function(name){
  var results = new RegExp('[\?&]' + name + '=([^&#]*)').exec(window.location.href);
  return results[1] || 0;
}

function advance_filter(){
  if($('#shipping_instructions_table').length != 0){
      yadcf.exFilterExternallyTriggered(shippingInstructionsTable);
    }
    if($('#bill_of_ladings_table').length != 0){
      yadcf.exFilterExternallyTriggered(billOfLadingsTable);
    }
    if($('#shipments_tracking_table').length != 0){
      yadcf.exFilterExternallyTriggered(shipmentsTrackingTable);
    }
    if($('#invoices_table').length != 0){
      yadcf.exFilterExternallyTriggered(invoicesTable);
    }
    if($('#payments_plan_table').length != 0){
      yadcf.exFilterExternallyTriggered(paymentsPlanTable);
    }
    if($('#payments_inquiry_table').length != 0){
      yadcf.exFilterExternallyTriggered(paymentsInquiryTable);
    }
    if($('#payments_tax_table').length != 0){
      yadcf.exFilterExternallyTriggered(paymentsTaxTable);
    }
    if($('#payments_deposit_table').length != 0){
      yadcf.exFilterExternallyTriggered(paymentsDepositTable);
    }
    if($('#control_center_table').length != 0){
      yadcf.exFilterExternallyTriggered(controlCenterTable);
    }
    if($('#control_center_short_paid_table').length != 0){
      yadcf.exFilterExternallyTriggered(controlCenterShortPaidTable);
    }
    if($('#control_center_deposit_table').length != 0){
      yadcf.exFilterExternallyTriggered(controlCenterDepositTable);
    }
    if($('#cost_revenues_table').length != 0){
      yadcf.exFilterExternallyTriggered(costRevenuesTable);
    }
}
$(function () {
  $("form#new_si_report").submit(function(){
    si_report();
  });

  $("form#new_bl_report").submit(function(){
    bl_report();
  });

  $("form#new_st_report").submit(function(){
    st_report();
  });

  $("form#new_invoice_report").submit(function(){
    invoice_report();
  });

  $("form#new_payment_plan_report").submit(function(){
    payment_plan_report();
  });

  $("form#new_payment_inquiry_report").submit(function(){
    payment_inquiry_report();
  });

  $("form#new_payment_tax_report").submit(function(){
    payment_tax_report();
  });

  $("form#new_payment_deposit_report").submit(function(){
    payment_deposit_report();
  });

  $("form#new_control_center_report").submit(function(){
    control_center_report();
  });

  $("form#new_control_center_short_paid_report").submit(function(){
    control_center_short_paid_report();
  });

  $("form#new_control_center_deposit_report").submit(function(){
    control_center_deposit_report();
  });

  $("form#new_cost_revenue_report").submit(function(){
    cost_revenue_report();
  });
});

function si_report() {
  var row_id = [];
  var form = "";

  shippingInstructionsTable.rows({search:'applied'}).every( function ( rowIdx, tableLoop, rowLoop ) {
    var rowNode = this.node();

    $(rowNode).find("td.row_id").each(function (){
      row_id.push( $(this).text().trim() );
      // form += '<input type="hidden" name="row_id['+rowIdx+']" value="'+$(this).text().trim()+'">';
    });
  });

  console.log(row_id);

  $.each(row_id, function(key, value){
    form += '<input type="hidden" name="si_report[row_ids][]" value="'+value+'">';
  });
  // form += '<input type="hidden" name="si_report[row_id]" value="'+row_id+'">';

  var columns = [];
  shippingInstructionsTable.columns(':not(.disable)').every( function ( rowIdx, tableLoop, rowLoop ) {
    // alert( 'Column index 0 is '+ (table.column( 0 ).visible() === true ? 'visible' : 'not visible')
    if(this.visible() === true){
      // console.log(rowIdx);
      columns.push(rowIdx);
    }
  } );

  console.log(columns);

  $.each(columns, function(key, value){
    form += '<input type="hidden" name="si_report[columns][]" value="'+value+'">';
  });
  // form += '<input type="hidden" name="si_report[column]" value="'+columns+'">';

  form += '<input type="hidden" name="si_report[format]" value="'+$('#format').val()+'">';
  var monthly = $('#yadcf-filter--shipping_instructions_table-16.inuse').val();
  if(monthly != undefined)
    form += '<input type="hidden" name="si_report[monthly]" value="'+monthly+'">';

  var from = $('#yadcf-filter--shipping_instructions_table-from-date-16.inuse').val();
  if(from != undefined)
    form += '<input type="hidden" name="si_report[from]" value="'+from+'">';

  var to = $('#yadcf-filter--shipping_instructions_table-to-date-16.inuse').val();
  if(to != undefined)
    form += '<input type="hidden" name="si_report[to]" value="'+to+'">';

  $('#report_params').html(form);
}

function bl_report() {
  var row_id = [];
  var form = "";
  billOfLadingsTable.rows({search:'applied'}).every( function ( rowIdx, tableLoop, rowLoop ) {
    var rowNode = this.node();

    $(rowNode).find("td.reference_id").each(function (){
      row_id.push( $(this).text().trim() );
    });
  });

  console.log(row_id);

  $.each(row_id, function(key, value){
    form += '<input type="hidden" name="bl_report[row_ids][]" value="'+value+'">';
  });

  var columns = [];
  billOfLadingsTable.columns(':not(.disable)').every( function ( rowIdx, tableLoop, rowLoop ) {
    if(this.visible() === true){
      columns.push(rowIdx);
    }
  } );

  console.log(columns);

  $.each(columns, function(key, value){
    form += '<input type="hidden" name="bl_report[columns][]" value="'+value+'">';
  });

  form += '<input type="hidden" name="bl_report[format]" value="'+$('#format').val()+'">';
  var monthly = $('#yadcf-filter--bill_of_ladings_table-15.inuse').val();
  if(monthly != undefined)
    form += '<input type="hidden" name="bl_report[monthly]" value="'+monthly+'">';

  var from = $('#yadcf-filter--bill_of_ladings_table-from-date-16.inuse').val();
  if(from != undefined)
    form += '<input type="hidden" name="bl_report[from]" value="'+from+'">';

  var to = $('#yadcf-filter--bill_of_ladings_table-to-date-16.inuse').val();
  if(to != undefined)
    form += '<input type="hidden" name="bl_report[to]" value="'+to+'">';

  $('#report_params').html(form);
}

function st_report() {
  var row_id = [];
  var form = "";
  shipmentsTrackingTable.rows({search:'applied'}).every( function ( rowIdx, tableLoop, rowLoop ) {
    var rowNode = this.node();

    $(rowNode).find("td.row_id").each(function (){
      row_id.push( $(this).text().trim() );
    });
  });

  console.log(row_id);

  $.each(row_id, function(key, value){
    form += '<input type="hidden" name="st_report[row_ids][]" value="'+value+'">';
  });

  var columns = [];
  shipmentsTrackingTable.columns(':not(.disable)').every( function ( rowIdx, tableLoop, rowLoop ) {
    if(this.visible() === true){
      columns.push(rowIdx);
    }
  } );

  console.log(columns);

  $.each(columns, function(key, value){
    form += '<input type="hidden" name="st_report[columns][]" value="'+value+'">';
  });

  form += '<input type="hidden" name="st_report[format]" value="'+$('#format').val()+'">';
  var monthly = $('#yadcf-filter--shipments_tracking_table-15.inuse').val();
  if(monthly != undefined)
    form += '<input type="hidden" name="st_report[monthly]" value="'+monthly+'">';

  var from = $('#yadcf-filter--shipments_tracking_table-from-date-16.inuse').val();
  if(from != undefined)
    form += '<input type="hidden" name="st_report[from]" value="'+from+'">';

  var to = $('#yadcf-filter--shipments_tracking_table-to-date-16.inuse').val();
  if(to != undefined)
    form += '<input type="hidden" name="st_report[to]" value="'+to+'">';

  $('#report_params').html(form);
}

function invoice_report() {
  var row_ids = [];
  var head_letters = [];
  var form = "";
  invoicesTable.rows({search:'applied'}).every( function ( rowIdx, tableLoop, rowLoop ) {
    var rowNode = this.node();

    $(rowNode).find("td.row_id").each(function (){
      row_ids.push( $(this).text().trim() );
    });
    $(rowNode).find("td.head_letter").each(function (){
      head_letters.push( $(this).text().trim() );
    });
  });

  console.log(row_ids);
  console.log(head_letters);

  $.each(row_ids, function(key, value){
    form += '<input type="hidden" name="invoice_report[row_ids][]" value="'+value+'">';
  });
  $.each(head_letters, function(key, value){
    form += '<input type="hidden" name="invoice_report[head_letters][]" value="'+value+'">';
  });

  var columns = [];
  invoicesTable.columns(':not(.disable)').every( function ( rowIdx, tableLoop, rowLoop ) {
    if(this.visible() === true){
      columns.push(rowIdx);
    }
  } );

  console.log(columns);

  $.each(columns, function(key, value){
    form += '<input type="hidden" name="invoice_report[columns][]" value="'+value+'">';
  });

  form += '<input type="hidden" name="invoice_report[format]" value="'+$('#format').val()+'">';
  var monthly = $('#yadcf-filter--invoices_table-17.inuse').val();
  if(monthly != undefined)
    form += '<input type="hidden" name="invoice_report[monthly]" value="'+monthly+'">';

  var from = $('#yadcf-filter--invoices_table-from-date-18.inuse').val();
  if(from != undefined)
    form += '<input type="hidden" name="invoice_report[from]" value="'+from+'">';

  var to = $('#yadcf-filter--invoices_table-to-date-18.inuse').val();
  if(to != undefined)
    form += '<input type="hidden" name="invoice_report[to]" value="'+to+'">';

  $('#report_params').html(form);
}

function payment_plan_report() {
  var row_id = [];
  var row_ref_id = [];
  var form = "";
  paymentsPlanTable.rows({search:'applied'}).every( function ( rowIdx, tableLoop, rowLoop ) {
    var rowNode = this.node();

    $(rowNode).find("td.row_id").each(function (){
      row_id.push( $(this).text().trim() );
    });
    $(rowNode).find("td.row_ref_id").each(function (){
      row_ref_id.push( $(this).text().trim() );
    });
  });

  console.log(row_id);
  console.log(row_ref_id);

  $.each(row_id, function(key, value){
    form += '<input type="hidden" name="payment_plan_report[row_ids][]" value="'+value+'">';
  });

  $.each(row_ref_id, function(key, value){
    form += '<input type="hidden" name="payment_plan_report[row_ref_ids][]" value="'+value+'">';
  });

  var columns = [];
  paymentsPlanTable.columns(':not(.disable)').every( function ( rowIdx, tableLoop, rowLoop ) {
    if(this.visible() === true){
      columns.push(rowIdx);
    }
  } );

  console.log(columns);

  $.each(columns, function(key, value){
    form += '<input type="hidden" name="payment_plan_report[columns][]" value="'+value+'">';
  });

  form += '<input type="hidden" name="payment_plan_report[format]" value="'+$('#format').val()+'">';
  var monthly = $('#yadcf-filter--payments_plan_table-15.inuse').val();
  if(monthly != undefined)
    form += '<input type="hidden" name="payment_plan_report[monthly]" value="'+monthly+'">';

  var from = $('#yadcf-filter--payments_plan_table-from-date-16.inuse').val();
  if(from != undefined)
    form += '<input type="hidden" name="payment_plan_report[from]" value="'+from+'">';

  var to = $('#yadcf-filter--payments_plan_table-to-date-16.inuse').val();
  if(to != undefined)
    form += '<input type="hidden" name="payment_plan_report[to]" value="'+to+'">';

  $('#report_params').html(form);
}

function payment_inquiry_report() {
  var row_id = [];
  var row_ref_id = [];
  var form = "";
  paymentsInquiryTable.rows({search:'applied'}).every( function ( rowIdx, tableLoop, rowLoop ) {
    var rowNode = this.node();

    $(rowNode).find("td.row_id").each(function (){
      row_id.push( $(this).text().trim() );
    });
    $(rowNode).find("td.row_ref_id").each(function (){
      row_ref_id.push( $(this).text().trim() );
    });
  });

  console.log(row_id);
  console.log(row_ref_id);

  $.each(row_id, function(key, value){
    form += '<input type="hidden" name="payment_inquiry_report[row_ids][]" value="'+value+'">';
  });

  $.each(row_ref_id, function(key, value){
    form += '<input type="hidden" name="payment_inquiry_report[row_ref_ids][]" value="'+value+'">';
  });

  var columns = [];
  paymentsInquiryTable.columns(':not(.disable)').every( function ( rowIdx, tableLoop, rowLoop ) {
    if(this.visible() === true){
      columns.push(rowIdx);
    }
  } );

  console.log(columns);

  $.each(columns, function(key, value){
    form += '<input type="hidden" name="payment_inquiry_report[columns][]" value="'+value+'">';
  });

  form += '<input type="hidden" name="payment_inquiry_report[format]" value="'+$('#format').val()+'">';
  var monthly = $('#yadcf-filter--payments_inquiry_table-15.inuse').val();
  if(monthly != undefined)
    form += '<input type="hidden" name="payment_inquiry_report[monthly]" value="'+monthly+'">';

  var from = $('#yadcf-filter--payments_inquiry_table-from-date-16.inuse').val();
  if(from != undefined)
    form += '<input type="hidden" name="payment_inquiry_report[from]" value="'+from+'">';

  var to = $('#yadcf-filter--payments_inquiry_table-to-date-16.inuse').val();
  if(to != undefined)
    form += '<input type="hidden" name="payment_inquiry_report[to]" value="'+to+'">';

  $('#report_params').html(form);
}

// function payment_tax_report() {
//   var row_id = [];
//   var form = "";
//   paymentsTaxTable.rows({search:'applied'}).every( function ( rowIdx, tableLoop, rowLoop ) {
//     var rowNode = this.node();

//     $(rowNode).find("td.row_id").each(function (){
//       row_id.push( $(this).text().trim() );
//     });
//   });

//   console.log(row_id);

//   $.each(row_id, function(key, value){
//     form += '<input type="hidden" name="payment_tax_report[row_ids][]" value="'+value+'">';
//   });

//   var columns = [];
//   paymentsTaxTable.columns(':not(.disable)').every( function ( rowIdx, tableLoop, rowLoop ) {
//     if(this.visible() === true){
//       columns.push(rowIdx);
//     }
//   } );

//   console.log(columns);

//   $.each(columns, function(key, value){
//     form += '<input type="hidden" name="payment_tax_report[columns][]" value="'+value+'">';
//   });

//   form += '<input type="hidden" name="payment_tax_report[format]" value="'+$('#format').val()+'">';
//   var monthly = $('#yadcf-filter--payments_tax_table-15.inuse').val();
//   if(monthly != undefined)
//     form += '<input type="hidden" name="payment_tax_report[monthly]" value="'+monthly+'">';

//   var from = $('#yadcf-filter--payments_tax_table-from-date-16.inuse').val();
//   if(from != undefined)
//     form += '<input type="hidden" name="payment_tax_report[from]" value="'+from+'">';

//   var to = $('#yadcf-filter--payments_tax_table-to-date-16.inuse').val();
//   if(to != undefined)
//     form += '<input type="hidden" name="payment_tax_report[to]" value="'+to+'">';

//   $('#report_params').html(form);
// }

function payment_tax_report() {
  var row_id = [];
  var vat_type = [];
  var form = "";
  paymentsTaxTable.rows({search:'applied'}).every( function ( rowIdx, tableLoop, rowLoop ) {
    var rowNode = this.node();

    $(rowNode).find("td.row_ref_id").each(function (){
      row_id.push( $(this).text().trim() );
    });

    $(rowNode).find("td.vat_type").each(function (){
      vat_type.push( $(this).text().trim() );
    });
  });

  console.log(row_id);
  console.log(vat_type);

  $.each(row_id, function(key, value){
    form += '<input type="hidden" name="payment_tax_report[row_ids][]" value="'+value+'">';
  });

  $.each(vat_type, function(key, value){
    form += '<input type="hidden" name="payment_tax_report[vat_types]][]" value="'+value+'">';
  });

  var columns = [];
  paymentsTaxTable.columns(':not(.disable)').every( function ( rowIdx, tableLoop, rowLoop ) {
    if(this.visible() === true){
      columns.push(rowIdx);
    }
  } );

  console.log(columns);

  $.each(columns, function(key, value){
    form += '<input type="hidden" name="payment_tax_report[columns][]" value="'+value+'">';
  });

  form += '<input type="hidden" name="payment_tax_report[format]" value="'+$('#format').val()+'">';
  var monthly = $('#yadcf-filter--payments_tax_table-15.inuse').val();
  if(monthly != undefined)
    form += '<input type="hidden" name="payment_tax_report[monthly]" value="'+monthly+'">';

  var from = $('#yadcf-filter--payments_tax_table-from-date-16.inuse').val();
  if(from != undefined)
    form += '<input type="hidden" name="payment_tax_report[from]" value="'+from+'">';

  var to = $('#yadcf-filter--payments_tax_table-to-date-16.inuse').val();
  if(to != undefined)
    form += '<input type="hidden" name="payment_tax_report[to]" value="'+to+'">';

  $('#report_params').html(form);
}

function payment_deposit_report() {
  var row_id = [];
  var ibl_ref = [];
  var carrier_id = [];
  var payment_type = [];
  var form = "";
  paymentsDepositTable.rows({search:'applied'}).every( function ( rowIdx, tableLoop, rowLoop ) {
    var rowNode = this.node();

    $(rowNode).find("td.row_id").each(function (){
      row_id.push( $(this).text().trim() );
    });

    $(rowNode).find("td.ibl_ref").each(function (){
      ibl_ref.push( $(this).text().trim() );
    });

    $(rowNode).find("td.carrier_id").each(function (){
      carrier_id.push( $(this).text().trim() );
    });

    $(rowNode).find("td.payment_type").each(function (){
      payment_type.push( $(this).text().trim() );
    });
  });

  console.log(row_id);
  console.log(ibl_ref);
  console.log(carrier_id);
  console.log(payment_type);

  $.each(row_id, function(key, value){
    form += '<input type="hidden" name="payment_deposit_report[row_ids][]" value="'+value+'">';
  });

  $.each(ibl_ref, function(key, value){
    form += '<input type="hidden" name="payment_deposit_report[ibl_refs][]" value="'+value+'">';
  });

  $.each(carrier_id, function(key, value){
    form += '<input type="hidden" name="payment_deposit_report[carrier_ids][]" value="'+value+'">';
  });

  $.each(payment_type, function(key, value){
    form += '<input type="hidden" name="payment_deposit_report[payment_types][]" value="'+value+'">';
  });

  var columns = [];
  paymentsDepositTable.columns(':not(.disable)').every( function ( rowIdx, tableLoop, rowLoop ) {
    if(this.visible() === true){
      columns.push(rowIdx);
    }
  } );

  console.log(columns);

  $.each(columns, function(key, value){
    form += '<input type="hidden" name="payment_deposit_report[columns][]" value="'+value+'">';
  });

  form += '<input type="hidden" name="payment_deposit_report[format]" value="'+$('#format').val()+'">';
  var monthly = $('#yadcf-filter--payments_deposit_table-15.inuse').val();
  if(monthly != undefined)
    form += '<input type="hidden" name="payment_deposit_report[monthly]" value="'+monthly+'">';

  var from = $('#yadcf-filter--payments_deposit_table-from-date-16.inuse').val();
  if(from != undefined)
    form += '<input type="hidden" name="payment_deposit_report[from]" value="'+from+'">';

  var to = $('#yadcf-filter--payments_deposit_table-to-date-16.inuse').val();
  if(to != undefined)
    form += '<input type="hidden" name="payment_deposit_report[to]" value="'+to+'">';

  $('#report_params').html(form);
}

function control_center_report() {
  var row_ids = [];
  var head_letters = [];
  var form = "";
  controlCenterTable.rows({search:'applied'}).every( function ( rowIdx, tableLoop, rowLoop ) {
    var rowNode = this.node();

    $(rowNode).find("td.row_id").each(function (){
      row_ids.push( $(this).text().trim() );
    });
    $(rowNode).find("td.head_letter").each(function (){
      head_letters.push( $(this).text().trim() );
    });
  });

  console.log(row_ids);
  console.log(head_letters);

  $.each(row_ids, function(key, value){
    form += '<input type="hidden" name="control_center_report[row_ids][]" value="'+value+'">';
  });
  $.each(head_letters, function(key, value){
    form += '<input type="hidden" name="control_center_report[head_letters][]" value="'+value+'">';
  });

  var columns = [];
  controlCenterTable.columns(':not(.disable)').every( function ( rowIdx, tableLoop, rowLoop ) {
    if(this.visible() === true){
      columns.push(rowIdx);
    }
  } );

  console.log(columns);

  $.each(columns, function(key, value){
    form += '<input type="hidden" name="control_center_report[columns][]" value="'+value+'">';
  });

  form += '<input type="hidden" name="control_center_report[format]" value="'+$('#format').val()+'">';
  var monthly = $('#yadcf-filter--control_center_table-20.inuse').val();
  if(monthly != undefined)
    form += '<input type="hidden" name="control_center_report[monthly]" value="'+monthly+'">';

  var from = $('#yadcf-filter--control_center_table-from-date-21.inuse').val();
  if(from != undefined)
    form += '<input type="hidden" name="control_center_report[from]" value="'+from+'">';

  var to = $('#yadcf-filter--control_center_table-to-date-21.inuse').val();
  if(to != undefined)
    form += '<input type="hidden" name="control_center_report[to]" value="'+to+'">';

  form += '<input type="hidden" name="control_center_report[report_type]" value="'+$('#report_type').val()+'">';

  $('#report_params').html(form);
}

function control_center_short_paid_report() {
  var row_ids = [];
  var form = "";
  controlCenterShortPaidTable.rows({search:'applied'}).every( function ( rowIdx, tableLoop, rowLoop ) {
    var rowNode = this.node();

    $(rowNode).find("td.row_id").each(function (){
      row_ids.push( $(this).text().trim() );
    });
  });

  console.log(row_ids);

  $.each(row_ids, function(key, value){
    form += '<input type="hidden" name="control_center_short_paid_report[row_ids][]" value="'+value+'">';
  });

  var columns = [];
  controlCenterShortPaidTable.columns(':not(.disable)').every( function ( rowIdx, tableLoop, rowLoop ) {
    if(this.visible() === true){
      columns.push(rowIdx);
    }
  } );

  console.log(columns);

  $.each(columns, function(key, value){
    form += '<input type="hidden" name="control_center_short_paid_report[columns][]" value="'+value+'">';
  });

  form += '<input type="hidden" name="control_center_short_paid_report[format]" value="'+$('#format').val()+'">';
  var monthly = $('#yadcf-filter--control_center_short_paid_table-10.inuse').val();
  if(monthly != undefined)
    form += '<input type="hidden" name="control_center_short_paid_report[monthly]" value="'+monthly+'">';

  var from = $('#yadcf-filter--control_center_short_paid_table-from-date-11.inuse').val();
  if(from != undefined)
    form += '<input type="hidden" name="control_center_short_paid_report[from]" value="'+from+'">';

  var to = $('#yadcf-filter--control_center_short_paid_table-to-date-11.inuse').val();
  if(to != undefined)
    form += '<input type="hidden" name="control_center_short_paid_report[to]" value="'+to+'">';

  $('#report_params').html(form);
}

// function control_center_deposit_report() {
//   var row_ids = [];
//   var form = "";
//   controlCenterDepositTable.rows({search:'applied'}).every( function ( rowIdx, tableLoop, rowLoop ) {
//     var rowNode = this.node();

//     $(rowNode).find("td.row_id").each(function (){
//       row_ids.push( $(this).text().trim() );
//     });
//   });

//   console.log(row_ids);

//   $.each(row_ids, function(key, value){
//     form += '<input type="hidden" name="control_center_deposit_report[row_ids][]" value="'+value+'">';
//   });

//   var columns = [];
//   controlCenterDepositTable.columns(':not(.disable)').every( function ( rowIdx, tableLoop, rowLoop ) {
//     if(this.visible() === true){
//       columns.push(rowIdx);
//     }
//   } );

//   console.log(columns);

//   $.each(columns, function(key, value){
//     form += '<input type="hidden" name="control_center_deposit_report[columns][]" value="'+value+'">';
//   });

//   form += '<input type="hidden" name="control_center_deposit_report[format]" value="'+$('#format').val()+'">';
//   var monthly = $('#yadcf-filter--control_center_deposit_table-5.inuse').val();
//   if(monthly != undefined)
//     form += '<input type="hidden" name="control_center_deposit_report[monthly]" value="'+monthly+'">';

//   var from = $('#yadcf-filter--control_center_deposit_table-from-date-6.inuse').val();
//   if(from != undefined)
//     form += '<input type="hidden" name="control_center_deposit_report[from]" value="'+from+'">';

//   var to = $('#yadcf-filter--control_center_deposit_table-to-date-6.inuse').val();
//   if(to != undefined)
//     form += '<input type="hidden" name="control_center_deposit_report[to]" value="'+to+'">';

//   $('#report_params').html(form);
// }

function control_center_deposit_report() {
  var row_id = [];
  var ibl_ref = [];
  var carrier_id = [];
  var payment_type = [];
  var form = "";
  controlCenterDepositTable.rows({search:'applied'}).every( function ( rowIdx, tableLoop, rowLoop ) {
    var rowNode = this.node();

    $(rowNode).find("td.row_id").each(function (){
      row_id.push( $(this).text().trim() );
    });

    $(rowNode).find("td.ibl_ref").each(function (){
      ibl_ref.push( $(this).text().trim() );
    });

    $(rowNode).find("td.carrier_id").each(function (){
      carrier_id.push( $(this).text().trim() );
    });

    $(rowNode).find("td.payment_type").each(function (){
      payment_type.push( $(this).text().trim() );
    });
  });

  console.log(row_id);
  console.log(ibl_ref);
  console.log(carrier_id);
  console.log(payment_type);

  $.each(row_id, function(key, value){
    form += '<input type="hidden" name="control_center_deposit_report[row_ids][]" value="'+value+'">';
  });

  $.each(ibl_ref, function(key, value){
    form += '<input type="hidden" name="control_center_deposit_report[ibl_refs][]" value="'+value+'">';
  });

  $.each(carrier_id, function(key, value){
    form += '<input type="hidden" name="control_center_deposit_report[carrier_ids][]" value="'+value+'">';
  });

  $.each(payment_type, function(key, value){
    form += '<input type="hidden" name="control_center_deposit_report[payment_types][]" value="'+value+'">';
  });

  var columns = [];
  controlCenterDepositTable.columns(':not(.disable)').every( function ( rowIdx, tableLoop, rowLoop ) {
    if(this.visible() === true){
      columns.push(rowIdx);
    }
  } );

  console.log(columns);

  $.each(columns, function(key, value){
    form += '<input type="hidden" name="control_center_deposit_report[columns][]" value="'+value+'">';
  });

  form += '<input type="hidden" name="control_center_deposit_report[format]" value="'+$('#format').val()+'">';
  var monthly = $('#yadcf-filter--control_center_deposit_table-15.inuse').val();
  if(monthly != undefined)
    form += '<input type="hidden" name="control_center_deposit_report[monthly]" value="'+monthly+'">';

  var from = $('#yadcf-filter--control_center_deposit_table-from-date-16.inuse').val();
  if(from != undefined)
    form += '<input type="hidden" name="control_center_deposit_report[from]" value="'+from+'">';

  var to = $('#yadcf-filter--control_center_deposit_table-to-date-16.inuse').val();
  if(to != undefined)
    form += '<input type="hidden" name="control_center_deposit_report[to]" value="'+to+'">';

  $('#report_params').html(form);
}

function cost_revenue_report() {
  var row_ids = [];
  var form = "";
  costRevenuesTable.rows({search:'applied'}).every( function ( rowIdx, tableLoop, rowLoop ) {
    var rowNode = this.node();

    $(rowNode).find("td.row_id").each(function (){
      row_ids.push( $(this).text().trim() );
    });
  });

  console.log(row_ids);

  $.each(row_ids, function(key, value){
    form += '<input type="hidden" name="cost_revenue_report[row_ids][]" value="'+value+'">';
  });

  var columns = [];
  costRevenuesTable.columns(':not(.disable)').every( function ( rowIdx, tableLoop, rowLoop ) {
    if(this.visible() === true){
      columns.push(rowIdx);
    }
  } );

  console.log(columns);

  $.each(columns, function(key, value){
    form += '<input type="hidden" name="cost_revenue_report[columns][]" value="'+value+'">';
  });

  form += '<input type="hidden" name="cost_revenue_report[format]" value="'+$('#format').val()+'">';
  var monthly = $('#yadcf-filter--cost_revenues_table-20.inuse').val();
  if(monthly != undefined)
    form += '<input type="hidden" name="cost_revenue_report[monthly]" value="'+monthly+'">';

  var from = $('#yadcf-filter--cost_revenues_table-from-date-21.inuse').val();
  if(from != undefined)
    form += '<input type="hidden" name="cost_revenue_report[from]" value="'+from+'">';

  var to = $('#yadcf-filter--cost_revenues_table-to-date-21.inuse').val();
  if(to != undefined)
    form += '<input type="hidden" name="cost_revenue_report[to]" value="'+to+'">';

  $('#report_params').html(form);
}

$(document).ready(function () {
  // $(".adjust").click(function (e) {
  $(".adjust").livequery(function () {
    $(this).click(function (e) {
      e.preventDefault();
      $(this).prev().toggleClass("collapsed");
      if ($(this).prev().hasClass("collapsed")) {
        $(this).text("+ More")
      } else {
        $(this).text("- Less")
      }
    });
  });

  $(".tax_issued").datepicker({
    changeMonth: true,
    changeYear: true,
    showButtonPanel: true,
    dateFormat: 'MM yy',
    onClose: function(dateText, inst) {
        var month = $("#ui-datepicker-div .ui-datepicker-month :selected").val();
        var year = $("#ui-datepicker-div .ui-datepicker-year :selected").val();
        $(this).datepicker('setDate', new Date(year, month, 1));
    }
  }).focus(function () {
    $(".ui-datepicker-calendar").hide();
  });
  // $(".tax_issued").change({$(this).val($.datepicker.formatDate("MM yy", new Date($(this).val())))});

  $(".tax_issued_with_date").datepicker({dateFormat: 'dd-M-yy'});
});
