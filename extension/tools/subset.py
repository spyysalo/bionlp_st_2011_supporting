#!/usr/bin/env python

# Generates a subset of given annotations in BioNLP ST-flavored
# standoff.

# Copyright (c) 2010-2011 BioNLP Shared Task organizers
# This script is distributed under the open source MIT license:
# http://www.opensource.org/licenses/mit-license

import sys
import re
import optparse

options = None

def equiv_referenced_ids(ann):
    """
    Given a line with an Equiv annotation, returns a collection
    containing the IDs referred to.
    """
    fields = ann.split("\t")
    if len(fields) < 2:
        return []
    args = fields[1].split(" ")
    return args[1:]

def modification_referenced_ids(ann):    
    """
    Given a line with an event modication annotation, returns a
    collection containing the IDs referred to.
    """
    # the Equiv syntax is a superset, so can use this
    return equiv_referenced_ids(ann)

def annotation_id(ann):
    """
    Given a line with an annotation with an ID, returns the ID.
    """
    m = re.match(r'^([A-Z]\d+)', ann)
    if not m:
        return None
    else:
        return m.group(1)

def event_referenced_ids(ann):
    """
    Given a line with an event annotation, returns a collection
    containing the IDs referred to.
    """
    fields = ann.split("\t")
    if len(fields) < 2:
        return []
    args = fields[1].split(" ")
    ids = []
    for a in args:
        m = re.match(r'\S+:([A-Z]\d+)', a)
        if m:
            ids.append(m.group(1))
    return ids

def remove_event_arguments(ann, remove_args):
    """
    Given a line with an event annotation and a collection of event
    arguments, returns a modification of the event annotation without
    those arguments.
    """
    
    # event arguments are found in the 2nd of tab-separated fields.
    fields = ann.split("\t")

    if len(fields) < 2:
        print >> sys.stderr, "Warning: failed to parse as event annotation (passing through unmodified): %s" % ann
        return ann

    # the 2nd field is structured as "Type:triggerID( Arg:refID)*" with
    # space separating the arguments.
    args = fields[1].split(" ")
    
    filtered_args = []
    for arg in args:
        # allow empty (i.e. extra space)
        if arg == "":
            filtered_args.append(arg)
            continue

        m = re.match(r'^(\S+?)\d*:([A-Z]\d+)$', arg)
        if not m:
            print >> sys.stderr, "Warning: failed to parse arg '%s' in event annotation (passing through unmodified): %s" % (arg, ann)
            return ann
        a, r = m.groups()
        if a not in remove_args:
            filtered_args.append(arg)
    
    # rebuild and return
    fields[1] = " ".join(filtered_args)
    return "\t".join(fields)


def is_duplicate_event(ann, seen):
    """
    Given a line with an event annotation, returns True if the event
    matches one previously seen, False otherwise. The second argument
    if a map the function uses to store representations of previously
    seen events.
    """

    # event arguments are found in the 2nd of tab-separated fields.
    fields = ann.split("\t")

    if len(fields) < 2:
        print >> sys.stderr, "Warning: failed to parse as event annotation (assuming non-duplidate): %s" % ann
        return False

    # the 2nd field contains space-separated event arguments and
    # trigger. Assume two events can only be duplicates if the
    # non-empty arguments are identical.
    args = fields[1].split(" ")
    args = [a for a in args if a != ""]
    args.sort()
    argrep = " ".join(args)

    if argrep in seen:
        return True
    else:
        seen[argrep] = True
        return False

