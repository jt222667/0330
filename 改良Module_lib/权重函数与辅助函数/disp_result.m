
function disp_result(num_modules_upper,num_modules,best_detail,best_cost,best_x)

disp('寻优完成！最优构型参数：');
module_gene  = best_x(2 : 1+num_modules_upper);
install_gene = best_x(2+num_modules_upper : 1+2*num_modules_upper);
align_gene   = best_x(2+2*num_modules_upper : end);

best_module  = module_gene(1:num_modules);
best_install = install_gene(1:num_modules);
best_align   = align_gene(1:num_modules);

fprintf('Best num_modules: %d\n', num_modules);
if isfield(best_detail, 'num_connect')
    fprintf('Best num_connect: %d\n', best_detail.num_connect);
end
fprintf('Module(units):  [%s]\n', num2str(best_module));
if isfield(best_detail, 'module_expanded') && ~isempty(best_detail.module_expanded)
    fprintf('Module(expanded): [%s]\n', num2str(best_detail.module_expanded));
end
fprintf('Install: [%s]\n', num2str(best_install));
fprintf('Align:   [%s]\n', num2str(best_align));
 
fprintf('Cost:    %.6f\n', best_cost);
fprintf('q_opt:   [%s]\n', num2str(best_detail.q_opt(:).'));
fprintf('w_opt:   [%s]\n', num2str(best_detail.w(:).'));
fprintf('sig_opt: %.6f\n', best_detail.sig);
end