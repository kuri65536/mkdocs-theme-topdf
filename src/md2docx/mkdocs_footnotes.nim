"""
Footnotes2 Extension for Python-Markdown
========================================

Adds footnote handling to Python-Markdown.

See <https://Python-Markdown.github.io/extensions/footnotes>
for documentation.

Copyright The Python Markdown Project

License: [BSD](https://opensource.org/licenses/bsd-license.php)

"""
from typing import Dict, List, Text

from markdown import Extension
from markdown.inlinepatterns import InlineProcessor
from markdown.treeprocessors import Treeprocessor
from markdown.postprocessors import Postprocessor
from markdown import util
from collections import OrderedDict
import re
import copy
import xml.etree.ElementTree as etree

FN_BACKLINK_TEXT = util.STX + "zz1337820767766393qq" + util.ETX
NBSP_PLACEHOLDER = util.STX + "qq3936677670287331zz" + util.ETX
DEF_RE = re.compile(r'[ ]{0,3}\[\^([^\]]*)\]:\s*(.*)')
TABBED_RE = re.compile(r'((\t)|(    ))(.*)')
RE_REF_ID = re.compile(r'(fnref)(\d+)')


class Footnote2Extension(Extension):
    """ Footnote2 Extension. """
    footnotes = OrderedDict()

    def __init__(self, **kwargs):
        """ Setup configs. """

        self.config = {
            'PLACE_MARKER':
                ["///Footnotes2 Go Here///",
                 "The text string that marks where the footnotes go"],
            'UNIQUE_IDS':
                [False,
                 "Avoid name collisions across "
                 "multiple calls to reset()."],
            "BACKLINK_TEXT":
                ["&#8617;",
                 "The text string that links from the footnote "
                 "to the reader's place."],
            "BACKLINK_TITLE":
                ["Jump back to footnote %d in the text",
                 "The text string used for the title HTML attribute "
                 "of the backlink. %d will be replaced by the "
                 "footnote number."],
            "SEPARATOR":
                [":",
                 "Footnote2 separator."]
        }
        super().__init__(**kwargs)

        # In multiple invocations, emit links that don't get tangled.
        self.unique_prefix = 0
        self.found_refs = {}
        self.used_refs = set()

        self.reset()

    def extendMarkdown(self, md):
        """ Add pieces to Markdown. """
        md.registerExtension(self)
        self.parser = md.parser
        self.md = md

        # Insert an inline pattern before ImageReferencePattern
        FOOTNOTE_RE = r'\[@([^\]]*)\]'  # blah blah [@...] blah
        md.inlinePatterns.register(
                Footnote2InlineProcessor(FOOTNOTE_RE, self), 'footnote2', 175)

        # Insert a tree-processor that will run after inline is done.
        # In this tree-processor we want to check our duplicate footnote trcker
        # And add additional backrefs to the footnote pointing back to the
        # duplicated references.
        md.treeprocessors.register(
                Footnote2PostTreeprocessor(self), 'footnote2-duplicate', 15)

        # Insert a postprocessor after amp_substitute processor
        md.postprocessors.register(
                Footnote2Postprocessor(self), 'footnote2', 25)

    def reset(self):
        """ Clear footnotes on reset, and prepare for distinct document. """
        self.unique_prefix += 1
        self.found_refs = {}
        self.used_refs = set()

    def unique_ref(self, reference, found=False):
        """ Get a unique reference if there are duplicates. """
        if not found:
            return reference

        original_ref = reference
        while reference in self.used_refs:
            ref, rest = reference.split(self.get_separator(), 1)
            m = RE_REF_ID.match(ref)
            if m:
                reference = '%s%d%s%s' % (m.group(1), int(m.group(2))+1,
                                          self.get_separator(), rest)
            else:
                reference = '%s%d%s%s' % (ref, 2, self.get_separator(), rest)

        self.used_refs.add(reference)
        if original_ref in self.found_refs:
            self.found_refs[original_ref] += 1
        else:
            self.found_refs[original_ref] = 1
        return reference

    def findPlaceholder(self, root):
        """ Return ElementTree Element that contains Footnote2 placeholder. """
        def finder(element):
            for child in element:
                if child.text:
                    if child.text.find(self.getConfig("PLACE_MARKER")) > -1:
                        return child, element, True
                if child.tail:
                    if child.tail.find(self.getConfig("PLACE_MARKER")) > -1:
                        return child, element, False
                child_res = finder(child)
                if child_res is not None:
                    return child_res
            return None

        res = finder(root)
        return res

    def set_item(self, id: Text, text: Text) -> None:
        """ Store a footnote for later retrieval. """
        self.footnotes[id] = text

    def get_separator(self):
        """ Get the footnote separator. """
        return self.getConfig("SEPARATOR")

    def makeFootnoteId(self, id):
        """ Return footnote link id. """
        if self.getConfig("UNIQUE_IDS"):
            return 'fn2%s%d-%s' % (self.get_separator(),
                                   self.unique_prefix, id)
        else:
            return 'fn2{}{}'.format(self.get_separator(), id)

    def makeFootnoteRefId(self, id, found=False):
        """ Return footnote back-link id. """
        if self.getConfig("UNIQUE_IDS"):
            return self.unique_ref('fn2ref%s%d-%s' % (
                    self.get_separator(), self.unique_prefix, id), found)
        else:
            return self.unique_ref('fn2ref{}{}'.format(
                    self.get_separator(), id), found)

    def makeDiv(self):
        """ Return div of footnotes as et Element. """

        if not list(self.footnotes.keys()):
            return None

        dct: Dict[Text, List[Text]] = {}
        for refid, id in self.footnotes.items():
            if id not in dct:
                dct[id] = []
            dct[id].append(refid)
        keys = sorted(dct.keys())

        dl = etree.Element("dl")
        dl.set('class', 'footnotes2')
        etree.SubElement(dl, "dt").text = "id"
        etree.SubElement(dl, "dd").text = "descriptions/backlinks"

        for id in keys:
            dt = etree.SubElement(dl, "dt")
            dd = etree.SubElement(dl, "dd")

            # Firefox Nightly 79 does not jump to dt's id attr.
            anchor = etree.SubElement(dt, 'span')
            # need a-href for python-markdown
            # anchor.set("href", "javascript:void();")
            anchor.set("id", self.makeFootnoteId(id))
            anchor.text = id

            for refid in dct[id]:
                backlink = etree.Element("a")
                backlink.set("href", "#" + refid)
                backlink.set("class", "footnote2-backref")
                backlink.text = FN_BACKLINK_TEXT

                # TODO(shimoda): extract one line of text.
                dd.append(backlink)
        return dl


