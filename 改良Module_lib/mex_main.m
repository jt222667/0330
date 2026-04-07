%% 构型寻优（MOPSO版本）
clc;
clear;

this_dir = fileparts(mfilename('fullpath'));
addpath(fullfile(this_dir, 'MOPSO层'));
addpath(fullfile(this_dir, 'GA层'));

%% 1. 构型库数据初始化
RP_data = Module_Lib();
% 权重设置（用于从Pareto前沿中选取推荐解）
RP_data.weight_cfg.lambda_sig = 1;
RP_data.weight_cfg.lambda_w = 1;
RP_data.weight_cfg.lambda_num_modules = 1;

%% 2. 【定义任务点】
goal = [0;0;10];

%% 3. 【变量边界设置】
num_modules_upper = 13;
num_modules_lower = 2;

nvars = 1 + 3 * num_modules_upper;

lb = [num_modules_lower, ...
      ones(1, num_modules_upper)*1, ...
      ones(1, num_modules_upper)*0, ...
      ones(1, num_modules_upper)*0];
ub = [num_modules_upper, ...
      ones(1, num_modules_upper)*10, ...
      ones(1, num_modules_upper)*1, ...
      ones(1, num_modules_upper)*2];

%% 4. 【MOPSO 参数配置】
mopso_options.SwarmSize = 120;
mopso_options.MaxIterations = 80;
mopso_options.ArchiveSize = 150;
mopso_options.InertiaWeight = 0.65;
mopso_options.C1 = 1.5;
mopso_options.C2 = 1.5;

%% 5. 【调用 MOPSO 求解】
fprintf('开始构型寻优（MOPSO，多目标：sig / 1-w / num_modules）...\n');
result = mopso_optimize(goal, RP_data, nvars, lb, ub, mopso_options);

best_x = result.best_x;
best_detail = result.best_detail;
num_modules = best_detail.num_modules;

%% 6. 【结果解析】
disp('寻优完成！推荐构型参数（来自Pareto前沿加权选优）：');
module_gene  = best_x(2 : 1+num_modules_upper);
install_gene = best_x(2+num_modules_upper : 1+2*num_modules_upper);
align_gene   = best_x(2+2*num_modules_upper : end);

best_module  = module_gene(1:num_modules);
best_install = install_gene(1:num_modules);
best_align   = align_gene(1:num_modules);

fprintf('Pareto 解数量: %d\n', size(result.pareto_x, 1));
fprintf('Best num_modules: %d\n', num_modules);
fprintf('Module(units):  [%s]\n', num2str(best_module));
if isfield(best_detail, 'module_expanded') && ~isempty(best_detail.module_expanded)
    fprintf('Module(expanded): [%s]\n', num2str(best_detail.module_expanded));
end
fprintf('Install: [%s]\n', num2str(best_install));
fprintf('Align:   [%s]\n', num2str(best_align));
 
fprintf('sig_opt: %.6f\n', best_detail.sig);
fprintf('w_opt:   [%s]\n', num2str(best_detail.w(:).'));
fprintf('q_opt:   [%s]\n', num2str(best_detail.q_opt(:).'));

assignin('base', 'mopso_result', result);
assignin('base', 'mopso_pareto_x', result.pareto_x);
assignin('base', 'mopso_pareto_f', result.pareto_f);
