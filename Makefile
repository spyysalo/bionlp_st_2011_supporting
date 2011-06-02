# Create a set of preprocessed data from a BioNLP 2011 release.
#
# Author: Pontus Stenetorp <pontus stenetorp se>
# Version: 2010-12-10
#
# WARNING: Note that just like pretty much any Makefile this one needs the
# input not to contain spaces, we do our best to handle it but it would be
# much better to conform with *NIX philosophy and simply don't use spaces and
# be happy.
# tl;dr: Don't use spaces in your filenames or suffer the consequences.
#
# NOTE: You can (and should) use the make ability to set the number of
# parallel processes, for example use -j ${NUMBER_OF_CORES}. You will
# enjoy the speed-up.

### Directory structure declarations
RES_DIR:=input
WRK_DIR:=wrk
WRK_DATA_DIR:=${WRK_DIR}/data
EXT_DIR:=${WRK_DIR}/external
EXT_DIR_ABS:=${PWD}/${EXT_DIR}
PATCH_DIR:=patches
TOOLS_DIR:=tools
GOOD_EXT_DIR:=${WRK_DIR}/good
GOOD_EXT_DIR_ABS:=${PWD}/${BAD_EXT_DIR}
BAD_EXT_DIR:=${WRK_DIR}/bad
BAD_EXT_DIR_ABS:=${PWD}/${BAD_EXT_DIR}
OUTPUT_DIR:=build
RELEASE_DIR:=${OUTPUT_DIR}/release

### Filename suffixes used internally before tools/repack.py
SS_SUFF:=ss
TOK_SUFF:=tok
PTB_TOK_SUFF:=ptbtok
MCCCJ_TOK_SUFF:=mcccjtok
ENJU_SUFF:=enju.xml
STANFORD_SUFF:=stp
BERKELEY_SUFF:=ucb
CANDC_SUFF:=candc
MCCCJ_SUFF:=mcccj
GDEP_SUFF:=gdep
# Generic format suffixes
PTB_SUFF:=ptb
SD_SUFF:=sd
BASIC_SD_SUFF:=basic.${SD_SUFF}
CCPROC_SD_SUFF:=ccproc.${SD_SUFF}
LTHCDCT_SUFF:=conll

### Commands
FETCH_CMD=wget
TOKENISE_CMD=${TOOLS_DIR}/GTB-tokenize.pl

# Output archive suffixes
SS_ARCHIVE_SUFF:=sentence_split
TOK_ARCHIVE_SUFF:=tokenised
ENJU_ARCHIVE_SUFF:=enju
STANFORD_ARCHIVE_SUFF:=stanford
BERKELEY_ARCHIVE_SUFF:=berkeley
CANDC_ARCHIVE_SUFF:=candc
MCCCJ_ARCHIVE_SUFF:=mcccj
GDEP_ARCHIVE_SUFF:=gdep

### Prefixes used for collections of targets of different types
ARCH_PRE:=ARCH
ARCH_PATH_PRE:=ARCH_PATH
ARCH_CONTENT_PRE:=ARCH_CONTENT
TXT_FILES_PRE:=TXT_FILES
SS_FILES_PRE:=SS_FILES
SS_ARCHIVE_PRE:=SS_ARCHIVE
TOK_FILES_PRE:=TOK_FILES
TOK_ARCHIVE_PRE:=TOK_ARCHIVE

ENJU_FILES_PRE:=ENJU_FILES
ENJU_ARCHIVE_PRE:=ENJU_ARCHIVE
ENJU_PTB_FILES_PRE:=ENJU_PTB_FILES
ENJU_BASIC_SD_FILES_PRE:=ENJU_BASIC_SD_FILES
ENJU_CCPROC_SD_FILES_PRE:=ENJU_CCPROC_SD_FILES
ENJU_LTHCDCT_FILES_PRE:=ENJU_LTHCDCT_FILES

STANFORD_FILES_PRE:=STANFORD_FILES
STANFORD_ARCHIVE_PRE:=STANFORD_ARCHIVE
STANFORD_BASIC_SD_FILES_PRE:=STANFORD_BASIC_SD_FILES
STANFORD_CCPROC_SD_FILES_PRE:=STANFORD_CCPROC_SD_FILES
STANFORD_LTHCDCT_FILES_PRE:=STANFORD_LTHCDCT_FILES

BERKELEY_FILES_PRE:=BERKELEY_FILES
BERKELEY_ARCHIVE_PRE:=BERKELEY_ARCHIVE
BERKELEY_BASIC_SD_FILES_PRE:=BERKELEY_BASIC_SD_FILES
BERKELEY_CCPROC_SD_FILES_PRE:=BERKELEY_CCPROC_SD_FILES
BERKELEY_LTHCDCT_FILES_PRE:=BERKELEY_LTHCDCT_FILES

CANDC_FILES_PRE:=CANDC_FILES
CANDC_ARCHIVE_PRE:=CANDC_ARCHIVE
CANDC_BASIC_SD_FILES_PRE:=CANDC_BASIC_SD_FILES

MCCCJ_FILES_PRE:=MCCCJ_FILES
MCCCJ_ARCHIVE_PRE:=MCCCJ_ARCHIVE
MCCCJ_BASIC_SD_FILES_PRE:=MCCCJ_BASIC_SD_FILES
MCCCJ_CCPROC_SD_FILES_PRE:=MCCCJ_CCPROC_SD_FILES
MCCCJ_LTHCDCT_FILES_PRE:=MCCCJ_LTHCDCT_FILES

GDEP_FILES_PRE:=GDEP_FILES
GDEP_ARCHIVE_PRE:=GDEP_ARCHIVE

# Registers an archive into our list of targets to be generated
define register-archive
ARCH_PATH:=$1
ARCH_FILE:=$${shell basename $${ARCH_PATH}}
ARCH_BASE:=$${shell echo $${ARCH_FILE} | sed -e 's|^\([^.]*\)\..*$$$$|\1|g'}
ARCH_SUFF:=$${shell echo $${ARCH_FILE} | sed -e 's|^[^.]*\.\(.*\)$$$$|\1|g'}

ARCH_CONTENT:=$${shell tar tfz $${ARCH_PATH}}
TXT_FILES:=$${addprefix ${WRK_DATA_DIR}/, $${filter %.txt, $${ARCH_CONTENT}}}
SS_FILES:=$${addsuffix .${SS_SUFF}, $${TXT_FILES}}
SS_ARCHIVE:=$${OUTPUT_DIR}/$${ARCH_BASE}_$${SS_ARCHIVE_SUFF}.$${ARCH_SUFF}
TOK_FILES:=$${addsuffix .${TOK_SUFF}, $${SS_FILES}}
TOK_ARCHIVE:=$${OUTPUT_DIR}/$${ARCH_BASE}_$${TOK_ARCHIVE_SUFF}.$${ARCH_SUFF}

