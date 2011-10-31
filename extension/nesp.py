#!/usr/bin/env python

'''
Apply hedging from a BioScope format to existing BioNLP ST-style annotations.

Author:     Pontus Stenetorp    <pontus stenetorp se>
Version:    2011-10-19
'''

from argparse import ArgumentParser
from collections import defaultdict
from re import compile as re_compile
from sys import stderr
from string import whitespace

### Constants
ARGPARSER = ArgumentParser()#XXX:
ARGPARSER.add_argument('ann_dir')
ARGPARSER.add_argument('bioscope_data_dir')
ARGPARSER.add_argument('-a', '--a1-dir', default='')
ARGPARSER.add_argument('-d', '--dry', action='store_true',
        help="dry run, don't store results")
ARGPARSER.add_argument('-e', '--heuristic',
        choices=['none', 'internal-root', 'root'], default='none',
        help='choice of heuristic refinement')
ARGPARSER.add_argument('-v', '--verbose', action='store_true')

WHITESPACE_CHARS = set(whitespace)

# TODO: Move this later
SENTENCE_REGEX = re_compile(
        r'<sentence id="(?P<id>[0-9]+)">(?P<content>.*?)</sentence>$')
# XXX: We assume that the order is type, then id for the attributes. We have
#   an assert to catch if this fails.
SCOPE_REGEX = re_compile(
        r'(?P<s_tag><scope type="(?P<type>[^"]+)" id="(?P<id>[0-9]+)">)(?P<content>.*?)(?P<e_tag></scope>)')
CUE_REGEX = re_compile(
        r'(?P<s_tag><cue type="(?P<type>[^"]+)" id="(?P<id>[0-9]+)">)(?P<content>.*?)(?P<e_tag></cue>)')
# Ultra liberal, but should suit our purpose
XML_TAG_REGEX = re_compile(r'<(?:/)?[a-zA-Z]+[^ ]*(?: [^>]*)?(?:/)?>')
###

def _find(dir, regexp):
    from os import walk
    from os.path import join as path_join
    from re import compile as re_compile
    c_regexp = re_compile(regexp)
    for dpath, dnames, fnames in walk(dir):
        for fpath in (path_join(dpath, f) for f in fnames):
            if c_regexp.match(fpath) is not None:
                yield fpath

def _to_id(path):
    from os.path import basename, splitext
    return splitext(basename(path))[0]

def _get_id_mappings(ann_dir, bioscope_data_dir, verbose=False, a1_dir=None):
    # Find all annotation text files
    if a1_dir is not None:
        txt_dir = a1_dir
    else:
        txt_dir = ann_dir

    id_to_txt = {}
    for txt_file_path in _find(txt_dir, r'.*\.txt$'):
        _id = _to_id(txt_file_path)
        assert _id not in id_to_txt, ('duplicate id {} for {} and {}'
                ).format(_id, txt_file_path, id_to_txt[_id])
        id_to_txt[_id] = txt_file_path

    assert id_to_txt, 'found no annotation text files'

    if verbose:
        print >> stderr, ('found {} annotation text files'
                ).format(len(id_to_txt))
        
    # Find the corresponding annotations (.a1)
    id_to_a1 = {}
    for a1_file_path in _find(a1_dir if a1_dir is not None else ann_dir,
            r'.*\.a1$'):
        _id = _to_id(a1_file_path)
        assert _id not in id_to_a1, ('duplicate id {} for {} and {}'
                ).format(_id, a1_file_path, id_to_a1[_id])
        id_to_a1[_id] = a1_file_path

    if verbose:
        print >> stderr, 'found {} annotation (a1) files'.format(len(id_to_a1))

    # Find the corresponding annotations (.a2)
    id_to_a2 = {}
    for a2_file_path in _find(ann_dir, r'.*\.a2$'):
        _id = _to_id(a2_file_path)
        assert _id not in id_to_a2, ('duplicate id {} for {} and {}'
                ).format(_id, a2_file_path, id_to_a2[_id])
        id_to_a2[_id] = a2_file_path

    if verbose:
        print >> stderr, 'found {} annotation (a2) files'.format(len(id_to_a1))

    # Find the BioScope files (.nesp)
    id_to_nesp = {}
    for nesp_file_path in _find(bioscope_data_dir, r'.*\.nesp'):
        # Some filenames contained spaces, for the parses we adjusted this but
        # not for all the participants starting with the original data, so we
        # correct the resulting ids here.
        _id = _to_id(nesp_file_path).replace(' ', '_')
        assert _id not in id_to_nesp, ('duplicate id {} for {} and {}'
                ).format(_id, nesp_file_path, id_to_nesp[_id])
        id_to_nesp[_id] = nesp_file_path
    
    if verbose:
        print >> stderr, ('found {} hedge annotation (nesp) files'
                ).format(len(id_to_nesp))

    for _id in id_to_a2:
        assert _id in id_to_nesp, ('no  hedge annotation file found for id {}'
                ).format(_id)

    return id_to_txt, id_to_a1, id_to_a2, id_to_nesp



