# Copyright (c) <2025> <Markus Leiter>
# License: MIT
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
# documentation files (the âSoftwareâ), to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
# and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED âAS ISâ, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
# LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT
# SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

#############################################################################
# some useful arguments:
#       --clean
#       --gui [optional: testcase name "lib.tb_*.testcasename" (wildcards allowed)
#       --minimal: compile used files only
#       for detailed info use -h or --help
#############################################################################

import sys
from pathlib import Path
from vunit import VUnit
import vunit_helpers
import os

# get the root path of the project
project_path = Path(__file__).parents[1]

# #############################################
# VUnit Simulator Selection
# #############################################
# select the simulator to use if the environment variable VUNIT_SIMULATOR is not set
if not "VUNIT_SIMULATOR" in os.environ:
    # use modelsim if the GUI is requested, otherwise use NVC
    if ("-g" in sys.argv) or ("--gui" in sys.argv):
        os.environ["VUNIT_SIMULATOR"] = "modelsim"
    else:
        os.environ["VUNIT_SIMULATOR"] = "nvc"
        ## some other supported simulators: ghdl, activehdl, rivierapro, modelsim

# log the selected simulator
print(f'\nVUnit is running tests using {os.environ["VUNIT_SIMULATOR"]}\n')

# #############################################
# VUnit Setup
# #############################################
prj = VUnit.from_argv(vhdl_standard="08")
prj.add_vhdl_builtins()

# ############################################
# add UVVM
# ############################################
vunit_helpers.add_uvvm_sources(prj, project_path / "verification" / "UVVM")

# ############################################
# Add source files
# ############################################
lib = prj.add_library("lib")  # the work of the project library
lib.add_source_files(project_path / "src" / "unit*" / "rtl" / "*.vhd")
lib.add_source_files(project_path / "src" / "unit*" / "tb" / "*.vhd")

#############################################
# Enable UVVM support for open source simulators
#############################################
# GHDL:
vunit_helpers.set_ghdl_flags_for_UVVM(prj)

# NVC:
prj.add_compile_option(
    "nvc.a_flags",
    value=["--relaxed", "--psl"],
)
prj.set_sim_option("nvc.heap_size", value="1g")

# ############################################
# automatically load wave.do and execute run -all
# This scripts also adds the "save_wave" tcl command to the simulator.
# ############################################
for tb in lib.get_test_benches():
    tb.set_sim_option("modelsim.init_file.gui", str(project_path / "verification" / "modelsim_gui.do"))
    
    ## The init file is also available for other simulators. Please contact <info@p2l2.com>:
    # tb.set_sim_option("activehdl.init_file.gui", str(project_path / "verification" / "activehdl_gui.do"))
    # tb.set_sim_option("rivierapro.init_file.gui", str(project_path / "verification" / "rivierapro_gui.do"))

# #############################################
# Generate toml file used by Language servers (GHDL_LS / rust_HDL)
# #############################################
vunit_helpers.generate_rust_hdl_toml(
    prj, str(project_path / "vhdl_ls.toml"), str(project_path / "verification")
)

# #############################################
# Run the simulation
# #############################################
prj.main()
