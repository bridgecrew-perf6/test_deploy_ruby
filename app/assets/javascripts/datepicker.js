var readyYear;
readyYear = function(){
  'use strict';
	$(".etd_date:eq(0)").livequery(function () {
    $(this).datepicker({
      dateFormat: 'dd MM yy',
      changeMonth: true,
      // changeYear: true,
      minDate: new Date(year, 0, 1),
      // maxdate: new Date(today.getFullYear(), 11, 31) 
      maxDate: new Date(year, 11, 31)
    });
  });

  $(".datepicker").livequery(function () {
    $(this).datepicker({
      dateFormat: 'dd MM yy',
      changeMonth: true,
      changeYear: true,
      minDate: new Date(year, 0, 1),
      // maxdate: new Date(today.getFullYear(), 11, 31) 
      // maxDate: new Date(year, 11, 31)
    });
  });

  $( ".filter_monthly" ).datepicker({
    changeMonth: true,
    changeYear: true,
    showButtonPanel: true,
    dateFormat: 'MM yy',
    // minDate: new Date(year, 0, 1),
    // maxDate: new Date(year, 11, 31),
    minDate: new Date(min_year, 0, 1),
    maxDate: new Date(max_year, 11, 31),
    onClose: function(dateText, inst) { 
        var month = $("#ui-datepicker-div .ui-datepicker-month :selected").val();
        var year = $("#ui-datepicker-div .ui-datepicker-year :selected").val();
        $(this).datepicker('setDate', new Date(year, month, 1));
    }
  }).focus(function () {
    $(".ui-datepicker-calendar").css("display", "none");
  });

  $( ".filter_from" ).datepicker({
    defaultDate: "+1w",
    changeMonth: true,
    changeYear: true,
    dateFormat: 'dd MM yy',
    // minDate: new Date(year, 0, 1),
    // maxDate: new Date(year, 11, 31),
    minDate: new Date(min_year, 0, 1),
    maxDate: new Date(max_year, 11, 31),
    onClose: function( selectedDate ) {
      $( ".filter_to" ).datepicker( "option", "minDate", selectedDate );
    }
  }).focus(function () {
    // $(".ui-datepicker-calendar").css("display", "block");
  });

  $( ".filter_to" ).datepicker({
    defaultDate: "+1w",
    changeMonth: true,
    changeYear: true,
    dateFormat: 'dd MM yy',
    // minDate: new Date(year, 0, 1),
    // maxDate: new Date(year, 11, 31),
    minDate: new Date(min_year, 0, 1),
    maxDate: new Date(max_year, 11, 31),
    onClose: function( selectedDate ) {
      $( ".filter_from" ).datepicker( "option", "maxDate", selectedDate );
    }
  }).focus(function () {
    // $(".ui-datepicker-calendar").css("display", "block");
  });
}