class Spans(object):
    def __init__(self):
        self.data = defaultdict(dict)

    def insert(self, span, elem, _type, id):
        assert id not in self.data[elem]
        self.data[elem][id] = (span, _type)

    def deletion(self, del_span, text):
        # Move all spans so that they are in sync
        for elem in self.data:
            for _id in self.data[elem]:
                span, _type = self.data[elem][_id]
                diff = del_span[1] - del_span[0]
                #print span, text[span[0]:span[1]]
                #print del_span, text[del_span[0]:del_span[1]]
                new_span = span
                # Have we been shifted? If so, move us back accordingly.
                if del_span[0] < span[0] and del_span[1] <= span[0]:
                    # Deletion prior to this span, move both start and end
                    new_span = [span[0] - diff, span[1] - diff]
                elif del_span[0] >= span[0] and del_span[1] <= span[1]:
                    # Deletion inside this span
                    new_span = [span[0], span[1] - diff]
                elif del_span[0] >= span[1] and del_span[1] > span[1]:
                    # Deletion after this span, do nothing
                    pass
                else:
                    assert False, 'deletion across span boundary'

                # Potentially update the data
                self.data[elem][_id] = (new_span, _type)

    def translate(self, trans):
        for elem in self.data:
            for _id in self.data[elem]:
                span, _type = self.data[elem][_id]
                self.data[elem][_id] = ([trans[span[0]], trans[span[1]]], _type)


    def ann_spans(self, text):
        ann_lines = []
        for elem in self.data:
            for _id in self.data[elem]:
                span, _type = self.data[elem][_id]
                ann_lines.append('{} ({}) ({}): "{}"'.format(elem, _id, _type,
                    text[span[0]:span[1]]))
        return '\n'.join(ann_lines)


def _contains_xml_tag(s):
    return XML_TAG_REGEX.search(s) is not None

