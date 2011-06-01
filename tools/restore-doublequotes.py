#!/usr/bin/env python

# Special-purpose script for replacing single quotes with double
# quotes in Penn Treebank format constituency output when double
# quotes appear in reference text. This processing is necessary to
# restore original text after special-case escaping for the 
# McClosky-Charniak parser.

# Author: Sampo Pyysalo
# Modified by Pontus Stenetorp to read from stdin

import sys
import re

PTB_unescapes = [
    ("-LRB-", "("),
    ("-RRB-", ")"),
    ("-LSB-", "["),
    ("-RSB-", "]"),
    ("-LCB-", "{"),
    ("-RCB-", "}"),
    ]

if len(sys.argv) != 2:
    print >> sys.stderr, "Usage:", sys.argv[0], "TEXT"
    sys.exit(1)

textfn = sys.argv[1]

# Read in the reference text in sentence-per-line format.
textlines = []
textf = open(textfn)
for l in textf:
    textlines.append(l.strip())
textf.close()

# read in the parses, assume sentence-per-line.
parselines = [line.rstrip('\n') for line in sys.stdin]
#parsef = open(parsefn)
#for l in parsef:
#    parselines.append(l.strip())
#parsef.close()

# align and output
if len(textlines) != len(parselines):
    print >> sys.stderr, "ERROR: cannot align %s to %s: %d lines in text, %d in parses!" % (textf, parses, len(textlines), len(parselines))
    sys.exit(1)

def restore_token(ttree, tokens, tokenindex):
    m = re.match(r'^(\s*\()([^ ()]+)(\s+)([^()]+)(\)\s*)$', ttree)
    assert m, "Error: failed to match single-token tree '%s'" % ttree
    openb, POS, opens, ttext, after = m.groups()

    # make unescaped version for comparison
    uttext = ttext
    for e, u in PTB_unescapes:
        uttext = uttext.replace(e, u)

    if uttext != tokens[tokenindex]:
        # if there's a single quote in the data and a double quote in
        # the text, replace the single quote with and escape
        # determined by the POS tag (which should be either `` or '',
        # matching a PTB escape).
        if ttext == "'" and tokens[tokenindex] == '"':
            if POS == "``":
                replacement = "``"
            else:
                # POS should be '', but may be different if there's errors ...
                replacement = "''"
            print >> sys.stderr, "Replaced %s -> %s (original %s)" % (ttext, replacement, tokens[tokenindex])
            ttext = replacement
        else:
            # warn but keep going
            print >> sys.stderr, "Warning: token mismatch: '%s' vs '%s' (uttext: %s)" % (ttext, tokens[tokenindex], uttext)

    return openb+POS+opens+ttext+after, tokenindex+1

def restore_text(tree, tokens, tokenindex = 0):
    # if we have a token only, no recursion
    m = re.match(r'^\s*\([^()]*\)\s*$', tree)
    if m:
        return restore_token(tree, tokens, tokenindex)

    # otherwise assume we have a tree and process recursively.

    # strip out the outermost level of nesting
    m = re.match(r'^(\s*\([^ ()]*)(.*?)(\s*\)\s*)$', tree)
    assert m, "ERROR: failed to match (sub)tree in %s: %s" % (parsefn, tree)

    before, nested, after = m.groups()

    # split the nested into subtrees by balanced brackets. Won't use
    # regex as there may be an arbitrary depth of nesting.
    subtrees = []
    current_depth = 0
    current_start = i = 0
    while i < len(nested):
        if nested[i] == "(":
            current_depth += 1
        elif nested[i] == ")":
            current_depth -= 1
            assert current_depth >= 0, "Error: imbalanced brackets in tree: %s" % tree
            if current_depth == 0:
                while i < len(nested) and nested[i].isspace():
                    i += 1
                subtrees.append(nested[current_start:i+1])
                current_start = i+1
        i += 1
    assert current_depth == 0, "Error: imbalanced brackets in tree: %s" % tree

    # ... and recurse
    restored_subtrees = []
    for st in subtrees:
        rst, tokenindex = restore_text(st, tokens, tokenindex)
        restored_subtrees.append(rst)

    return before+"".join(restored_subtrees)+after, tokenindex

for i in range(len(textlines)):
    text, parse = textlines[i], parselines[i]

    try:
        restored, dummy = restore_text(parse, text.split(" "))
        print restored
    except:
        print >> sys.stderr, "ERROR: failed for '%s'" % parse
        raise
