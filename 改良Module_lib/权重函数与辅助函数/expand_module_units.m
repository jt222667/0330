function [module_out, install_out, align_out, num_modules_physical] = expand_module_units(module_units, install_units, align_units, RP_data)

module_out = [];
install_out = [];
align_out = [];

num_single = 5;
integrated_modules = RP_data.integrated_modules;

for i = 1:length(module_units)
    unit_id = round(module_units(i));
    unit_install = round(install_units(i));
    unit_align = round(align_units(i));

    if unit_id <= num_single
        module_out(end+1) = unit_id; %#ok<AGROW>
        install_out(end+1) = unit_install; %#ok<AGROW>
        align_out(end+1) = unit_align; %#ok<AGROW>
    else
        idx_integrated = unit_id - num_single;
        if idx_integrated < 1 || idx_integrated > numel(integrated_modules)
            module_out(end+1) = 1; %#ok<AGROW>
            install_out(end+1) = unit_install; %#ok<AGROW>
            align_out(end+1) = unit_align; %#ok<AGROW>
            continue;
        end

        unit = integrated_modules{idx_integrated};
        module_out = [module_out, unit.module]; %#ok<AGROW>
        install_out = [install_out, unit.install]; %#ok<AGROW>
        align_out = [align_out, unit.align]; %#ok<AGROW>
    end
end

num_modules_physical = length(module_units) - numel(find(module_units > num_single));
for i = 1:length(module_units)
    unit_id = round(module_units(i));
    if unit_id > num_single
        idx_integrated = unit_id - num_single;
        if idx_integrated >= 1 && idx_integrated <= numel(integrated_modules)
            num_modules_physical = num_modules_physical + length(integrated_modules{idx_integrated}.module);
        else
            num_modules_physical = num_modules_physical + 1;
        end
    end
end

end
