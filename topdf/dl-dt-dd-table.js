/* dl-dt-dd for tables {{{1 */
function dldtdd_tables() {
    var seq_dl = document.querySelectorAll(".before-dl-table + dl");
    for (var i in seq_dl) {
        var dl = seq_dl[i];
        if (typeof(dl.parentNode) == "undefined") {
            continue;
        }

        var tbl = document.createElement("table");
        var tbody = document.createElement("thead");
        var tr = document.createElement("tr");
        tbl.appendChild(tbody);
        tbody.appendChild(tr);

        var f_head = 0;
        var seq_dl_children = dl.childNodes;
        for (var j in seq_dl_children) {
            var elm = seq_dl_children[j];
            if (elm.nodeName == "DD") {
                //
            } else if (elm.nodeName == "DT" && f_head == 0) {
                f_head += 1;
            } else if (elm.nodeName == "DT" && f_head == 1) {
                var tbody = document.createElement("tbody")
                tbl.appendChild(tbody);
                tr = document.createElement("tr")
                tbody.appendChild(tr);
            } else if (elm.nodeName == "DT" && f_head == 1) {
                tr = document.createElement("tr")
                tbody.appendChild(tr);
                f_head += 1;
            } else {
                continue;
            }

            var td = document.createElement("td");
            td.innerHTML = elm.innerHTML;
            tr.appendChild(td);
        }
        var par = dl.parentNode;
        par.insertBefore(tbl, dl);
        par.removeChild(dl);
    }
}


/* 3stamps {{{1 */
function table_3stamps() {
    var seq_tbl = document.querySelectorAll(".table-3stamps");
    for (var tbl of seq_tbl) {
        var th = tbl.querySelector("th");
        var html = th.innerHTML;
        html = html.replace("<br>", "</div>")
        html = html.replace("<br />", "</div>")
        html = "<div>" + html;
        th.innerHTML = html;
    }
}


/* main {{{1 */
window.addEventListener('load', function() {
    dldtdd_tables();
    table_3stamps();
});

/* end of file {{{1
 * vi: ft=javascript:fdm=marker
 */
