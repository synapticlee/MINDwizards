clear

mfile_name = mfilename('fullpath');
[pathstr]  = fileparts(mfile_name);
cd(pathstr);

% Set duration (in minutes)
runtime = 5;

% Skip screen sync test in PTB
Screen('Preference', 'SkipSyncTests', 1);

% Set screen variables
whichScreen = 0; 
textColor = [255 255 255];
bgColor = [0 0 0];   
windowSize = []; % Full size screen 

% Open initial PTB screen window
[window] = Screen('OpenWindow', whichScreen, bgColor, windowSize);

Screen('TextSize', window, 30);
Screen('TextFont', window,'Helvetica', 1);

name = GetEchoString(window,'subject number:',400,400,textColor, bgColor);
date = datestr(now,'mm_dd_yyyy_HH_MM_SS');

gemInstructions(window,name)

%  Fixed Weights

% bw = [0.4 0.3 0.2 0.1 0] % linear
bw = [0.55 0.25 0.12 0.06 0.02] % ~1/X
% bw = [0.7 0.2 0.07 0.025 0.005] % ~1/X^2
colors = [255 255 1;1 255 255; 255 1 255; 255 1 1; 1 255 1]
rng('shuffle')
b_ind = randperm(5)
c_ind = randperm(5)
b_rand = bw(b_ind);          
colorVec = colors(c_ind,:)

B1 = b_rand(1);
B2 = b_rand(2);
B3 = b_rand(3);
B4 = b_rand(4);
B5 = b_rand(5);

numMinutes = runtime % run time in minutes

startTime = GetSecs;
totalTime = numMinutes*60;
runTime = 0;
score(1) = 0;
rng(10)
i = 1;

while runTime < totalTime
        
        Screen('FillRect', window,bgColor, windowSize);
        Screen('Flip', window ,[], 1);
        instruction_text = sprintf('The wizard is here to help with training right now. \n\n You can''t earn points while the wizard is helping.');
        DrawFormattedText(window, instruction_text , 400, 400, textColor);
        Screen('Flip', window ,[], 1);
        WaitSecs(0.3);
        key_press = 0;
        while ~key_press 
        [key_press] = KbCheck;
        [~,~,key_press] = GetMouse;
        end
        WaitSecs(0.3)
        Screen('FillRect', window,bgColor, windowSize);
        Screen('Flip', window ,[], 1);
    
        for t = 1:10
        fb = 1;
        [Value(i), Guess(i), T1(i),T2(i),T3(i),T4(i),T5(i),FB(i),points(i), rt(i)] = gemBox5(B1,B2,B3,B4,B5,colorVec,fb,window, score(i),t);
        b1(i) = B1; b2(i) = B2; b3(i) = B3; b4(i) = B4; b5(i) = B5;
        score(i+1) = score(i) + points(i);
        i = i + 1;
        end
        
        Screen('FillRect', window,bgColor, windowSize);
        Screen('Flip', window ,[], 1);
        instruction_text = sprintf('Now you have to guess the value on your own without the wizard.\n\n You will recieve points after ten guesses based upon your performance. ');
        DrawFormattedText(window, instruction_text , 400, 400, textColor);
        Screen('Flip', window ,[], 1);
        WaitSecs(1);
        key_press = 0;
        while ~key_press 
        [key_press] = KbCheck;
        [~,~,key_press] = GetMouse;
        end
        WaitSecs(0.3)
        Screen('FillRect', window,bgColor, windowSize);
        Screen('Flip', window ,[], 1);
        
        for t = 1:10
        fb = 0;
        [Value(i), Guess(i), T1(i),T2(i),T3(i),T4(i),T5(i),FB(i),points(i), rt(i)] = gemBox5(B1,B2,B3,B4,B5,colorVec,fb,window, score(i-t),t);
        b1(i) = B1; b2(i) = B2; b3(i) = B3; b4(i) = B4; b5(i) = B5;
        score(i+1) = score(i) + points(i);
        i = i + 1;
        end
        Screen('TextSize', window, 35);
        instruction_text = sprintf(' You scored a total of %d out of 200 possible points. ', round(score(i)-score(i-10)));
        DrawFormattedText(window, instruction_text , 400, 400, textColor);
        Screen('Flip', window ,[], 1);
        WaitSecs(3);
        key_press = 0;
        while ~key_press 
        [key_press] = KbCheck;
        [~,~,key_press] = GetMouse;
        end
        WaitSecs(0.3)
        Screen('FillRect', window,bgColor, windowSize);
        Screen('Flip', window ,[], 1);
        runTime = GetSecs-startTime;
end

        instruction_text = sprintf('The game is now over. Your total score is %d. Great job!\n\nThank you for participating in this experiment.',round(score(end)));
        DrawFormattedText(window, instruction_text , 400, 400, textColor);
        Screen('Flip', window ,[], 1);
        WaitSecs(10)
        
sca
score = score(2:end);
data_table = table(Value(:), Guess(:), score(:), points(:), T1(:), T2(:), T3(:), T4(:), T5(:), b1(:), b2(:), b3(:), b4(:),b5(:), FB(:),rt(:));
filename = [filepath 'sub' name '_' date '.csv'];
writetable(data_table,filename)

