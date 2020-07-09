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
                if (f_head == 1) {
                    var tbody = document.createElement("tbody")
                    tbl.appendChild(tbody);
                }
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


/* styled tables {{{1 */
function styled_tables() {
    function has_width_class(el) {
        for (var cls of el.classList) {
            if (!cls.startsWith("table")) {
                continue;
            }
            cls = cls.substring(5);
            ret = [];
            for (var part of cls.split("-")) {
                if (part == "a") {
                    ret.push(0);
                    continue;
                }
                // parse "1mm"
                if (part.endsWith("mm")) {
                    var dgt = part.substring(0, part.length - 2);
                    var val = parseFloat(dgt);
                    if (isNaN(val)) {
                        ret = null;
                        break;
                    }
                    ret.push(part);
                    continue;
                }
                // parse "1"
                var val = parseInt(part);
                if (!isNaN(val)) {
                    ret.push(val);
                    continue;
                }
                var val = parseFloat(part);
                if (!isNaN(val)) {
                    ret.push(val);
                    continue;
                }
                ret = null;
                break;
            }
            if (ret === null) {
                continue;
            }
            return ret;
        }
        return null;
    }

    function conv_width(widths) {
        var sum = 0;
        for (var i of widths) {
            if ((i === 0) || (typeof i === "string")) {
                continue;
            }
            sum += parseFloat(i);
        }
        sum = isNaN(sum) ? 16:
              sum <= 10 ? 16: 160 / sum;
        var ret = [];
        for (var i of widths) {
            if ((i === 0) || (typeof i === "string")) {
                //
            } else {
                i = (i * sum) + "mm";
            }
            ret.push(i);
        }
        return ret;
    }

    var seq_tbls = document.querySelectorAll("table");
    for (var tbl of seq_tbls) {
        if (typeof(tbl.parentNode) == "undefined") {
            continue;
        }
        var para = tbl.previousElementSibling;
        var widths = has_width_class(para);
        if (widths === null) {
            continue;
        }
        widths = conv_width(widths);

        var tr = tbl.querySelector("tr");
        var tds = tbl.querySelectorAll("th, td");
        for (var td of tds) {
            if (widths.length < 1) {break;}
            var width = widths.shift();
            if (typeof width === "string") {
                td.style.width = width;
            }
        }
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


/** <!-- fix_mkdocs_ids {{{1 -->
 */
function fix_mkdocs_ids() {
    var pfx = "fix_mkdocs_ids";
    var seq_a = document.querySelectorAll("a");
    seq_a.forEach(anchor => {
        var name = anchor.getAttribute("name");
        // console.log("fix_mkdocs_ids: a-name..." + name);
        if (name !== null && name.length > 0) {
            if (name[0].match("[0-9]")) {
                console.log("fix_mkdocs_ids: name..." + name);
                anchor.setAttribute("name", pfx + name);
            }
        }
        var href = anchor.getAttribute("href");
        // console.log("fix_mkdocs_ids: a-href..." + href);
        if (href !== null && href.length > 1 && href[0] == "#") {
            if (href[1].match("[0-9]")) {
                console.log("fix_mkdocs_ids: href..." + href);
                var id = href.substring(1);
                anchor.setAttribute("href", "#" + pfx + id);
            }
        }
    });
    var seq_h = document.querySelectorAll("h1, h2, h3, h4, h5, h6");
    seq_h.forEach(head => {
        var id = head.getAttribute("id");
        if (id !== null && id.length > 0 && id[0].match("[0-9]")) {
            console.log("fix_mkdocs_ids: h?-id..." + id);
            head.setAttribute("id", pfx + id);
        }
    });
}


/** <!-- controller {{{1 -->
 */
function controller() {
    /// 1. manipulate controller/ define callback for change styles.
    var chars_allow = [
        ['A', 'V', '>', '<', '<->', 'stl'],
        // ⬆ ↗ ➡ ↘ ⬇ ↙ ⬅ ↖ ↕ ↔ ↩ ↪ ⤴ ⤵ 🔃 🔄 🔙 🔚 🔛 🔜 🔝
        ['⬆', '⬇', '➡', '⬅', '↔', '🔃'],
        // 🔀 🔁 🔂 ▶ ⏩ ◀ ⏪ 🔼 ⏫ 🔽 ⏬ ⏹ ⏏ 🎦
        ['🔼', '🔽', '▶', '◀', '🔁', '⏏'],
    ];

    var div = document.createElement("div");
    document.body.append(div);
    div.classList.add("topdf-ctrl");
    var markup = '<a class="topdf-ctrl-btn" href="javascript:void()">zzz</a>';
    var html = '';
    for (var i of chars_allow[0]) {
        html += markup;
    }
    html += markup.replace("zzz", 'footnotes2');
    div.innerHTML = html;

    var circum_style = -1;
    var fn_man = function () {
        var n = circum_style = (circum_style + 1) % chars_allow.length;
        var j = 0;
        for (var i of chars_allow[n]) {
            j += 1;
            var anchor = div.querySelector('a:nth-child(' + j + ')');
            anchor.innerText = i;
        }
    };
    fn_man();
    var a_st = div.querySelector("a:nth-child(6)");
    a_st.addEventListener("click", fn_man);

    /// 2. manipulate controlelr/ define callback for change styles.
    var circum_enlarge = -1;
    var a_s2 = div.querySelector("a:nth-child(5)");
    a_s2.addEventListener("click", function (ev) {
        var styles = ["topdf-normal", "topdf-large", "topdf-small"];
        var n = circum_enlarge = (circum_enlarge + 1) % styles.length;
        for (var name of styles) {
            div.classList.remove(name, div.classList.contains(name));
        }
        div.classList.add(styles[n]);
    });

    /// 3. define callback for footnotes2
    var fn_fn2_0 = function (e) {
        e.style.display = "inline";
        e.style.fontSize = "10pt";  // smaller
    };
    var fn_fn2_1 = function (e) {
        e.style.display = "none";   // disappear
    };
    var fn_fn2_2 = function (e) {
        e.style.display = "inline";
        e.style.fontSize = "6pt";   // normal
    };

    var a_fn2 = div.querySelector("a:nth-child(7)");
    var circum = 0;
    a_fn2.addEventListener("click", function (ev) {
        // change CSS
        var n = circum = (circum + 1) % 3;
        for (var e of document.querySelectorAll(".footnotes2-ref")) {
            switch (n) {
            case 1: fn_fn2_1(e); break;
            case 2: fn_fn2_2(e); break;
            default: fn_fn2_0(e); break;  /* case 0: */
            }
        }
    });

    /// 3. define callback to jumping
    var n_navi = 0;
    var fn_scr = function (add) {
        var i = 0;
        var j = n_navi;
        n_navi += add;
        n_navi = n_navi < 0 ? 0: n_navi;
        for (var e of document.querySelectorAll(".toc a")) {
            i += 1;
            if (i <= j) {continue;}
            var id_ = e.getAttribute("href");
            if (!id_) {console.log("not have href: " + e); return;}
            id_ = id_.substring(1);  // remove "#"
            e = document.getElementById(id_);
            if (!e) {console.log("not exists: " + id_); return;}
            e.scrollIntoView(true);
            return;
        }
        n_navi = i - 1;
        console.log("over: " + n_navi);
    };

    var a_u = div.querySelector("a:nth-child(1)");
    var a_d = div.querySelector("a:nth-child(2)");
    var a_r = div.querySelector("a:nth-child(3)");
    var a_l = div.querySelector("a:nth-child(4)");
    a_u.addEventListener("click", function (ev) {fn_scr(-1);});
    a_d.addEventListener("click", function (ev) {fn_scr(1);});
    a_r.addEventListener("click", function (ev) {fn_scr(-9999);});
    a_l.addEventListener("click", function (ev) {fn_scr(9999); fn_scr(0);});
}


/* main {{{1 */
window.addEventListener('load', function() {
    fix_mkdocs_ids();
    dldtdd_tables();
    styled_tables();
    table_3stamps();
    code_blocks();
    controller();
});

/* end of file {{{1
 * vi: ft=javascript:fdm=marker
 */
