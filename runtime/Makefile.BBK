# Disable all implicit Makefile rules
MAKEFLAGS += --no-builtin-rules
.SUFFIXES: ;

CXX ?= g++
PROTOC ?= protoc

VERBOSE ?= 1

DEPDIR ?= .deps
DEPFLAGS = -MT $@ -MMD -MP -MF $(DEPDIR)/$(@:.o=.d)
$(shell mkdir -p $(DEPDIR) >/dev/null)
$(shell mkdir -p $(DEPDIR)/bessport >/dev/null)
$(shell mkdir -p $(DEPDIR)/bessport/utils >/dev/null)
$(shell mkdir -p $(DEPDIR)/bessport/hooks >/dev/null)
$(shell mkdir -p $(DEPDIR)/bessport/kmod >/dev/null)
$(shell mkdir -p $(DEPDIR)/port >/dev/null)
$(shell mkdir -p $(DEPDIR)/samples > /dev/null)
$(shell mkdir -p $(DEPDIR)/rpc > /dev/null)
$(shell mkdir -p $(DEPDIR)/module > /dev/null)
$(shell mkdir -p $(DEPDIR)/actor > /dev/null)
$(shell mkdir -p $(DEPDIR)/actor/base > /dev/null)
$(shell mkdir -p $(DEPDIR)/nf/base > /dev/null)
$(shell mkdir -p $(DEPDIR)/nf/pktcounter > /dev/null)
$(shell mkdir -p $(DEPDIR)/nf/firewall > /dev/null)
$(shell mkdir -p $(DEPDIR)/nf/flowmonitor > /dev/null)
$(shell mkdir -p $(DEPDIR)/nf/httpparser > /dev/null)
$(shell mkdir -p $(DEPDIR)/reliable > /dev/null)
$(shell mkdir -p $(DEPDIR)/reliable/base > /dev/null)
$(shell mkdir -p $(DEPDIR)/samples/real_rpc_basic > /dev/null)
$(shell mkdir -p $(DEPDIR)/samples/migration > /dev/null)
$(shell mkdir -p $(DEPDIR)/samples/replication > /dev/null)
$(shell mkdir -p $(DEPDIR)/utils > /dev/null)

# e.g., 4.9.3 -> 40903
CXXVERSION := $(shell $(CXX) -dumpversion | sed -e 's/\.\([0-9][0-9]\)/\1/g' -e 's/\.\([0-9]\)/0\1/g' -e 's/^[0-9]\{3,4\}$$/&00/')

CXXVERSION_4_8_OR_HIGHER := $(shell expr $(CXXVERSION) \>= 40800)
ifeq "$(CXXVERSION_4_8_OR_HIGHER)" "0"
  $(error g++ 4.8 or higher is required)
endif

RTE_SDK ?= $(abspath ../deps/bess/deps/dpdk-16.07)
RTE_TARGET ?= $(shell uname -m)-native-linuxapp-gcc
DPDK_LIB ?= dpdk

