// var readyFormat;
// readyFormat = function(){
$(document).ready(function () {
  $(".money_text").livequery(function(){
    $(this).each(function(){
      $(this).val(money_format($(this).val()));
    });
  });
  
  $(".volume_text").livequery(function(){
    $(this).each(function(){
      $(this).val(volume_format($(this).val()));
    });
  });

  $(".money_text").livequery(function(){
    $(this).focus(function(){
      var number = $(this).val() == '' ? 0 : $(this).val();
      $(this).val(number_format(number));
    });
    $(this).focusout(function(){
      var number = $(this).val() == '' ? 0 : $(this).val();
      $(this).val(money_format(number));
    });
  });

  $(".volume_text").livequery(function(){
    $(this).focus(function(){
      var number = $(this).val() == '' ? 0 : $(this).val();
      $(this).val(number_format(number));
    });
    $(this).focusout(function(){
      var number = $(this).val() == '' ? 0 : $(this).val();
      $(this).val(volume_format(number));
    });
  });

  $("form").livequery(function(){
    $(this).submit(function(){
      $(".money_text, .volume_text").each(function(){ $(this).val(number_format($(this).val())) });
      // if($('#revenue-description').length != 0){
      //   $(".selling_total_after_tax, .buying_total_after_tax").prop( "disabled", false );
      // }
    });
  });
});
// };

function money_format(number){
  // return (number != 0) ? accounting.formatMoney(number, "", 2, ",", "."):'';
  // return accounting.formatMoney(number, "", 2, ",", ".");
  number = number_format(number).toFixed(2);
  // console.log(number);
  return (number%1 == 0) ? accounting.formatMoney(number, "", 0, ",", ".") : accounting.formatMoney(number, "", 2, ",", ".");
}

function volume_format(number){
  // return (number != 0) ? accounting.formatMoney(number, "", 3, ",", "."):'';
  number = number_format(number);
  return (number%1 == 0) ? accounting.formatMoney(number, "", 0, ",", ".") : accounting.formatMoney(number, "", 3, ",", ".");
}

function parentheses_format(number, currency){
  number = number_format(number);
  // if(number == 0){
  //   return
  // }
  var negative = false;
  if(number<0){
    negative = true;
    number = number * (-1);
  }
  currency = currency || '';
  if(currency.length != 0) currency = ' '+currency;
  if(negative) return '('+money_format(number)+currency+')';
  else return money_format(number)+currency;
}

// function parentheses_format(number){
//   number = number_format(number);
//   var negative = false;
//   if(number<0){
//     negative = true;
//     number = number * (-1);
//   }
//   if(negative) return '('+money_format(number)+')';
//   else return money_format(number);
// }

function number_format(money){
  var flag = 1;
  money = money+'';
  if(money.indexOf('(') != -1 || money.indexOf(')') != -1)
    flag = -1;
  money = typeof money === 'string' ? money.replace(/[\()USD IDR,]/g, '')*1*flag : typeof money === 'number' ? money*flag : 0;
  return accounting.unformat(money);
}

function money_with_decimal_format(number){
  number = number_format(number).toFixed(2);
  return accounting.formatMoney(number, "", 2, ",", ".");
}

function volume_with_decimal_format(number){
  number = number_format(number).toFixed(3);
  return accounting.formatMoney(number, "", 3, ",", ".");
}