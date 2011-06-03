# BioNLP Shared Task 2011 Data Pre-processing #

For the [BioNLP Shared Task 2011][st] pre-processed data was released to ease
the burden on the participants and allow them to focus on the task instead of
spending time pre-processing the data. We used a suite of NLP tools listed in
the "Software Used" section and released the resulting data.

The reason for also releasing the scripts and documenting the procedures used
is to allow participants the chance to verify the procedure in search of
errors. It also enables future research to replicate the procedures used to
generate the pre-processed data, for example to create suitable training data
for systems participating in the shared task.

If you make use of this work please cite the publication provided in
[BibTeX][bibtex] format:

    @InProceedings{stenetorp2011b,
       author = {Stenetorp, Pontus and Topi{\'c}, Goran and Pyysalo, Sampo
           and Ohta, Tomoko and Kim, Jin-Dong and Tsujii, Jun'ichi},
       title     = {BioNLP Shared Task 2011: Supporting Resources},
       booktitle = {Proceedings of the BioNLP 2011 Workshop Companion
           Volume for Shared Task},
       month     = {June},
       year      = {2011},
       address   = {Portland, Oregon},
       publisher = {Association for Computational Linguistics},
    }

[st]: https://sites.google.com/site/bionlpst/
[bibtex]: http://en.wikipedia.org/wiki/BibTeX

## Usage ##

This section covers the usage of the scripts and how to set them up appropriately.

## Quick-start ##

In an ideal world, you would ge able to just pull this repository and run it,
but as [Carmack][carmack] has pointed out on [a different note][writeonce]
"Write-once-run-anywhere. Ha. Hahahahaha." Most likely you will have to read
the "Prerequisites" section, but here is the absolutely quickest way to
replicate the process using this repository.

Clone the repository:

    git clone git@github.com:ninjin/bionlp_st_2011_supporting.git

Or download and extract the repository using the "Downloads" button on this
page.

Create the `input` directory and place one or several Gzipped tarballs
containing files with `.txt` extensions and run:

    make

Or, if you prefer to only use one out of several available parsers use one of
the following:

<!-- Expand the names here! -->

    make berkeley
    make candc
    make enju
    make gdep
    make mcccj
    make ss
    make stanford
    make tok

[carmack]: http://en.wikipedia.org/wiki/John_D._Carmack
[writeonce]: http://www.armadilloaerospace.com/n.x/johnc/recent%20updates/archive?news_id=295

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

For other operating systems please refer to your manual or the documents found
on the homepages of the respective software.

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
their license agreement. All other software is already included in the
repository.

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

For the easiest case just use and follow the instructions to manually download
the software which licenses prohibits us to access it automatically.

    cd ${WHERE_YOU_DOWLOADED_AND_EXTRACTED_THE_REPOSITORY}
    make

<!-- TODO: Without bad software! -->
<!-- TODO: Just a single type -->
<!-- TODO: Select the data directory. -->
<!-- TODO: Where will the data end up? -->

[nix]: http://en.wikipedia.org/wiki/Unix-like "Unix-like on Wikipedia"
[perl]: http://www.perl.org/ "Perl Homepage"
[python]: http://www.python.org/ "Python Homepage"
[ruby]: http://www.ruby-lang.org/ "Ruby Homepage"
[gnu]: http://en.wikipedia.org/wiki/GNU "GNU on Wikipedia"
[ubuntu]: http://www.ubuntu.com/ "Ubuntu Homepage"
[cpp]: http://en.wikipedia.org/wiki/C%2B%2B "C++ on Wikipedia"
[gcc]: http://gcc.gnu.org/ "The GNU C Compiler (GCC) Homepage"
[clang]: http://clang.llvm.org/ "Clang Homepage"
[llvm]: http://llvm.org/ "LLVM Homepage"
[linux]: http://en.wikipedia.org/wiki/GNU/Linux_naming_controversy "GNU/Linux Naming Controversy on Wikipedia"
[java]: http://www.java.com/ "Java Hompage"
[tar]: http://en.wikipedia.org/wiki/Tar_%28file_format%29 "Tarball on Wikipedia"
[openjdk]: http://openjdk.java.net/ "OpenJDK Homepage"
[ubuntujava]: https://help.ubuntu.com/community/Java "Community Documentation on Java for Ubuntu"

## Software used ##

<!-- TODO: List it all here -->

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

[graphviz]: http://www.graphviz.org/ "Graphviz Homepage"
[pipeline_img]: https://github.com/ninjin/bionlp_st_2011_supporting/raw/master/doc/parsing_pipeline.png

### GNU Make ###

We use [GNU Make][gnumake] to control the generation of the files. This
enables us to run several sessions concurrently and be able to regenerate only
the relevant files upon changing the procedure.

<!-- TODO: This section -->
<!-- XXX: We did apply extra code some times! -->

[gnumake]: http://www.gnu.org/software/make/ "GNU Make Hompage"
[geniass]: http://www-tsujii.is.s.u-tokyo.ac.jp/~y-matsu/geniass/ "GeniaSS Homepage"
[enju]: http://www-tsujii.is.s.u-tokyo.ac.jp/enju/ "Enju Homepage"
[berkeley]: http://code.google.com/p/berkeleyparser/ "Berkeley Parser Hompage"
[stanford]: http://nlp.stanford.edu/software/lex-parser.shtml "Stanford Parser Hompage"
[ccg]: http://svn.ask.it.usyd.edu.au/trac/candc/wiki "CCG "
[gdep]: http://people.ict.usc.edu/~sagae/parser/gdep/index.html

## Naming Conventions ##

### Releases ###

<!-- TODO: This section -->

### File Suffixes ###
We use two different conventions for file naming, one for the final releases
and one internally for the postprocessing script.

<!-- TODO: This section -->

#### Internal ####

<!-- TODO: This section -->

#### Release Directory Structure ####

In order to conform to the [BioNLP'09 Shared Task][bionlp09] post-processed
data directory structure the output from the Makefile is re-structured into
another following format before release. This is done using a script that can
be found in `tools/repack.py`.

    tools/repack.py ${OUTPUT_DIR} ${REFORMATTED_OUTPUT_DIR}

The format is as follows:

<!-- TODO: List all of it -->

[bionlp09]: http://www-tsujii.is.s.u-tokyo.ac.jp/GENIA/SharedTask/ "BioNLP'09 Shared Task Homepage"

## Parse failures ##

<!-- TODO: Here we will list sources of failures for different parser software. Maybe link it if it is too big. -->

## Postmortem ##

<!-- This section will be expanded over time* -->

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

<!-- TODO: Mention data licensing as well -->

[iscl]: http://opensource.org/licenses/isc-license "ISC License at opensource.org"

<!-- "It's a trap!" (for bots) -->
[](http://bob.llamaslayers.net/contact.php?view=862)