ENJU_FILES:=$${addsuffix .${ENJU_SUFF}, $${TOK_FILES}}
ENJU_PTB_FILES:=$${addsuffix .${PTB_SUFF}, $${ENJU_FILES}}
ENJU_BASIC_SD_FILES:=$${addsuffix .${BASIC_SD_SUFF}, $${ENJU_PTB_FILES}}
ENJU_CCPROC_SD_FILES:=$${addsuffix .${CCPROC_SD_SUFF}, $${ENJU_PTB_FILES}}
ENJU_LTHCDCT_FILES:=$${addsuffix .${LTHCDCT_SUFF}, $${ENJU_PTB_FILES}}
ENJU_ARCHIVE:=$${OUTPUT_DIR}/$${ARCH_BASE}_$${ENJU_ARCHIVE_SUFF}.$${ARCH_SUFF}

STANFORD_FILES:=$${addsuffix .${STANFORD_SUFF}, $${TOK_FILES}}
STANFORD_BASIC_SD_FILES:=$${addsuffix .${BASIC_SD_SUFF}, $${STANFORD_FILES}}
STANFORD_CCPROC_SD_FILES:=$${addsuffix .${CCPROC_SD_SUFF}, $${STANFORD_FILES}}
STANFORD_LTHCDCT_FILES:=$${addsuffix .${LTHCDCT_SUFF}, $${STANFORD_FILES}}
STANFORD_ARCHIVE:=$${OUTPUT_DIR}/$${ARCH_BASE}_$${STANFORD_ARCHIVE_SUFF}.$${ARCH_SUFF}

BERKELEY_FILES:=$${addsuffix .${PTB_TOK_SUFF}.${BERKELEY_SUFF}, $${SS_FILES}}
BERKELEY_BASIC_SD_FILES:=$${addsuffix .${BASIC_SD_SUFF}, $${BERKELEY_FILES}}
BERKELEY_CCPROC_SD_FILES:=$${addsuffix .${CCPROC_SD_SUFF}, $${BERKELEY_FILES}}
BERKELEY_LTHCDCT_FILES:=$${addsuffix .${LTHCDCT_SUFF}, $${BERKELEY_FILES}}
BERKELEY_ARCHIVE:=$${OUTPUT_DIR}/$${ARCH_BASE}_$${BERKELEY_ARCHIVE_SUFF}.$${ARCH_SUFF}

CANDC_FILES:=$${addsuffix .${CANDC_SUFF}, $${TOK_FILES}}
CANDC_BASIC_SD_FILES:=$${addsuffix .${BASIC_SD_SUFF}, $${CANDC_FILES}}
CANDC_ARCHIVE:=$${OUTPUT_DIR}/$${ARCH_BASE}_$${CANDC_ARCHIVE_SUFF}.$${ARCH_SUFF}

MCCCJ_FILES:=$${addsuffix .${MCCCJ_TOK_SUFF}.${MCCCJ_SUFF}, $${SS_FILES}}
MCCCJ_BASIC_SD_FILES:=$${addsuffix .${BASIC_SD_SUFF}, $${MCCCJ_FILES}}
MCCCJ_CCPROC_SD_FILES:=$${addsuffix .${CCPROC_SD_SUFF}, $${MCCCJ_FILES}}
MCCCJ_LTHCDCT_FILES:=$${addsuffix .${LTHCDCT_SUFF}, $${MCCCJ_FILES}}
MCCCJ_ARCHIVE:=$${OUTPUT_DIR}/$${ARCH_BASE}_$${MCCCJ_ARCHIVE_SUFF}.$${ARCH_SUFF}

GDEP_FILES:=$${addsuffix .${GDEP_SUFF}, $${TOK_FILES}}
GDEP_ARCHIVE:=$${OUTPUT_DIR}/$${ARCH_BASE}_$${GDEP_ARCHIVE_SUFF}.$${ARCH_SUFF}

VAR_PRE:=$${ARCH_PRE}_$${ARCH_PATH}

$${VAR_PRE}_$${ARCH_PATH_PRE}:=$${ARCH_PATH}
$${VAR_PRE}_$${ARCH_CONTENT_PRE}:=$${ARCH_CONTENT}
$${VAR_PRE}_$${TXT_FILES_PRE}:=$${TXT_FILES}
$${VAR_PRE}_$${SS_FILES_PRE}:=$${SS_FILES}
$${VAR_PRE}_$${SS_ARCHIVE_PRE}:=$${SS_ARCHIVE}
$${VAR_PRE}_$${TOK_FILES_PRE}:=$${TOK_FILES}
$${VAR_PRE}_$${TOK_ARCHIVE_PRE}:=$${TOK_ARCHIVE}

$${VAR_PRE}_$${ENJU_FILES_PRE}:=$${ENJU_FILES}
$${VAR_PRE}_$${ENJU_PTB_FILES_PRE}:=$${ENJU_PTB_FILES}
$${VAR_PRE}_$${ENJU_BASIC_SD_FILES_PRE}:=$${ENJU_BASIC_SD_FILES}
$${VAR_PRE}_$${ENJU_CCPROC_SD_FILES_PRE}:=$${ENJU_CCPROC_SD_FILES}
$${VAR_PRE}_$${ENJU_LTHCDCT_FILES_PRE}:=$${ENJU_LTHCDCT_FILES}
$${VAR_PRE}_$${ENJU_ARCHIVE_PRE}:=$${ENJU_ARCHIVE}

$${VAR_PRE}_$${STANFORD_FILES_PRE}:=$${STANFORD_FILES}
$${VAR_PRE}_$${STANFORD_BASIC_SD_FILES_PRE}:=$${STANFORD_BASIC_SD_FILES}
$${VAR_PRE}_$${STANFORD_CCPROC_SD_FILES_PRE}:=$${STANFORD_CCPROC_SD_FILES}
$${VAR_PRE}_$${STANFORD_LTHCDCT_FILES_PRE}:=$${STANFORD_LTHCDCT_FILES}
$${VAR_PRE}_$${STANFORD_ARCHIVE_PRE}:=$${STANFORD_ARCHIVE}

$${VAR_PRE}_$${BERKELEY_FILES_PRE}:=$${BERKELEY_FILES}
$${VAR_PRE}_$${BERKELEY_BASIC_SD_FILES_PRE}:=$${BERKELEY_BASIC_SD_FILES}
$${VAR_PRE}_$${BERKELEY_CCPROC_SD_FILES_PRE}:=$${BERKELEY_CCPROC_SD_FILES}
$${VAR_PRE}_$${BERKELEY_LTHCDCT_FILES_PRE}:=$${BERKELEY_LTHCDCT_FILES}
$${VAR_PRE}_$${BERKELEY_ARCHIVE_PRE}:=$${BERKELEY_ARCHIVE}

$${VAR_PRE}_$${CANDC_FILES_PRE}:=$${CANDC_FILES}
$${VAR_PRE}_$${CANDC_BASIC_SD_FILES_PRE}:=$${CANDC_BASIC_SD_FILES}
$${VAR_PRE}_$${CANDC_ARCHIVE_PRE}:=$${CANDC_ARCHIVE}

$${VAR_PRE}_$${MCCCJ_FILES_PRE}:=$${MCCCJ_FILES}
$${VAR_PRE}_$${MCCCJ_BASIC_SD_FILES_PRE}:=$${MCCCJ_BASIC_SD_FILES}
$${VAR_PRE}_$${MCCCJ_CCPROC_SD_FILES_PRE}:=$${MCCCJ_CCPROC_SD_FILES}
$${VAR_PRE}_$${MCCCJ_LTHCDCT_FILES_PRE}:=$${MCCCJ_LTHCDCT_FILES}
$${VAR_PRE}_$${MCCCJ_ARCHIVE_PRE}:=$${MCCCJ_ARCHIVE}

