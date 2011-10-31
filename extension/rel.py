#!/usr/bin/env python

'''
Exploit the REL sub-task data to enrich a submission with Site([0-9]+)? and
CSite arguments.

Author:     Pontus Stenetorp    <pontus stenetorp se>
Version:    2011-10-20
'''

from argparse import ArgumentParser
from collections import defaultdict
from sys import stderr

### Constants
ARGPARSER = ArgumentParser()#XXX:
ARGPARSER.add_argument('ann_dir')
ARGPARSER.add_argument('rel_dir')
ARGPARSER.add_argument('-a', '--a1-dir', default='')
ARGPARSER.add_argument('-d', '--dry-run', action='store_true')
ARGPARSER.add_argument('-v', '--verbose', action='store_true')
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

def sort_nicely(l): 
    """ Sort the given list in the way that humans expect. 
    """ 
    import re 
    convert = lambda text: int(text) if text.isdigit() else text 
    alphanum_key = lambda key: [ convert(c) for c in re.split('([0-9]+)', key) ] 
    l.sort( key=alphanum_key ) 

def _parse_ann(a1_path, a2_path, rel_path):
    # Some prefer to put it all in the a2 file...
    if a1_path is not None:
        with open(a1_path) as a1_file:
            a1_data = a1_file.read()
    else:
        a1_data = ''
    with open(a2_path) as a2_file:
        a2_data = a2_file.read()
    with open(rel_path) as rel_file:
        rel_data = rel_file.read()

    # We need all the ids from the a2 for later reference
    a2_ids = [l.split('\t', 1)[0] for l in a2_data.split('\n') if l]
    ann_data = [l for l in (a1_data + a2_data).split('\n') if l]
    rel_data = [l for l in rel_data.split('\n') if l]

    # Find all relations
    # NOTE: There could be clashes between the ID;s here, so we will update
    #   the ids when we have parsed the text bounds
    rels_by_id = {}
    reltbs_by_id = {}
    for l in rel_data:
        if l.startswith('T'):
            _id, body, txt = l.split('\t')
            _type, start, end = body.split(' ')
            reltbs_by_id[_id] = ((int(start), int(end)), _type, txt)
        elif l.startswith('R'):
            # Example: 'R3  Protein-Component Arg1:T22 Arg2:T111'
            _id, body = l.split('\t')
            _type, arg1, arg2 = body.split(' ')
            arg1 = arg1.split(':')[1]
            arg2 = arg2.split(':')[1]

            # NOTE: We discard all non Protein-Components here
            if _type == 'Protein-Component':
                rels_by_id[_id] = (_type, arg1, arg2)
    # Fill in the rels with actual arguments
    for r_id, rel in rels_by_id.iteritems():
        # The first argument should be a protein from the official .a1 which
        #   we haven't parsed yet.
        rels_by_id[r_id] = (rel[0], rel[1], (rel[2], reltbs_by_id[rel[2]]))
    del reltbs_by_id # Done with relation text bounds

    # Find all textbounds
    # (span, type, txt)
    tbs_by_id = {}
    for l in ann_data:
        if l.startswith('T'):
            try:
                _id, body, txt = l.split('\t')
            except ValueError:
                # Probably left out the text...
                _id, body = l.split('\t')
                txt = None

            _type, start, end = body.split(' ')
            tbs_by_id[_id] = ((int(start), int(end)), _type, txt)
    # Fill in the rels with a1 text bound arguments
    for r_id, rel in rels_by_id.iteritems():
        # The first argument should be a protein from the official .a1 which
        #   we haven't parsed yet.
        rels_by_id[r_id] = (rel[0], (rel[1], tbs_by_id[rel[1]]), rel[2])

    # Then all events
    # (span, type, txt, args)
    evs_by_id = {}
    for l in ann_data:
        if l.startswith('E'):
            _id, body = l.split('\t')
            if ' ' in body:
                spec, args = body.split(' ', 1)
            else:
                spec = body
                args = None
            _type, t_id = spec.split(':')
            trigger = tbs_by_id[t_id]
            assert trigger[1] == _type
            span = trigger[0]
            txt = trigger[2]
            args_dic = {}
            if args:
                for role, r_id in (arg.split(':') for arg in args.split()):
                    args_dic[role] = r_id
            evs_by_id[_id] = (span, _type, txt, args_dic, t_id)
    # Fill in the event arguments with tuples
    for _, ev in evs_by_id.iteritems():
        for role, r_id in ev[3].iteritems():
            if r_id.startswith('E'):
                ev[3][role] = (r_id, evs_by_id[r_id])
            else:
                ev[3][role] = (r_id, tbs_by_id[r_id])

    return a2_ids, rels_by_id, tbs_by_id, evs_by_id