def generate_subset(orig):
    global options

    # store read annotations separately by type as (lineindex, line)
    # tuples to allow output in original order
    textbound_ann    = []
    event_ann        = []
    modification_ann = []
    equiv_ann        = []
    other_lines      = []

    # Processing by ID: "E[0-9]" assumed to identify events, "M[0-9]"
    # modifications, other "regular" ID formats textbounds. Also
    # identify Equivs by the non-ID "*" and preserve empties to
    # minimize diff.

    for i,l in enumerate(orig):
        l = l.strip(' \n\r')

        if re.match(r'^E\d+', l):
            event_ann.append((i,l))
        elif re.match(r'^M\d+', l):
            modification_ann.append((i,l))
        elif re.match(r'^[A-Z]\d+', l):
            textbound_ann.append((i,l))
        elif re.match(r'^\*', l):
            equiv_ann.append((i,l))
        elif re.match(r'^\s*$', l):
            other_lines.append((i,l))
        else:
            print >> sys.stderr, "Warning: failed to identify annotation (passing through unmodified): %s" % l
            other_lines.append((i,l))

    # modifications and equivs can be removed simply by
    # blanking the read annotations

    if options.remove_eq:
        if options.verbose and equiv_ann != []:
            print >> sys.stderr, "\n".join(["Remove eq : %s" % e[1] for e in equiv_ann])
        equiv_ann = []

    if options.remove_mod:
        if options.verbose and modification_ann != []:
            print >> sys.stderr, "\n".join(["Remove mod: %s" % e[1] for e in modification_ann])
        modification_ann = []

    # event args are more tricky, requiring parsing of the argument
    # structure, elimination of possibly created duplicates and
    # elimination of possibly created dangling references.

    removed_annotation_id = {}

    if options.remove_arg is not None:
        remove_args = options.remove_arg.split(",")

        for idx,(i,a) in enumerate(event_ann):
            na = remove_event_arguments(a, remove_args)
            if options.verbose and a != na:
                print >> sys.stderr, "Remove arg: %s -> %s" % (a, na)
            event_ann[idx] = (i,na)

        filtered_event_ann = []
        seen = {}
        for i,a in event_ann:
            if is_duplicate_event(a, seen):
                if options.verbose:
                    print >> sys.stderr, "Remove dup: %s -> %s" % (a, na)
                removed_annotation_id[annotation_id(a)] = True
            else:
                filtered_event_ann.append((i,a))
        event_ann = filtered_event_ann

    # processing may create dangling references; clean up. Note
    # that removal may create further dangling.

    while True:
        annotation_removed = False

        for ann, refid in ((event_ann, event_referenced_ids),
                           (modification_ann, modification_referenced_ids)):
            i = 0
            while i < len(ann):
                ref = refid(ann[i][1])
                dangling = [aid for aid in ref if aid in removed_annotation_id]
                if dangling == []:
                    i += 1
                else:
                    if options.verbose:
                        print >> sys.stderr, "Remove: dangling ref(s) %s: %s" % (",".join(dangling), ann[i][1])
                    removed_annotation_id[annotation_id(ann[i][1])] = True
                    del ann[i]
                    annotation_removed = True
        
        if not annotation_removed:
            break

    # finally, removals may create unreferenced Textbounds. Remove these.
        
    referenced_id = {}
    for i,a in equiv_ann:
        for aid in equiv_referenced_ids(a):
            referenced_id[aid] = True
    for i,a in modification_ann:
        for aid in modification_referenced_ids(a):
            referenced_id[aid] = True
    for i,a in event_ann:
        for aid in event_referenced_ids(a):
            referenced_id[aid] = True

    filtered_textbound_ann = []
    for i,a in textbound_ann:
        if annotation_id(a) in referenced_id:
            filtered_textbound_ann.append((i,a))
        elif options.verbose:
            print >> sys.stderr, "Remove unref: %s" % a
    textbound_ann = filtered_textbound_ann


    # recreate annotation from what remains
    remaining = event_ann+modification_ann+textbound_ann+equiv_ann+other_lines
    remaining.sort()

    return [a[1] for a in remaining]
    

def main(argv):
    global options
    
    op = optparse.OptionParser("\n  %prog [OPTIONS] FILES\n\nDescription:\n  Removes specifed annotations from a BioNLP Shared Task annotation file.")
    op.add_option("-a","--arg",action="store",dest="remove_arg",metavar="ARG1[,ARG2...]",default=None,help="Remove listed event arguments.")
    op.add_option("-m","--modifications",action="store_true",dest="remove_mod",default=False,help="Remove event modification annotations.")
    # use "-q" instead of "-e" to avoid confusion with "-e" option to
    # generate-task-specific-a2-file.pl, which *keeps* Equivs.
    op.add_option("-q","--equivs",action="store_true",dest="remove_eq",default=False,help="Remove equiv annotations.")
    op.add_option("-s","--suffix",action="store",dest="suffix",default="subset",help="Additional suffix to assign to written files.")
    op.add_option("-v","--verbose",action="store_true",dest="verbose",default=False,help="Verbose output.")

    options, args = op.parse_args(argv[1:])

    if len(args) < 1:
        op.print_help()
        return 1

    for fn in args:
        try:
            f = open(fn)
            subset = generate_subset(f)
            f.close()

            of = open(fn+"."+options.suffix, "w")
            if subset != []:
                print >> of, "\n".join(subset)
            of.close()
            
        except Exception, e:
            print >> sys.stderr, "ERROR: failed to process %s: %s" % (fn, e)
            raise

if __name__ == "__main__":
    sys.exit(main(sys.argv))