ifneq ($(wildcard $(RTE_SDK)/$(RTE_TARGET)/*),)
    DPDK_INC_DIR = $(RTE_SDK)/$(RTE_TARGET)/include
    DPDK_LIB_DIR = $(RTE_SDK)/$(RTE_TARGET)/lib
else ifneq ($(wildcard $(RTE_SDK)/build/*),)
    # if the user didn't do "make install" for DPDK
    DPDK_INC_DIR = $(RTE_SDK)/build/include
    DPDK_LIB_DIR = $(RTE_SDK)/build/lib
else
    ifeq ($(words $(MAKECMDGOALS)),1)
        ifneq ($(MAKECMDGOALS),clean)
            $(error DPDK is not available. \
                    Make sure $(abspath $(RTE_SDK)) is available and built)
        endif
    endif
endif

PROTOCXXFLAGS = -std=gnu++11 -O0 -Wno-unused-parameter

CXXFLAGS += -std=gnu++11 -g3 -ggdb3 -Ofast -march=native \
	    -isystem $(DPDK_INC_DIR) -D_GNU_SOURCE \
	    -Wall -Wextra -Wcast-align -Wno-unused-parameter

# -Wshadow should not be used for g++ 4.x, as it has too many false positives
CXXVERSION_5_OR_HIGHER := $(shell expr $(CXXVERSION) \>= 50000)
ifeq "$(CXXVERSION_5_OR_HIGHER)" "1"
  CXXFLAGS += -Wshadow
endif

LDFLAGS += -rdynamic -L$(DPDK_LIB_DIR) -Wl,-rpath=$(DPDK_LIB_DIR) -pthread \
	   -static-libstdc++

LIBS += -Wl,-non_shared \
	-Wl,--whole-archive -l$(DPDK_LIB) -Wl,--no-whole-archive \
	-lglog -lgflags -lprotobuf -lgrpc++ -lgrpc \
	-lssl -lcrypto -lunwind -llzma -lpcap -lz \
	-Wl,-call_shared \
	-ldl

ifdef SANITIZE
    CXXFLAGS += -fsanitize=address -fno-omit-frame-pointer
    LDFLAGS += -fsanitize=address -static-libasan
endif

ifdef COVERAGE
    # override -Ofast with -Og for better results
    CXXFLAGS += --coverage -Og
    LDFLAGS += --coverage
endif

LIBS += -libverbs

PROTO_DIR = bessport
PROTOS = $(wildcard $(PROTO_DIR)/*.proto)
PROTO_SRCS = $(patsubst %.proto,%.pb.cc, $(PROTOS))
PROTO_SRCS += $(patsubst %.proto,%.grpc.pb.cc, $(PROTOS))
PROTO_HEADERS = $(patsubst %.cc,%.h, $(PROTO_SRCS))
PROTOCFLAGS += --proto_path=$(PROTO_DIR) --proto_path=$(PROTO_DIR) --cpp_out=$(PROTO_DIR) --grpc_out=$(PROTO_DIR) --plugin=protoc-gen-grpc=`which grpc_cpp_plugin`

ALL_SRCS = $(wildcard bessport/*.cc bessport/hooks/*.cc bessport/utils/*.cc *.cc rpc/*.cc port/*.cc actor/*.cc actor/base/*.cc module/*.cc nf/*/*.cc reliable/*.cc reliable/*/*.cc utils/*.cc samples/*.cc samples/*/*.cc) 
                      
HEADERS =  $(wildcard bessport/*.h bessport/hooks/*.h bessport/utils/*.h bessport/kmod/*.h *.h rpc/*.h port/*.h actor/*.h actor/base/*.h module/*.h nf/*/*.h reliable/*.h reliable/*/*.h utils/*.h)

TEST_SRCS = $(filter %_test.cc gtest_main.cc, $(ALL_SRCS))
TEST_OBJS = $(TEST_SRCS:.cc=.o)
TEST_ALL_EXEC = all_test

SRCS = $(filter-out $(TEST_SRCS), $(ALL_SRCS)) $(PROTO_SRCS)
OBJS = $(SRCS:.cc=.o)

GTEST_DIR = /usr/src/gtest

# The following variables are defined for sample examples.

SAMPLES_SRCS = $(wildcard samples/*.cc)
SAMPLES_SRCS += $(wildcard samples/*/*.cc)
SAMPLES_OBJS = $(SAMPLES_SRCS:.cc=.o)

NFA_RPC_CLIENT_EXEC = samples/nfa_rpc_client
NFA_RPC_CLIENT_OBJS = $(filter-out main.o $(filter-out samples/nfa_rpc_client.o,$(SAMPLES_OBJS)),$(OBJS))

MODULE_BASIC_EXEC = samples/module_basic
MODULE_BASIC_OBJS = $(filter-out main.o $(filter-out samples/module_basic.o,$(SAMPLES_OBJS)),$(OBJS))

REAL_RPC_BASIC_MAIN_EXEC = samples/real_rpc_basic/server_main
REAL_RPC_BASIC_MAIN_OJBS = $(filter-out main.o $(filter-out samples/real_rpc_basic/server_main.o,$(SAMPLES_OBJS)),$(OBJS))

MIGRATION_START_EXEC = samples/migration_start
MIGRATION_START_OBJS = $(filter-out main.o $(filter-out samples/migration_start.o,$(SAMPLES_OBJS)),$(OBJS))

REPLICATION_START_EXEC = samples/replication_start
REPLICATION_START_OBJS = $(filter-out main.o $(filter-out samples/replication_start.o,$(SAMPLES_OBJS)),$(OBJS))

RECOVER_START_EXEC = samples/recover_start
RECOVER_START_OBJS = $(filter-out main.o $(filter-out samples/recover_start.o,$(SAMPLES_OBJS)),$(OBJS))

#for migration test
M_INIT_EXEC = samples/migration/m_init
M_INIT_OBJS = $(filter-out main.o $(filter-out samples/migration/m_init.o,$(SAMPLES_OBJS)),$(OBJS))

M_START_EXEC = samples/migration/m_start
M_START_OBJS = $(filter-out main.o $(filter-out samples/migration/m_start.o,$(SAMPLES_OBJS)),$(OBJS))

R_INIT_EXEC = samples/replication/r_init
R_INIT_OBJS = $(filter-out main.o $(filter-out samples/replication/r_init.o,$(SAMPLES_OBJS)),$(OBJS))

R_START_EXEC = samples/replication/r_start
R_START_OBJS = $(filter-out main.o $(filter-out samples/replication/r_start.o,$(SAMPLES_OBJS)),$(OBJS))

R_RECOVER_EXEC = samples/replication/r_recover
R_RECOVER_OBJS = $(filter-out main.o $(filter-out samples/replication/r_recover.o,$(SAMPLES_OBJS)),$(OBJS))


.PHONY: all clean tests protobuf

all: $(OBJS) $(REAL_RPC_BASIC_MAIN_EXEC) $(MIGRATION_START_EXEC) $(NFA_RPC_CLIENT_EXEC) $(REPLICATION_START_EXEC) $(RECOVER_START_EXEC) $(M_INIT_EXEC) $(M_START_EXEC) $(R_INIT_EXEC) $(R_START_EXEC) $(R_RECOVER_EXEC)

clean:
	rm -rf $(EXEC) .deps/*.d .deps/*/*.d *_test */*_test *_bench */*_bench \
		*.a *.pb.* *.o */*.o *.gcda *.gcno */*.gcda */*.gcno \
		coverage.info coverage_html */*.pb.cc */*.pb.h
		
tests: $(TEST_OBJS) $(TEST_ALL_EXEC)
		
protobuf: $(PROTO_SRCS)

# This build wrapper takes 4 parameters:
# $(1): build type (CXX, LD, ...)
# $(2): Make target
# $(3): Make prerequisites
# $(4): command
define BUILD
$(2): $(3)
	$$(eval _TYPE = $$(strip $(1)))
	$$(eval _CMD = $$(strip $(4)))
	@if [ $$(VERBOSE) -eq 0 ]; then \
		printf "%-11s %s\n" "[$$(_TYPE)]" "$$@"; \
	else \
		printf "%-11s %s\n" "[$$(_TYPE)]" "$$(_CMD)"; \
	fi
	@if ! $$(_CMD); then \
		echo "Error: \033[0;31m$$@"; \
		echo "\033[0;33m$$(_CMD)\033[0m"; \
		false; \
	fi
endef

$(eval $(call BUILD, \
	PROTOC, \
	%.pb.cc %.pb.h %.grpc.pb.cc %.grpc.pb.h, \
	%.proto, \
	$$(PROTOC) $$< $$(PROTOCFLAGS)))
	
$(eval $(call BUILD, \
	CXX, \
	%.pb.o, \
	%.pb.cc $(DEPDIR)/$$@.d, \
	$$(CXX) -o $$@ -c $$< $$(PROTOCXXFLAGS) $$(DEPFLAGS)))

$(eval $(call BUILD, \
	CXX, \
	%.o, \
	%.cc $(PROTO_HEADERS) $(DEPDIR)/$$@.d, \
	$$(CXX) -o $$@ -c $$< $$(CXXFLAGS) $$(DEPFLAGS)))
	
$(eval $(call BUILD, \
	TEST_CXX, \
	%_test.o, \
	%_test.cc $(DEPDIR)/$$@.d, \
	$$(CXX) -o $$@ -c $$< $$(CXXFLAGS) $$(DEPFLAGS)))

$(eval $(call BUILD, \
	TEST_LD, \
	$$(TEST_ALL_EXEC), \
	$$(TEST_OBJS) gtest-all.o bess.a, \
	$$(CXX) -o $$@ $$^ $$(LDFLAGS) $(LIBS)))

$(eval $(call BUILD, \
	TEST_CXX, \
	gtest-all.o, \
	$$(GTEST_DIR)/src/gtest-all.cc, \
	$$(CXX) -o $$@ -c $$< -I$$(GTEST_DIR) $$(CXXFLAGS) $$(DEPFLAGS)))

CORE_OBJS = $(OBJS)

$(eval $(call BUILD, \
	AR, \
	bess.a, \
	$(CORE_OBJS), \
	$$(AR) rcs $$@ $$^))

# The rule for linking samples are added below here.
	
$(eval $(call BUILD, \
	LD, \
	$$(NFA_RPC_CLIENT_EXEC), \
	$$(NFA_RPC_CLIENT_OBJS), \
	$$(CXX) -o $$@ $$^ $$(LDFLAGS) $$(LIBS)))
	
$(eval $(call BUILD, \
	LD, \
	$$(MODULE_BASIC_EXEC), \
	$$(MODULE_BASIC_OBJS), \
	$$(CXX) -o $$@ $$^ $$(LDFLAGS) $$(LIBS)))
	
$(eval $(call BUILD, \
	LD, \
	$$(REAL_RPC_BASIC_MAIN_EXEC), \
	$$(REAL_RPC_BASIC_MAIN_OJBS), \
	$$(CXX) -o $$@ $$^ $$(LDFLAGS) $$(LIBS)))
	
$(eval $(call BUILD, \
	LD, \
	$$(MIGRATION_START_EXEC), \
	$$(MIGRATION_START_OBJS), \
	$$(CXX) -o $$@ $$^ $$(LDFLAGS) $$(LIBS)))
		
$(eval $(call BUILD, \
	LD, \
	$$(REPLICATION_START_EXEC), \
	$$(REPLICATION_START_OBJS), \
	$$(CXX) -o $$@ $$^ $$(LDFLAGS) $$(LIBS)))
	
$(eval $(call BUILD, \
	LD, \
	$$(RECOVER_START_EXEC), \
	$$(RECOVER_START_OBJS), \
	$$(CXX) -o $$@ $$^ $$(LDFLAGS) $$(LIBS)))
	
$(eval $(call BUILD, \
	LD, \
	$$(M_INIT_EXEC), \
	$$(M_INIT_OBJS), \
	$$(CXX) -o $$@ $$^ $$(LDFLAGS) $$(LIBS)))
	
$(eval $(call BUILD, \
	LD, \
	$$(M_START_EXEC), \
	$$(M_START_OBJS), \
	$$(CXX) -o $$@ $$^ $$(LDFLAGS) $$(LIBS)))
	
$(eval $(call BUILD, \
	LD, \
	$$(R_INIT_EXEC), \
	$$(R_INIT_OBJS), \
	$$(CXX) -o $$@ $$^ $$(LDFLAGS) $$(LIBS)))
	
$(eval $(call BUILD, \
	LD, \
	$$(R_START_EXEC), \
	$$(R_START_OBJS), \
	$$(CXX) -o $$@ $$^ $$(LDFLAGS) $$(LIBS)))
	
$(eval $(call BUILD, \
	LD, \
	$$(R_RECOVER_EXEC), \
	$$(R_RECOVER_OBJS), \
	$$(CXX) -o $$@ $$^ $$(LDFLAGS) $$(LIBS)))

%.d: ;

.PRECIOUS: %.d $(PROTO_HEADERS)

-include $(patsubst %,$(DEPDIR)/%.d,$(basename $(ALL_SRCS)))