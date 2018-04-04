%% Emotional Face Change Localization Task _ Seperated
% Zane W. Z. Xie 
% December, 6, 2012
%% Collect info at beginning of block in popup window 

ExperimentTitile = {'EWMC'};
prompt = {'Enter subject number', 'Enter session number', 'Practice? Y/N'}';
def={'99', '1', 'Y'};
answer = inputdlg(prompt, 'Experimental setup information',1,def);
[subjectNumber, sessionNumber, prac]  = deal(answer{:});
% hidecursor;

%% Import facedata 
imagearray1 = cell(1,6);
imagearray2 = cell(1,6);

% This is the positive set
imagearray1{1} = imread([filedirectoy 'Positive/C0.jpg'],'jpg');
imagearray1{2} = imread([filedirectoy 'Positive/P1.jpg'],'jpg');
imagearray1{3} = imread([filedirectoy 'Positive/P2.jpg'],'jpg');
imagearray1{4} = imread([filedirectoy 'Positive/P3.jpg'],'jpg');
imagearray1{5} = imread([filedirectoy 'Positive/P4.jpg'],'jpg');
imagearray1{6} = imread([filedirectoy 'Positive/P5.jpg'],'jpg');

% This is the negative set
imagearray2{1} = imread([filedirectoy 'Negative/C0.jpg'],'jpg');
imagearray2{2} = imread([filedirectoy 'Negative/N1.jpg'],'jpg');
imagearray2{3} = imread([filedirectoy 'Negative/N2.jpg'],'jpg');
imagearray2{4} = imread([filedirectoy 'Negative/N3.jpg'],'jpg');
imagearray2{5} = imread([filedirectoy 'Negative/N4.jpg'],'jpg');
imagearray2{6} = imread([filedirectoy 'Negative/N5.jpg'],'jpg');

imagesetsize = length(imagearray1);

%% Set up screen
backgroundCol = [60, 60, 60]; 
fixationCol = [0 0 0];
screens=Screen('Screens');sca

screenNumber=max(screens);
Screen('Preference', 'SkipSyncTests', 1);
Screen('Preference', 'Verbosity',1);
[expWin,rect]=Screen('OpenWindow',screenNumber, backgroundCol); %, [0 0 800 600]);
[centerX, centerY] = RectCenter(rect);
% if centerX~=400; clear all, close all, display('What?  Why did you change the screen resolution?  Put it back to 600x800!!'); end

% Open file and print time and header
fileName = [filedirectoy 'data/' subjectNumber '_' sessionNumber '_EWMC.txt'];
dataFile = fopen(fileName, 'a');
startTime = datestr(now, 0);
if (strcmp(prac,'N') || strcmp(prac,'n'))
    fprintf(dataFile, '%s\t', startTime);
    fprintf(dataFile, '%i\n', subjectNumber);
    fprintf(dataFile, 'Subject\tTrial\tCondition\tPreChangeImg\tPostChangeImg\tChangelocation\tClickX\tClickY\tReportedChange\tAccuracy\tRT\n');
end

%% Set timings
fixTime=.5;
cueTime=.5;
retentionTime=1;
%retentionTime=.1; %for checking accuracy
%note:ITI is set in set up variables loop
%notused:longestResp=25;

%% set up fixation 

% fixSize=4;
fixSize=centerX*0.02;
fixRect=[centerX-.5*fixSize; centerY-.5*fixSize; centerX+.5*fixSize; centerY+.5*fixSize];

%% Creat a location Rect to place the image stimuli
% sqrsize = 90;
% startx = 220;
% starty =120;
% sqrsize = centerX*0.15;
startx = centerX*0.70;
starty =centerY*0.40;

locationRect = cell(1,24);
interval = (centerX-startx)/2;
sqrsize = interval*0.95;


for iloc = 1:5
    locationRect{iloc} = [startx-sqrsize/2+interval*(iloc-1), starty-sqrsize/2, startx+sqrsize/2+interval*(iloc-1), starty+sqrsize/2];
end

for iloc = 6:10
    locationRect{iloc} = [startx-sqrsize/2+interval*(iloc-6), starty-sqrsize/2+interval*1, startx+sqrsize/2+interval*(iloc-6), starty+sqrsize/2+interval*1];
end

for iloc = 11:12
   locationRect{iloc} = [startx-sqrsize/2+interval*(iloc-11), starty-sqrsize/2+interval*2, startx+sqrsize/2+interval*(iloc-11), starty+sqrsize/2+interval*2];
end


for iloc = 13:14
   locationRect{iloc} = [startx-sqrsize/2+interval*(iloc-10), starty-sqrsize/2+interval*2, startx+sqrsize/2+interval*(iloc-10), starty+sqrsize/2+interval*2];
end

for iloc = 15:19
   locationRect{iloc} = [startx-sqrsize/2+interval*(iloc-15), starty-sqrsize/2+interval*3, startx+sqrsize/2+interval*(iloc-15), starty+sqrsize/2+interval*3];