$${VAR_PRE}_$${GDEP_FILES_PRE}:=$${GDEP_FILES}
$${VAR_PRE}_$${GDEP_ARCHIVE_PRE}:=$${GDEP_ARCHIVE}

ARCHIVES+=$${VAR_PRE}
ARCHIVES:=$${sort $${ARCHIVES}}
endef
ARCHIVES:=
# Iterate over all the archives in the RES_DIR and register them
${foreach ARCHIVE_FILE, \
	${shell find "${RES_DIR}" -name '*.tar.gz' -o -name '*.tgz'}, \
	${eval ${call register-archive, ${ARCHIVE_FILE}}} \
}

### Links and information for software with non-liberal licenses
# Enju
ENJU_VERSION=2.4.1
ENJU_DOWNLOAD_URL=http://www-tsujii.is.s.u-tokyo.ac.jp/enju/\#download
# WARNING: You may need another version here for your system
ENJU_TAR_GZ=enju-${ENJU_VERSION}-centos4-x86_64.tar.gz
ENJU_DIR=${EXT_DIR}/enju-${ENJU_VERSION}

# C&C CCG Parser
CANDC_VERSION=1.00
CANDC_DOWNLOAD_URL=http://svn.ask.it.usyd.edu.au/trac/candc/wiki/Download
CANDC_BIN_TAR_GZ=candc-linux-${CANDC_VERSION}.tgz
CANDC_DIR=${EXT_DIR}/candc-${CANDC_VERSION}
CANDC_DOWNLOAD_BIN_URL=\
http://svn.ask.it.usyd.edu.au/download/candc/${CANDC_BIN_TAR_GZ}
CANDC_MODELS_TAR_GZ=models-1.02.tgz
CANDC_MODELS_DIR=${EXT_DIR}/models
CANDC_MODELS_URL=http://svn.ask.it.usyd.edu.au/download/candc/models-1.02.tgz
CANDC_POS_MODEL_TAR_GZ=pos_bio-${CANDC_VERSION}.tgz
CANDC_POS_MODEL_DIR=${EXT_DIR}/pos_bio-${CANDC_VERSION}
CANDC_DOWNLOAD_POS_MODEL_URL=\
http://www.cl.cam.ac.uk/research/nl/nl-download/candc/${CANDC_POS_MODEL_TAR_GZ}
CANDC_SUPER_MODEL_TAR_GZ=super_bio-${CANDC_VERSION}.tgz
CANDC_SUPER_MODEL_DIR=${EXT_DIR}/super_bio-${CANDC_VERSION}
CANDC_DOWNLOAD_SUPER_MODEL_URL=\
http://www.cl.cam.ac.uk/research/nl/nl-download/candc/${CANDC_SUPER_MODEL_TAR_GZ}
CANDC_GRS2SD=grs2sd-1.00
CANDC_GRS2SD_PATH=${GOOD_EXT_DIR}/${CANDC_GRS2SD}
CANDC_DOWNLOAD_GRS2SD_URL=\
http://www.cl.cam.ac.uk/research/nl/nl-download/candc/${CANDC_GRS2SD}
CANDC_MARKEDUP_SD=markedup_sd-1.00
CANDC_MARKEDUP_SD_PATH=${GOOD_EXT_DIR}/${CANDC_MARKEDUP_SD}
CANDC_DOWNLOAD_MARKEDUP_SD_URL=\
http://www.cl.cam.ac.uk/research/nl/nl-download/candc/${CANDC_MARKEDUP_SD}

# The warning message issued if we don't have the "bad" software archives
define FETCH_WARNING
WARNING, we depend on software that may not be freely distributed. You will
therefore need to complete the final fetches manually. If you only need either
of these two parsers, feel free to not to download the other one.

    1.) Register (mandatory), download and compile C&C ${CANDC_VERSION} from:
        ${CANDC_DOWNLOAD_URL}
        You need:
        ${CANDC_DOWNLOAD_BIN_URL}
		${CANDC_MODELS_URL}
        ${CANDC_DOWNLOAD_POS_MODEL_URL}
        ${CANDC_DOWNLOAD_SUPER_MODEL_URL}
	
    2.) Register (can be spoofed) and download Enju ${ENJU_VERSION} from:
        ${ENJU_DOWNLOAD_URL}
        Get the file:
        ${ENJU_TAR_GZ}
        If this file does not match your system, download the one applicable
        and edit the variable ENJU_TAR_GZ in this Makefile accordingly.

    3.) Place all the downloaded files in the following directory:
        ${BAD_EXT_DIR_ABS}
endef
# Export-hack for later access to the variable
export FETCH_WARNING

# Archives for the "bad" software
EXTERNAL_BAD=${BAD_EXT_DIR}/${ENJU_TAR_GZ} ${BAD_EXT_DIR}/${CANDC_BIN_TAR_GZ} \
	${BAD_EXT_DIR}/${CANDC_POS_MODEL_TAR_GZ} \
	${BAD_EXT_DIR}/${CANDC_SUPER_MODEL_TAR_GZ}

### Links and information on software with liberal licensing
# Charniak-Johnson with the McClosky BioNLP model
MCCCJ_VERSION=August\'06
MCCCJ_SRC_TAR_GZ=reranking-parserAug06.tar.gz
MCCCJ_SRC_URL=ftp://ftp.cs.brown.edu/pub/nlparser/${MCCCJ_SRC_TAR_GZ}
MCCCJ_SRC_DIR=${EXT_DIR}/reranking-parser
MCCCJ_MODEL_TAR_GZ=bioparsingmodel-rel1.tar.gz
MCCCJ_MODEL_DIR=${EXT_DIR}/biomodel
MCCCJ_MODEL_URL=http://bllip.cs.brown.edu/download/${MCCCJ_MODEL_TAR_GZ}
# The current Charniak-Johnson release won't compile with newer GCC, patch it
MCCCJ_PATCH=${PATCH_DIR}/parseIt.C.patch

# Berkeley parser
BERKELEY_VERSION=September\'09
BERKELEY_JAR=berkeleyParser.jar
BERKELEY_JAR_PATH=${GOOD_EXT_DIR}/${BERKELEY_JAR}
BERKELEY_JAR_URL=\
http://berkeleyparser.googlecode.com/files/${BERKELEY_JAR}
BERKELEY_GRAMMAR=eng_sm6.gr
BERKELEY_GRAMMAR_PATH=${GOOD_EXT_DIR}/${BERKELEY_GRAMMAR}
BERKELEY_GRAMMAR_URL=\
http://berkeleyparser.googlecode.com/files/${BERKELEY_GRAMMAR}

# Stanford parser
STANFORD_VERSION:=1.6.5
STANFORD_TAR_GZ:=stanford-parser-2010-11-30.tgz
STANFORD_DIR:=${EXT_DIR}/${shell basename ${STANFORD_TAR_GZ} .tgz}
STANFORD_JAR:=${STANFORD_DIR}/stanford-parser.jar
STANFORD_GRAMMAR:=${STANFORD_DIR}/englishFactored.ser.gz
STANFORD_DOWNLOAD_URL:=http://nlp.stanford.edu/software/${STANFORD_TAR_GZ}

