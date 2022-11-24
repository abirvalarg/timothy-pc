
# PlanAhead Launch Script for Pre-Synthesis Floorplanning, created by Project Navigator

create_project -name timothy -dir "/home/abir/projects/Timothy/timothy/planAhead_run_3" -part xc6slx16ftg256-2
set_param project.pinAheadLayout yes
set srcset [get_property srcset [current_run -impl]]
set_property target_constrs_file "timothy.ucf" [current_fileset -constrset]
set hdlfile [add_files [list {ipcore_dir/rom0.vhd}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {vcpu816/half_adder.vhd}]]
set_property file_type VHDL $hdlfile
set_property library vcpu816 $hdlfile
set hdlfile [add_files [list {vcpu816/rctl.vhd}]]
set_property file_type VHDL $hdlfile
set_property library vcpu816 $hdlfile
set hdlfile [add_files [list {vcpu816/control_unit.vhd}]]
set_property file_type VHDL $hdlfile
set_property library vcpu816 $hdlfile
set hdlfile [add_files [list {vcpu816/alu.vhd}]]
set_property file_type VHDL $hdlfile
set_property library vcpu816 $hdlfile
set hdlfile [add_files [list {vcpu816/cpu.vhd}]]
set_property file_type VHDL $hdlfile
set_property library vcpu816 $hdlfile
set hdlfile [add_files [list {prescaller.vhd}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {ndisp.vhd}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {timothy.vhd}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set_property top timothy $srcset
add_files [list {timothy.ucf}] -fileset [get_property constrset [current_run]]
add_files [list {ipcore_dir/rom0.ncf}] -fileset [get_property constrset [current_run]]
open_rtl_design -part xc6slx16ftg256-2
