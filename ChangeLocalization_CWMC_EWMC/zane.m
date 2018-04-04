
clear all;
sca;

Lststr = {'CWMC','EWMC'};

[VSelected,OKFlg] = listdlg('PromptString','Select a working directory:',...
              'SelectionMode','single',...
              'ListString',Lststr);
          

filedirectoy = ['/Users/weizhenxie/Desktop/ChangeLocalization_CWMC_EWMC/'];
cd(filedirectoy);          

if OKFlg == 0
	pwd;
else
	switch VSelected
    case 1
        CWMC;
    case 2
        EWMC;
    end 
end 
