% load_regions.m
% 
% Load the preprocessed regional masks then create the absolute and
% fractional areas for doing spatial averages etc. 
% 
% These .mat files are stored in PreProcessedData/ and are generate by
% scripts including load_UK_regions.m which are  not included in the main
% Git package. 
%

% Check if the data exists
if ~exist('PreProcessedData','dir')
    disp('Error: PreProcessedData not found ? please contact alan.kennedy@bristol.ac.uk');
    return
end

% Load the data masks for the UK (from generate_UK_datamask.m)
load('PreProcessedData/datamask2.mat')
load('PreProcessedData/datamask025deg.mat')
load('PreProcessedData/datamask1.mat')
load('PreProcessedData/datamask12.mat')
load('PreProcessedData/datamask60.mat')
datamask025dega = datamask025deg(49:88,42:83);

% Load LSM data
load('PreProcessedData/LSM2.mat')
load('PreProcessedData/LSM1.mat')
load('PreProcessedData/LSM12.mat')
load('PreProcessedData/LSM60.mat')

% Load the lat-long data directly from the data
% load_UK_latlon
load('PreProcessedData/long_UK_CPM.mat')
load('PreProcessedData/lat_UK_CPM.mat')
load('PreProcessedData/long_UK_RCM.mat')
load('PreProcessedData/lat_UK_RCM.mat')
load('PreProcessedData/long_UK_GCM.mat')
load('PreProcessedData/lat_UK_GCM.mat')

% Load the area of each lat-lon box (from generate_UK_latlon_area.m)
load PreProcessedData/areas_60km_abs.mat
load PreProcessedData/areas_60km_frac.mat
load PreProcessedData/areas_60km_frac_UK.mat
load PreProcessedData/areas_12km_abs.mat
load PreProcessedData/areas_12km_frac.mat
load PreProcessedData/areas_12km_frac_UK.mat
load PreProcessedData/areas_2km_abs.mat
load PreProcessedData/areas_2km_frac.mat
load PreProcessedData/areas_2km_frac_UK.mat
load PreProcessedData/areas_1km_abs.mat
load PreProcessedData/areas_1km_frac.mat
load PreProcessedData/areas_1km_frac_UK.mat
load PreProcessedData/areas_025deg_abs.mat
load PreProcessedData/areas_025deg_frac.mat
load PreProcessedData/areas_025deg_frac_UK.mat

load('PreProcessedData/UKregions025deg.mat')
load('PreProcessedData/UKregions2.mat')
load('PreProcessedData/UKregions12.mat')
load('PreProcessedData/UKregions1.mat')
load('PreProcessedData/UKregions60.mat')

% Regions for reference:
regs = {'Scotland','North East','North West','Yorkshire and the Humber','East Midlands','West Midlands','East of England','Greater London','South East','South West','Wales','Northern Ireland','Isle of Man'};


%% Calculate the absolute and fractional areas for each region
% Create blank array to fill
areas_025deg_abs_regions = zeros(length(areas_025deg_abs(:,1)),length(areas_025deg_abs(1,:)),12);
areas_025deg_frac_regions = zeros(length(areas_025deg_abs(:,1)),length(areas_025deg_abs(1,:)),12);
areas_2km_abs_regions = zeros(length(areas_2km_abs(:,1)),length(areas_2km_abs(1,:)),12);
areas_2km_frac_regions = zeros(length(areas_2km_abs(:,1)),length(areas_2km_abs(1,:)),12);
areas_12km_abs_regions = zeros(length(areas_12km_abs(:,1)),length(areas_12km_abs(1,:)),12);
areas_12km_frac_regions = zeros(length(areas_12km_abs(:,1)),length(areas_12km_abs(1,:)),12);
areas_60km_abs_regions = zeros(length(areas_60km_abs(:,1)),length(areas_60km_abs(1,:)),12);
areas_60km_frac_regions = zeros(length(areas_60km_abs(:,1)),length(areas_60km_abs(1,:)),12);

% Go through each region
for r=1:12
    areas_025deg_abs_regions(:,:,r) = areas_025deg_abs.*(UKregions025deg == r);
    areas_025deg_frac_regions(:,:,r) = areas_025deg_abs_regions(:,:,r)./nansum(nansum(areas_025deg_abs_regions(:,:,r)));
    areas_2km_abs_regions(:,:,r) = areas_2km_abs.*(UKregions2 == r);
    areas_2km_frac_regions(:,:,r) = areas_2km_abs_regions(:,:,r)./nansum(nansum(areas_2km_abs_regions(:,:,r)));
    areas_12km_abs_regions(:,:,r) = areas_12km_abs.*(UKregions12 == r);
    areas_12km_frac_regions(:,:,r) = areas_12km_abs_regions(:,:,r)./nansum(nansum(areas_12km_abs_regions(:,:,r)));
    areas_60km_abs_regions(:,:,r) = areas_60km_abs.*(UKregions60 == r);
    areas_60km_frac_regions(:,:,r) = areas_60km_abs_regions(:,:,r)./nansum(nansum(areas_60km_abs_regions(:,:,r)));
end
