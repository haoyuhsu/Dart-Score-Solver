function [total_points]  = estimateDartScore(backgroundImage, dartImage, scale)

    % Set up vlfeat Toolbox
    % run('vlfeat-0.9.21/toolbox/vl_setup.m'); % path to vlfeat
    % warning off;

    %% 決定處理圖片的參數
    % scale = 0.5;      % 圖片縮放大小

    %% 使用者輸入圖片
%     fprintf('Select Background Image.\n');
    backgroundImage = imresize(im2double(backgroundImage), scale);

%     fprintf('Select Dart Image..\n');
    dartImage = imresize(im2double(dartImage), scale);

    %% 偵測飛鏢盤可能的區域並依此做圖片裁減
%     fprintf('Cropping DartBoard....\n');
    [backgroundImage, grayBackgroundImage, dartImage, grayDartImage] = cropDartBoard(backgroundImage, dartImage);
    [rows, columns, channels] = size(backgroundImage);

    %% 製作得分區域圖
%     fprintf('Creating Pointmap.....\n');

    % 找到每一個得分區域的mask
    masks = findRegionMasks(backgroundImage);

    % 找到中心點的質心座標
    center = regionprops(masks.innerBull, 'Centroid');

    % 找出每個分數區塊之間的分隔線
    [lines, region] = findScoreBorder(grayBackgroundImage .* masks.board);

    %% 對齊圖片，讓兩個圖片比較相近
%     fprintf('Aligning Images.....\n');
    [dartImage, grayDartImage] = alignImage(grayBackgroundImage, grayDartImage, backgroundImage, dartImage);

    %% 透過兩個圖片的差異找出前景物件的 Heatmap
%     fprintf('Detecting Foreground.....\n');
    dart = findForeground(dartImage, backgroundImage, masks);

    %% 透過對 Heatmap 做處理得到飛鏢尖頭落在盤上的位置
%     fprintf('Finding Dart Location.......\n');
    [xhit, yhit, num_dart] = findDartLocation_v2(dart, masks);

    %% 計算總得分
%     fprintf('Calculating Final Score.......\n');
    total_points = 0;
    total_mask = false(rows, columns);
    for i = 1:num_dart
        [points, hit_mask] = getScore(xhit(i), yhit(i), center, region, masks);
        total_mask = total_mask | hit_mask;
        total_points = total_points + points;
    end

       %% Display on Images
%     fprintf('Displaying Results........\n');
    gcf = figure(1);
    imshow(dartImage);
    hold on;

    boundary = bwboundaries(total_mask);
    for numRegion = 1:numel(boundary)
        plot(boundary{numRegion,1}(:,2), boundary{numRegion,1}(:,1), 'y', 'LineWidth', 2)
    end

    text(columns/2,rows,sprintf('Total Points: %d', total_points), ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'bottom', ...
        'FontSize', 28, ...
        'FontWeight', 'bold', ...
        'Color', 'b', ...
        'BackgroundColor', 'w');
    pause(2);
    hold off; 

    warning on;
    
%     fprintf('Program Complete!\n');
    
    % frame = getframe(gcf);
    % [displayImage, ~] = frame2im(frame);
    
end