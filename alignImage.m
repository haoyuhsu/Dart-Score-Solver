function [dartImage, grayDartImage] = alignImage(grayBackgroundImage, grayDartImage, backgroundImage, dartImage)
    % 使用 SIFT 去做特徵比對
    matchResult = matchSIFT(grayBackgroundImage, grayDartImage);
    
    % 圖片轉換的 Homography Matrix
    H = matchResult.model;
    
    % Homography Transformation
    [u,v] = meshgrid(1:size(backgroundImage,2), 1:size(backgroundImage,1));
    z_ = H(3,1) * u + H(3,2) * v + H(3,3) ;
    u_ = (H(1,1) * u + H(1,2) * v + H(1,3)) ./ z_ ;
    v_ = (H(2,1) * u + H(2,2) * v + H(2,3)) ./ z_ ;
    dartImage = vl_imwbackward(dartImage,u_,v_) ;
    grayDartImage = rgb2gray(dartImage);
end