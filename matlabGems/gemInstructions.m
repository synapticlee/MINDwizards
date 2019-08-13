function gemInstructions(window,name)

HideCursor
whichScreen = 0; 
textColor = [255 255 255];
bgColor = [0 0 0];   
windowSize = []; % Full size screen 

[width, height]=Screen('WindowSize',0) 

Screen('FillRect', window,bgColor, windowSize)
Screen('Flip', window ,[], 1);

    Screen('TextSize', window, 60);
    wiz_image = imread('Wizard_bowie.jpg');
    Screen('PutImage', window, wiz_image); % put image on screen
    DrawFormattedText(window, 'I need your help', 600, 800, [255 255 255])
    Screen('Flip',window); % now visible on screen
    WaitSecs(3)

% Instructions
Screen('TextSize', window, 35);

Screen('FillRect', window,bgColor, windowSize);
Screen('Flip', window ,[], 1);
instruction_text = sprintf('You are a wizard''s apprentice, learning to buy magical gems for the wizard. The wizard is\n\ntraining you by letting you guess the value of different gems and then telling you the real value.\n\nThrough his feedback on your guesses you must learn how to quickly and accurately estimate\n\nthe value of new gems on your own when the wizard isn''t around to help. ');
DrawFormattedText(window, instruction_text , 200, 300, textColor);
Screen('Flip', window ,[], 1);
WaitSecs(0.5);
KbWait
Screen('FillRect', window,bgColor, windowSize);
Screen('Flip', window ,[], 1);

Screen('FillRect', window,bgColor, windowSize);
Screen('Flip', window ,[], 1);
instruction_text = sprintf(' The size of the bars on the left side represent the level of different kinds of magic that \n\neach gem possesses.  ');
DrawFormattedText(window, instruction_text , 200, 800, textColor);

Box1 = [140; 250; 200; 650]; % Box outline
Val1 = [140; 300; 200; 650]; % Filled box to height of trait value (vv1)

Box2 = [340; 250; 400; 650];
Val2 = [340; 485; 400; 650];

Box3 = [540; 250; 600; 650];
Val3 = [540; 600; 600; 650];

Box4 = [740; 250; 800; 650];
Val4 = [740; 500; 800; 650];

Box5 = [940; 250; 1000; 650];
Val5 = [940; 535; 1000; 650];

Screen('FrameRect', window ,[255 255 255] ,Box1,2);
Screen('FillRect', window ,[255 255 1] ,Val1);

Screen('FrameRect', window ,[255 255 255] ,Box2,2);
Screen('FillRect', window ,[255 1 255] ,Val2);

Screen('FrameRect', window ,[255 255 255] ,Box3,2);
Screen('FillRect', window ,[1 255 255] ,Val3);

Screen('FrameRect', window ,[255 255 255] ,Box4,2);
Screen('FillRect', window ,[255 1 1] ,Val4);

Screen('FrameRect', window ,[255 255 255] ,Box5,2);
Screen('FillRect', window ,[1 255 1] ,Val5);
Screen('Flip', window ,[], 1);
WaitSecs(0.5);
KbWait

instruction_text = sprintf(' The size of the bars on the left side represent the level of different kinds of magic that \n\neach gem possesses.  The size of these magic power bars goes into determining the gem''s value \n\nrepresented by the size of the bar on the right.');
DrawFormattedText(window, instruction_text , 200, 800, textColor);

Box_Guess = [1300; 250; 1360; 650];
Screen('FrameRect', window ,[255 255 255] ,Box_Guess, 2);
GuessBox = [1300; 450; 1360; 650];
Screen('Flip', window ,[], 1);
WaitSecs(0.5);
KbWait

Screen('FillRect', window,bgColor, [1; 680 ; width; height]);
instruction_text = sprintf( 'It''s important to note that the wizard does not necessarily care about all kinds of magic equally. \n\nSome bars may be more important others.' )
DrawFormattedText(window, instruction_text , 200, 800, textColor);
Screen('Flip', window ,[], 1);
WaitSecs(0.5);
KbWait

Screen('FillRect', window,bgColor, [1; 680 ; width; height]);
instruction_text = sprintf('You start by guessing a value by clicking on the value bar on the right with your mouse');
DrawFormattedText(window, instruction_text , 200, 800, textColor);
Screen('FillRect', window ,[180 180 150] ,GuessBox);
Screen('Flip', window ,[], 1);
WaitSecs(0.5);
KbWait

Screen('FillRect', window,bgColor, [1; 680 ; width; height]);
instruction_text = sprintf('The wizard will give you feedback so you can learn how to value gems. \n\nYou must use the wizard''s feedback to figure out which magic powers he cares about most and least.\n\nThen you can use what you''ve learned to help when he isn''t around.');
DrawFormattedText(window, instruction_text , 200, 800, textColor);
w_pos = 300;
Wiz_val = [1290; w_pos; 1370; w_pos+10];
DrawFormattedText(window, 'Real\n value' , 1120, w_pos, [1 1 255]);
Screen('FillRect', window ,[1 1 255] ,Wiz_val);
Screen('PutImage', window, wiz_image, [1450; 334; 1650; 600]); % put image on screen
Screen('Flip', window ,[], 1);
WaitSecs(0.5)
KbWait

Screen('FillRect', window,bgColor, [1; 680 ; width; height]);
Screen('FillRect', window,bgColor, [1450; 334; 1650; 600]);
ScoreBox = [350; 100; 1150; 150];
Screen('FrameRect', window ,[255 255 255] ,ScoreBox, 2);


instruction_text = sprintf('When the wizard isn''t around you can score points by guessing the \n\nvalue of gems. The closer to the real value, the more points you get.')
DrawFormattedText(window, instruction_text , 200, 800, textColor);
Screen('Flip', window ,[], 1);
WaitSecs(0.5)
KbWait

ScoreVal = [350; 100; 350+100; 150];
Screen('FillRect', window ,[45 166 1] ,ScoreVal);
Screen('Flip', window ,[], 1);

WaitSecs(0.5)
KbWait

ShowCursor