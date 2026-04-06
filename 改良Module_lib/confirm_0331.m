clear;
RP_data=Module_Lib();

module  = [9 9 9 8 9 1 9];
install = [1 1 1 1 1 1 1];
align   = [2 0 0 2 2 2 2];
% 1. 解码染色体 x 还原为构型参数（支持集成模块）
% [module_out, install_out, align_out, num_modules_physical] = expand_module_units(module, install, align, RP_data)

x = [7 module install align];
goal = [0;0;6];


[cost, detail] = mex_ev(x, goal, RP_data);