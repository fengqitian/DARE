function [finalMask, S_fused, refinedMap, binaryMap] = fusionAndRefinement(S_dyn, S_sta, W_dyn, W_sta, params)
    
    
    S_dyn = mat2gray(S_dyn);
    S_sta = mat2gray(S_sta);
    

    % Dyn Weight Processing
    if W_dyn == 0 
        w_d = 0; 
    elseif W_dyn == 1
        w_d = 1; 
    else
        
        w_d = max(0.01, min(0.99, W_dyn)); 
    end
    
    % Sta Weight Processing
    if W_sta == 0
        w_s = 0;
    elseif W_sta == 1
        w_s = 1;
    else
        
        w_s = max(0.01, min(0.99, W_sta));
    end
    
    
    w_sum = w_d + w_s;
    if w_sum == 0, w_sum = 1; end 
    w_d = w_d / w_sum;
    w_s = w_s / w_sum;
    
    
    % Geometric Fusion
    S_geo = (S_dyn .^ w_d) .* (S_sta .^ w_s);
    S_geo = mat2gray(S_geo);
    
   
    se_post = strel('disk', 10);
    S_post = imtophat(S_geo, se_post);
    S_post = mat2gray(S_post);
    
    
    S_fused = S_post .^ 2;
    
    if isfield(params, 'k_factor')
        k = params.k_factor;
    else
        k = 3.0; 
    end
    
    S_fused = mat2gray(S_fused);
    
    
    stats_mean = mean(S_fused(:));
    stats_std = std(S_fused(:));
    
    adapt_thresh = stats_mean + k * stats_std;
    
    refinedMap = S_fused;
    binaryMap = S_fused > adapt_thresh;
    
    
    if isfield(params, 'minArea')
        minArea = params.minArea;
    else
        minArea = 3;
    end
    
    binaryMap = bwareaopen(binaryMap, minArea);
    
    se_dilate = strel('disk', 2);
    dilatedMap = imdilate(binaryMap, se_dilate);
    finalMask = imfill(dilatedMap, 'holes');
end