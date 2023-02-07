% HeatES.m
% Heat Ensemble Statistics (HeatES) the OpenCLIM heat workflow.


%% Start
% Record start time
startt = now;

disp('Running HeatES (Heat Ensemble Statistics)')
disp('Version 1.0. Contact alan.kennedy@bristol.ac.uk for queries.')
disp('-----')
disp(' ')

% Set output directory
Outputdir = '/data/outputs/';


%% Read in environment variables
env_file = getenv('FILENAME');
env_varn = getenv('VARNAME');
env_mm = getenv('MEANMEDIAN');
env_plow = getenv('PLOW');
env_phigh = getenv('PHIGH');
env_regta = getenv('REGTOTAVE');
env_reg = getenv('REGION');

if ~isempty(env_file)
    disp(['Loading files with name: ', char(string(env_file))])
    inputs.FileName = char(string(env_file));
end

if ~isempty(env_varn)
    disp(['Loading variable: ', char(string(env_varn))])
    if strcmp(string(env_varn),'aveheatmort')
        inputs.Variable = 'average heat mortality';
    elseif strcmp(string(env_varn),'avecoldmort')
        inputs.Variable = 'average cold mortality';
    elseif strcmp(string(env_varn),'aveheatmortinc')
        inputs.Variable = 'average heat mortality per increment';
    elseif strcmp(string(env_varn),'avecoldmortinc')
        inputs.Variable = 'average cold mortality per increment';
    elseif strcmp(string(env_varn),'tas')
        inputs.Variable = 'tas';
    end
end

if ~isempty(env_mm)
    if strcmp(string(env_mm),'Mean')
        disp('Calculating multi-model mean')
        inputs.MeanMedian = char(string(env_mm));
        MMM = 1;
    elseif strcmp(string(env_mm),'Median')
        disp('Calculating multi-model median')
        inputs.MeanMedian = char(string(env_mm));
        MMM = 2;
    end
    
end

if ~isempty(env_plow)
    disp(['Lower percentile bounds set at :', char(string(env_plow))])
    inputs.pLow = str2double(string(env_plow));
end

if ~isempty(env_phigh)
    disp(['Upper percentile bounds set at :', char(string(env_phigh))])
    inputs.pHigh = str2double(string(env_phigh));
end

if ~isempty(env_regta)
    if strcmp(string(env_regta),'Mean')
        disp('Calculating regional mean')
        inputs.RegionTotAve = {env_regta};
        RTA = 1;
    elseif strcmp(string(env_regta),'Total')
        disp('Calculating regional total')
        inputs.RegionTotAve = {env_regta};
        RTA = 2;
    end
end

if ~isempty(env_reg)
    disp(['Calculating regional analysis for ', char(string(env_reg))])
    inputs.Region = char(string(env_reg));
else
    disp('Calculating regional analysis for all of UK')
    inputs.Region = 'UK';
end

if isfield(inputs,'Region')
    % Select correct region ID for subsetting from pre-processed
    % regions mask
    if strcmp(inputs.Region,'Scotland')
        region_n = 1;
    elseif strcmp(inputs.Region,'NorthEast')
        region_n = 2;
    elseif strcmp(inputs.Region,'NorthWest')
        region_n = 3;
    elseif strcmp(inputs.Region,'YorkshireHumber')
        region_n = 4;
    elseif strcmp(inputs.Region,'EastMidlands')
        region_n = 5;
    elseif strcmp(inputs.Region,'WestMidlands')
        region_n = 6;
    elseif strcmp(inputs.Region,'EastEngland')
        region_n = 7;
    elseif strcmp(inputs.Region,'GreaterLondon')
        region_n = 8;
    elseif strcmp(inputs.Region,'SouthEast')
        region_n = 9;
    elseif strcmp(inputs.Region,'SouthWest')
        region_n = 10;
    elseif strcmp(inputs.Region,'Wales')
        region_n = 11;
    elseif strcmp(inputs.Region,'NorthernIreland')
        region_n = 12;
    end
end

disp('-----')
disp(' ')


%% Load data
% Find list of files to load and define parameters for input climate dataset
% Climatedirin = '/data/inputs/ClimateData/';
Climatedirin = '/data/inputs/Climate/';
files = dir([Climatedirin '*.nc']);

% Assuming data files exist, continue with loading
if isempty(files)
    disp('No valid netCDF data to load: CANCELLING')
    return
else
    disp('The following netCDFs are being loaded:')
    ls([Climatedirin '*.nc'])
    disp('-----')
    disp(' ')
end

% Load one file as an example to check if data is in 3D
file = ([files(1).folder,'/',files(1).name]);
datatest = double(ncread(file,char(inputs.Variable)));
catdim = ndims(datatest) + 1;

% Load all of the files between the start and end file
for i = 1:length(files)
    
    % File name
    file = ([files(i).folder,'/',files(i).name]);
    
    % Load temperature for the correct region and concatenate through time if necessary
    if i == 1
        data = double(ncread(file,char(inputs.Variable)));
        
    else
        data = cat(catdim,data,double(ncread(file,char(inputs.Variable))));
        
    end
end


