function saliencyMap = dynamicFilteringPath_v2(frameBuffer, params)
    
    currentFrame = double(frameBuffer(:,:,end));
    [H, W] = size(currentFrame);

   
    se_tophat = strel('disk', 15); 
    currentFrame_clean = imtophat(currentFrame, se_tophat); 
    
  
    currentFrame_clean = medfilt2(currentFrame_clean, [3 3]);


    logFilter1 = fspecial('log', 13, 2);
    logFilter2 = fspecial('log', 21, 3);

    sMap1 = abs(imfilter(currentFrame_clean, logFilter1, 'replicate', 'conv'));
    sMap2 = abs(imfilter(currentFrame_clean, logFilter2, 'replicate', 'conv'));
    
    sMap = max(sMap1, sMap2);
    sMap = mat2gray(sMap); 


    n = params.temporalInterval; 
    if size(frameBuffer, 3) >= 2*n + 1
    frame_t = double(frameBuffer(:,:,end));
    frame_t_n = double(frameBuffer(:,:,end-n));
    

    [optimizer, metric] = imregconfig('monomodal');
    tform = imregtform(frame_t_n, frame_t, 'translation', optimizer, metric);

    ref_frame_warped = imwarp(frame_t_n, tform, 'OutputView', imref2d(size(frame_t)), 'FillValues', mean(frame_t(:)));
    

    tMap = abs(frame_t - ref_frame_warped);
        tMap = mat2gray(tMap);
    else
        tMap = zeros(H, W); 
    end


    saliencyMap = sMap .* (1 + params.alpha * tMap);
    saliencyMap = mat2gray(saliencyMap);
end