class Footnote2InlineProcessor(InlineProcessor):
    """ InlinePattern for footnote markers in a document's body text. """

    def __init__(self, pattern: Text, footnotes: Footnote2Extension) -> None:
        super().__init__(pattern)
        self.footnotes = footnotes

    def handleMatch(self, m, data):
        id = m.group(1)

        sup = etree.Element("sup")
        a = etree.SubElement(sup, "a")
        refid = self.footnotes.makeFootnoteRefId(id, found=True)
        sup.set('id', refid)
        a.set('href', '#' + self.footnotes.makeFootnoteId(id))
        a.set('class', 'footnotes2-ref')
        a.text = id

        self.footnotes.set_item(refid, id)
        return sup, m.start(0), m.end(0)


class Footnote2PostTreeprocessor(Treeprocessor):
    """ Amend footnote div with duplicates. """

    def __init__(self, footnotes):
        self.footnotes = footnotes

    def add_duplicates(self, li, duplicates):
        """ Adjust current li and add the duplicates: fnref2, fnref3, etc. """
        for link in li.iter('a'):
            # Find the link that needs to be duplicated.
            if link.attrib.get('class', '') == 'footnote2-backref':
                ref, rest = link.attrib['href'].split(
                        self.footnotes.get_separator(), 1)
                # Duplicate link the number of times we need to
                # and point the to the appropriate references.
                links = []
                for index in range(2, duplicates + 1):
                    sib_link = copy.deepcopy(link)
                    sib_link.attrib['href'] = '%s%d%s%s' % (
                            ref, index, self.footnotes.get_separator(), rest)
                    links.append(sib_link)
                    self.offset += 1
                # Add all the new duplicate links.
                el = list(li)[-1]
                for l in links:
                    el.append(l)
                break

    def get_num_duplicates(self, li):
        """ Get the number of duplicate refs of the footnote. """
        fn, rest = li.attrib.get('id', '').split(
                self.footnotes.get_separator(), 1)
        link_id = '{}ref{}{}'.format(fn, self.footnotes.get_separator(), rest)
        return self.footnotes.found_refs.get(link_id, 0)

    def handle_duplicates(self, parent):
        """ Find duplicate footnotes and format and add the duplicates. """
        for li in list(parent):
            # Check number of duplicates footnotes and insert
            # additional links if needed.
            count = self.get_num_duplicates(li)
            if count > 1:
                self.add_duplicates(li, count)

    def run(self, root):
        """ Crawl the footnote div and add missing duplicate footnotes. """
        self.offset = 0
        for div in root.iter('div'):
            if div.attrib.get('class', '') == 'footnote2':
                # Footnote2s shoul be under the first orderd list under
                # the footnote div.  So once we find it, quit.
                for ol in div.iter('ol'):
                    self.handle_duplicates(ol)
                    break

        self.run_placer(root)

    def run_placer(self, root: etree.Element) -> None:
        print("tree:%s-ext:%s" % (self, self.footnotes))
        placer = self.footnotes.findPlaceholder(root)
        result = self.footnotes.makeDiv()

        if result is None and placer is None:
            return
        if placer is None:
            root.append(result)
            return

        child, parent, isText = placer
        ind = list(parent).index(child)
        if result is None:
            child.text = "///there are no footnotes2 contents...///"
            child.tail = None
            return

        if isText:
            parent.remove(child)
            parent.insert(ind, result)
        else:
            parent.insert(ind + 1, result)
            child.tail = None


class Footnote2Postprocessor(Postprocessor):
    """ Replace placeholders with html entities. """
    def __init__(self, footnotes):
        self.footnotes = footnotes

    def run(self, text):
        text = text.replace(
            FN_BACKLINK_TEXT, self.footnotes.getConfig("BACKLINK_TEXT")
        )
        return text.replace(NBSP_PLACEHOLDER, "&#160;")


def makeExtension(**kwargs):  # pragma: no cover
    """ Return an instance of the Footnote2Extension """
    return Footnote2Extension(**kwargs)

# vi: ft=python