# Genia dependence parser
GDEP_VERSION:=beta2
GDEP_TAR_GZ:=gdep-${GDEP_VERSION}.tgz
GDEP_DIR:=${EXT_DIR}/${shell basename ${GDEP_TAR_GZ} .tgz}
GDEP_URL:=http://people.ict.usc.edu/~sagae/parser/gdep/${GDEP_TAR_GZ}

# Genia Sentence Splitter
GENIASS_VERSION=1.00
GENIASS_TAR_GZ=geniass-${GENIASS_VERSION}.tar.gz
GENIASS_DIR=${EXT_DIR}/geniass
GENIASS_SH=${GENIASS_DIR}/run_geniass.sh
GENIASS_URL=\
http://www-tsujii.is.s.u-tokyo.ac.jp/~y-matsu/geniass/${GENIASS_TAR_GZ}
# Postprocessing script to fix obvious splitting errors
GENIASS_POSTPROC=${TOOLS_DIR}/geniass-postproc.pl

# Lund Institute of Technology (LTH) Constituent-to-Dependency Conversion Tool
LTHCDCT_VERSION=2008-08-07
LTHCDCT_JAR=pennconverter.jar
LTHCDCT_JAR_PATH=${GOOD_EXT_DIR}/${LTHCDCT_JAR}
LTHCDCT_URL=\
http://fileadmin.cs.lth.se/nlp/software/pennconverter/${LTHCDCT_JAR}

EXTERNAL_GOOD=${GOOD_EXT_DIR}/${MCCCJ_SRC_TAR_GZ} \
	${GOOD_EXT_DIR}/${MCCCJ_MODEL_TAR_GZ}

EXTERNAL_GOOD_DIRS=${MCCCJ_SRC_DIR} ${MCCCJ_MODEL_DIR} \
	${BERKELEY_JAR_PATH} ${BERKELEY_GRAMMAR_PATH} ${GENIASS_SH}

### From here on we use our declarations to accomplish things

.PHONY: release
release: repack checksum

# Re-pack our internal format to emulate BioNLP'09 ST, will fail for new data
.PHONY: repack
repack: internal | ${RELEASE_DIR}
	tools/repack.py ${OUTPUT_DIR} ${RELEASE_DIR}

# Internal parcing format, this target should work for pretty much any input
.PHONY: internal
internal: ss tok enju stanford berkeley candc mcccj gdep

### Archive targets
define archive-target
$1: $2 $3 $4 $5 $6 $7 $8 $9 | ${OUTPUT_DIR}
	rm -f $$@.tmp
	tar -c -f $$@.tmp --files-from=/dev/null
	tar -C ${WRK_DATA_DIR} -u -f $$@.tmp ${subst ${WRK_DATA_DIR}/,, $2}
	tar -C ${WRK_DATA_DIR} -u -f $$@.tmp ${subst ${WRK_DATA_DIR}/,, $3}
	tar -C ${WRK_DATA_DIR} -u -f $$@.tmp ${subst ${WRK_DATA_DIR}/,, $4}
	tar -C ${WRK_DATA_DIR} -u -f $$@.tmp ${subst ${WRK_DATA_DIR}/,, $5}
	tar -C ${WRK_DATA_DIR} -u -f $$@.tmp ${subst ${WRK_DATA_DIR}/,, $6}
	gzip -c $$@.tmp > $$@
	rm -f $$@.tmp

ARCHIVE_NAMES+=$1
ARCHIVE_NAMES:=$${sort $${ARCHIVE_NAMES}}
endef
ARCHIVE_NAMES:=
# Archive containing GeniaSS processed data
${foreach ARCHIVE, ${ARCHIVES}, \
	${eval ${call archive-target, \
		${${ARCHIVE}_${SS_ARCHIVE_PRE}}, ${${ARCHIVE}_${SS_FILES_PRE}}} \
	} \
}

# Checksums for the archives
#XXX: CHECKSUM
#XXX: Extract the command
.PHONY: checksum
checksum: ${RELEASE_DIR}/CHECKSUM.MD5 ${RELEASE_DIR}/CHECKSUM.SHA256

${RELEASE_DIR}/CHECKSUM.MD5: repack | ${RELEASE_DIR}
	cd ${RELEASE_DIR} && \
		rm -f CHECKSUM.MD5 && \
		find . -name '*.tar.gz' \
		| xargs -n 1 -r basename \
		| xargs md5sum \
		> CHECKSUM.MD5

${RELEASE_DIR}/CHECKSUM.SHA256: repack | ${RELEASE_DIR}
	cd ${RELEASE_DIR} && \
		rm -f CHECKSUM.SHA256 && \
		find . -name '*.tar.gz' \
		| xargs -n 1 -r basename \
		| xargs sha256sum \
		> CHECKSUM.SHA256

# Sentence split target
.PHONY: ss
ss: ${foreach ARCHIVE, ${ARCHIVES}, ${${ARCHIVE}_${SS_ARCHIVE_PRE}}}

# Archive containing tokenised data
${foreach ARCHIVE, ${ARCHIVES}, \
	${eval ${call archive-target, \
		${${ARCHIVE}_${TOK_ARCHIVE_PRE}}, ${${ARCHIVE}_${TOK_FILES_PRE}}} \
	} \
}

# Tokenised target
.PHONY: tok
tok: ${foreach ARCHIVE, ${ARCHIVES}, ${${ARCHIVE}_${TOK_ARCHIVE_PRE}}}

# Archive for data processed by Enju
${foreach ARCHIVE, ${ARCHIVES}, \
	${eval ${call archive-target, \
		${${ARCHIVE}_${ENJU_ARCHIVE_PRE}}, \
		${${ARCHIVE}_${ENJU_FILES_PRE}}, \
		${${ARCHIVE}_${ENJU_PTB_FILES_PRE}}, \
		${${ARCHIVE}_${ENJU_BASIC_SD_FILES_PRE}}, \
		${${ARCHIVE}_${ENJU_CCPROC_SD_FILES_PRE}}, \
		${${ARCHIVE}_${ENJU_LTHCDCT_FILES_PRE}} \
		} \
	} \
}

# Enju target
.PHONY: enju
enju: ${foreach ARCHIVE, ${ARCHIVES}, ${${ARCHIVE}_${ENJU_ARCHIVE_PRE}}}

# Archive for data processed by the Stanford parser
${foreach ARCHIVE, ${ARCHIVES}, \
	${eval ${call archive-target, \
		${${ARCHIVE}_${STANFORD_ARCHIVE_PRE}}, \
		${${ARCHIVE}_${STANFORD_FILES_PRE}}, \
		${${ARCHIVE}_${STANFORD_BASIC_SD_FILES_PRE}}, \
		${${ARCHIVE}_${STANFORD_CCPROC_SD_FILES_PRE}}, \
		${${ARCHIVE}_${STANFORD_LTHCDCT_FILES_PRE}} \
		} \
	} \
}

# Stanford target
.PHONY: stanford
stanford: ${foreach ARCHIVE, ${ARCHIVES}, \
	${${ARCHIVE}_${STANFORD_ARCHIVE_PRE}}}

