function[ F_Hz ] = PPM2Hz(F_PPM,FieldStrength,SpectREF)
%% function[ F_Hz ] = PPM2Hz(F_PPM,FieldStrength,SpectREF)
%
% Function to convert proton MRS frequencies from PPM to Hz
%
% Input:    F_PPM = Frequency (PPM)
% Optional  FieldStrength = Field strength (T)
% Output:   F_hz = Frequency (Hz)
%
% C.W.Davies-Jenkins, Johns Hopkins University 2022

if ~exist('FieldStrength','var')
    SpectFreq = 123.243*10^6;
else
    Gamma = 42.57747892*(10^6); % Gyromagnetic ratio [Hz/T]
    SpectFreq = Gamma * FieldStrength; % Spectrometer frequency [Hz]
end

if ~exist('SpetREF','var')
    SpectREF = 0;
end

F_Hz = (F_PPM / 10^6 * SpectFreq) + SpectREF;

end