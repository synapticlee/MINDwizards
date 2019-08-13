function [Value, Guess, T1,T2,T3,T4,T5,FB,points,rt]  = gemBox5(B1,B2,B3,B4,B5, colorVec,fb,window,score,t)

data = [];
whichScreen = 0; 
textColor = [255 255 255];
bgColor = [0 0 0];   
windowSize = []; % Full size screen 
wiz_image = imread('Wizard_bowie.jpg');
% flag_g = 0;
% flag_s = 0;
% flag_t = 0;


FB = fb;
T1 = round(rand,2)*100;
T2 = round(rand,2)*100;
T3 = round(rand,2)*100;
T4 = round(rand,2)*100;
T5 = round(rand,2)*100;

% Calculate and store(i) true value from weights and trait values
Value = B1*T1 + B2*T2 + B3*T3 + B4*T4 + B5*T5;
%% Show boxes  Dimensions: [Left ; Top ; Right; Bottom] 
Box1 = [140; 250; 200; 650]; % Box outline
vv1 = 650-T1*4;
Val1 = [140; vv1; 200; 650]; % Filled box to height of trait value (vv1)

Box2 = [340; 250; 400; 650];
vv2 = 650-T2*4;
Val2 = [340; vv2; 400; 650];

Box3 = [540; 250; 600; 650];
vv3 = 650-T3*4;
Val3 = [540; vv3; 600; 650];

Box4 = [740; 250; 800; 650];
vv4 = 650-T4*4;
Val4 = [740; vv4; 800; 650];

Box5 = [940; 250; 1000; 650];
vv5 = 650-T5*4;
Val5 = [940; vv5; 1000; 650];

GemBox = [450; 750; 700; 1000];
ScoreBox = [350; 100; 1150; 150];
TrainBox = [1550; 300; 1700; 450];
TestBox = [1550; 500; 1700; 650];

Box_Guess = [1300; 250; 1360; 650]; % Box dimensions for their click guess

Screen('FillRect', window,bgColor, windowSize);
Screen('Flip', window ,[], 1);

%% PTB functions to draw shapes (in background for time sync)
% Screen('FillRect', window ,[randi(255) randi(255) randi(255)] ,GemBox);

Screen('FrameRect', window ,[255 255 255] ,Box1,2);
Screen('FillRect', window ,colorVec(1,:) ,Val1);

Screen('FrameRect', window ,[255 255 255] ,Box2,2);
Screen('FillRect', window ,colorVec(2,:) ,Val2);

Screen('FrameRect', window ,[255 255 255] ,Box3,2);
Screen('FillRect', window ,colorVec(3,:) ,Val3);

Screen('FrameRect', window ,[255 255 255] ,Box4,2);
Screen('FillRect', window ,colorVec(4,:) ,Val4);

Screen('FrameRect', window ,[255 255 255] ,Box5,2);
Screen('FillRect', window ,colorVec(5,:) ,Val5);

Screen('FrameRect', window ,[255 255 255] ,Box_Guess, 2);
Screen('FrameRect', window ,[255 255 255] ,ScoreBox, 2);

if fb
ScoreVal = [350; 100; 350+score/4; 150];
Screen('FillRect', window ,[45 166 1] ,ScoreVal);
Screen('PutImage', window, wiz_image, [1450; 334; 1650; 600]); % put image on screen
else
end


% if flag_s
%     Screen('FrameRect', window ,[0 0 255] ,TestBox, 2);
%     Screen('FrameRect', window ,[255 255 255] ,TrainBox, 2);
%     flag_t = 0;
% elseif flag_t
%     Screen('FrameRect', window ,[0 0 255] ,TrainBox, 2);
%     Screen('FrameRect', window ,[255 255 255] ,TestBox, 2);
%     flag_s = 0;
% else 
%     Screen('FrameRect', window ,[255 255 255] ,TestBox, 2);
%     Screen('FrameRect', window ,[255 255 255] ,TrainBox, 2);
% 
% end




% DrawFormattedText(window, 'TEST' , 1550, 400, textColor);
% DrawFormattedText(window, 'TRAIN' ,1550, 600, textColor);
DrawFormattedText(window, sprintf('Gem %d out of 10',t) , 470, 850, textColor);
DrawFormattedText(window, 'Value bar' , 1260, 690, textColor);
DrawFormattedText(window, 'Gem''s magic traits' , 450, 690, textColor);

% "Flip" reveals on screen what PTB has drawn in the background
Screen('Flip', window ,[], 1);
stim_on = GetSecs;

y_pos = 0;
flag_g = 0;
while ~flag_g
% Return height of subject's mouse click on value bar and draw it

        [x,y_pos,b] = GetMouse
        
        if b(1)>0 && x > Box_Guess(1) && x < Box_Guess(3) && y_pos > Box_Guess(2) && y_pos < Box_Guess(4) 
            flag_g = 1;
            click_time = GetSecs;
%         elseif b(1)>0 && x > TrainBox(1) && x < TrainBox(3) && y_pos > TrainBox(2) && y_pos < TrainBox(4)
%             flag_s = 1;
%             Screen('FrameRect', window ,[0 0 255] ,TrainBox, 2);
%             Screen('Flip', window ,[], 1);
%         elseif b(1)>0 && x > TestBox(1) && x < TestBox(3) && y_pos > TestBox(2) && y_pos < TestBox(4)
%             flag_t = 1;
%             Screen('FrameRect', window ,[0 0 255] ,TestBox, 2);
%             Screen('Flip', window ,[], 1);
        else
        end
        
end
rt = click_time-stim_on;
GuessBox = [1300; y_pos; 1360; 650];
Guess = (650-y_pos)/4;
WaitSecs(0.4);


Screen('FillRect', window ,[180 180 150] ,GuessBox);
Screen('Flip', window ,[], 1);


if fb
% Draw true value on bar
w_pos = 650-(Value*4);
Wiz_val = [1290; w_pos; 1370; w_pos+10];
DrawFormattedText(window, 'Real\n value' , 1120, w_pos, [1 1 255]);
Screen('FillRect', window ,[1 1 255] ,Wiz_val);
Screen('Flip', window ,[], 1);
points = 0;
% Wait time to let subject see result
WaitSecs(2);
else
    
WaitSecs(0.5);
difff = Value-Guess;
score_weight = 0.05;
points = 20 - (score_weight * ((difff)^2));
min_score = 0;
points(points<min_score) = min_score;

% "FillRect" here is clearing the screen by drawing black over everything
Screen('FillRect', window,bgColor, windowSize);
Screen('Flip', window ,[], 1);

end
