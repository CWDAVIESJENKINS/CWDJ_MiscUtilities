function[] = PingEmail(Text,Att,Subj)
%% function[] = PingEmail(Text,Att,Subj)
%
% Description: Send an email from a Gmail account to a recipient specified 
%              in a config file.
%
% Input:     Text = The text to be sent as the email body
% Optional:  Att = any attachments to be added (string path or cell of 
%                  string paths). Default = []
%            Subj = Subject line. Default = "Email ping"
%
% Example usage:
%       PingEmail('New results generated','Path/To/Png')
%
% C.W. Davies-Jenkins, Johns Hopkins University 2025
arguments
Text {mustBeText};
Att = [];
Subj {mustBeText} = 'Email ping';
end

% Load the config details
Path = fullfile(fileparts(mfilename('fullpath')),'PingEmailConfig.JSON');
Config = jsondecode(fileread(Path));

% Message specifics
destination = Config.default_dest;

%set up SMTP service for Gmail
setpref('Internet','E_mail',Config.src_email);
setpref('Internet','SMTP_Server','smtp.gmail.com');
setpref('Internet','SMTP_Username',Config.src_email);
setpref('Internet','SMTP_Password',Config.src_pwd);

% Gmail server.
props = java.lang.System.getProperties;
props.setProperty('mail.smtp.auth','true');
props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
props.setProperty('mail.smtp.socketFactory.port','465');

% Send the email
sendmail(destination,Subj,Text,Att);

% [Optional] Remove the preferences at the end (for privacy)
setpref('Internet','E_mail','');
setpref('Internet','SMTP_Server','''');
setpref('Internet','SMTP_Username','');
setpref('Internet','SMTP_Password','');

end