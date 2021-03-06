function [output_width_map, output_height_map] = proposal_calc_output_size_caltech(conf, test_net_def_file)
% [output_width_map, output_height_map] = proposal_calc_output_size_caltech(conf, test_net_def_file)
% --------------------------------------------------------
% RPN_BF
% Copyright (c) 2016, Liliang
% Licensed under The MIT License [see LICENSE for details]
% --------------------------------------------------------

%     caffe.init_log(fullfile(pwd, 'caffe_log'));
    caffe_net = caffe.Net(test_net_def_file, 'test');
    
     % set gpu/cpu
    if conf.use_gpu
        caffe.set_mode_gpu();
    else
        caffe.set_mode_cpu();
    end
    
%     input = conf.scales:conf.max_size;
% %     if conf.max_size == 640      
% %         input = [480 640];
% %     end
%     % caltech image size are fixed as 640x480
    input = [conf.max_size conf.scales];
    
    output_w = nan(size(input));
    output_h = nan(size(input));
    for i = 1:length(input)
        s = input(i);
        im_blob = single(zeros(s, s, 3, 1));
        net_inputs = {im_blob};

        % Reshape net's input blobs
        caffe_net.reshape_as_input(net_inputs);
        caffe_net.forward(net_inputs);
        
        cls_score = caffe_net.blobs('proposal_cls_score').get_data();
        output_w(i) = size(cls_score, 1);
        output_h(i) = size(cls_score, 2);
    end
    
    output_width_map = containers.Map(input, output_w);
    output_height_map = containers.Map(input, output_h);
    
    caffe.reset_all(); 
end