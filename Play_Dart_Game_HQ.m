%% Setup
clear all;
% Set up vlfeat Toolbox
run('vlfeat-0.9.21/toolbox/vl_setup.m'); % path to vlfeat
warning off;

%% Games Settings
fprintf('Setting up games......\n');
init_points = 301;
num_players = 2;

playerPoints = zeros(num_players, 1);
for i = 1:num_players
   playerPoints(i) = init_points; 
end

img_scale = 0.5;
final_winner = 0;
endgame = 0;

%% Load Background Image
fprintf('Please take one background image in "./Published/Background/"\n');
% 讓使用者去拍照片
input('(press Enter if done taking image)\n');

fprintf('Capturing Background Image.....\n');
backgroundFolderPath = './Published/Background/';
backgroundImgPath = strcat(backgroundFolderPath, getlatestfile(backgroundFolderPath));
backgroundImage = imread(backgroundImgPath);

%% Calculate Points
fprintf('Starting Dart Game.....\n');

while final_winner == 0 && endgame == 0
    for i = 1:num_players
        
       showText = sprintf('Player %d throwing...(Press "0" to leave the game)   \n', i);
       response = input(showText);
       if response == 0
           endgame = 1;
           break;
       end
       
       fprintf('Please take one dart image in "./Published/Dart/"\n');
       % 輸入射完飛鏢的圖片
       input('(press Enter if done taking image)\n');
       dartFolderPath = './Published/Dart/';
       dartImgPath = strcat(dartFolderPath, getlatestfile(dartFolderPath));
       dartImage = imread(dartImgPath);
       % 計算得分
       points = estimateDartScore(backgroundImage, dartImage, img_scale);
       % 扣除玩家得分
       prev_points = playerPoints(i);
       cur_points = playerPoints(i) - points;
       
       if (cur_points < 0)
           playerPoints(i) = prev_points;
       else
           playerPoints(i) = cur_points;
       end
       fprintf('\n\nPlayer %d: %d\n\n', i, playerPoints(i));
    end
    % 如果扣光即結束遊戲
    iszero = find(playerPoints(i) == 0);
    if(isempty(iszero))
        final_winner = 0;  
    else
        frpintf('Player %d wins\n', iszeros(1));  % which one wins?
        final_winner = 1;
    end
end

%% Print Results
