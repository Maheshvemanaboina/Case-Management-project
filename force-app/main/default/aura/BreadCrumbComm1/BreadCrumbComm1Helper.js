({
    helperMethod : function() {

    },
    verifyUrlLoad : function(component,event,helper){
        var urlVal = window.location.href;
        var subsData = urlVal.substring(urlVal.indexOf('s/')+2);
        console.log('In helper subsdata:: '+subsData);
    }
})