# Archive for data processed by the Berkley parser
${foreach ARCHIVE, ${ARCHIVES}, \
	${eval ${call archive-target, \
		${${ARCHIVE}_${BERKELEY_ARCHIVE_PRE}}, \
		${${ARCHIVE}_${BERKELEY_FILES_PRE}}, \
		${${ARCHIVE}_${BERKELEY_BASIC_SD_FILES_PRE}}, \
		${${ARCHIVE}_${BERKELEY_CCPROC_SD_FILES_PRE}}, \
		${${ARCHIVE}_${BERKELEY_LTHCDCT_FILES_PRE}} \
		} \
	} \
}

# Berkeley target
.PHONY: berkeley
berkeley: ${foreach ARCHIVE, ${ARCHIVES}, ${${ARCHIVE}_${BERKELEY_ARCHIVE_PRE}}}

# Archive for data processed by the C&C parser
${foreach ARCHIVE, ${ARCHIVES}, \
	${eval ${call archive-target, \
		${${ARCHIVE}_${CANDC_ARCHIVE_PRE}}, \
		${${ARCHIVE}_${CANDC_FILES_PRE}}, \
		${${ARCHIVE}_${CANDC_BASIC_SD_FILES_PRE}} \
		} \
	} \
}

# C&C CCG target
.PHONY: candc
candc: ${foreach ARCHIVE, ${ARCHIVES}, ${${ARCHIVE}_${CANDC_ARCHIVE_PRE}}}

# Archive for data processed by the Charniak-Johnson parser
${foreach ARCHIVE, ${ARCHIVES}, \
	${eval ${call archive-target, \
		${${ARCHIVE}_${MCCCJ_ARCHIVE_PRE}}, \
		${${ARCHIVE}_${MCCCJ_FILES_PRE}}, \
		${${ARCHIVE}_${MCCCJ_BASIC_SD_FILES_PRE}}, \
		${${ARCHIVE}_${MCCCJ_CCPROC_SD_FILES_PRE}}, \
		${${ARCHIVE}_${MCCCJ_LTHCDCT_FILES_PRE}} \
		} \
	} \
}

# McClosky Charniak Johnsson target
.PHONY: mcccj
mcccj: ${foreach ARCHIVE, ${ARCHIVES}, ${${ARCHIVE}_${MCCCJ_ARCHIVE_PRE}}}

# Archive for data processed by GDep
${foreach ARCHIVE, ${ARCHIVES}, \
	${eval ${call archive-target, \
		${${ARCHIVE}_${GDEP_ARCHIVE_PRE}}, \
		${${ARCHIVE}_${GDEP_FILES_PRE}}} \
	} \
}

# GDep target
.PHONY: gdep
gdep: ${foreach ARCHIVE, ${ARCHIVES}, ${${ARCHIVE}_${GDEP_ARCHIVE_PRE}}}

### Targets for the dirs
${EXT_DIR}:
	mkdir -p ${EXT_DIR}

${GOOD_EXT_DIR}:
	mkdir -p ${GOOD_EXT_DIR}

${BAD_EXT_DIR}:
	mkdir -p ${BAD_EXT_DIR}

${WRK_DIR}:
	mkdir -p ${WRK_DIR}

${WRK_DATA_DIR}:
	mkdir -p ${WRK_DATA_DIR}

${OUTPUT_DIR}:
	mkdir -p ${OUTPUT_DIR}

${RELEASE_DIR}:
	mkdir -p ${RELEASE_DIR}

### Targets for the "bad" software
${EXTERNAL_BAD}: | ${BAD_EXT_DIR}
	@echo "$${FETCH_WARNING}"
	@exit -1

${ENJU_DIR}: ${EXT_DIR} ${EXTERNAL_BAD}
	tar xfz ${BAD_EXT_DIR}/${ENJU_TAR_GZ} -C ${EXT_DIR} -m

${CANDC_DIR}: ${BAD_EXT_DIR}/${CANDC_BIN_TAR_GZ} | ${EXT_DIR}
	tar xfz ${BAD_EXT_DIR}/${CANDC_BIN_TAR_GZ} -C ${EXT_DIR} -m

${CANDC_MODELS_DIR}: ${BAD_EXT_DIR}/${CANDC_MODELS_TAR_GZ} | ${EXT_DIR}
	tar xfz ${BAD_EXT_DIR}/${CANDC_MODELS_TAR_GZ} -C ${EXT_DIR} -m

${CANDC_POS_MODEL_DIR}: ${BAD_EXT_DIR}/${CANDC_POS_MODEL_TAR_GZ} | ${EXT_DIR}
	tar xfz ${BAD_EXT_DIR}/${CANDC_POS_MODEL_TAR_GZ} -C ${EXT_DIR} -m

${CANDC_SUPER_MODEL_DIR}: ${BAD_EXT_DIR}/${CANDC_POS_MODEL_TAR_GZ} | ${EXT_DIR}
	tar xfz ${BAD_EXT_DIR}/${CANDC_SUPER_MODEL_TAR_GZ} -C ${EXT_DIR} -m

#### Targets for the "good" software
${CANDC_GRS2SD_PATH}: | ${GOOD_EXT_DIR}
	cd ${GOOD_EXT_DIR} && ${FETCH_CMD} ${CANDC_DOWNLOAD_GRS2SD_URL}
	chmod +x ${CANDC_GRS2SD_PATH}

${CANDC_MARKEDUP_SD_PATH}: | ${GOOD_EXT_DIR}
	cd ${GOOD_EXT_DIR} && ${FETCH_CMD} ${CANDC_DOWNLOAD_MARKEDUP_SD_URL}

${GOOD_EXT_DIR}/${MCCCJ_SRC_TAR_GZ}: | ${GOOD_EXT_DIR}
	cd ${GOOD_EXT_DIR} && ${FETCH_CMD} ${MCCCJ_SRC_URL}

${MCCCJ_SRC_DIR}: ${GOOD_EXT_DIR}/${MCCCJ_SRC_TAR_GZ} | ${EXT_DIR}
	tar xfz ${GOOD_EXT_DIR}/${MCCCJ_SRC_TAR_GZ} -C ${EXT_DIR} -m
	patch ${MCCCJ_SRC_DIR}/first-stage/PARSE/parseIt.C ${MCCCJ_PATCH}
	cd ${MCCCJ_SRC_DIR} && make

${GOOD_EXT_DIR}/${MCCCJ_MODEL_TAR_GZ}: | ${GOOD_EXT_DIR}
	cd ${GOOD_EXT_DIR} && ${FETCH_CMD} ${MCCCJ_MODEL_URL}

${MCCCJ_MODEL_DIR}: ${GOOD_EXT_DIR}/${MCCCJ_MODEL_TAR_GZ} | ${EXT_DIR}
	tar xfz ${GOOD_EXT_DIR}/${MCCCJ_MODEL_TAR_GZ} -C ${EXT_DIR} -m

${BERKELEY_JAR_PATH}: | ${GOOD_EXT_DIR}
	cd ${GOOD_EXT_DIR} && ${FETCH_CMD} ${BERKELEY_JAR_URL}