def main(args):
    argp = ARGPARSER.parse_args(args[1:])

    id_to_rel = {}
    for rel_path in _find(argp.rel_dir, '.*\.rel$'):
        _id = _to_id(rel_path)
        assert _id not in id_to_rel, ('duplicate id {} for {} and {}'
                ).format(_id, rel_path, id_to_rel[_id])
        id_to_rel[_id] = rel_path
    assert id_to_rel, 'no relations files found'
    
    if argp.verbose:
        print >> stderr, ('found {} relation annotation (.rel) files'
                ).format(len(id_to_rel))

    if argp.a1_dir:
        a1_dir = argp.a1_dir
    else:
        a1_dir = argp.ann_dir
    id_to_a1 = defaultdict(lambda : None)
    for a1_path in _find(a1_dir, '.*\.a1$'):
        _id = _to_id(a1_path)
        assert _id not in id_to_a1, ('duplicate id {} for {} and {}'
                ).format(_id, a1_path, id_to_a1[_id])
        id_to_a1[_id] = a1_path
    assert id_to_rel, 'no a1 files found'
    
    if argp.verbose:
        print >> stderr, ('found {} annotation (.a1) files'
                ).format(len(id_to_a1))

    id_to_a2 = defaultdict(lambda : None)
    for a2_path in _find(argp.ann_dir, '.*\.a2$'):
        _id = _to_id(a2_path)
        assert _id not in id_to_a2, ('duplicate id {} for {} and {}'
                ).format(_id, a2_path, id_to_a2[_id])
        id_to_a2[_id] = a2_path
    assert id_to_rel, 'no a2 files found'
    
    if argp.verbose:
        print >> stderr, ('found {} annotation (.a2) files'
                ).format(len(id_to_a2))

    redundant_num = len(id_to_rel) - len(id_to_a2)
    if redundant_num:
        if argp.verbose:
            print >> stderr, ('skipping {} files(s) that lack events, will '
                    'process the other {} file(s)').format(redundant_num,
                            len(id_to_rel) - redundant_num)

        redundant = [_id for _id in id_to_a1 if _id not in id_to_a2]
        for _id in redundant:
            # These could crash for some corner cases, but let it slide...
            del id_to_a1[_id]
            del id_to_rel[_id]

    # We are now ready to do some actual work!

    # NOTE: We only iterate over the a2;s since those are the ones we enrich
    for id_i, _id in enumerate(id_to_a2, start=1):
        if argp.verbose:
            print >> stderr, ('Processing ({}/{}): {}'
                    ).format(id_i, len(id_to_a2), _id)

        a1_path = id_to_a1[_id]
        a2_path = id_to_a2[_id]
        rel_path = id_to_rel[_id]
        a2_ids, rels_by_id, tbs_by_id, evs_by_id = _parse_ann(
                a1_path, a2_path, rel_path)

        try:
            max_seen_tb = max(int(_id.split('T')[1]) for _id in tbs_by_id)
        except ValueError:
            # No seen tbs
            max_seen_tb = 0
            
        # Text bounds that we need to add from rel
        new_tb_by_id = {}
        reltb_id_to_ann_tb_id = {}
        # Enrich with sites etc.
        for e_id, ev in evs_by_id.iteritems():
            e_args = ev[3]
            trigger = tbs_by_id[ev[4]]

            if ev[1] in set(('Transcription', 'Gene_expression',
                    'Localization', )):
                # These events does not take site arguments
                continue

            args_to_add = {}
            for arg_role, arg_tup in e_args.iteritems():
                arg_id, arg = arg_tup

                # Ignore events
                if arg_id.startswith('E'):
                    continue


                # Check if there are relations originating from this arg
                for rel_id, rel in rels_by_id.iteritems():
                    if rel[1][0] == arg_id:
                        old_tb_id = rel[2][0]

                        if arg_role == 'Cause':
                            new_arg_role = 'CSite'
                        elif arg_role.startswith('Theme'):
                            new_arg_role = 'Site'
                            # Append any potential numbering of the theme
                            new_arg_role += arg_role.split('Theme')[1]
                        else:
                            assert False

                        # It is possible to have a conflict, for this we use
                        #   the relation from the argument which is closest
                        #   to the trigger
                        if new_arg_role in args_to_add:
                            # Conflict resolution
                            existing_tb_id = args_to_add[new_arg_role][0]
                            existing_tb = new_tb_by_id[existing_tb_id]
                            
                            # Mmmm... Taste the indexing... I should be punished
                            #   for this...

                            new_span = rel[2][1][0]
                            existing_span = existing_tb[0]
                            trigger_span = trigger[0]

                            new_dist = min(
                                    abs(trigger_span[0] - new_span[0]),
                                    abs(trigger_span[0] - new_span[1]),
                                    abs(trigger_span[1] - new_span[0]),
                                    abs(trigger_span[1] - new_span[1]))

                            existing_dist = min(
                                    abs(trigger_span[0] - existing_span[0]),
                                    abs(trigger_span[0] - existing_span[1]),
                                    abs(trigger_span[1] - existing_span[0]),
                                    abs(trigger_span[1] - existing_span[1]))

                            if new_dist > existing_dist:
                                # Ignore the additional relation
                                continue
                            elif new_dist == existing_dist:
                                # Pick the one closest to the right end of the
                                #   trigger span
                                if (new_dist[1] - trigger_span[1]
                                        < existing_span[1] - trigger_span[1]):
                                    continue
                            # We will replace the role
                            del args_to_add[new_arg_role]

                            if argp.verbose:
                                print >> stderr, ('Replace {} for role {}'
                                        ).format(existing_tb_id, new_arg_role)

                        # Potentially add a new tb to reference
                        try:
                            new_tb_id = reltb_id_to_ann_tb_id[old_tb_id]
                        except KeyError:
                            # We haven't added this tb previously
                            max_seen_tb += 1
                            new_tb_id = 'T{}'.format(max_seen_tb)
                            reltb_id_to_ann_tb_id[old_tb_id] = new_tb_id
                            # We need to add the text bound to the annotation file
                            #   later on or we will lack a referenced tb
                            new_tb_by_id[new_tb_id] = rel[2][1]

                        args_to_add[new_arg_role] = (new_tb_id,
                                new_tb_by_id[new_tb_id])
            # Add new args
            for arg_role, tb in args_to_add.iteritems():
                assert arg_role not in e_args
                e_args[arg_role] = tb
                if argp.verbose:
                    print >> stderr, ('Added role: {} to {}'
                            ).format(arg_role, e_id)

        # We have been poking around in the event structures, so we need to
        #   re-write the a2 file from scratch
        if new_tb_by_id:
            lines = []
    
            # We only want to keep the tb triggers for the a2
            #ev_triggers = [ev[4] for ev in evs_by_id.itervalues()]
            ev_triggers = [_id for _id in a2_ids if _id.startswith('T')]
            for t_id in ev_triggers:
                trigger = tbs_by_id[t_id]
                new_tb_by_id[t_id] = trigger

            tb_ids = [_id for _id in new_tb_by_id] 
            sort_nicely(tb_ids)
            for tb_id in tb_ids:
                tb = new_tb_by_id[tb_id]
                tb_str = '{id}\t{type} {start} {end}{text}'.format(
                        id=tb_id,
                        # Should have gone with named tuples...
                        start=tb[0][0],
                        end=tb[0][1],
                        type=tb[1],
                        text= '\t' + tb[2] if tb[2] is not None else '')
                lines.append(tb_str)
            
            ev_ids = [_id for _id in evs_by_id]
            sort_nicely(ev_ids)
            for ev_id in ev_ids:
                ev = evs_by_id[ev_id]
                ev_args = ev[3]
                t_id = ev[4]
                args_str = ' '.join(':'.join((arg_role, arg[0]))
                        for arg_role, arg in ev_args.iteritems())
                ev_str = '{}\t{}:{}{}'.format(ev_id, ev[1], t_id,
                        ' ' + args_str if args_str else '')
                lines.append(ev_str)

            new_ann = '\n'.join(l for l in lines if l.strip())
            if argp.verbose:
                print >> stderr, 'New annotations:'
                print >> stderr, new_ann

            if not argp.dry_run:
                with open(a2_path, 'w') as a2_file:
                    a2_file.write(new_ann.strip())

if __name__ == '__main__':
    from sys import argv
    exit(main(argv))
