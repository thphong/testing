var mdlCommon = angular.module('mdlCommon', []);

function AjaxAsync(service, para, delegate) {
    $.ajax({
        type: "POST",
        url: service,
        data: para,
        contentType: "application/json",
        success: delegate,
        error: function () {
        }
    });
}

function ShowLoading() {
    //$("div#main").showLoading();
}

function HideLoading() {
    //$("div#main").hideLoading();
}


function AjaxSync(service, para) {

    var result = null;
    $.ajax({
        type: "POST",
        url: service,
        data: para,
        contentType: "application/json",
        async: false,
        beforeSend: ShowLoading,
        complete: HideLoading,
        success: function (data) {
            result = data;
        },
        error: function () {
            result = null;
        }
    });
    return result;
}

function AjaxSyncWithoutLoading(service, para) {

    var result = null;
    $.ajax({
        type: "POST",
        url: service,
        data: para,
        contentType: "application/json",
        async: false,
        success: function (data) {
            result = data;
        },
        error: function () {
            result = null;
        }
    });
    return result;
}

/*$(document).ready(function () {
    //alert($(".tab-pane").length);
    $(".tabbable .nav-tabs li").click(function () {
        var tabForId = $(this).attr("tab-for");
        alert(tabForId);
        var groupTab = $(".tab-pane#" + tabForId).attr("tab-group");
        $(".tab-pane[tab-group='" + groupTab + "']").removeClass("active");
        $(".tab-pane#" + tabForId).addClass("active");
    })
})*/

function ShowErrorMessage(message) 
{
    $("#popUpModal .modal-title").html("Lỗi");
    $("#popUpModal .modal-body p").html(message);
    $("#popUpModal .modal-header").removeClass("infobox-green").addClass("infobox-red");
    $("button[data-target='#popUpModal']").click();
}

function ShowSuccessMessage(message) {
    $("#popUpModal .modal-title").html("Thành công");
    $("#popUpModal .modal-body p").html(message);
    $("#popUpModal .modal-header").removeClass("infobox-red").addClass("infobox-green");
    $("button[data-target='#popUpModal']").click();
}

function CheckRangeDate(fromDate, toDate) {
    var fromDateList = fromDate.split('-');
    var toDateList = toDate.split('-');
    for (var i = toDateList.length - 1; i >= 0; i--) {
        if (toDateList[i] < fromDateList[i]) {
            return false;
        }
        else if (toDateList[i] > fromDateList[i]) {
            break;
        }
    }
    return true;
}


function CalculateTime(fromTime, toTime) {
    if (!CheckTimeValid(fromTime) || !CheckTimeValid(toTime))
        return "";
    var fromTimeList = fromTime.split(':');
    var toTimeList = toTime.split(':');
    var t = 3600;
    var sFrom = 0;
    for (var i = 0; i < fromTimeList.length; i++) {
        sFrom += t * parseInt(fromTimeList[i]);
        t /= 60;
    }

    t = 3600;
    var sTo = 0;
    for (i = 0; i < toTimeList.length; i++) {
        sTo += t * parseInt(toTimeList[i]);
        t /= 60;
    }
    var result = sTo - sFrom;
    if (result < 0)
        result = result + 86400;

    return sformat(result);
    //var hh = Math.floor(result / 3600),
    //mm = Math.floor(result / 60) % 60,
    //ss = Math.floor(result) % 60;
    //return (hh ? (hh < 10 ? "0" : "") + hh + ":" : "") + ((mm < 10) && hh ? "0" : "") + mm + ":" + (ss < 10 ? "0" : "") + ss;
}

function CheckDateValid(value)
{
    if (!value) return true;
    var index = value.split('-');
    if (index.length != 3) {
        return false;
    }
    var newDate = new Date(index[2] + "-" + index[1] + "-" + index[0]);
    if(newDate.getDate())
    {
        return true;
    }
    return false;
}

function CheckTimeValid(value) {
    if (!/^(([0-1][0-9])|([2][0-3])):([0-5][0-9])(:([0-5][0-9]))?$/.test(value))
        return false;
    var index = value.split(':');
    if (index[0] > 23 || index[1] > 59 || index[2] > 59)
        return false;
    return true;
}

function CheckEmailValid(email) {
    if (!email) return true;
    var re = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    return re.test(email);
}

function sformat(s) {
    var fm = [
          Math.floor(s / 60 / 60) % 24, // HOURS
          Math.floor(s / 60) % 60, // MINUTES
          s % 60 // SECONDS
    ];
    return $.map(fm, function (v, i) { return ((v < 10) ? '0' : '') + v; }).join(':');
}

function formatDate(date) {
    var d = date,
        month = '' + (d.getMonth() + 1),
        day = '' + d.getDate(),
        year = d.getFullYear();

    if (month.length < 2) month = '0' + month;
    if (day.length < 2) day = '0' + day;

    return [day, month, year].join('-');
}