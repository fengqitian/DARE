function [W_dyn, W_sta] = adaptiveWeighting(sceneDesc, params)
   
    Score_Dyn = params.dynamismFactor * sceneDesc.D;

   
    Score_Sta = (1 - sceneDesc.D) + params.complexityFactor * sceneDesc.C;
    

    
    Total_Score = Score_Dyn + Score_Sta;
    
    
    if Total_Score > 1e-6
        W_dyn = Score_Dyn / Total_Score;
        W_sta = Score_Sta / Total_Score;
    else
        
        W_dyn = 0.5;
        W_sta = 0.5;
    end
   
end