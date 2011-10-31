#!/usr/bin/env python

'''
Enrich (or replace) negation/speculation (hedging) and (some) additional
arguments (task 2) for existing annotations.

Author:	Pontus Stenetorp	<pontus stenetorp se>
Version:	2011-10-28
'''

from argparse import ArgumentParser
from os.path import dirname, join as path_join
from sys import path as sys_path
from shutil import rmtree
from tempfile import mkdtemp
from re import compile as re_compile

from nesp import main as nesp_main
from rel import main as rel_main

sys_path.append('tools')

from subset import main as subset_main

### Constants
ARGPARSER = ArgumentParser()#XXX:
ARGPARSER.add_argument('sub_arch') # Path to old arch
ARGPARSER.add_argument('output_arch') # Path to new arch
# TODO: Could treat archs as a dirs instead with a flag
NESP_DIR = path_join(dirname(__file__), 'res', 'nesp')
A1_DIR = path_join(dirname(__file__), 'res', 'a1')
REL_DIR = path_join(dirname(__file__), 'res', 'rel')
NESP_REGEX = re_compile(r'^M[0-9]+\t(Speculation|Negation)$')
###

from subprocess import Popen, PIPE
from shlex import split as shlex_split
from sys import stderr

def _find(dir, regexp):
    from os import walk
    from os.path import join as path_join
    from re import compile as re_compile
    c_regexp = re_compile(regexp)
    for dpath, dnames, fnames in walk(dir):
        for fpath in (path_join(dpath, f) for f in fnames):
            if c_regexp.match(fpath) is not None:
                yield fpath

# Extract an archive to a directory using external tar
def _extract(arch_path, dir_path):
    tar_cmd = 'tar -x -z -f {} -C {}'.format(arch_path, dir_path)
    tar_p = Popen(shlex_split(tar_cmd), stderr=PIPE)
    tar_p.wait()
    tar_p_stderr = tar_p.stderr.read()
    if tar_p_stderr:
        print >> stderr, tar_p_stderr
        assert False, 'tar exited with an error'

from shutil import move
from os.path import isfile

# Remove existing negation/speculation annotations and task 2 args (if any)
def _blind(dir_path):
    # First strip additional arguments
    subset_cmd = ('./subset.py -s core -m '
            '-a Site,CSite,Sidechain,Contextgene {}'
            ).format(' '.join(_find(dir_path, '.*\.a2')))
    subset_main(shlex_split(subset_cmd))

    # We need to rename the new core files
    for a2_core_file_path in _find(dir_path, '.*\.a2.core'):
        a2_file_path = a2_core_file_path[:-5]
        assert isfile(a2_file_path)
        move(a2_core_file_path, a2_file_path)

    # Then negation and speculations
    for a2_file_path in _find(dir_path, '.*\.a2'):
        with open(a2_file_path, 'r') as a1_file:
            a1_data = a1_file.read().split('\n')

        # Write the annotations again without modifiers
        with open(a2_file_path, 'w') as a1_file:
            lines = []
            for line in a1_data:
                line_m = NESP_REGEX.match(line)
                if line_m is None:
                    lines.append(line)
            a1_file.write('\n'.join(lines))
        
# Enrich an extracted submission with task 2 args
def _enrich_with_args(dir_path):
    rel_cmd = './rel.py -a {} {} {}'.format(A1_DIR, dir_path, REL_DIR)
    rel_main(shlex_split(rel_cmd))

# Extract an extracted submission with negation/speculation annotations
def _enrich_with_nesp(dir_path):
    nesp_cmd = ('./nesp.py -a {} -e internal-root {} {}'
            ).format(A1_DIR, dir_path, NESP_DIR)
    nesp_main(shlex_split(nesp_cmd))

from os.path import basename

def _repack(tmp_dir, arch_path):
    tar_cmd = 'tar cfz enriched.tar.gz {}'.format(
            ' '.join(basename(p) for p in _find(tmp_dir, '.*\.a2')))
    tar_p = Popen(shlex_split(tar_cmd), stderr=PIPE, cwd=tmp_dir)
    tar_p.wait()
    tar_p_stderr = tar_p.stderr.read()
    if tar_p_stderr:
        print >> stderr, tar_p_stderr
        assert False, 'tar exited with an error'
    move(path_join(tmp_dir, 'enriched.tar.gz'), arch_path)

def main(args):
    argp = ARGPARSER.parse_args(args[1:])

    tmp_dir = None
    try:
        tmp_dir = mkdtemp()

        print >> stderr, 'tmp_dir:', tmp_dir, 'sub_arch:', argp.sub_arch

        _extract(argp.sub_arch, tmp_dir)
        _blind(tmp_dir)
        #raw_input('Paused...')
        _enrich_with_args(tmp_dir)
        #raw_input('Paused...')
        _enrich_with_nesp(tmp_dir)
        #raw_input('Paused...')
        _repack(tmp_dir, argp.output_arch)
    finally:
        if tmp_dir is not None:
            rmtree(tmp_dir)

    return 0

if __name__ == '__main__':
    from sys import argv
    exit(main(argv))
