# BioNLP Shared Task 2011 Data Pre-processing #

For the [BioNLP Shared Task 2011][st] pre-processed data was released to ease
the burden on the participants and allow them to focus on the task instead of
spending time pre-processing the data. We used a suite of NLP tools listed in
the "Software Used" section and released the resulting data.

The reason for also releasing the scripts and documenting the procedures used
is to allow participants the chance to verify the procedure in search of
errors. It also enables future research to replicate the procedures used to
generate the pre-processed data, for example to create suitable training data
for systems that participated in the shared task.

You can download the data from the [BioNLP Shared Task 2011 website][st] and
for a good overview of the process please see this [flowchart][pipeline_img].

If you make use of the released data or these instructions in your
publications please cite the publication below which is provided
in [BibTeX][bibtex] format:

    @InProceedings{stenetorp2011b,
       author    = {Stenetorp, Pontus and Topi{\'c}, Goran and Pyysalo, Sampo
           and Ohta, Tomoko and Kim, Jin-Dong and Tsujii, Jun'ichi},
       title     = {BioNLP Shared Task 2011: Supporting Resources},
       booktitle = {Proceedings of the BioNLP 2011 Workshop Companion
           Volume for Shared Task},
       month     = {June},
       year      = {2011},
       address   = {Portland, Oregon},
       publisher = {Association for Computational Linguistics},
    }

## Usage ##

This section covers the usage of the scripts and how to set them up appropriately.

### Quick-start ###

In an ideal world, you would be able to just pull this repository and run it,
but as [Carmack][carmack] has pointed out on [a different note][carmack_blog]
"[Write-once-run-anywhere][writeonce]. Ha. Hahahahaha." Most likely you will
have to read the "Prerequisites" section, but here is the absolutely quickest
way to replicate the process using this repository.

Clone the repository:

    git clone git@github.com:ninjin/bionlp_st_2011_supporting.git

Or download and extract the repository using the "Downloads" button on this
page:

    tar xfz ${NAME_OF_THE_ARCHIVE_YOU_DOWNLOADED}

Create the `input` directory inside the repository structure and place one or
several Gzipped tarballs containing files with `.txt` extensions:

    cd bionlp_st_2011_supporting
    mkdir input
    cp ${WHERE_YOU_KEEP_YOUR_TEXT_TARBALLS} input

From here the script should take over, download, compile and produce the
output using the same pipeline that was used for BioNLP ST 2011:

    make

Or, if you prefer to only use one out of several available parsers use one of
the following. Afterwards your parses will be in the `build` directory.

The [Berkeley parser][berkeley]:

    make berkeley

The [CCG][ccg]:

    make candc

The [Enju parser][enju]:

    make enju

The [Genia Dependency parser][gdep]:

    make gdep

The [McClosky Biomedical model][mcclosky] for
the [Charniak-Johnson parser][cj]:

    make mcccj

The [Genia Sentence Splitter][geniass] and/or tokenisation:

    make ss
    make tok

The  [Stanford parser][stanford]:

    make stanford

If you want some additional speed you can use the `-j` flag for `make` and
execute several processes in parallel. The number of CPU;s in your system plus
one can be a good choice for the number of parallel processes.

### Prerequisites ##

This section covers the software that is required to run the main scripts and
provide details on which versions that were used to create the pre-processed
shared task data.

#### Installation ####

We assume that the system you are using is a [*NIX][nix] operating system that
has [Perl][perl], [Python][python], [Ruby][ruby], [GNU Make][gnumake],
[The GNU C Compiler][gcc] (GCC) and [Sun Java 6][java] installed.

For [Ubuntu][ubuntu] you would use the following command to install the script
dependencies using the package manager (for newer versions of Ubuntu you may
need to enable additional software sources under
"System/Administration/Update Manager/Settings/Ubuntu Software", make sure that
the option "Community Maintained Open Source software" (universe) is checked).

    sudo apt-get install perl python ruby make gcc sun-java6-jre

For other operating systems please refer to your manual or the documentation
found on the homepages of the respective software.

#### Perl ####

We used the following version of Perl, older and newer versions may work but
this information is provided for reference purposes.

    > perl --version

    This is perl 5, version 12, subversion 2 (v5.12.2) built for x86_64-linux
    
    Copyright 1987-2010, Larry Wall
    
    Perl may be copied only under the terms of either the Artistic License or the
    GNU General Public License, which may be found in the Perl 5 source kit.
    
    Complete documentation for Perl, including FAQ lists, should be found on
    this system using "man perl" or "perldoc perl".  If you have access to the
    Internet, point your browser at http://www.perl.org/, the Perl Home Page.

#### Python ####

We used the following version of Python, older and newer versions may work but
this information is provided for reference purposes.

    > python --version
    Python 2.7.1

#### Ruby ####

We used the following version of Ruby, older and newer versions may work but
this information is provided for reference purposes.

    > ruby --version
    ruby 1.8.6 (2008-03-13 patchlevel 5000) [x86_64-linux]

#### GNU Make ####

If you are running a non-[GNU][gnu] based system (this usually means
non-[Linux][linux]) you may not have [GNU Make][gnumake] installed by default,
once installed it may be launched either using `make` or `gmake`, the latter
is more common on non-GNU systems. If you try to use another implementation of
Make you will most likely encounter a wide array of syntax errors.

Please verify using the `--version` flag that you are indeed running a GNU
version of Make (what is important is the "GNU Make" part and that it is not
ancient, anything after the year 2000 should be fine).

    > gmake --version
    GNU Make 3.82
    Built for x86_64-unknown-linux-gnu
    Copyright (C) 2010  Free Software Foundation, Inc.
    License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
    This is free software: you are free to change and redistribute it.
    There is NO WARRANTY, to the extent permitted by law.

#### GCC ####

Some parsers needs to be compiled manually since they are not provided as
pre-compiled binaries. Thus they need to be compiled which is why we depend on
the [GNU C Compiler][gcc] (other compiler such as [Clang][clang] for
[LLVM][llvm] should also work but has not been tested). GCC is notorious for
not being stable between versions for [C++][cpp] (which itself is notoriously
different between implementations), we have verified that all included
software that needs to be compiled works with version 4.2.1.

    > gcc --version
    gcc (GCC) 4.2.1
    Copyright (C) 2007 Free Software Foundation, Inc.
    This is free software; see the source for copying conditions.  There is NO
    warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

#### Sun Java 6 ####

The [Berkeley][berkeley] and [Stanford Parser][stanford] along with a few of
our conversion tools are implemented in Java, thus requiring a Java Virtual
Machine (JVM) to run. We used version 6 of the official Sun Java distribution.
Other distributions such as [OpenJDK][openjdk] may work but has not been
tested. Check your version as seen below (do note the single hyphen before the
version flag, this is unlike all invocations we have shown so far).

    > java -version
    java version "1.6.0_20"
    Java(TM) SE Runtime Environment (build 1.6.0_20-b02)
    Java HotSpot(TM) 64-Bit Server VM (build 16.3-b01, mixed mode)

For Ubuntu you may not see the expected output although you have installed the
sun-java6-jre package. Ubuntu delivers its own way of selecting which JVM to
use when using the `java` command, please see the
[Ubuntu Wiki on Java][ubuntujava] for more information.

### Invocation ###

This section covers the procedure which to use to generate the pre-processed
data.

#### Licensing Restrictions and You ####

During the first invocation of the makefile you will be prompted to manually
download the resources necessary to run [C&C][ccg] and [Enju][enju] since
their licenses don't allow re-distribution without explicitly agreeing with
their license agreement.

#### Liberally Licensed Software ####

Since source repositories tend to handle binary data poorly and GitHub has
restrictions on repository sizes the Makefile will attempt to download all
other software automatically. But just like the restricted software the
liberally licensed software can be placed manually into (but into `wrk/good`
as opposed to `wrk/bad`), this will cause GNU Make not to fetch and instead
used the manually placed software.

For the data, the restricted software and the liberally licensed software
checksums are provided of the archives used for the released parses. These can
be found in the `checksums` directory.

#### Placing the Data ####

Simply place a Gzipped [Tarball][tar] (.tar.gz) in the data directory and
GNU Make will read it and produce the corresponding post-processed files in
the output directory. The script will preserve the directory hierarchy used
and the naming conventions for the files in the Tarball.

**NOTE:** The input text files must have the file suffix ".txt" or they will
be ignored by the post-processing script. This is the cue for GNU Make to
consider a file to be suitable as input. Also note that any files you may not
want to process should not use this file suffix.

#### Invoking the Pre-processing ####

To invoke the pipeline just execute:

    make

If you want to run several processes in parallel for increased speed use
the `-j` flag for `make` to set the number of parallel processes. After the
processes has terminated your output will be found in the `build` directory.

## Software used ##

### Workflow ###

While a description in text of a workflow may be suitable for some it is
difficult to get a clear overview of the process. For a better overview please
see [this flowchart image][pipeline_img] generated using [Graphviz][graphviz].
It is fairly large so you may want to open it in a separate tab or window for
easier viewing.

You can find the file used to generate the flowchart at
`doc/parsing_pipeline.dot` and then generate an image using
the following command if you have Graphviz installed.

    dot -T ${IMAGE_FORMAT} doc/parsing_pipeline.dot \
        > doc/parsing_pipeline.${IMAGE_FORMAT}


### GNU Make ###

We use [GNU Make][gnumake] to control the generation of the files. This
enables us to run several sessions concurrently and be able to regenerate only
the relevant files upon changing the procedure.


### GeniaSS ###

[GeniaSS][geniass] is used for sentence splitting, but since the GeniaSS
output is generally quite *"raw"*, we use small Perl script
(`tools/geniass-postproc.pl`) to refine the output.

### Tokenisation ###

For tokenisation we use an in-house tokenisation script
(`tools/GTB-tokenize.pl`) that emulates the tokenisation used in
the [Genia Treebank][gtb] (GTB). The script also supports several flags such
as `-ptb` that produces Penn Treebank (PTB) escapes which is necessary for the
Berkley parser input. `-mccc` is also used for shortcomings in the McClosky
model used, please see the section on "McClosky Charniak-Johnson" for details.

### Enju Parser ###

[Enju][enju] is a "deep-parser" which uses its own XML-format but also
supplies conversion tools into other formats. To convert into PTB-style output
we use the Enju `convert` tool and a custom Perl script provided by the Enju
developers `tools/postenju2ptb.prl`.

Enju uses an "unknown" POS-tag `UNK` which can not be accommodated by the
conversion tools for PTB-style output. To accommodate we convert all `UNK` tags
into `NP`, this is a naive approach which would have been taken by a majority
vote classifier and could be refined but works well enough for our purposes.

As for most parsers Enju can fail to parse certain sentences, for these cases
Enju outputs a so-called flat parse:

    (error ${SENTENCE})

We replace these with a parse of the sentence "Parse failed !", this approach is
discussed in the "Postmortem" section.

*Warning:* Enju provides a multitude of binaries, the one used for the shared
task was `enju-2.4.1-centos4-x86_64`. You will have to alter this in the
Makefile to suit your environment.

### Stanford Parser ###

The [Stanford parser][stanford] is a widely used parser that produces standard
PTB-style output. We use the `englishFactored` grammar, which although
imposing a heavy performance penalty provides the highest possible accuracy.

Upon failing to parse a sentence the Stanford parser outputs two warnings
on `stdout`, just as for Enju we replace these with the sentence
"Parse failed !", this approach is discussed in the "Postmortem" section.

### GDep ###

[GDep][gdep] is a dependency parser geared towards biomedical texts, unlike
all other parsers we are unable to convert its output into other formats.
Thus GDep output is only provided in its native CoNLL-X style format.

### C&C CCG Parser ###

Like Enju the [Clark & Curran CCG parser][candc] is a "deep-parser" which uses
a native format different from PTB-style output. However, unlike Enju CCG
parses can not be readily converted into PTB-style parses. Fortunately there
is a conversion script available to convert the CCG output into Stanford
dependency output. We used the supplied Biomedical models for the parser to
better suit our domain.

As is the case for most of our parsers there are sentences for which the
parser is unable to provide any output, so for this parsers as well we replace
the sentence with "Parse failed!". However, the tokenisation is slightly
different in this case and a space is lacking before the exclamation mark.
This is an error but will be kept for consistency.

### McClosky Charniak-Johnson ###

[McClosky Charniak-Johnson][mcclosky] refers to the Charniak-Johnson
re-ranking parser using the McClosky biomedical model. This is a parser with a
long history and for the August 2006 release it can potentially hang upon some
given input. This causes the parser to never terminate and the "dangerous"
sentences must be extracted by narrowing down the possible alternatives and
then making sure that the sentence is never fed to the parser. We treat this
similarly to the failed parses for the other parsers and replace these
sentences with "Parse failed !". Although this is a bit of additional work it
is justified by the parser with the given model producing arguably the best
parses for texts from the biomedical domain.


**Note:** If you are constructing your own parsing pipeline or don't care for backwards compability with the BioNLP ST 2011 parses. It is highly recommended to try out the latest releases of the Charniak-Johnson parser from  [charniak][this repository].

### Berkeley Parser ###

The [Berkeley parser][berkeley] is a modern parser that outputs PTB-style parses. 

Upon failing to parse a sentence the Berkeley parser outputs a blank parse
on `stdout`:

    (())

Just as with the other parsers we replace this with the parse of the sentence
"Parse failed !".

### Stanford Tools ###

[Stanford Tools][stanfordtools] enables the conversion of PTB style parses
into dependency parses. We convert the PTB style output from our parsers into
dependency parses and collapsed dependency parses. The tools themselves are
robust and apart from making sure that the root node is called `ROOT` as
opposed to `TOP` which is the case for some parsers no significant
pre-processing is necessary. A single sentence from Enju failed to be
converted by the tools and was manually replaced with:

    (TOP (S (NP (NNP Conversion)) (VP (VBD failed))))

This approach is discussed in the "Postmortem" section.

### Pennconverter ###

[Pennconverter][pennconverter] or more formally "The LTH
Constituent-to-Dependency Conversion Tool for Penn-style Treebanks", a name
which pretty much works as a description. While the tool itself was not
constructed to handle the output of probabilistic parsers it is still fairly
robust and by tweaking it for some special cases we converted all of the
output from our parsers apart from C&C CCG and GDep into CoNLL-X style
dependency parses using this tool. All sentences that could not be converted
by the tool were replaced with the corresponding PTB-style parse of the
sentence "Conversion failed !", this approach is discussed further in the
"Postmortem" section.

## Release Directory Structure ##

In order to conform to the [BioNLP'09 Shared Task][bionlp09] post-processed
data directory structure the output from the Makefile is re-structured into
another following format before release. This is done using a script that can
be found in `tools/repack.py`.

    tools/repack.py ${OUTPUT_DIR} ${REFORMATTED_OUTPUT_DIR}

## Repository Directory Structure ##

This is the layout of the repository directories, directories marked with
stars (\*) are created by the script and those marked with hashes has (#) to
be created by the user.

    .
    ├── build // Destination of the final "internal" output data (*)
    │   └── release // Output data packaged as it was released (*)
    ├── checksums // Checksums for relevant data and software
    ├── doc // Documentation related data
    ├── input // Input data for the parsing pipeline (#)
    ├── patches // Patches necessary to run certain software
    ├── tools // Tools provided by the organisers and associates
    └── wrk // Work directory, freely write-able by the script (*)
        ├── bad // Software with restricted licenses (*)
        ├── data // Temporary storage of data while being processed (*)
        ├── external // Extracted and built software (*)
        └── good // Liberally licensed software (*)

## Postmortem ##

Few parsers are robust enough to be released on data *"in the wild"*, this
being said, we should always seek to report these errors since much of our
research is dependent on parsing working correctly and we should encourage a
software/research culture where we can rely on the work and implementations of
others.

To sum up what I have learnt about Makefiles over the course of this work,
there are many alternatives to Make, not necessarily because people didn't
know of the existence of Make, but rather that a lot of people got to know
Make and then moved on. The syntax is error prone, sometimes you end up with
unexpected behaviour and building a concurrent workflow beyond the invocation
of several targets in parallel is not supported (best way I can come up while
writing this is running a service somewhere else and allowing Make to send
requests to it).

In hindsight I regret inserting "Parse failed!" as a replacement for failed
parses. This choice may appear reasonably at first sight since it makes sure
that the participants can simply assume the style of the input further down
the line. But it is really a case of silencing errors, instead a clear marking
such as PARSE\_FAILED should be used since it ensures that the participants
will take action and note the issue instead of potentially missing it and
potentially leading to problems with for example alignment further down the
line.

While make provides some methods to parallelise the workflow it is still
somewhat lacking in regards to how it enables high-performing workflows. Many
parsers have high start-up costs and starting a new process for each target
may induce a higher degree of redundancy but in the case for a parser like
GDep it causes the execution time to be prolonged by a factor in the
hundreds. This is a problem if what you desire is a high-performing workflow
and would require you to take another approach.

## Contact ##
For questions regarding these scripts, how they work in relation to the
released datasets and most importantly about any short-comings and/or errors
on this page. Please contact:

* Pontus Stenetorp &lt;pontus stenetorp se&gt;

For questions regarding the datasets please refer to:

* BioNLP'11 Organising Committee &lt;bionlp-st googlegroups com&gt;

Please substitute the first space with an @ sign and the second space with a .
for the above addresses to gain the actual address.

## License ##

All work is available under the [ISC License][iscl]. Do note that not all the
software used to produce the post-processed data use this license, check with
each software provider and their website for their respective license and
requirements.

<!-- Links goes here -->

[berkeley]: http://code.google.com/p/berkeleyparser/ "Berkeley Parser Homepage"
[bibtex]: http://en.wikipedia.org/wiki/BibTeX "BibTeX Entry on Wikipedia"
[bionlp09]: http://www-tsujii.is.s.u-tokyo.ac.jp/GENIA/SharedTask/ "BioNLP'09 Shared Task Homepage"
[carmack]: http://en.wikipedia.org/wiki/John_D._Carmack "John D. Carmack Entry on Wikipedia"
[carmack_blog]: http://www.armadilloaerospace.com/n.x/johnc/recent%20updates/archive?news_id=295 "Carmack on Mobile Java Development"
[ccg]: http://svn.ask.it.usyd.edu.au/trac/candc/wiki "Curran and Clark CCG Parser Homepage"
[charniak]: https://bitbucket.org/bllip/bllip-parser/ "Charniak-Johnson Parser Repository"
[cj]: http://www.cs.brown.edu/~ec/ "Charniak-Johnson Parser Homepage"
[clang]: http://clang.llvm.org/ "Clang Homepage"
[cpp]: http://en.wikipedia.org/wiki/C%2B%2B "C++ Entry on Wikipedia"
[enju]: http://www-tsujii.is.s.u-tokyo.ac.jp/enju/ "Enju Parser Homepage"
[gcc]: http://gcc.gnu.org/ "The GNU C Compiler (GCC) Homepage"
[gdep]: http://people.ict.usc.edu/~sagae/parser/gdep/index.html "GDep Homepage"
[geniass]: http://www-tsujii.is.s.u-tokyo.ac.jp/~y-matsu/geniass/ "GeniaSS Homepage"
[gnu]: http://en.wikipedia.org/wiki/GNU "GNU on Wikipedia"
[gnumake]: http://www.gnu.org/software/make/ "GNU Make Homepage"
[graphviz]: http://www.graphviz.org/ "Graphviz Homepage"
[gtb]: http://www-tsujii.is.s.u-tokyo.ac.jp/GENIA/home/wiki.cgi?page=GENIA+Treebank "Genia Treebank Homepage"
[iscl]: http://opensource.org/licenses/isc-license "ISC License at opensource.org"
[java]: http://www.java.com/ "Java Homepage"
[linux]: http://en.wikipedia.org/wiki/GNU/Linux_naming_controversy "GNU/Linux Naming Controversy on Wikipedia"
[llvm]: http://llvm.org/ "LLVM Homepage"
[mcclosky]: http://www.cs.brown.edu/~dmcc/biomedical.html "David McClosky's Biomedical Models Homepage"
[nix]: http://en.wikipedia.org/wiki/Unix-like "Unix-like on Wikipedia"
[openjdk]: http://openjdk.java.net/ "OpenJDK Homepage"
[pennconverter]: http://nlp.cs.lth.se/software/treebank_converter/ "Pennconverter Homepage"
[perl]: http://www.perl.org/ "Perl Homepage"
[pipeline_img]: https://github.com/ninjin/bionlp_st_2011_supporting/raw/master/doc/parsing_pipeline.png "Image Illustrating the Parsing Pipeline"
[python]: http://www.python.org/ "Python Homepage"
[ruby]: http://www.ruby-lang.org/ "Ruby Homepage"
[st]: https://sites.google.com/site/bionlpst/ "BioNLP Shared Task 2011 Homepage"
[stanford]: http://nlp.stanford.edu/software/lex-parser.shtml "Stanford Parser Homepage"
[stanfordtools]: http://nlp.stanford.edu/software/corenlp.shtml "Stanford CoreNLP Tools Homepage"
[tar]: http://en.wikipedia.org/wiki/Tar_%28file_format%29 "Tarball on Wikipedia"
[ubuntu]: http://www.ubuntu.com/ "Ubuntu Homepage"
[ubuntujava]: https://help.ubuntu.com/community/Java "Community Documentation on Java for Ubuntu"
[writeonce]: http://en.wikipedia.org/wiki/Write_once,_run_anywhere "Write-once-run-anywhere Entry on Wikipedia"

<!-- "It's a trap!" (for bots) -->
[](http://bob.llamaslayers.net/contact.php?view=862)