${BERKELEY_GRAMMAR_PATH}: | ${GOOD_EXT_DIR}
	cd ${GOOD_EXT_DIR} && ${FETCH_CMD} ${BERKELEY_GRAMMAR_URL}

${GOOD_EXT_DIR}/${GENIASS_TAR_GZ}: | ${GOOD_EXT_DIR}
	cd ${GOOD_EXT_DIR} && ${FETCH_CMD} ${GENIASS_URL}

${LTHCDCT_JAR_PATH}: | ${GOOD_EXT_DIR}
	cd ${GOOD_EXT_DIR} && ${FETCH_CMD} ${LTHCDCT_URL}

${GOOD_EXT_DIR}/${STANFORD_TAR_GZ}: | ${GOOD_EXT_DIR}
	cd ${GOOD_EXT_DIR} && ${FETCH_CMD} ${STANFORD_DOWNLOAD_URL}

${STANFORD_JAR}: ${GOOD_EXT_DIR}/${STANFORD_TAR_GZ}
	tar xfz ${GOOD_EXT_DIR}/${STANFORD_TAR_GZ} -C ${EXT_DIR} -m

${GOOD_EXT_DIR}/${GDEP_TAR_GZ}: | ${GOOD_EXT_DIR}
	cd ${GOOD_EXT_DIR} && ${FETCH_CMD} ${GDEP_URL}

${GDEP_DIR}: ${GOOD_EXT_DIR}/${GDEP_TAR_GZ} | ${EXT_DIR}
	tar xfz ${GOOD_EXT_DIR}/${GDEP_TAR_GZ} -C ${EXT_DIR} -m
	cd ${GDEP_DIR} && make

${GENIASS_SH}: ${GOOD_EXT_DIR}/${GENIASS_TAR_GZ} | ${EXT_DIR}
	tar xfz ${GOOD_EXT_DIR}/${GENIASS_TAR_GZ} -C ${EXT_DIR} -m
	cd ${GENIASS_DIR} && make

### Preprocessing targets
# Text-file targets
define textfile-target
$1: $2 | ${WRK_DATA_DIR}
	tar -C ${WRK_DATA_DIR} -x -z -f $$< $${subst ${WRK_DATA_DIR}/,, $$@} -m
	touch $$@
endef

${foreach ARCHIVE, ${ARCHIVES}, \
	${foreach TXT_FILE, ${${ARCHIVE}_${TXT_FILES_PRE}}, \
		${eval ${call textfile-target, \
			${TXT_FILE}, ${${ARCHIVE}_${ARCH_PATH_PRE}}}} \
	} \
}

# GeniaSS targets
define geniass-target
$1.${SS_SUFF}: $1 | ${GENIASS_SH}
	rm -f $$@.tmp
	cd ${GENIASS_DIR} && ${PWD}/${GENIASS_SH} ${PWD}/$$< ${PWD}/$$@.tmp
	${GENIASS_POSTPROC} $$@.tmp > $$@
	rm -f $$@.tmp
endef

${foreach ARCHIVE, ${ARCHIVES}, \
	${foreach TXT_FILE, ${${ARCHIVE}_${TXT_FILES_PRE}}, \
		${eval ${call geniass-target, ${TXT_FILE}}} \
	} \
}

# Generate tokenisation targets
define tokenise-target
$1.${TOK_SUFF}: $1
	cat $$< | ${TOKENISE_CMD} > $$@
endef

${foreach ARCHIVE, ${ARCHIVES}, \
	${foreach SS_FILE, ${${ARCHIVE}_${SS_FILES_PRE}}, \
		${eval ${call tokenise-target, ${SS_FILE}}} \
	} \
}

# Generate Enju targets
define enju-target
$1.${ENJU_SUFF}: $1 | ${ENJU_DIR}
	cat $$< | ${ENJU_DIR}/enju -A -genia -xml \
		-t "${ENJU_DIR}/bin/stepp \
		-e -p -m ${ENJU_DIR}/share/stepp/models_medline" \
		> $$@
endef

${foreach ARCHIVE, ${ARCHIVES}, \
	${foreach TOK_FILE, ${${ARCHIVE}_${TOK_FILES_PRE}}, \
		${eval ${call enju-target, ${TOK_FILE}}} \
	} \
}

# The replacement of UNK (unknown) with NP is motivated by the fact that
# further conversions can't handle unknowns and NP is the most frequent
# PoS-tag and thus a likely candidate for any known tag (although this
# assumption is rather naive).
# Enju is actually pretty nice when it fails to parse and the conversion
# script sets the POS-tag to "error" if it detects a failure. We swap these
# out for failed parses.
ENJU_ERROR_DROP_IN:=(TOP (S (NP (NNP Parse)) (VP (VBD failed))))
define enju-ptb-target
$1.${PTB_SUFF}: $1
	cat $$< | ${ENJU_DIR}/share/enju2ptb/convert -genia \
		| ${TOOLS_DIR}/postenju2ptb.prl \
		| sed \
		-e "s|\\\\/|/|g" \
		-e "s|(UNK |(NP |g" \
		-e 's|^.*(error.*$$$$|${ENJU_ERROR_DROP_IN}|g' \
		> $$@
endef

${foreach ARCHIVE, ${ARCHIVES}, \
	${foreach ENJU_FILE, ${${ARCHIVE}_${ENJU_FILES_PRE}}, \
		${eval ${call enju-ptb-target, ${ENJU_FILE}}} \
	} \
}

# Generate Stanford parser targets
# When Stanford fails it prints the following, we can't have that laying
# around. So switch it into failed parses. Two lines are printed, delete
# the second, replace the first.
STANFORD_FAILED_FIRST=Sentence skipped:[ ]\+no PCFG fallback\.
STANFORD_FAILED_SECOND=SENTENCE_SKIPPED_OR_UNPARSABLE
STANFORD_FAILED_DROPIN=(ROOT (S (NP (NN Parse)) (VP (VBD failed)) (. !)))
define stanford-target
$1.${STANFORD_SUFF}: $1 ${STANFORD_JAR} ${STANFORD_GRAMMAR}
	java -mx4096m -cp ${STANFORD_JAR} \
		edu.stanford.nlp.parser.lexparser.LexicalizedParser \
		-sentences newline -tokenized \
		-escaper edu.stanford.nlp.process.PTBEscapingProcessor \
		-retainTmpSubcategories -outputFormat oneline \
		${STANFORD_GRAMMAR} $$< \
		| sed -e "s|${STANFORD_FAILED_FIRST}|${STANFORD_FAILED_DROPIN}|g" \
		| sed "/${STANFORD_FAILED_SECOND}/d" \
		> $$@
endef

${foreach ARCHIVE, ${ARCHIVES}, \
	${foreach TOK_FILE, ${${ARCHIVE}_${TOK_FILES_PRE}}, \
		${eval ${call stanford-target, ${TOK_FILE}}} \
	} \
}

# Generate Berkley parser targets
define berkeley-target
$1.${PTB_TOK_SUFF}.${BERKELEY_SUFF}: $1 ${BERKELEY_JAR_PATH} ${BERKELEY_GRAMMAR_PATH}
	cat $$< | sed '/^$$$$/d' | ${TOKENISE_CMD} -ptb \
		| java -mx4096m -jar ${BERKELEY_JAR_PATH} \
		-gr ${BERKELEY_GRAMMAR_PATH} \
		| sed -e 's|^(())$$$$|( (S (NP (NNP Parse)) (VP (VBD failed)) (. !)) )|g' \
		> $$@
