# Generic AArch64:
#     make FFLAGS="-mcpu=generic -I$(ARMPL_DIR)/include " \
           FLINKFLAGS="-mcpu=generic" CLINKFLAGS="-mcpu=generic" \
           CFLAGS="-mcpu=generic -I$(ARMPL_DIR)/include -std=c99"
# Neoverse-N1:
#     make FFLAGS="-mcpu=neoverse-n1 -I$(ARMPL_DIR)/include " \
           FLINKFLAGS="-mcpu=neoverse-n1" CLINKFLAGS="-mcpu=neoverse-n1 " \
           CFLAGS="-mcpu=neoverse-n1 -I$(ARMPL_DIR)/include -std=c99"
# ThunderX2:
#     make FFLAGS="-mcpu=thunderx2t99 -I$(ARMPL_DIR)/include " \
           FLINKFLAGS="-mcpu=thunderx2t99" CLINKFLAGS="-mcpu=thunderx2t99 " \
           CFLAGS="-mcpu=thunderx2t99 -I$(ARMPL_DIR)/include -std=c99"

ARMPL_DIR= /home/fugelin/Tools/arm/armpl_21.0_gcc-10.2

ifeq ($(ARMPL_DIR),)
  $(error "ARMPL_DIR not set, try loading the appropriate module or explicitly exporting the variable")
endif

CC := gcc-10
CLINK ?= $(CC)
CFLAGS ?=  -I$(ARMPL_DIR)/include -mcpu=native -std=c11 -march=armv8-a+sve
CLINKFLAGS ?=  -mcpu=native
CLINKLIBS ?= -L$(ARMPL_DIR)/lib -larmpl_lp64 -lgfortran -lm -static

EXPORT_PATH ?= LD_LIBRARY_PATH=$(ARMPL_DIR)/lib:$(LD_LIBRARY_PATH)
RUNNER ?=

obj := o

.SUFFIXES: .c .$(obj) .exe .res .diff .expected

# Source code of C example programs
CSOURCE := armpl_dgemm_interleave_batch_c_example.c \
	dgesdd_c_example.c \
	dgetrf_c_example.c \
	spmm_c_example.c spadd_c_example.c spmv_c_example.c \

CEXE := $(CSOURCE:.c=.exe)

RESULTS := $(FSOURCE:.f90=.res) $(CSOURCE:.c=.res)

all: $(RESULTS) diffs

# Rule to compile/run a C example program and produce a .res file
.c.res:
	@echo ""
	@echo "Compiling program $*.c:"
	$(CC) -c $(CFLAGS) $*.c -o $*.$(obj)
	@echo "Linking program $*.exe:"
	$(CLINK) $(CLINKFLAGS) $*.$(obj) $(CLINKLIBS) -o $*.exe
	@echo "Running program $*.exe:"
	$(EXPORT_PATH) $(RUNNER) ./$*.exe > $*.res
#       Show the results
	@cat $@
#	Compare the results with the expected results
	@diff -w $@ $*.expected | cat > $*.diff
#       Delete the diff file if it is empty
	@if [ -s $*.diff ]; then \
	  echo "!!! $* has diffs !!!"; \
	else \
	  rm -f $*.diff; \
	fi

diffs: $(RESULTS)
	@(ndiff=`ls *.diff 2> /dev/null | wc -w | sed -e 's/ //g'` ; \
	  echo ""; \
	  if [ "$${ndiff}" = "0" ]; then \
	    echo "Testing: no example difference files were generated."; \
	    echo "Test passed OK"; \
	  else \
	    echo "Testing: $${ndiff} example difference files were generated:"; \
	    ls -l *.diff; \
	  fi)

clean:
	rm -f $(CEXE) \
	      $(CSOURCE:.c=.$(obj)) \
	      $(RESULTS) *.diff
