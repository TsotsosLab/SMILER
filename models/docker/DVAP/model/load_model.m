function model = load_model(model_dir)
    ld             = load(fullfile(model_dir, 'model'));
    model = ld.attention_model;
    clear ld;
    %% load attention model
    model.attention_net_def ...
                                = fullfile(model_dir, model.attention_net_def);
    model.attention_net ...
                                = fullfile(model_dir, model.attention_net);                                               
end