function[MRSCont] = osp_TakeSubset(MRSCont,Ind)
%% function[MRSCont] = osp_TakeSubset(MRSCont,Ind)
%
% Description: A function for taking a subset of an Osprey MRS container.
% For e.g., this function can be used test models on a subset of a large
% processed dataset.
%
% Input:     MRSCont = Osprey Container
%            Ind = Indices of the subset to extract
% Output:    MRSCont = Reduced Osprey container
%
% Example usage: MRSCont_reduced = osp_TakeSubset(MRSCont,[1:10]) % Takes
% 1st 10 datasets from MRSCont 
%
% C.W. Davies-Jenkins, Johns Hopkins University 2025

%% Update file location definitions
if ~isempty(MRSCont.files)
    MRSCont.files = MRSCont.files(:,Ind);
end
if ~isempty(MRSCont.files_mm)
    MRSCont.files_mm = MRSCont.files_mm(:,Ind);
end
if ~isempty(MRSCont.files_ref)
    MRSCont.files_ref = MRSCont.files_ref(:,Ind);
end
if ~isempty(MRSCont.files_w)
    MRSCont.files_w = MRSCont.files_w(:,Ind);
end
if ~isempty(MRSCont.files_mm_ref)
    MRSCont.files_mm_ref = MRSCont.files_mm_ref(:,Ind);
end
if ~isempty(MRSCont.files_nii)
    MRSCont.files_nii = MRSCont.files_nii(:,Ind);
end

MRSCont.nDatasets(1) = length(Ind);

%% Update loaded data

if MRSCont.flags.didLoad
    MRSCont.raw = MRSCont.raw(Ind);
    MRSCont.raw_ref = MRSCont.raw_ref(Ind);
    MRSCont.raw_w = MRSCont.raw_w(Ind);
end

%% Update processed data
if MRSCont.flags.didProcess
    MRSCont.processed.metab = MRSCont.processed.metab(:,Ind);
    MRSCont.processed.ref = MRSCont.processed.ref(:,Ind);
    MRSCont.processed.w = MRSCont.processed.w(:,Ind);
end

%% More to add later!
if MRSCont.flags.didFit
    warning('Only load and processed implemented so far!')
end

%% Update QMs (necessary for modeling)
MRSCont.QM.tables = MRSCont.QM.tables(Ind,:);

end
