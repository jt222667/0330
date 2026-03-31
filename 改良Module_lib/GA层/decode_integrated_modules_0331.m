function [module_expanded, install_expanded, align_expanded, num_connect] = decode_integrated_modules_0331(module_gene, install_gene, align_gene, RP_data)
% 将“单模块 + 集成模块”混合编码，展开为 LP_generate 可直接使用的基础模块序列。
% 规则：
% 1) 普通模块 id（<=5）按原样写入。
% 2) 集成模块 id（见 RP_data.integrated_modules）展开为预定义 module/install/align。
% 3) num_connect 按“连接单元”计数：每个单模块或每个集成模块都记 1 次。

module_expanded = [];
install_expanded = [];
align_expanded = [];
num_connect = 0;

for i = 1:numel(module_gene)
    id = module_gene(i);
    num_connect = num_connect + 1;

    if isfield(RP_data, 'integrated_modules')
        ids = [RP_data.integrated_modules.id];
        idx = find(ids == id, 1);
    else
        idx = [];
    end

    if isempty(idx)
        module_expanded = [module_expanded, id];
        install_expanded = [install_expanded, install_gene(i)];
        align_expanded = [align_expanded, align_gene(i)];
    else
        im = RP_data.integrated_modules(idx);
        module_expanded = [module_expanded, im.module];
        install_expanded = [install_expanded, im.install];
        align_expanded = [align_expanded, im.align];
    end
end

end
