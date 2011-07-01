clear;

%% Initialize dataset
VOCYEAR = 'VOC2007';
suffix = '/nfs/baikal/tmalisie/demo11/';
dataset_params = get_voc_dataset(VOCYEAR,suffix);
dataset_params.display_machine = '';%'onega';
dataset_params.display = 0;

dataset_params.must_have_seg = 0;
dataset_params.must_have_seg_string = '';
%dataset_params.model_type = 'scene';
dataset_params.model_type = 'exemplar';

%Initialize framing function
init_params.sbin = 8;
init_params.goal_ncells = 200;
init_params.MAXDIM = 15;
init_params.init_function = @initialize_goalsize_model;
init_params.init_type = 'f';

% %Initialize framing function
% init_params.sbin = 8;
% init_params.hg_size = [8 8];
% init_params.init_function = @initialize_fixedframe_model;
% init_params.init_type = 'f';

%Choose the training function (do_svm, do_rank, ...)
training_function = @do_svm;

dataset_params.init_params = init_params;
dataset_params.training_function = training_function;

%Get the default mining parameters (plus some fixes for training)
mining_params = get_default_mining_params;
mining_params.SKIP_GTS_ABOVE_THIS_OS = 1.0;
mining_params.dump_last_image = 1;
mining_params.dump_images = 0;
mining_params.MAXSCALE = 0.5;
mining_params.NMS_MINES_OS = 1.0;
mining_params.MAX_WINDOWS_BEFORE_SVM = 1000;
mining_params.TOPK = 50;
mining_params.MAX_TOTAL_MINED_IMAGES = 2000;

if strcmp(dataset_params.model_type, 'scene')
  mining_params.MIN_SCENE_OS = 0.5;
end
dataset_params.mining_params = mining_params;

%Initialize exemplar stream
dataset_params.stream_set_name = 'trainval';
dataset_params.stream_max_ex = 50;

dataset_params.trainset_name = 'train';
dataset_params.trainset_maxk = 100;

dataset_params.valset_name = 'trainval';
dataset_params.valset_maxk = 20;

dataset_params.testset_name = 'test';
dataset_params.testset_maxk = 2000;

%Choose a short string to indicate the type of training run we are doing
dataset_params.models_name = ...
    [init_params.init_type ...
     dataset_params.must_have_seg_string ...
     '.' ...
     dataset_params.model_type];

classes = {...
    'bus'
};

myRandomize;
r = randperm(length(classes));
classes = classes(r);

for i = 1:length(classes)
  dataset_params.trainset_name2 = ['-' classes{i}];
  dataset_params.valset_name2 = ['-' classes{i}];
  dataset_params.testset_name2 = classes{i};
  
  voc_template(dataset_params, classes{i});
end