end

for iloc = 20:24
   locationRect{iloc} = [startx-sqrsize/2+interval*(iloc-20), starty-sqrsize/2+interval*4 startx+sqrsize/2+interval*(iloc-20), starty+sqrsize/2+interval*4];
end


%% Set up variables
setSizes=4;
numTrials=120*size(setSizes,1);
trialSS=Shuffle(repmat(setSizes,1,numTrials/size(setSizes,2)));

%initiate variables
colcode=zeros(numTrials,max(setSizes));
ITI=zeros(numTrials);
firstpresentimg = nan(numTrials, setSizes);
changeimg = nan(numTrials, setSizes);
ranloc = nan(numTrials, setSizes);
PreChangeImg = nan(numTrials,1);
PostChangeImg = nan(numTrials,1);
    
for a = 1:numTrials
    firstpresentimg(a,:) = randperm(imagesetsize,setSizes);
    ranloc(a,:) = randperm(24,setSizes);
end 
    
ranchange = nan(numTrials,1);
changemask = nan(numTrials,setSizes);

for a = 1:numTrials
    ranchange(a,:) = randsample(firstpresentimg(a,:),1);
    changemask(a,:) = ranchange(a,:) == firstpresentimg(a,:);
end 

imagematrix = nan(numTrials,imagesetsize);

for itrial = 1:numTrials
    imagematrix(itrial,:) = 1:imagesetsize;
end 

secondpresentimg = nan(numTrials,setSizes);
secondpresentimg(~changemask) = firstpresentimg(~changemask);
for itrial = 1: numTrials
    remainset(itrial,:)=find(~ismember(imagematrix(itrial,:),firstpresentimg(itrial,:)));
    
    for isize = 1:setSizes
        if isnan(secondpresentimg(itrial, isize))
         secondpresentimg(itrial, isize) = randsample(remainset(itrial,:),1);
        end 
        
    end 
end 

firstpresentimgT = firstpresentimg';
secondpresentimgT = secondpresentimg';
ranlocT = ranloc';

