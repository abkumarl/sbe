# IBM_PROLOG_BEGIN_TAG
# This is an automatically generated prolog.
#
# $Source: src/build/import_hwp_mk/istep2/istep2files.mk $
#
# OpenPOWER sbe Project
#
# Contributors Listed Below - COPYRIGHT 2016,2017
# [+] International Business Machines Corp.
#
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied. See the License for the specific language governing
# permissions and limitations under the License.
#
# IBM_PROLOG_END_TAG
#  @file istep2files.mk
#
#  @brief mk for including istep2 object files
#
##########################################################################
# Object Files
##########################################################################

ISTEP2-CPP-SOURCES = p9_sbe_attr_setup.C
ISTEP2-CPP-SOURCES +=p9_sbe_tp_chiplet_init1.C
ISTEP2-CPP-SOURCES +=p9_sbe_tp_gptr_time_initf.C
ISTEP2-CPP-SOURCES +=p9_sbe_npll_initf.C
ISTEP2-CPP-SOURCES +=p9_sbe_clock_test2.C
ISTEP2-CPP-SOURCES +=p9_sbe_tp_chiplet_reset.C
ISTEP2-CPP-SOURCES +=p9_sbe_tp_repr_initf.C
ISTEP2-CPP-SOURCES +=p9_sbe_tp_chiplet_init2.C
ISTEP2-CPP-SOURCES +=p9_sbe_tp_arrayinit.C
ISTEP2-CPP-SOURCES +=p9_sbe_tp_initf.C
ISTEP2-CPP-SOURCES +=p9_sbe_tp_chiplet_init3.C
ISTEP2-C-SOURCES =
ISTEP2-S-SOURCES =

ISTEP2_OBJECTS += $(ISTEP2-CPP-SOURCES:.C=.o)
ISTEP2_OBJECTS += $(ISTEP2-C-SOURCES:.c=.o)
ISTEP2_OBJECTS += $(ISTEP2-S-SOURCES:.S=.o)
