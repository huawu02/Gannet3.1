function GannetRun(gabafile, target, T1w_dcmdir)
%
% GannetRun(gabafile, [target], [T1w_dir])
%
% Wrapper function that calls Gannet fitting and coregistration functions 
%
% Input:
%   gabafile        - pfile of the MRS scan
%   target          - target metabolite of GannetFit, 'GABAGlx', 'GSH', 'Lac' or 'EtOH'. Default is 'GABAGlx'.
%   T1w_dcmdir      - directory of the T1w dicoms, if left empty then no coregistration will be done.
%                     Does not work in deployed version. 
%                     Need to manually remove the METADATA.json and DIGEST.txt - delete doesn't work?
%
% By: Hua Wu, Stanford CNI, 2017

warning off;

if ~isempty(gabafile) && ischar(gabafile)
    gabafile = strsplit(gabafile,' ');
    if length(gabafile)>1
        error('Use one pfile at a time!');
    end
end
if ~exist('target', 'var') || isempty('target')   % fit GABA+Glx by default
    target = 'GABAGlx';
end

disp('Running Gannet toolbox...');

MRS_struct = GannetLoad(gabafile);
MRS_struct = GannetFit(MRS_struct, target);

if exist('T1w_dcmdir', 'var') && ~isempty(T1w_dcmdir)
    metadata_file = fullfile(T1w_dcmdir, '/METADATA.json');
    digest_file = fullfile(T1w_dcmdir, '/DIGEST.txt');
    if exist(metadata_file, 'file')
        delete metadata_file;
    end
    if exist(digest_file, 'file')
        delete digest_file;
    end
    MRS_struct = GannetCoRegister(MRS_struct, strsplit(T1w_dcmdir,' '));
    MRS_struct = GannetSegment(MRS_struct);
end

save(['e' num2str(MRS_struct.p.ex_no) '_s' num2str(MRS_struct.p.se_no) '_MRS_struct_' target], 'MRS_struct');

disp('Gannet Fit finished.');