PreChangeImg = firstpresentimgT(changemask'==1);
PostChangeImg = secondpresentimgT(changemask'==1);
change  = ranlocT(changemask'==1);
changemaskT = changemask';




%% Present Trials

clickTime=nan(1,numTrials);
changeReport=nan(1,numTrials);
accuracy=nan(1,numTrials);
changereport=zeros(setSizes, numTrials);
clickloc=zeros(numTrials,2);

if strcmp(prac,'Y')
    numTrials=15;
    Screen('FillRect', expWin, backgroundCol);
    DrawFormattedText(expWin, 'Press mouse to start', 'center', 'center', [0 0 0], 90);
    Screen('Flip',expWin);
else
    Screen('FillRect', expWin, backgroundCol);
    DrawFormattedText(expWin,'Press mouse to start', 'center');
    Screen('Flip',expWin);
end

clickstart=0;
    while clickstart==0 %&& ((GetSecs-startResp)<longestResp)
        [clicks, mx, my, whichButton]=GetClicks(expWin, .5);
        if any(whichButton) %any(mbuttons) 
            clickstart=1;
        end
    end


Screen('FillRect', expWin, backgroundCol);
[vbl SOT]=Screen('Flip', expWin); %#ok<*ASGLU>

for tt=1:numTrials
    display(tt);
    %Take a break if halfway through
    if ((strcmp(prac,'N') || strcmp(prac,'n')) && any(tt==40+1 || tt==80+1 || tt==120+1));
        Screen('FillRect', expWin, backgroundCol);
        DrawFormattedText(expWin, 'Press the mouse to begin', 'center', 'center', [0 0 0], 90);
        Screen('Flip',expWin);
        clickstart=0;
        while clickstart==0 %&& ((GetSecs-startResp)<longestResp)
            [clicks, mx, my, whichButton]=GetClicks(expWin, .5);
            if any(whichButton) %any(mbuttons) 
                clickstart=1;
            end
        [vbl SOT]=Screen('Flip', expWin, SOT+ITI(tt));
        end
    end
    
    %Present Fixation
    Screen('FillRect', expWin, fixationCol, fixRect);
    [vbl SOT]=Screen('Flip', expWin, SOT+ITI(tt));
    
    ransex = randi(2);
    
    % ransex = 1 for positive 
    % ransex = 2 for negative
    
     %Present Cues
    if ransex == 1
        for isize = 1:setSizes
            Allimg = imagearray1{firstpresentimg(tt,isize)};
            tex=Screen('MakeTexture', expWin, Allimg);
            tRect=Screen('Rect', tex);
            Screen('DrawTexture',  expWin, tex,[],locationRect{ranloc(tt,isize)});Screen('close',tex)        
%             Screen('PutImage',expWin,imagearray1{firstpresentimg(tt,isize)},locationRect{ranloc(tt,isize)});
        end
    else 
        for isize = 1:setSizes
            Allimg = imagearray2{firstpresentimg(tt,isize)};
            tex=Screen('MakeTexture', expWin, Allimg);
            tRect=Screen('Rect', tex);
            Screen('DrawTexture',  expWin, tex,[],locationRect{ranloc(tt,isize)});Screen('close',tex)
%             Screen('PutImage',expWin,imagearray2{firstpresentimg(tt,isize)},locationRect{ranloc(tt,isize)});
        end
    end %     
    clear tex Allimg    
    
    
    [vbl SOT]=Screen('Flip', expWin, SOT+fixTime);
   %Screen('FillRect', expWin, cuecolmat(:,:,tt), loctmat(:,:,tt));
   % Screen('FillRect', expWin, fixationCol, fixRect);
   
    
    %Present Retention
    Screen('FillRect', expWin, fixationCol, fixRect);
    [vbl SOT]=Screen('Flip', expWin, SOT+cueTime+.5);
    
    %Present Test   
    if ransex == 1
        for isize = 1:setSizes
            Allimg = imagearray1{secondpresentimg(tt,isize)};
            tex=Screen('MakeTexture', expWin, Allimg);
            tRect=Screen('Rect', tex);
            Screen('DrawTexture',  expWin, tex,[],locationRect{ranloc(tt,isize)});Screen('close',tex)        
%             Screen('PutImage',expWin,imagearray1{firstpresentimg(tt,isize)},locationRect{ranloc(tt,isize)});
        end
    else 
        for isize = 1:setSizes
            Allimg = imagearray2{secondpresentimg(tt,isize)};
            tex=Screen('MakeTexture', expWin, Allimg);
            tRect=Screen('Rect', tex);
            Screen('DrawTexture',  expWin, tex,[],locationRect{ranloc(tt,isize)});Screen('close',tex)
%             Screen('PutImage',expWin,imagearray2{firstpresentimg(tt,isize)},locationRect{ranloc(tt,isize)});
        end
    end %     
    clear tex Allimg  
    % Screen('FillRect', expWin, testcolmat(:,:,tt), loctmat(:,:,tt));
    % Screen('FillRect', expWin, fixationCol, fixRect);
    Screen('Flip', expWin, SOT+retentionTime);
    

    %%Get Response
    SetMouse(centerX, centerY, expWin);
    ShowCursor('CrossHair');
%     WaitTicks(1);
    startResp=GetSecs;
    clickok=0; % dist=nan(size(locationcenter,1),1);
    
    
    while clickok==0 %&& ((GetSecs-startResp)<longestResp)
%         [mx,my,mbuttons] = GetMouse(expWin);
        [clicks, mx, my, whichButton]=GetClicks(expWin, .5);

        if any(whichButton) %any(mbuttons) %get location of click
            clickloc(tt,:)=[mx,my];
            clickTime(tt)=GetSecs-startResp;
        end

        %Calculate which object clicked    
        for a=1:setSizes    
            if mx>locationRect{ranloc(tt,a)}(1) && mx<locationRect{ranloc(tt,a)}(3) && my>locationRect{ranloc(tt,a)}(2) && my<locationRect{ranloc(tt,a)}(4) 
           % if mx>loctmat(1,a,tt) && mx<loctmat(3,a,tt) && my>loctmat(2,a,tt) && my<loctmat(4,a,tt) 
                changereport(a,tt)=1;
            else
                changereport(a,tt)=0;
            end
        end
        
        if sum(changereport(:,tt))==1 %click must be on an object 
            clickok=1;
        end
        
    end
    
    %gather accuracy and print report
    
  
    if  find(changemaskT(:,tt)) == find(changereport(:,tt))
        accuracy(tt)=1;
    else
        accuracy(tt)=0;
    end
     
    if (strcmp(prac,'N') || strcmp(prac,'n'))
   %     fprintf(dataFile, 'Subject\tTrial\tPreChangeImg\tPostChangeImg\tChangelocation\tClickX\tClickY\tReportedChange\tAccuracy\tRT\n');        
         fprintf(dataFile, '%s\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%f\n',subjectNumber,tt,ransex,PreChangeImg(tt,:), PostChangeImg(tt,:), find(changemaskT(:,tt)), clickloc(tt,1), clickloc(tt,2), find(changereport(:,tt)), accuracy(tt), clickTime(tt));     
    end 
                
    Screen('FillRect', expWin, backgroundCol);
    [vbl SOT]=Screen('Flip', expWin);
    HideCursor;

    
end

    Screen('FillRect', expWin, backgroundCol);
    DrawFormattedText(expWin, 'You finished this block!', 'center', 'center');
    [vbl SOT]=Screen('Flip', expWin);
    ShowCursor;
    WaitSecs(1);
    Screen('CloseAll');