function[ F_PPM ] = Hz2PPM(F_hz,FieldStrength,SpectREF)
%% function[ F_PPM ] = Hz2PPM(F_hz,FieldStrength,SpectREF)
%
% Function to convert proton MRS frequencies from Hz 2 PPM
%
% Input:    F_hz = Frequency (Hz)
% Optional  FieldStrength = Field strength (T)
% Output:   F_PPM = Frequency (Hz)
%
% C.W. Davies-Jenkins, Johns Hopkins University 2022

if ~exist('FieldStrength','var')
    SpectFreq = 123.243*10^6;
else
    Gamma = 42.57747892*(10^6); % Gyromagnetic ratio [Hz/T]
    SpectFreq = Gamma * FieldStrength; % Spectrometer frequency [Hz]
end

if ~exist('SpetREF','var')
    SpectREF = 0;
end

F_PPM = ((F_hz - SpectREF) / SpectFreq) * 10^6;

end