endef

${foreach ARCHIVE, ${ARCHIVES}, \
	${foreach SS_FILE, ${${ARCHIVE}_${SS_FILES_PRE}}, \
		${eval ${call berkeley-target, ${SS_FILE}}} \
	} \
}

# Generate C&C parser targets
# We convert sentences that fail to parse to save the parser.
CANDC_PFAIL_1=The genes were designated tap1 , flgD , flgE , orf4 , motA , motB , fliL , fliM , fliY , orf10 and fliP \.
CANDC_PFAIL_2=The sigma W regulon includes a penicillin binding protein ( PBP4\* ) and a co-transcribed amino acid racemase ( RacX ) , homologues of signal peptide peptidase ( YteI ) , flotillin ( YuaG ) , ABC transporters ( YknXYZ ) , non-haem bromoperoxidase ( YdjP ) , epoxide hydrolase ( YfhM ) and three small peptides with structural similarities to bacteriocin precursor polypeptides \.
CANDC_PFAIL_3=The structural gene ( sigK ) for the mother-cell RNA polymerase sigma-factor sigma K in Bacillus subtilis is a composite of two truncated genes , named spoIVCB and spoIIIC , which are brought together by site-specific recombination during sporulation \.
CANDC_CANT_PARSE_DROPIN=Parse failed!
define candc-target
$1.${CANDC_SUFF}: $1 ${CANDC_MARKEDUP_SD_PATH} | ${CANDC_DIR} \
	${CANDC_MODELS_DIR} ${CANDC_POS_MODEL_DIR} ${CANDC_SUPER_MODEL_DIR}
	cat $$< \
		| sed \
		-e 's|${CANDC_PFAIL_1}|${CANDC_CANT_PARSE_DROPIN}|g' \
		-e 's|${CANDC_PFAIL_2}|${CANDC_CANT_PARSE_DROPIN}|g' \
		-e 's|${CANDC_PFAIL_3}|${CANDC_CANT_PARSE_DROPIN}|g' \
		| ${CANDC_DIR}/bin/pos --model ${CANDC_POS_MODEL_DIR} \
		| ${CANDC_DIR}/bin/parser \
			--printer grs \
			--model ${CANDC_MODELS_DIR}/parser \
			--super ${CANDC_SUPER_MODEL_DIR} \
			--parser-markedup ${CANDC_MARKEDUP_SD_PATH} \
		> $$@
endef

${foreach ARCHIVE, ${ARCHIVES}, \
	${foreach TOK_FILE, ${${ARCHIVE}_${TOK_FILES_PRE}}, \
		${eval ${call candc-target, ${TOK_FILE}}} \
	} \
}

define candc-basic-sd-target
$1.${BASIC_SD_SUFF}: $1 ${CANDC_GRS2SD_PATH}
	${CANDC_GRS2SD_PATH} --ccgbank $$< \
		| ${TOOLS_DIR}/sd_format.pl \
		> $$@
endef

${foreach ARCHIVE, ${ARCHIVES}, \
	${foreach CANDC_FILE, ${${ARCHIVE}_${CANDC_FILES_PRE}}, \
		${eval ${call candc-basic-sd-target, ${CANDC_FILE}}} \
	} \
}

# Generate McClosky Charniak-Johnson targets
# Charniak-Johnson is a bit special requires each sentence to be on the format:
# "<s> ${SENTENCE} </s>" Do note the space preceeding the opening tag and
# the space preceeding the closing tag. Without these you won't get any output.
# Nor is any error or warning invoked, so much for XML.
# Note the -mccc flag to correct some errors in McClosky's model, may change
# for later releases.
# Below is a horrific hack, replacing two lines which crashes the parser with
# output produced by the Stanford Parser. This will break depending on
# the sentence splitting and tokenisation.
PMID_8632999_BAD_LINE=Recently , a multivalent guanylhydrazone -LRB- CNI-1493 -RRB- developed as an inhibitor of macrophage activation was shown to suppress TNF production and protect against tissue inflammation and endotoxin lethality -LSB- Bianchi , M\. , Ulrich , P\. , Bloom , O\. , Meistrell , M\. , Zimmerman , G\.A\. , Schmidtmayerova , H\. , Bukrinsky , M\. , Donnelley , T\. , Bucala , R\. , Sherry , B\. , Manogue , K\.R\. , Tortolani , A\.J\. , Cerami , A\. & Tracey , K\.J\.-LRB-1995-RRB- Mol\.Med\.1 , 254-266 , and Bianchi , M\. , Bloom , O\. , Raabe , T\. , Cohen , P\. S\. , Chesney , J\. , Sherry , B\. , Schmidtmayerova , H\. , Zhang , X\. , Bukrinsky , M\. , Ulrich , P\. , Cerami , A\. & Tracey , J\.-LRB-1996-RRB- J\.Exp\.Med\. , in press -RSB- \.
PMID_7559346_BAD_LINE=\.
PMID_8632999_BAD_LINE_DROP_IN=(S1 (S (NP (NN Parse)) (VP (VBD failed)) (. !)))
PMID_7559346_BAD_LINE_DROP_IN=(S1 (S (NP (NN Parse)) (VP (VBD failed)) (. !)))
# Remember a dot after the dummy line, we then replace the line after the parse
DUMMY=THIS_IS_NOT_A_SENTENCE
DUMMY_P_BEF_NUM:=(S1 (S (NP (NP (NN ${DUMMY}
DUMMY_P_AFT_NUM=)) (\. \.))))
define mcccj-target
$1.${MCCCJ_TOK_SUFF}.${MCCCJ_SUFF}: $1 | ${MCCCJ_SRC_DIR} ${MCCCJ_MODEL_DIR}
	-rm -f $$@.tmp
	cat $$< | ${TOKENISE_CMD} | sed '/^$$$$/d' > $$@.tmp
	cat $$< | ${TOKENISE_CMD} -mccc \
		| sed '/^$$$$/d' \
		| sed \
		-e "s|^${PMID_8632999_BAD_LINE}$$$$|${DUMMY}_0 \.|g" \
		-e "s|^${PMID_7559346_BAD_LINE}$$$$|${DUMMY}_1 \.|g" \
		| sed -e 's|^|<s> |g' -e 's|$$$$| </s>|g' \
		| ${MCCCJ_SRC_DIR}/first-stage/PARSE/parseIt -K -l399 -N50 \
		${MCCCJ_MODEL_DIR}/parser/ \
		| ${MCCCJ_SRC_DIR}/second-stage/programs/features/best-parses \
		-l ${MCCCJ_MODEL_DIR}/reranker/features.gz \
		${MCCCJ_MODEL_DIR}/reranker/weights.gz \
		| sed \
		-e "s|^${DUMMY_P_BEF_NUM}_0${DUMMY_P_AFT_NUM}$$$$|${PMID_8632999_BAD_LINE_DROP_IN}|g" \
		-e "s|^${DUMMY_P_BEF_NUM}_1${DUMMY_P_AFT_NUM}$$$$|${PMID_7559346_BAD_LINE_DROP_IN}|g" \
		-e "s|(ROOT |(S1 |g" \
		| ${TOOLS_DIR}/restore-doublequotes.py $$@.tmp > $$@
	-rm -f $$@.tmp
