function c_connect = weight_num_connect(num_connect, cfg)
% 将连接次数映射为最小化代价项。连接次数越少越优。

num_ref = cfg.num_connect_ref;
lambda_connect = cfg.lambda_num_connect;
p_connect = cfg.p_num_connect;

num_ref = max(num_ref, 1);
ratio = num_connect / num_ref;
c_connect = lambda_connect * (ratio ^ p_connect);

end
