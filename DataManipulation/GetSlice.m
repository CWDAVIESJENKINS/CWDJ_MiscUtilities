function[SlicedArray] = GetSlice(Array, Dim, Idx)
%% function[SlicedArray] = GetSlice(Array, Dim, Idx)
%
% Description: Takes a slice of multi-dimensional array in dimension "Dim"
% at the specified index: Idx.
%
% Input:     Array = Aray to be sliced 
%            Dim = Dimension in which to slice
%            Idx = Index (or indices) to extract from dimension "Dim"
% Output:    SlicedArray = Subset of array
%
% Example usage:
%   For a 7D array, "Data":
%
%   SlicedData = GetSlice(Data, 5, 1:5);
%       returns 7D array but with only the 1st 5 entries in 5th dim
%
% C.W. Davies-Jenkins, Johns Hopkins University 2024

arguments
Array = [];
Dim {mustBeInteger} = [];
Idx {mustBeInteger} = [];
end

Specification = repmat({':'}, 1, ndims(Array)); % Create an vector whose length matches the dimensionality of the Array
Specification{Dim} = Idx; % At the specified Dim, add the indices we want to extract

SlicedArray = Array(Specification{:}); % Apply the slicing!

end
