# Author: Markus Leiter <leiter@p2l2.com> P2L2 GmbH
# Date: 20.03.2025
# Description:
# This TCL commands are executed when using the --gui attribute (debugging)
# It handles loading the correct wave file:
# - a wave file named {tb_name}_wave.do is loaded automatically
# - If this file is not found, as a fallback, a file named wave.do is loaded
# - the macro save_wave is provided to simplify saving changes.
#   There is no need to click through the directories in the modelsim gui anymore :)
#
# Additionally, the script provides a button to restart the simulation and to save the wave file.
# It also disables the automatic opening of the source file on env.stop. 
#
# License: MIT
# Copyright (c) Markus Leiter <leiter@p2l2.com> P2L2 GmbH <www.p2l2.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.


################################################################################################################


puts ${vunit_tb_path}
puts ${vunit_tb_name}

# get a list of all files in the design
set data [ write report -tcl ]

# extract the name of the testbench
regexp {(tb_[A-Z_a-z0-9]*)(?:-\w*)*?.vhd} $data -> design_unit
puts "Found Design Unit: $design_unit"

# generate the path & name of the wave file
# this is global, because it's needed in the save_wave procedure later
global wavename
set wavename ${vunit_tb_path}/${design_unit}

# try to source a wave file with the name of the design_unit
if { [file exists ${wavename}_wave.do] } {
    puts "loading wave from '${wavename}_wave.do'."
    do ${wavename}_wave.do
} elseif { [file exists ${vunit_tb_path}/wave.do] } {
    # fallback: generic wave.do
    do ${vunit_tb_path}/wave.do
    puts "loaded default wave.do file since no file matched the name '${wavename}_wave.do'."
    puts "You can use the 'save_wave' command to save the wave file in the correct format."
} else {
    puts "No Wave file found in the testbench directory. If you save a wave as '${wavename}_wave.do', it will be loaded automatically next time."
    puts "You can use the 'save_wave' command to do so."
}

# provide a command to save the wave automatically in the correct location.
proc save_wave {} {
    global wavename
    puts "writing wave to '${wavename}_wave.do'..."
    write format wave -window .main_pane.wave.interior.cs.body.pw.wf ${wavename}_wave.do
    puts "done."
}

proc sw {} {
    global wavename
    puts "writing wave to '${wavename}_wave.do'..."
    write format wave -window .main_pane.wave.interior.cs.body.pw.wf ${wavename}_wave.do
    puts "done."
}

# Define the alias vr for vunit_restart
proc vr {} {
    if {[info commands vunit_restart] != ""} {
        vunit_restart
    } else {
        puts "Error: vunit_restart is not defined yet."
    }
}

# add vunit_restart button to the GUI
set script_dir [file dirname [file normalize [info script]]]
set vunit_img_path [file join $script_dir "VUnit.png"]
if {[file exists $vunit_img_path]} {
    set vunit_icon_name "vunit_icon"
    image create photo $vunit_icon_name -file $vunit_img_path
    add button " VUnit Restart" {vunit_restart} Disable " -image $vunit_icon_name -compound left"
}

# add save_wave button to the GUI
set p2l2_img_path [file join $script_dir "p2l2.png"]
if {[file exists $p2l2_img_path]} {
    set p2l2_icon_name "p2l2_icon"
    image create photo $p2l2_icon_name -file $p2l2_img_path
    add button " Save Wave" {save_wave} NoDisable " -image $p2l2_icon_name -compound left"
}

# disable open source file on env.stop
global PrefSource
set PrefSource(OpenOnFinish) 0
set PrefSource(OpenOnBreak) 0

# print info about the provided save_wave command
puts ""
puts "List of additional commands:"
puts "save_wave, sw"
puts "  - Save the current wave file as {tb_name}_wave.do located in the directory of the testbench"
puts "vr"
puts "  - short form of vunit_restart, restarts the simulation"
puts ""

################################################################################################################
# run the simulation
run -all