endef

${foreach ARCHIVE, ${ARCHIVES}, \
	${foreach SS_FILE, ${${ARCHIVE}_${SS_FILES_PRE}}, \
		${eval ${call mcccj-target, ${SS_FILE}}} \
	} \
}

# Generate GDep targets
define gdep-target
$1.${GDEP_SUFF}: $1 ${GDEP_DIR}
	cd ${GDEP_DIR} && cat ${PWD}/$$< | ./gdep -nt > ${PWD}/$$@
endef

${foreach ARCHIVE, ${ARCHIVES}, \
	${foreach TOK_FILE, ${${ARCHIVE}_${TOK_FILES_PRE}}, \
		${eval ${call gdep-target, ${TOK_FILE}}} \
	} \
}

ENJU_NONCONV=(TOP (S (NP (NP (NNP Food) (CC and) (NNP Drug) (NNP Administration) (PP (IN for) (NP (NN fever) (NN blister))) (CC and))) (VP (VP (VBD cold) (NP (NN sore) (NN treatment))) (, ,) (CC but) (VP (VBZ is) (VP (VBN considered) (S (VP (TO to) (VP (VB be) (ADJP (ADJP (JJ safe)) (CC and) (ADJP (JJ effective)) (PP (IN as) (NP (DT an) (JJ external) (JJ analgesic) (NN counterirritant))))))))))))
ENJU_NONCONV_DROPIN=(TOP (S (NP (NNP Conversion)) (VP (VBD failed))))

# The inititial sed conversion of the root node name is due to inconsistencies
# between Berkley and Enju output in relation to the Stanford Tools.
define stanford-basic-dependency-target
$1.${BASIC_SD_SUFF}: $1 ${STANFORD_JAR}
	rm -f $$@.tmp
	cat $$< \
		| sed \
		-e "s|${ENJU_NONCONV}|${ENJU_NONCONV_DROPIN}|g" \
		-e 's|(TOP |(ROOT |g' \
		> $$@.tmp
	java -mx4096m -cp ${STANFORD_JAR} \
		edu.stanford.nlp.trees.EnglishGrammaticalStructure \
		-basic -keepPunct -treeFile $$@.tmp > $$@
	rm -f $$@.tmp
endef

${foreach ARCHIVE, ${ARCHIVES}, \
	${foreach ENJU_PTB_FILE, ${${ARCHIVE}_${ENJU_PTB_FILES_PRE}}, \
		${eval ${call stanford-basic-dependency-target, ${ENJU_PTB_FILE}}} \
	} \
}
${foreach ARCHIVE, ${ARCHIVES}, \
	${foreach MCCCJ_FILE, ${${ARCHIVE}_${MCCCJ_FILES_PRE}}, \
		${eval ${call stanford-basic-dependency-target, ${MCCCJ_FILE}}} \
	} \
}
${foreach ARCHIVE, ${ARCHIVES}, \
	${foreach BERKELEY_FILE, ${${ARCHIVE}_${BERKELEY_FILES_PRE}}, \
		${eval ${call stanford-basic-dependency-target, ${BERKELEY_FILE}}} \
	} \
}
${foreach ARCHIVE, ${ARCHIVES}, \
	${foreach STANFORD_FILE, ${${ARCHIVE}_${STANFORD_FILES_PRE}}, \
		${eval ${call stanford-basic-dependency-target, ${STANFORD_FILE}}} \
	} \
}

define stanford-ccproc-dependency-target
$1.${CCPROC_SD_SUFF}: $1 ${STANFORD_JAR}
	rm -f $$@.tmp
	cat $$< | sed -e 's|(TOP |(ROOT |g' > $$@.tmp
	java -mx4096m -cp ${STANFORD_JAR} \
		edu.stanford.nlp.trees.EnglishGrammaticalStructure \
		-CCprocessed -keepPunct -treeFile $$@.tmp > $$@
	rm -f $$@.tmp
endef

${foreach ARCHIVE, ${ARCHIVES}, \
	${foreach ENJU_PTB_FILE, ${${ARCHIVE}_${ENJU_PTB_FILES_PRE}}, \
		${eval ${call stanford-ccproc-dependency-target, ${ENJU_PTB_FILE}}} \
	} \
}
${foreach ARCHIVE, ${ARCHIVES}, \
	${foreach MCCCJ_FILE, ${${ARCHIVE}_${MCCCJ_FILES_PRE}}, \
		${eval ${call stanford-ccproc-dependency-target, ${MCCCJ_FILE}}} \
	} \
}
${foreach ARCHIVE, ${ARCHIVES}, \
	${foreach BERKELEY_FILE, ${${ARCHIVE}_${BERKELEY_FILES_PRE}}, \
		${eval ${call stanford-ccproc-dependency-target, ${BERKELEY_FILE}}} \
	} \
}
${foreach ARCHIVE, ${ARCHIVES}, \
	${foreach STANFORD_FILE, ${${ARCHIVE}_${STANFORD_FILES_PRE}}, \
		${eval ${call stanford-ccproc-dependency-target, ${STANFORD_FILE}}} \
	} \
}

define lthcdct-target
$1.${LTHCDCT_SUFF}: $1 ${LTHCDCT_JAR_PATH}
	cat $$< \
		| sed \
		-e 's|(ROOT |(TOP |g' \
		-e 's|\\\\||g' \
		-f ${TOOLS_DIR}/conll_error_sentences.ptb.sed \
		| java -mx4096m -jar ${LTHCDCT_JAR_PATH} -splitSlash=false -raw \
		| perl -pi -e 's/^(\d+\s+)\`\`/$$$$1"/; s/^(\d+\s+)'\'\''/$$$$1"/; s/\\\//\//g; s/-LRB-/\(/g; s/-RRB-/\)/g;s/-LSB-/\[/g; s/-RSB-/\]/g' \
		> $$@
endef

${foreach ARCHIVE, ${ARCHIVES}, \
	${foreach ENJU_PTB_FILE, ${${ARCHIVE}_${ENJU_PTB_FILES_PRE}}, \
		${eval ${call lthcdct-target, ${ENJU_PTB_FILE}}} \
	} \
}
${foreach ARCHIVE, ${ARCHIVES}, \
	${foreach MCCCJ_FILE, ${${ARCHIVE}_${MCCCJ_FILES_PRE}}, \
		${eval ${call lthcdct-target, ${MCCCJ_FILE}}} \
	} \
}
${foreach ARCHIVE, ${ARCHIVES}, \
	${foreach BERKELEY_FILE, ${${ARCHIVE}_${BERKELEY_FILES_PRE}}, \
		${eval ${call lthcdct-target, ${BERKELEY_FILE}}} \
	} \
}
${foreach ARCHIVE, ${ARCHIVES}, \
	${foreach STANFORD_FILE, ${${ARCHIVE}_${STANFORD_FILES_PRE}}, \
		${eval ${call lthcdct-target, ${STANFORD_FILE}}} \
	} \
}

.PHONY: clean
clean:
	rm -rf wrk build