def _enrich_a2_with_hedges(id_to_txt, id_to_a1, id_to_a2, id_to_nesp,
        verbose=False, heuristic='none', dry_run=False):
    # In-short:
    # * Map offsets between the stand-off and "XML"
    # * Find events affected by hedging
    # * Enrich the a2 file with the found hedges

    # Rant: What ever the fuck this nesp thing is, it isn't XML in any
    #   meaning of the god damn word, it doesn't have proper character escapes
    #   etc. so it is easier to parse it using god damn regular expressions
    #   than treating it as XML. In many ways I hate XML with a passion, but
    #   what I hate even more than XML is retarded formats posing as XML.

    for id_i, _id in enumerate(id_to_a2, start=1):
        if verbose:
            print >> stderr, ('Processing id ({}/{}): {}'
                    ).format(id_i, len(id_to_txt), _id)

        # Some trickery is necessary to make this work, we first need a mapping
        # between the offsets for the stand-off and the BioScope "XML"

        nesp_lines = []
        with open(id_to_nesp[_id]) as nesp_file:
            for line in (l.rstrip('\n') for l in nesp_file):
                s_match = SENTENCE_REGEX.match(line)
                assert s_match is not None
                nesp_lines.append(s_match.groupdict()['content'])
        # We now have some text but it most likely still contains XML
        nesp_text = '\n'.join(nesp_lines)

        # Mine the marked XML-ish spans and extract the actual text
        spans = Spans()
        for r_type, regex in (('scope', SCOPE_REGEX), ('cue', CUE_REGEX), ):
            # Remove the spans
            while True:
                m = regex.search(nesp_text)
                if m is None:
                    # Done with this tag
                    break

                # Remove the tags from the tex
                gdic = m.groupdict()
                spans.insert(m.span(4), r_type, gdic['type'], gdic['id'])
                s_tag_span = m.span(1)
                spans.deletion(s_tag_span, nesp_text)
                nesp_text = nesp_text[:s_tag_span[0]] + nesp_text[s_tag_span[1]:]
                # Compensating for the removal of the start tag
                e_tag_span = [e - (s_tag_span[1] - s_tag_span[0]) for e in m.span(5)]
                spans.deletion(e_tag_span, nesp_text)
                nesp_text = nesp_text[:e_tag_span[0]] + nesp_text[e_tag_span[1]:]

        assert not _contains_xml_tag(nesp_text), 'xml remains after clean-up: ' + nesp_text

        with open(id_to_txt[_id]) as txt_file:
            txt_text = txt_file.read()

        nesp_to_txt_index_map = {}
        txt_i = 0
        nesp_i = 0
        while True:
            if txt_i >= len(txt_text) or nesp_i >= len(nesp_text):
                break
            txt_c = txt_text[txt_i]
            nesp_c = nesp_text[nesp_i]
            if txt_c == nesp_c:
                nesp_to_txt_index_map[nesp_i] = txt_i
                txt_i += 1
                nesp_i += 1
            elif txt_c in WHITESPACE_CHARS:
                txt_i += 1
            # nesp has some really fucked up escapes(?) using inserted = signs
            #   we allow to ignore equal marks and hope for the best:
            #
            #   Example: "PKD1/3-/-:" => "PKD1/3==-==/==- = = :"
            #
            #   My best guess is that they have escaped hyphens and then ran a
            #   tokeniser over it, nice, that is easily reversible (not).
            elif nesp_c in WHITESPACE_CHARS or nesp_c == '=':
                nesp_to_txt_index_map[nesp_i] = None
                nesp_i += 1
            else:
                #print txt_c, nesp_c
                assert False
        # Iterate backwards and fill in the indices for erased chars as the
        #   next character in the text file
        ids = sorted(e for e in nesp_to_txt_index_map)
        for i in ids[::-1]:
            if nesp_to_txt_index_map[i] is None:
                nesp_to_txt_index_map[i] = last_val
            else:
                last_val = nesp_to_txt_index_map[i]
        # For anything beyond the final index we give the max
        d = defaultdict(lambda : ids[-1])
        for k, v in nesp_to_txt_index_map.iteritems():
            d[k] = v
        nesp_to_txt_index_map = d
        spans.translate(nesp_to_txt_index_map)

        # Events OR Arguments in a negated span
        a1_path = id_to_a1[_id]
        try:
            a2_path = id_to_a2[_id]
        except KeyError:
            a2_path = None
        evs_by_id = _parse_ann(a1_path, a2_path)
        
        # Inject negations and speculations
        found = []
        for span, _type in spans.data['scope'].itervalues():
            # BioScope type mapped to BioNLP-ST annotation type
            if _type == 'spec':
                type_str = 'Speculation'
            elif _type == 'neg':
                type_str = 'Negation'
            else:
                assert False

            found_in_scope = set()
            for e_id, ev in evs_by_id.iteritems():
                e_span = ev[0]
                args = ev[3]
                if (
                        # Included in span
                        (e_span[0] >= span[0] and e_span[1] <= span[1])
                        # Argument included in span
                        or any(a[0][0] >= span[0] and a[0][1] <= span[1]
                            for _, a in args.itervalues())
                        # XXX: Also Sampo's heuristic, only leaves
                        ): # <-- Sad bracket )=
                   
                    # Collect a list and unique
                    found_in_scope.add(e_id)

            # Internal root heuristic, we discard any event marked that is
            #   referenced by other events that was marked in the same span
            if heuristic == 'internal-root':
                to_remove = set()
                for f_id in found_in_scope:
                    f_args = evs_by_id[f_id][3]
                    for arg_id, _ in f_args.itervalues():
                        # Sanity check, there COULD be self-referencing events,
                        #   if the submitter has forgotten some sanity check
                        if arg_id == f_id:
                            continue

                        if arg_id in found_in_scope:
                            if verbose:
                                print >> stderr, (
                                        'internal-root: {} referenced by {}, removing'
                                        ).format(arg_id, f_id)
                            to_remove.add(arg_id)
                found_in_scope = found_in_scope - to_remove
            # Root heuristic, we discard events that exists along the chain of
            #   references starting from each event invoked in the span
            elif heuristic == 'root':
                to_remove = set()
                for f_id in found_in_scope:
                    # Extract the event reference chain
                    f_args = evs_by_id[f_id][3]

                    ref_chain = set() # Store the reference chain
                    recursed = set() # To avoid loops
                    def _chain_recurse(rec_id):
                        recursed.add(rec_id)

                        for arg_id, _ in evs_by_id[rec_id][3].itervalues():
                            if arg_id in recursed: # Don't re-recurse
                                continue

                            if arg_id.startswith('E'):
                                ref_chain.add(arg_id)
                                _chain_recurse(arg_id)
                    _chain_recurse(f_id)

                    for arg_id in ref_chain:
                        if verbose:
                            print >> stderr, (
                                    'root: {} chain-referenced by {}, removing'
                                    ).format(arg_id, f_id)
                        to_remove.add(arg_id)

                found_in_scope = found_in_scope - to_remove

            for f_id in found_in_scope:
                found.append((f_id, type_str))
        found = [' '.join(t[::-1]) for t in set(found)]
        sort_nicely(found)
        found = ['M{}\t{}'.format(f_i, f)
            for f_i, f in enumerate(found, start=1)]
        output = '\n'.join(found)
        if output:
            if verbose:
                print >> stderr, output

            if not dry_run:
                with open(a2_path, 'r') as a2_file:
                    to_write = [l for l in (output + '\n' + a2_file.read()).split('\n') if l.strip()]
                    sort_nicely(to_write)
                
                #print >> stderr, '\n'.join(to_write)

                with open(a2_path, 'w') as a2_file:
                    a2_file.write('\n'.join(to_write).strip())

