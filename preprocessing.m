% set current folder to where the text files are
cd 'C:/Users/PRASANNA/Desktop/sem9/eeg_project/eegdatafiles/'
%set path where data will be saved
pathtosave = 'C:\Users\PRASANNA\Desktop\sem9\eeg_project\osfstorage-archive-scripts\matlab_variables\';
 
 % load file with channel locations
 load('EEG21locs'); 
 
 %------------Import text options (import wizard)-----------------------
 
 % Set up the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 23);

% Specify range and delimiter
opts.DataLines = [2, Inf];
opts.Delimiter = ",";

% Specify column names and types
opts.VariableNames = ["FP1", "FP2", "F7", "F3", "Fz", "F4", "F8", "T3", "C3", "Cz", "C4", "T4", "T5", "P3", "PZ", "P4", "T6", "O1", "O2", "A1", "A2", "SensorCEOG", "SensorDEOG"];
opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";


 % load list of all files in folder
sbj = dir('*.txt'); 
 
%open eeglab to access functions
eeglab; close;


%create empty variables to be filled later
rejected_componentandtype= cell(size(sbj,1),1);
answer = cell(size(sbj,1),1);
confidence = cell(size(sbj,1),1);
sleepiness= cell(size(sbj,1),1);
focus= cell(size(sbj,1),1);
sensation= cell(size(sbj,1),1);
engagement= cell(size(sbj,1),1);
visual= cell(size(sbj,1),1);
auditory= cell(size(sbj,1),1);
flat_channels = zeros(size(sbj,1),1);
noisy_channels = zeros(size(sbj,1),1);


 for s = 1:size(sbj,1)%loop to import data files 
     
    %%%%%%%%%%%%%% Reading data %%%%%%%%%%%%%%%%%%%%
     
    %import subject data 
    data = readtable(sbj(s).name); 

    %get the trigger names and times if any
    trig = data.Events;
    [trig_time, ~] = find(~cellfun(@isempty,{trig}));
    trig_names = trig(trig_time);

  
    %put data in in eeglab-friendly structure (excl events)
    data= data(:,1:end-1);
    data_mat = data{:,:}';
    
    %get rid of nans if any (normally last samples)
    [row,column] = find(isnan(data_mat));
    data_mat(:,unique(column)) = [];
   
    %import in EEGlab
    EEG = pop_importdata('data',data_mat);
    EEG.srate = 512;
    EEG.chanlocs = EEG21locs;
    EEG.times = linspace(0,size(EEG.data,2)/EEG.srate,size(EEG.data,2)).*1000;%EEG times is in milisecond unit
    
    
    X = data(1,:);
    newopts.fs = 500;
    f1 = jfeeg('bpa', X, newopts); 
    % Tsallis Entropy
    newopts.alpha = 2;
    f2 = jfeeg('te', X, newopts);
    
    % Feature vector
    feat = [f1, f2];

   %  if strcmp(str1{2},'task')==1 %create events, get behavior and downsample
   % 
   %      %delete trigger 0
   %      %due to technical problems we got a trigger with number 0 once in a while;
   %      zero_epochs = zeros(size(trig_names,1),1);
   %      for t = 1:size(trig_names) %for each trial
   %          zero_epochs(t,1) = isempty(strfind(trig_names{t}, 'RS232 Trigger: 0('))== 0;
   %      end
   %      trig_names(logical(zero_epochs))=[];
   %      trig_time(logical(zero_epochs))=[];
   % 
   %      %find bell sound trigger
   %      index_trigger = zeros(size(trig_names,1),1);
   %      for t = 1:size(trig_names) %loop trial
   %          if isempty(strfind(trig_names{t}, '100'))== 0
   %              index_trigger(t,1) = 1;
   %          end
   %      end
   % 
   %      %find bell sample and create event in EEGlab
   %      bell_sample = trig_time(index_trigger==1);
   % 
   %      %create event in EEGLAB with bell sound trigger
   %      for t = 1:size(bell_sample,1)
   %          EEG.event(t).latency = bell_sample(t);
   %          EEG.event(t).type = 'bell';
   %          EEG.event(t).urevent = t;
   %          EEG.urevent(t).latency = bell_sample(t);
   %          EEG.urevent(t).type = 'bell';
   %      end
   % 
   %  %save answers to probes and catch invalid triggers if any
   %  %(invalid triggers also show up once in a while due to a technical problem)
   %  for t = 1:size(trig_names) %loop trial
   %      %answer,confidence and sleepiness in all valid trials
   %      if isempty(strfind(trig_names{t}, '100'))== 0 %question marker
   %          try
   %              answer{s,1}(1,t) = str2double(trig_names{t+1}(16));
   %          catch
   %              answer{s,1}(1,t) = nan;
   %          end
   % 
   %          try
   %              confidence{s,1}(1,t) = str2double(trig_names{t+2}(16));
   %          catch
   %              confidence{s,1}(1,t) = nan;
   %          end
   % 
   %          try
   %              sleepiness{s,1}(1,t)=str2double(trig_names{t+3}(16));
   %          catch
   %              sleepiness{s,1}(1,t)= nan;
   %          end
   % 
   %          %if answer is focusing on breath save level of focus
   %          try
   %              if str2double(trig_names{t+1}(16))== 1
   %                  try
   %                      focus{s,1}(1,t)= str2double(trig_names{t+4}(16));
   %                  catch
   %                      focus{s,1}(1,t) = nan;
   %                  end
   % 
   %              end
   %          catch   
   %          end
   % 
   % 
   %          %if answer is thinking about something else save level of
   %          %engagement, visual and auditory components
   %          try
   %              if str2double(trig_names{t+1}(16))== 2
   %                  try
   %                      engagement{s,1}(1,t)= str2double(trig_names{t+4}(16));
   %                  catch
   %                      engagement{s,1}(1,t)= nan;
   %                  end
   % 
   %                  try
   %                      visual{s,1}(1,t)= str2double(trig_names{t+5}(16));
   %                  catch
   %                      visual{s,1}(1,t)= nan;
   %                  end
   %                  try
   %                      auditory{s,1}(1,t)= str2double(trig_names{t+6}(16));
   %                  catch
   %                      auditory{s,1}(1,t)= nan;
   %                  end
   %              end
   %          catch
   %          end
   % 
   % 
   % 
   %          %if answer is distracted by something else save sensation
   %          try
   %              if str2double(trig_names{t+1}(16))== 3
   % 
   %                  try
   %                      sensation{s,1}(1,t)= str2double(trig_names{t+4}(16));
   %                  catch
   %                      sensation{s,1}(1,t)= nan;
   %                  end
   %              end
   %          catch
   %          end
   % 
   % 
   %      end
   %  end
   % 
   % %delete zeros
   % answer{s,1}= nonzeros(answer{s})';
   % confidence{s,1}= nonzeros(confidence{s})';
   % sleepiness{s,1}= nonzeros(sleepiness{s})';
   % focus{s,1}= nonzeros(focus{s})';
   % sensation{s,1}= nonzeros(sensation{s})';
   % engagement{s,1}= nonzeros(engagement{s})';
   % visual{s,1}= nonzeros(visual{s})';
   % auditory{s}= nonzeros(auditory{s})';
   % 
   % %save in EEG structure
   % EEG.etc.answer = answer{s,1};
   % EEG.etc.confidence = confidence{s,1};
   % EEG.etc.sleepiness = sleepiness{s,1};
   % EEG.etc.focus = focus{s,1};
   % EEG.etc.sensation = sensation{s,1};
   % EEG.etc.engagement = engagement{s,1};   
   % EEG.etc.visual = visual{s,1};
   % EEG.etc.auditory = auditory{s,1};
   % 
   
    %downsample to 256 to speed up processing
    EEG = pop_resample(EEG,256) ;
       
       %else %it is meditation or rest
           %just downsample to 256 to speed up processing
        %   EEG = pop_resample(EEG,256) ;
       %end
   
    %%%%%%%%%%%%%%%%% Pre-processing  %%%%%%%%%%%%%
   
    %filter data
    EEG = pop_eegfiltnew(EEG, [], 1, [], true, [], 0); % Highpass filter 1 Hz
    EEG = pop_eegfiltnew(EEG, [], 40, [], false, [], 0); % Lowpass filter 40 Hz
   
    %save EOG channels (last 2 electrodes)
    EEG.etc.eog = EEG.data(end-1:end,:);
     
    %detect and delete flat or noisy channels
    EEG_select = pop_select( EEG, 'nochannel', {'VEOG','HEOG'}); %exclude eye channels
    % EEG = clean_flatlines(EEG_select,120); %delete flat channels
     
    %save flat or noisy channels
    % flat_channels(s,1) = 21 - size(EEG.data,1);
    % EEG = clean_channels(EEG,0.5); %delete noisy channels
    % noisy_channels(s,1) = 21 - size(EEG.data,1) - flat_channels(s,1);
     
    %interpolate flat electrodes or noisy channels
    % EEG = pop_interp(EEG,EEG_select.chanlocs , 'spherical');
     
    % re_reference to average
    % EEG = pop_reref(EEG, []);
    

    %run ICA adjusting for data rank 
    %(number of components = non-interpolated
    %electrodes -1)
   
    EEG= pop_runica(EEG, 'icatype', 'runica','options',{'pca', 21-(noisy_channels(s,1) + flat_channels(s,1))-1} );
    EEG = iclabel(EEG); %classify components
   
    %delete suspicious components
    %reject components that are muscle, eyes, heart or channel noise (p>80%)
    [component,type] = find(EEG.etc.ic_classification.ICLabel.classifications(:,[2 3 4 6])>0.8);
    if isempty(component)==0 %if there are noisy components
        EEG= pop_subcomp(EEG, unique(component),0);
        rejected_componentandtype{s,1} = [component,type]; %keep track of components you reject
    end

    %save preprocessed data in a folder
    file_name1 = strcat(pathtosave, sbj(s,1).name);
    file_name = strcat(file_name1, '.mat');
    save(file_name, 'EEG')
    clearvars EEG EEG_select data data_mat

 end
 
 %save meta variables 
 save('extra_vars', ...
     'answer','confidence','sleepiness',...
     'focus','sensation','engagement','visual','auditory',...
     'rejected_componentandtype',...
     'sbj','noisy_channels','flat_channels')
   
 

 