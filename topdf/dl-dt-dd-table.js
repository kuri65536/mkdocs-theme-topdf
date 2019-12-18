/* dl-dt-dd for tables {{{1 */
function dldtdd_tables() {
    var seq_dl = document.querySelectorAll(".before-dl-table + dl");
    for (var i in seq_dl) {
        var dl = seq_dl[i];
        if (typeof(dl.parentNode) == "undefined") {
            continue;
        }
        var para = dl.previousElementSibling;

        var tbl = document.createElement("table");
        var tbody = document.createElement("thead");
        var tr = document.createElement("tr");
        for (var cls of para.classList) {
            if (cls == "before-dl-table") {continue;}
            tbl.classList.add(cls);
        }
        tbl.classList.add("dl-table");
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
            } else if (elm.nodeName == "DT") {
                var tbody = document.createElement("tbody")
                tbl.appendChild(tbody);
                tr = document.createElement("tr")
                tbody.appendChild(tr);
                f_head += 1;
            } else {
                continue;
            }

            var td_or_th = f_head == 1 ? "th": "td";
            var td = document.createElement(td_or_th);
            td.innerHTML = elm.innerHTML;
            tr.appendChild(td);
        }
        var par = dl.parentNode;
        par.insertBefore(tbl, dl);
        par.removeChild(dl);
        para.remove();
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

        var n = 0;
        for (var th of tbl.querySelectorAll("th")) {
            n += 1;
            if (n <= 1) {continue;}
            if (th.innerHTML.includes("<br")) {
                var html = th.innerHTML;
                html = html.replace("<br>", "</div>")
                html = html.replace("<br />", "</div>")
                th.innerHTML = "<div>" + html;
                continue;
            }
            th.style.backgroundImage =
               "url(\"data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/" +
               "2000/svg' width='40mm' height='40mm'>" +
               "<line fill='none' x1='0' y1='0' x2='100%' y2='100%' " +
               "stroke='black' stroke-width='1pt' /></svg>\")";
            th.classList.add("no-stamp");
        }
    }
}


/* code blocks {{{1 */
function code_blocks() {
    var seq_code = document.querySelectorAll("code");
    for (var code of seq_code) {
        var pre = code.parentNode;
        if (pre.nodeName != "PRE") {continue;}
        for (var cls of code.classList) {
            pre.classList.add(cls);
        }
    }
}


/* main {{{1 */
window.addEventListener('load', function() {
    dldtdd_tables();
    table_3stamps();
    code_blocks();
});

/* end of file {{{1
 * vi: ft=javascript:fdm=marker
 */