def sort_nicely(l): 
    """ Sort the given list in the way that humans expect. 
    """ 
    import re 
    convert = lambda text: int(text) if text.isdigit() else text 
    alphanum_key = lambda key: [ convert(c) for c in re.split('([0-9]+)', key) ] 
    l.sort( key=alphanum_key ) 

def _parse_ann(a1_path, a2_path):
    with open(a1_path) as a1_file:
        a1_data = a1_file.read()
    if a2_path is not None:
        with open(a2_path) as a2_file:
            a2_data = a2_file.read()
    else:
        a2_data = ''
    ann_data = [l for l in (a1_data + a2_data).split('\n') if l]
    #print >> stderr, '\n'.join(ann_data)

    #print >> stderr, '\n'.join(ann_data)

    # Find all textbounds
    # (span, type, txt)
    tbs_by_id = {}
    for l in ann_data:
        if l.startswith('T'):
            try:
                _id, body, txt = l.split('\t')
            except ValueError:
                # Probably forgot the text...
                _id, body = l.split('\t')
                txt = None

            _type, start, end = body.split(' ')
            tbs_by_id[_id] = ((int(start), int(end)), _type, txt)
    # Then all events
    # (span, type, txt, args)
    evs_by_id = {}
    for l in ann_data:
        if l.startswith('E'):
            _id, body = l.split('\t')
            try:
                spec, args = body.split(' ', 1)
            except ValueError:
                # No arguments
                spec = body
                args = None
            _type, t_id = spec.split(':')
            trigger = tbs_by_id[t_id]
            assert trigger[1] == _type
            span = trigger[0]
            txt = trigger[2]
            args_dic = {}
            if args:
                for role, r_id in (arg.split(':') for arg in args.split(None)):
                    args_dic[role] = r_id
            evs_by_id[_id] = (span, _type, txt, args_dic)
    # Fill in the event arguments with tuples
    for _, ev in evs_by_id.iteritems():
        for role, r_id in ev[3].iteritems():
            if r_id.startswith('E'):
                ev[3][role] = (r_id, evs_by_id[r_id])
            else:
                ev[3][role] = (r_id, tbs_by_id[r_id])

    return evs_by_id

def main(args):
    argp = ARGPARSER.parse_args(args[1:])

    if argp.a1_dir:
        a1_dir = argp.a1_dir
    else:
        a1_dir = None

    id_to_txt, id_to_a1, id_to_a2, id_to_nesp = _get_id_mappings(argp.ann_dir,
            argp.bioscope_data_dir, verbose=argp.verbose, a1_dir=a1_dir)

    _enrich_a2_with_hedges(id_to_txt, id_to_a1, id_to_a2, id_to_nesp,
            verbose=argp.verbose, heuristic=argp.heuristic, dry_run=argp.dry)

    return 0

if __name__ == '__main__':
    from sys import argv
    exit(main(argv))
