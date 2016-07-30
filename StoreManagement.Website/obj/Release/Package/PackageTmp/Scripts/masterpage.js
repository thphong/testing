$(document).ready(function () {
    var pathname = window.location.pathname;
    $("#nav-list-menu li").each(function () {
        if ($(this).children("a[href=" + pathname + "]").length > 0) {
            $(this).addClass("active");
        }
    });
});