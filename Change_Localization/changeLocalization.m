%% Change Localization program 

clear all;

%%Collect info at beginning of block in popup window 
prompt = {'Enter subject number', 'Enter session number', 'Practice? Y/N'}';
def={'99', '1', 'Y'};
answer = inputdlg(prompt, 'Experimental setup information',1,def);
[subjectNumber, sessionNumber, prac]  = deal(answer{:});

% hidecursor;

%% Set up screen
backgroundCol = [60, 60, 60];   % set the background color
fixationCol = [0 0 0];          % set the fixation point color

screens=Screen('Screens');    
screenNumber=max(screens);

Screen('Preference', 'SkipSyncTests', 1);
Screen('Preference', 'Verbosity', 1);

[expWin,rect]=Screen('OpenWindow',screenNumber, backgroundCol); %, [0 0 800 600]);
[centerX, centerY] = RectCenter(rect);
% if centerX~=400; clear all, close all, display('What?  Why did you change the screen resolution?  Put it back to 600x800!!'); end

%% Open file and print time and header
%fileName = ['/Users/Shared/tDCS_Change_Localization_Task/' subjectNumber '_' sessionNumber];
fileName = ['E:\common progrom\matlab2\data\' subjectNumber '_' sessionNumber];
dataFile = fopen(fileName, 'a');
startTime = datestr(now, 0);
if (strcmp(prac,'N') || strcmp(prac,'n'))
    fprintf(dataFile, '%s\t', startTime);
    fprintf(dataFile, '%i\n', subjectNumber);
    fprintf(dataFile, 'Subject\tTrial\tCueLocations\tCueColorCodes\tChange\tClickX\tClickY\tReportedChange\tAccuracy\tRT\n');
end

%%  Set timings
fixTime=.5;
cueTime=.5;
retentionTime=1;
%retentionTime=.1; %for checking accuracy
%note:ITI is set in set up variables loop
%notused:longestResp=25;

%set objects
objectSize=20;
offsetSize=48;
fixSize=4;
fixRect=[centerX-.5*fixSize; centerY-.5*fixSize; centerX+.5*fixSize; centerY+.5*fixSize];

location=zeros(4,25);
locationcenter=zeros(25,2);
col=1; obj=1;
for a=-2:2
    for b=-2:2
        location(1, col)= centerX+b*offsetSize-.5*objectSize;
        location(2, col)= centerY+a*offsetSize-.5*objectSize;
        location(3, col)= centerX+b*offsetSize+.5*objectSize;
        location(4, col)= centerY+a*offsetSize+.5*objectSize;
        locationcenter(obj,:)=[centerX+b*offsetSize, centerY+a*offsetSize]; 
        obj=obj+1;
        col=col+1;
    end
end


%setcolors 
colors(:,:,1)=[238 162 173;   205 38 38; 255 165 79; 205 133 0; 255 235 139; 205 105 201];
colors(:,:,2)=[107	142	35; 113 198 113;  3 168 158; 135 206 250; 125 38 205; 154 205 50 ];

%% Set up variables
setSizes=6;
numTrials=100*size(setSizes,1);
trialSS=Shuffle(repmat(setSizes,1,numTrials/size(setSizes,2)));

%initiate variables
colt=zeros(numTrials,max(setSizes), 2);
loct=zeros(numTrials,max(setSizes));
loctmat=zeros(4,max(setSizes),numTrials);
select=zeros(numTrials,max(setSizes));
change=zeros(numTrials);
cuecolmat=zeros(3,max(setSizes),numTrials);
colcode=zeros(numTrials,max(setSizes));
testcolmat=cuecolmat;
ITI=zeros(numTrials);
    
for a=1:numTrials;
    
    
    
    % get SS locations from the 24 posible location values (5x5 grid excluding
    % central)
    loct(a,:)=randsample([1:12 14:25],trialSS(a));
    
    for c=1:size(loct(a,:),2)
        loctmat(:,c,a)=location(:,loct(a,c));
    end
    
    %choose which one of each color pair is selected
    select(a,:)=randsample([ones(1,trialSS(a)) 2*ones(1,trialSS(a))],trialSS(a));
    
    %choose which item changes (1:SS possible options);
    change(a)=randsample(1:trialSS(a),1); %mod(x+2,2)+1 swaps from 1 to 2
    
    %generate acutal matrices for the color and location values for each
    %trial
    for d=1:size(loct(a,:),2)
        cuecolmat(:,d,a)=colors(d,:,select(a,d))';
    end
    testcolmat(:,:,a)=cuecolmat(:,:,a);
    testcolmat(:,change(a),a)=colors(change(a),:,mod(select(a,change(a))+2,2)+1)';
    
    %set each trial ITI
    ITI(a)=1+rand*.5;
end
    


%% Present Trials
clickTime=nan(1,numTrials);
changeReport=nan(1,numTrials);
accuracy=nan(1,numTrials);
changereport=zeros(numTrials,size(loctmat,2));
clickloc=zeros(numTrials,2);

if strcmp(prac,'Y')
    numTrials=15;
    Screen('FillRect', expWin, backgroundCol);
    DrawFormattedText(expWin, ['First you will see a set of objects.  After a blank screen you will see the set '...
    'of objects again, but one item will have changed.  Your job is to move the cursor to the changed item '...
    'and click on it.  Press a mouse button when you are ready to begin the practice.'], 'center', 'center','wrapat', [0 0 0], 90);
    Screen('Flip',expWin);
else
    Screen('FillRect', expWin, backgroundCol);
    DrawFormattedText(expWin,'Press a mouse button when you are ready to begin.','center', 'center');
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
    if ((strcmp(prac,'N') || strcmp(prac,'n')) && tt==numTrials/2+1)
        Screen('FillRect', expWin, backgroundCol);
        DrawFormattedText(expWin, 'Take a short break.  You are done with half of this task. Press a mouse button when you are ready to continue. ', 'center', 'center', [0 0 0], 90);
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
    
    %Present Cues
    Screen('FillRect', expWin, cuecolmat(:,:,tt), loctmat(:,:,tt));
    Screen('FillRect', expWin, fixationCol, fixRect);
    [vbl SOT]=Screen('Flip', expWin, SOT+fixTime);
    
    %Present Retention
    Screen('FillRect', expWin, fixationCol, fixRect);
    [vbl SOT]=Screen('Flip', expWin, SOT+cueTime);
    
    %Present Test
    Screen('FillRect', expWin, testcolmat(:,:,tt), loctmat(:,:,tt));
    Screen('FillRect', expWin, fixationCol, fixRect);
    Screen('Flip', expWin, SOT+retentionTime);
    

    %%Get Response
    SetMouse(centerX, centerY, expWin);
    ShowCursor('CrossHair');
    WaitTicks(1);
    startResp=GetSecs;
    clickok=0; dist=nan(size(locationcenter,1),1);
    
    
    while clickok==0 %&& ((GetSecs-startResp)<longestResp)
%         [mx,my,mbuttons] = GetMouse(expWin);
        [clicks, mx, my, whichButton]=GetClicks(expWin, .5);

        if any(whichButton) %any(mbuttons) %get location of click
            clickloc(tt,:)=[mx,my];
            clickTime(tt)=GetSecs-startResp;
        end

        %Calculate which object clicked 
        
        for a=1:size(loctmat,2)
            if mx>loctmat(1,a,tt) && mx<loctmat(3,a,tt) && my>loctmat(2,a,tt) && my<loctmat(4,a,tt) 
                changereport(tt,a)=1;
            else
                changereport(tt,a)=0;
            end
        end
        
        if sum(changereport(tt,:))==1 %click must be on an object 
            clickok=1;
        end
        
        
    end
    
    %gather accuracy and print report
    if change(tt) == find(changereport(tt,:));
        accuracy(tt)=1;
    else
        accuracy(tt)=0;
    end
     
    if (strcmp(prac,'N') || strcmp(prac,'n'))
    %header='Subject\tTrial\tCueLocations\tCueColorCodes\tChange\tClickX\tClickY\tReportedChange\tAccuracy\tRT\n
                fprintf(dataFile, '%s\t %d\t %s\t %s\t %d\t %d\t %d\t %d\t %d\t %f\n',...
                    subjectNumber, tt, num2str(loct(tt,:)), num2str(select(tt,:)), change(tt), clickloc(tt,1), clickloc(tt,2), find(changereport(tt,:)), accuracy(tt), clickTime(tt));
    end
                
    Screen('FillRect', expWin, backgroundCol);
    [vbl SOT]=Screen('Flip', expWin);
    HideCursor;

    
end

    Screen('FillRect', expWin, backgroundCol);
    DrawFormattedText(expWin, 'You finished this block!', 'center', 'center');
    [vbl SOT]=Screen('Flip', expWin);
    ShowCursor;
    WaitSecs(5);
    Screen('CloseAll');