%% Calculate averages and uncertainty
disp(['Input data is ',num2str(catdim-1),'D, taking averages etc. along dimension ',num2str(catdim)])
disp('Calculating...')
if MMM == 1
    MMMdata = nanmean(data,catdim);
elseif MMM == 2
    MMMdata = nanmedian(data,catdim);
end

MMlow = prctile(data,inputs.pLow,catdim);
MMhigh = prctile(data,inputs.pHigh,catdim);

disp('               Done.')
disp('-----')
disp(' ')


%% Regional averaging if required
if exist('RTA','var')
    % Load regional averaging data
    load_regions
    
    % Find resolution
    disp('Checking model resolution:')
    s1 = size(datatest);
    if s1(1) == 82 && s1(2) == 112
        disp('Input data is on UKCP18 RCM grid')
        lats = lat_UK_RCM;
        lons = long_UK_RCM;
        LSM = LSM12;
        datamask = datamask12;
        UK_area = areas_12km_frac_UK;
        reg_area = areas_12km_frac_regions;
        reg_mask = UKregions12;
        
        averaging = 1;
        
    elseif s1(1) == 17 && s1(2) == 23
        disp('Input data is on UKCP18 GCM grid')
        lats = lat_UK_GCM;
        lons = long_UK_GCM;
        LSM = LSM60;
        datamask = datamask60;
        UK_area = areas_60km_frac_UK;
        reg_area = areas_60km_frac_regions;
        reg_mask = UKregions60;
        
        averaging = 1;
        
    elseif s1(1) == 484 && s1(2) == 606
        disp('Input data is on UKCP18 CPM grid')
        lats = lat_UK_CPM;
        lons = long_UK_CPM;
        LSM = LSM2;
        datamask = datamask2;
        UK_area = areas_2km_frac_UK;
        reg_area = areas_2km_frac_regions;
        reg_mask = UKregions2;
        
        averaging = 1;
        
    else
        disp('Input data is on unknown grid: map plotting and area averaging/totalling disabled.')
        averaging = 0;
    end
    
    % Only do averaging if on known grid
    if averaging == 1
        if ~exist('region_n','var')
            area_mask = UK_area;
            mask = datamask;
        else
            area_mask = reg_area(:,:,region_n);
            mask = datamask == region_n;
        end
        
        % Do regional averaging
        if RTA == 1
            MMMreg = nansum(nansum(MMMdata .* area_mask));
            MMlowreg = nansum(nansum(MMlow .* area_mask));
            MMhighreg = nansum(nansum(MMhigh .* area_mask));
            % Or regional totalling
        elseif RTA == 2
            MMMreg = nansum(nansum(MMMdata .* mask));
            MMMlowreg = nansum(nansum(MMlow .* mask));
            MMMhighreg = nansum(nansum(MMhigh .* mask));
        end
        
        % Save output values
        dlmwrite([Outputdir,'MMMreg.csv'],MMMreg, 'delimiter', ',', 'precision', '%i')
        dlmwrite([Outputdir,'MMlowreg.csv'],MMlowreg, 'delimiter', ',', 'precision', '%i')
        dlmwrite([Outputdir,'MMhighreg.csv'],MMhighreg, 'delimiter', ',', 'precision', '%i')
    end
    
    disp('-----')
    disp(' ')
    
end


%% Save output
disp('Saving output')

if catdim == 3
    dlmwrite([Outputdir,'MMM.csv'],MMMdata, 'delimiter', ',', 'precision', '%i')
    dlmwrite([Outputdir,'MMlow.csv'],MMlow, 'delimiter', ',', 'precision', '%i')
    dlmwrite([Outputdir,'MMhigh.csv'],MMhigh, 'delimiter', ',', 'precision', '%i')
    
    % Make some plots
    UK_subplot(MMMdata.*datamask,['Multi-model ' inputs.MeanMedian],Outputdir,lats,lons)
    UK_subplot(MMlow.*datamask,['Lower bound at ' num2str(inputs.pLow) ' percentile'],Outputdir,lats,lons)
    UK_subplot(MMhigh.*datamask,['Upper bound at ' num2str(inputs.pHigh) ' percentile'],Outputdir,lats,lons)
    
    
elseif catdim == 4
    if length(MMMdata(1,1,:)) == 5
        disp('Assuming output saved with 5 age categories in 3rd dimension')
        
        agecats = {'0-99','0-64','65-74','75-84','85-99'};
        for ages = 1:5
            dlmwrite([Outputdir,'MMM',char(agecats(ages)),'.csv'],MMMdata(:,:,ages), 'delimiter', ',', 'precision', '%i')
            dlmwrite([Outputdir,'MMlow',char(agecats(ages)),'.csv'],MMlow(:,:,ages), 'delimiter', ',', 'precision', '%i')
            dlmwrite([Outputdir,'MMhigh',char(agecats(ages)),'.csv'],MMhigh(:,:,ages), 'delimiter', ',', 'precision', '%i')
        end
    else
        disp('3D output saving still to be added. No output saved')
    end
end
disp('Analysis complete!')

endt = now;
fprintf('Total time taken to run: %s\n', datestr(endt-startt,'HH:MM:SS'))
disp('-----')
close all

