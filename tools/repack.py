#!/usr/bin/env python

'''
Converts the everything-in-one-directory-with-long-file-endings gzipped tars
from the BioNLP'11 Shared Task parses Makefile into a directory structure and
file naming convention similar to the BioNLP'08 Shared Task

Warning: Quick hack, can be improved but "Just works"(tm)

Author:     Pontus Stenetorp <pontus stenetorp se>
Version:    2011-01-10
'''

from argparse import ArgumentParser
from os import listdir, makedirs
from os.path import join, abspath, basename
from shutil import rmtree, move
from subprocess import Popen
from tempfile import mkdtemp

### Constants
ARGPARSER = ArgumentParser(description="re-package BioNLP'11 Shared Task " +
        "archives into BioNLP'09-like Shared Task archives")
ARGPARSER.add_argument('archive_directory',
        help='directory from where to fetch archives to re-pack')
ARGPARSER.add_argument('output_directory',
        help='directory where to put the re-packed archives')
###

def _fname_to_dir_new_fname(fname):
    '''
    Derive the proper directory and new filename based on a files suffix.

    Arguments:
    fname - filename from which to derive target directory and new filename

    Returns:
    A tuple with the target directory of the file relative to the archive root
    directory where it is assumed to be currently located.
    '''

    fname_root = fname[:fname.find('.')]

    # I dictonary with functions is much nicer than this...
    if fname.endswith('.enju.xml'):
        return ('enju/original', fname_root + '.xml')
    elif fname.endswith('.enju.xml.ptb'):
        return ('enju/ptb', fname_root + '.ptb')
    elif fname.endswith('.enju.xml.ptb.conll'):
        return ('enju/conll', fname_root + '.conll')
    elif fname.endswith('.enju.xml.ptb.basic.sd'):
        return ('enju/sd_basic', fname_root + '.sd')
    elif fname.endswith('.enju.xml.ptb.ccproc.sd'):
        return ('enju/sd_ccproc', fname_root + '.sd')
    elif fname.endswith('.ucb'):
        return ('berkeley/ptb', fname_root + '.ptb')
    elif fname.endswith('.ucb.conll'):
        return ('berkeley/conll', fname_root + '.conll')
    elif fname.endswith('.ucb.basic.sd'):
        return ('berkeley/sd_basic/', fname_root + '.sd')
    elif fname.endswith('.ucb.ccproc.sd'):
        return ('berkeley/sd_ccproc/', fname_root + '.sd')
    elif fname.endswith('.candc'):
        return ('candc/ccg', fname_root + '.ccg')
    elif fname.endswith('.candc.basic.sd'):
        return ('candc/sd_basic', fname_root + '.sd')
    elif fname.endswith('.gdep'):
        return ('gdep', fname_root + '.conll')
    elif fname.endswith('.mcccj'):
        return ('mccc/ptb', fname_root + '.ptb')
    elif fname.endswith('.mcccj.basic.sd'):
        return ('mccc/sd_basic', fname_root + '.sd')
    elif fname.endswith('.mcccj.ccproc.sd'):
        return ('mccc/sd_ccproc', fname_root + '.sd')
    elif fname.endswith('.mcccj.conll'):
        return ('mccc/conll', fname_root + '.conll')
    elif fname.endswith('.ss'):
        return ('sentence_split', fname_root + '.ss')
    elif fname.endswith('.tok'):
        return ('tokenised', fname_root + '.tok')
    elif fname.endswith('.stp'):
        return ('stanford/ptb', fname_root + '.ptb')
    elif fname.endswith('.stp.basic.sd'):
        return ('stanford/sd_basic', fname_root + '.sd')
    elif fname.endswith('.stp.ccproc.sd'):
        return ('stanford/sd_ccproc', fname_root + '.sd')
    elif fname.endswith('.stp.conll'):
        return ('stanford/conll', fname_root + '.conll')
    else:
        assert False, fname

_ARCH_MAP = {
        '_berkeley': 'Berkeley-parses',
        '_candc': 'CCG-parses',
        '_enju': 'Enju-parses',
        '_gdep': 'GDep-parses',
        '_mcccj': 'McCC-parses',
        '_sentence_split': 'Sentence-split',
        '_stanford': 'Stanford-parses',
        '_tokenised': 'Tokenised'
        }

def _arch_to_new_arch_name(arch_name):
    new_arch_name = arch_name
    # If we have multiple we want to spin around and corrupt it properly
    for id, prefix in _ARCH_MAP.iteritems():
        if id in new_arch_name:
            new_arch_name = prefix + '-' + new_arch_name.replace(id, '')
    return new_arch_name

def main(args):
    argp = ARGPARSER.parse_args(args[1:])
    archs_dir = argp.archive_directory
    output_dir_path = abspath(argp.output_directory)

    archs = [join(archs_dir, f)
            for f in listdir(archs_dir) if f.endswith('.tar.gz')]
    for arch in archs:
        tmp_dir = None
        try:
            # Extract in a temporary directory
            tmp_dir = mkdtemp()
            tar_p = Popen('tar -x -z -f {} -C {}'.format(arch, tmp_dir).split())
            tar_p.wait()

            # We assume only one directory here, and no sub-dirs
            dir_name = listdir(tmp_dir)[0]
            # Get the new name and location relative to the dir-name
            for f in listdir(join(tmp_dir, dir_name)):
                dir, new_fname = _fname_to_dir_new_fname(f)
                dir_path = join(tmp_dir, dir_name, dir)
                try:
                    makedirs(dir_path)
                except OSError:
                    pass
                # Then move the file into its proper place
                move(join(tmp_dir, dir_name, f), join(dir_path, new_fname))
            
            # Re-pack the archive into the output directory
            cmd = 'cd {} && tar -c -z -f {} {}'.format(tmp_dir,
                join(output_dir_path, _arch_to_new_arch_name(basename(arch))),
                dir_name)
            tar_p = Popen(cmd, shell=True)
            tar_p.wait()
        finally:
            # Make sure that we clean up, don't mess with the admins
            if tmp_dir is not None:
                rmtree(tmp_dir)

if __name__ == '__main__':
    from sys import argv
    exit(main(argv))
