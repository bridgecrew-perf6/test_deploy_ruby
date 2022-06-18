$.fn.dataTableExt.oApi.fnSetFilteringDelay = function ( oSettings, iDelay, searchOnly ) {
    var _that = this;

    if ( iDelay === undefined ) {
        iDelay = 1500;
    }

    searchOnly = !isset(searchOnly) ? false : searchOnly;

    this.each( function ( i ) {
        $.fn.dataTableExt.iApiIndex = i;
        var
            oTimerId = null,
            sPreviousSearch = null,
            anControl = $( 'input', _that.fnSettings().aanFeatures.f );

        anControl.unbind( 'keyup search input' ).bind( 'keyup search input', function() {

            if (sPreviousSearch === null || sPreviousSearch != anControl.val()) {

                if(searchOnly && $.trim(anControl.val()).length==0){
                    return this;
                }

                window.clearTimeout(oTimerId);
                sPreviousSearch = anControl.val();
                oTimerId = window.setTimeout(function() {
                    $.fn.dataTableExt.iApiIndex = i;
                    _that.fnFilter( anControl.val() );
                }, iDelay);

            }
        });

        return this;
    } );
    return this;
};