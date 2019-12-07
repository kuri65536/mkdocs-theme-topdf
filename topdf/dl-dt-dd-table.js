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


window.addEventListener('load', function() {
    dldtdd_tables();
});
