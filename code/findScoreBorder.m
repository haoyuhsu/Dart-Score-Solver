function [lines, region] = findScoreBorder(image)
    % 利用 Canny Edge Detector 去找出飛鏢盤的邊緣
    edgeImage = edge(image, 'canny', 0.25);
    
    imshow(edgeImage);

    % 利用 Hough Transform 得到前10名的 hough peaks，每一個都代表一條線(劃分分數的線)
    theta_res = 0.5;
    [H, theta, rho] = hough(edgeImage, 'Theta', -90:theta_res:90-theta_res);
    P = houghpeaks(H, 10, 'threshold', ceil(0.05*max(H(:))));


    % 把 90度角 當作北方，並對所有角度做排序處理
    angles = theta(P(:,2))-90;
    angles = sort(mod([angles angles+180]+360,360)); 

    % Plot out the lines
    lines = houghlines(image, theta, rho, P);

    values = [10, 15, 2, 17, ...
        3, 19, 7, 16, 8, 11, 14, 9, 12, 5, 20, 1, 18, 4, 13, 6];

    % 將每個分數及其對應的角度儲存起來
    region(1:20) = struct('minAngle','%f','maxAngle','%f','value','%d');
    for i = 1:numel(region)
        region(i).minAngle = angles(i);
        region(i).maxAngle = angles(mod(i,numel(angles))+1);
        region(i).value = values(i);
    end
end