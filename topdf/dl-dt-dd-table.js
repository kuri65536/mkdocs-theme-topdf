function dldtdd_tables() {
    seq_dl.forEach(function(dl) {
    var dl = $(".before-dl-table + dl");
    dl.each(function(i) {
        var dom = $('<table class="dl-table"><thead><tr></tr></thead>' +
                    '<tbody><tr></tr></tbody></table>');
        var _dl = $(dl[i]);
        dom.addClass(_dl.prev().attr("class"));
        dom.removeClass("before-dl-table");
        var f_head = 0;
        var seq = $(dl[i]).children();
        seq.each(function(i) {
            var elm = seq[i];
            if (elm.nodeName == "DD" && f_head < 2) {
                html = elm.innerHTML;
                $("thead > tr", dom).append("<td>" + html + "</td>");
            } else if (elm.nodeName == "DD") {
                html = elm.innerHTML;
                $("tbody > tr:last", dom).append("<td>" + html + "</td>");
            } else if (elm.nodeName == "DT" && f_head == 0) {
                f_head += 1;
                html = elm.innerHTML;
                $("thead > tr", dom).append("<td>" + html + "</td>");
            } else if (elm.nodeName == "DT" && f_head == 1) {
                f_head += 1;
                html = elm.innerHTML;
                $("tbody > tr", dom).append("<td>" + html + "</td>");
            } else if (elm.nodeName == "DT") {
                html = elm.innerHTML;
                $("tbody", dom).append("<tr><td>" + html + "</td></tr>");
            }
        });
        console.log(dom);
        dom.insertAfter(_dl);
        $(_dl).remove();
    }
}


window.addEventListener('load', function() {
    dldtdd_tables();
});
