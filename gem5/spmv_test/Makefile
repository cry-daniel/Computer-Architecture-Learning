ARMPL_DIR= /home/fugelin/Tools/arm/armpl_21.0_gcc-10.2
GEM5_DIR=~/gem5

ifeq ($(ARMPL_DIR),)
  $(error "ARMPL_DIR not set, try loading the appropriate module or explicitly exporting the variable")
endif

CC := aarch64-linux-gnu-gcc-10 #gcc-7
CLINK ?= $(CC) -I $(ARMPL_DIR)/include
CFLAGS ?=  -I $(ARMPL_DIR)/include -std=c11 -march=armv8-a -I $(GEM5_DIR)/include
CFLAGS_SVE ?=  -I $(ARMPL_DIR)/include -std=c11 -march=armv8-a+sve -I $(GEM5_DIR)/include
CFLAGS_SIMD ?=  -I $(ARMPL_DIR)/include -std=c11 -march=armv8-a+simd -I $(GEM5_DIR)/include

EXPORT_PATH ?= LD_LIBRARY_PATH=$(ARMPL_DIR)/lib:$(LD_LIBRARY_PATH)
RUNNER ?=

obj := o

.SUFFIXES: .c .$(obj) .exe .res .diff .expected

# Source code of C example programs
CSOURCE := spmv_c_example.c 

CEXE := $(CSOURCE:.c=.exe)

RESULTS := $(CSOURCE:.c=.res)

all: $(RESULTS)

# Rule to compile/run a C example program and produce a .res file
.c.res:
	@echo ""
	@echo "Compiling program $*.c:"
	$(CC) -c $(CFLAGS) $*.c -o $*.$(obj)
	@echo "Linking program $*.exe:"
	$(CLINK) $(CLINKFLAGS) $*.$(obj) $(CLINKLIBS) -o $*.exe
	@echo ""
	@echo "Compiling program $*.c: (SVE)"
	$(CC) -c $(CFLAGS_SVE) $*.c -o $*.$(obj)
	@echo "Linking program $*.exe: (SVE)"
	$(CLINK) $(CLINKFLAGS) $*.$(obj) $(CLINKLIBS) -o $*_sve.exe
	@echo ""
	@echo "Compiling program $*.c: (simd)"
	$(CC) -c $(CFLAGS_SIMD) $*.c -o $*.$(obj)
	@echo "Linking program $*.exe: (simd)"
	$(CLINK) $(CLINKFLAGS) $*.$(obj) $(CLINKLIBS) -o $*_simd.exe
	@echo "Running program $*.exe:"
	$(EXPORT_PATH) $(RUNNER) ./$*.exe > $*.res
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
